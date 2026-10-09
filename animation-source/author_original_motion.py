"""Original procedural locomotion, authored from rig rest anatomy only.
Run with Blender --background --python author_original_motion.py -- BASELINE OUTPUT
No existing animation samples are read. Strips animation-only accessors/bufferViews
and physically rebuilds the binary before adding newly computed rotation curves.
Coordinates: glTF Y up; forward inferred from Head -> headfront anatomy.
"""
import sys,json,struct,copy,math,hashlib,pathlib,shutil
from mathutils import Matrix,Vector,Quaternion
ROOT=pathlib.Path(__file__).resolve().parent
args=sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else []
DEFAULT_PROJECT=ROOT.parent/'starter' if (ROOT.parent/'starter/project.godot').exists() else ROOT/'candidate/starter'
SOURCE=pathlib.Path(args[0]) if args else DEFAULT_PROJECT
OUT=pathlib.Path(args[1]) if len(args)>1 else DEFAULT_PROJECT
sha=lambda b:hashlib.sha256(b).hexdigest()
def load_glb(p):
 b=p.read_bytes(); n=struct.unpack_from('<I',b,12)[0];return json.loads(b[20:20+n]),b[28+n:]
def save_glb(p,d,b):
 d['buffers']=[{'byteLength':len(b)}];j=json.dumps(d,separators=(',',':')).encode();j+=b' '*((-len(j))%4);b+=b'\0'*((-len(b))%4)
 p.write_bytes(struct.pack('<III',0x46546c67,2,28+len(j)+len(b))+struct.pack('<II',len(j),0x4e4f534a)+j+struct.pack('<II',len(b),0x004e4942)+b)
def strip(d,b):
 d=copy.deepcopy(d);d.pop('animations',None)
 used=set()
 for m in d['meshes']:
  for p in m['primitives']:
   used.update(p['attributes'].values())
   if 'indices'in p:used.add(p['indices'])
   for t in p.get('targets',[]):used.update(t.values())
 used.update(s['inverseBindMatrices'] for s in d.get('skins',[]) if 'inverseBindMatrices'in s)
 amap={a:i for i,a in enumerate(sorted(used))};acc=[d['accessors'][a] for a in sorted(used)]
 views={a['bufferView'] for a in acc};views.update(im['bufferView'] for im in d.get('images',[]) if 'bufferView'in im)
 vmap={v:i for i,v in enumerate(sorted(views))};new=bytearray();vs=[]
 for v in sorted(views):
  old=d['bufferViews'][v];new.extend(b'\0'*((-len(new))%4));nv=copy.deepcopy(old);nv['byteOffset']=len(new);nv['buffer']=0;vs.append(nv);o=old.get('byteOffset',0);new.extend(b[o:o+old['byteLength']])
 for a in acc:a['bufferView']=vmap[a['bufferView']]
 for m in d['meshes']:
  for p in m['primitives']:
   p['attributes']={k:amap[v] for k,v in p['attributes'].items()}
   if 'indices'in p:p['indices']=amap[p['indices']]
   for t in p.get('targets',[]):
    for k in t:t[k]=amap[t[k]]
 for s in d.get('skins',[]):
  if 'inverseBindMatrices'in s:s['inverseBindMatrices']=amap[s['inverseBindMatrices']]
 for im in d.get('images',[]):
  if 'bufferView'in im:im['bufferView']=vmap[im['bufferView']]
 d['accessors']=acc;d['bufferViews']=vs;d['asset']['generator']='Original rest-anatomy procedural locomotion';return d,new

def author(who):
 d,old=load_glb(SOURCE/'assets'/f'{who}.glb');d,b=strip(d,old);nodes=d['nodes']; names={n.get('name'):i for i,n in enumerate(nodes)}
 parent={c:i for i,n in enumerate(nodes) for c in n.get('children',[])};rest={};local={}
 def world(i):
  if i in rest:return rest[i]
  n=nodes[i];q=n.get('rotation',[0,0,0,1]);m=Matrix.LocRotScale(Vector(n.get('translation',[0,0,0])),Quaternion((q[3],*q[:3])),Vector(n.get('scale',[1,1,1])));local[i]=m
  rest[i]=world(parent[i])@m if i in parent else m;return rest[i]
 for i in range(len(nodes)):world(i)
 pos=lambda name:rest[names[name]].translation.copy()
 up=Vector((0,1,0));fwd=pos('headfront')-pos('Head');fwd.y=0;fwd.normalize();right=up.cross(fwd).normalized()
 assert fwd.z>.95,'Anatomical forward disagrees with existing controller +Z'
 cal=json.loads((SOURCE/'calibration.json').read_text())[who];scale=cal['scale'];hips=names['Hips'];joints=d['skins'][0]['joints']
 report={'anatomical_forward':list(fwd),'clips':{},'source_sha256':sha((SOURCE/'assets'/f'{who}.glb').read_bytes())}
 def accessor(values,kind):
  width={'SCALAR':1,'VEC3':3,'VEC4':4}[kind];flat=[x for v in values for x in (v if width>1 else [v])];raw=struct.pack('<'+'f'*len(flat),*flat);b.extend(b'\0'*((-len(b))%4));vi=len(d['bufferViews']);d['bufferViews'].append({'buffer':0,'byteOffset':len(b),'byteLength':len(raw)});b.extend(raw);a={'bufferView':vi,'componentType':5126,'count':len(values),'type':kind}
  if kind=='SCALAR':a.update(min=[min(values)],max=[max(values)])
  d['accessors'].append(a);return len(d['accessors'])-1
 d['animations']=[]
 for clip,duration,speed,crouch,lift in [('Idle',2.4,0,.045,0),('Walk',.72,1.8,.105,.13),('Run',.42,3.8,.195,.21)]:
  count=round(duration*60);times=[duration*k/count for k in range(count+1)];rot={i:[] for i in joints};trans=[];landmarks=[];unreachable=0
  for k,t in enumerate(times):
   phase=(k/count)%1;desired={i:rest[i].to_quaternion() for i in joints}
   # Gentle pelvis sway and vertical breathing; no horizontal root translation.
   bob=.004*math.sin(phase*math.tau) if speed==0 else .009*(1-math.cos(phase*math.tau*2))
   hp=pos('Hips')+up*(-crouch+bob-cal['offsets'][clip]/scale)
   # Offsets are presentation-only; contacts receive exactly the same compensation.
   floor_adjust=-cal['offsets'][clip]/scale
   current={};legs_info={}
   def evalnode(i):
    if i in current:return current[i]
    if i==hips:p=hp
    elif i in parent:p=evalnode(parent[i]).translation+evalnode(parent[i]).to_quaternion()@(Vector(nodes[i].get('translation',[0,0,0]))*rest[parent[i]].to_scale().x)
    else:p=rest[i].translation
    q=desired.get(i,rest[i].to_quaternion());current[i]=Matrix.LocRotScale(p,q,rest[i].to_scale());return current[i]
   def aim(name,child,target):
    i=names[name];origin=evalnode(i).translation;v=pos(child)-pos(name);delta=v.rotation_difference(target-origin);desired[i]=delta@rest[i].to_quaternion();current.clear()
   for side,offset in [('Left',0),('Right',.5)]:
    q=(phase+offset)%1;ankle=pos(side+'Foot')+up*floor_adjust
    # Feet are brought under the hip, retaining native sole pitch/rotation.
    ankle.x=pos(side+'UpLeg').x+(0.035 if side=='Left' else -.035)
    if speed:
     stride=speed/scale*duration*.5
     if q<.5:z=stride*(.5-2*q);height=0
     else:
      s=(q-.5)*2;z=stride*(-.5+(3*s*s-2*s*s*s)-(2*s*s*s-3*s*s+s));height=lift*math.sin(math.pi*s)**2
     ankle+=fwd*z+up*height
    origin=evalnode(names[side+'UpLeg']).translation
    a=(pos(side+'Leg')-pos(side+'UpLeg')).length;c=(pos(side+'Foot')-pos(side+'Leg')).length;v=ankle-origin;dist=v.length
    if dist>a+c-1e-5:unreachable+=1;v*=((a+c-1e-5)/dist);dist=v.length;ankle=origin+v
    direction=v.normalized();along=(a*a-c*c+dist*dist)/(2*dist);h=math.sqrt(max(0,a*a-along*along));pole=(fwd-direction*fwd.dot(direction)).normalized();knee=origin+direction*along+pole*h
    aim(side+'UpLeg',side+'Leg',knee);aim(side+'Leg',side+'Foot',ankle)
    desired[names[side+'Foot']]=rest[names[side+'Foot']].to_quaternion();current.clear()
    legs_info[side]={'ankle':list(evalnode(names[side+'Foot']).translation),'knee':list(knee),'stance':speed==0 or q<.5}
    # Counter-swing: arm moves backward while same-side foot reaches forward.
    swing=0 if speed==0 else -(.32 if clip=='Walk' else .55)*math.cos(q*math.tau)
    arm=side+'Arm';elbow=side+'ForeArm';hand=side+'Hand';sign=1 if side=='Left' else -1
    origin=evalnode(names[arm]).translation;length=(pos(elbow)-pos(arm)).length
    direction=(right*(sign*.18)-up*math.cos(swing)+fwd*math.sin(swing)).normalized();target=origin+direction*length;aim(arm,elbow,target)
    origin=evalnode(names[elbow]).translation;length=(pos(hand)-pos(elbow)).length
    bend=.22 if clip!='Run' else .75
    direction=(right*(sign*.13)-up*math.cos(swing+bend)+fwd*math.sin(swing+bend)).normalized();aim(elbow,hand,origin+direction*length)
    # Hand retains its rest relation to the newly posed forearm.
    desired[names[hand]]=desired[names[elbow]]@rest[names[elbow]].to_quaternion().inverted()@rest[names[hand]].to_quaternion();current.clear()
   for i in joints:
    p=parent.get(i);q=evalnode(p).to_quaternion().inverted()@desired[i] if p is not None else desired[i];q.normalize();arr=[q.x,q.y,q.z,q.w]
    if rot[i] and sum(x*y for x,y in zip(arr,rot[i][-1]))<0:arr=[-x for x in arr]
    rot[i].append(arr)
   pmat=rest[parent[hips]];trans.append(list(pmat.inverted()@hp));landmarks.append(legs_info)
  # Exact endpoint copy is authored seam closure, not old-motion sampling.
  for i in rot:rot[i][-1]=rot[i][0][:]
  trans[-1]=trans[0][:]
  inp=accessor(times,'SCALAR');anim={'name':clip,'channels':[],'samplers':[]}
  for i,values in rot.items():
   out=accessor(values,'VEC4');n=len(anim['samplers']);anim['samplers'].append({'input':inp,'output':out,'interpolation':'LINEAR'});anim['channels'].append({'sampler':n,'target':{'node':i,'path':'rotation'}})
  out=accessor(trans,'VEC3');n=len(anim['samplers']);anim['samplers'].append({'input':inp,'output':out,'interpolation':'LINEAR'});anim['channels'].append({'sampler':n,'target':{'node':hips,'path':'translation'}});d['animations'].append(anim)
  report['clips'][clip]={'duration':duration,'samples':len(times),'unreachable_samples':unreachable,'speed_world':speed,'landmarks':landmarks}
 dest=OUT/'assets'/f'{who}.glb';dest.parent.mkdir(parents=True,exist_ok=True);save_glb(dest,d,bytes(b));report['output_sha256']=sha(dest.read_bytes());return report
if __name__=='__main__':
 reports={who:author(who) for who in ['tek','doge']};(ROOT/'motion_numeric.json').write_text(json.dumps(reports,indent=2));print(json.dumps({w:{c:{k:v for k,v in r.items() if k!='landmarks'} for c,r in x['clips'].items()} for w,x in reports.items()},indent=2))
