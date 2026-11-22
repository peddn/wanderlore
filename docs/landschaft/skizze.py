# Sketch of four landform formulas of Wanderlore as shaded relief.
# A discussion aid in Python, not game code. Usage: python3 skizze.py [out.png]
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont
S=800; P=400                      # each panel: S x S nodes, P px
def vnoise(x,y,scale,seed):
    r=np.random.default_rng(seed); g=r.random((128,128))
    xs=x/scale; ys=y/scale; x0=np.floor(xs).astype(int); y0=np.floor(ys).astype(int)
    fx=xs-x0; fy=ys-y0; fx=fx*fx*(3-2*fx); fy=fy*fy*(3-2*fy)
    a=g[x0%128,y0%128]; b=g[(x0+1)%128,y0%128]; c=g[x0%128,(y0+1)%128]; d=g[(x0+1)%128,(y0+1)%128]
    return (a*(1-fx)+b*fx)*(1-fy)+(c*(1-fx)+d*fx)*fy
def fbm(x,y,scale,seed,oct=4):
    v=0;amp=1;tot=0
    for o in range(oct):
        v+=amp*vnoise(x,y,scale/(2**o),seed+7*o); tot+=amp; amp*=0.5
    return v/tot*2-1
def smooth(t): t=np.clip(t,0,1); return t*t*(3-2*t)
xs=np.linspace(0,S,P); x,z=np.meshgrid(xs,xs)
def hills():      # gentle hills with stream valleys
    h=24+22*fbm(x,z,260,1)
    v=np.abs(fbm(x,z,330,5,2)); return h-14*(1-smooth(v/0.12)), 6
def terraces():   # stepped terraces with basins
    b=55+48*fbm(x,z,420,11,3); step=11
    q=np.floor(b/step); f=b/step-q
    return step*(q+smooth((f-0.82)/0.18))+0.6*fbm(x,z,40,13,2), 2
def canyons():    # plateau cut by canyons
    plateau=84+8*fbm(x,z,200,21)
    r=1-np.abs(fbm(x,z,360,25,3)); cut=smooth((r-0.80)/0.12)
    return plateau-72*cut+4*cut*fbm(x,z,50,27,2), 6
def spires():     # flat ground with needles
    base=10+4*fbm(x,z,220,31)
    p=fbm(x,z,55,35,2); return base+118*np.clip((p-0.30)/0.5,0,1)**1.5, 2
panels=[("Hügel mit Bachtälern (Blossom Downs)",hills,[(60,120,60),(120,190,90),(190,220,140)]),
        ("Terrassen (Bamboo Terraces)",terraces,[(40,110,90),(110,170,90),(210,220,150)]),
        ("Schluchten (Ember Scar)",canyons,[(230,120,30),(140,60,40),(200,120,90)]),
        ("Felsnadeln (Frost Spires)",spires,[(150,190,220),(200,225,240),(250,250,255)])]
try: f=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',15); fs=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',13)
except Exception: f=fs=ImageFont.load_default()
out=Image.new('RGB',(2*P+30,2*(P+170)+10),(25,28,32)); d=ImageDraw.Draw(out)
for i,(name,fn,cols) in enumerate(panels):
    h,water=fn(); lo,hi=h.min(),h.max()
    t=(h-lo)/(hi-lo+1e-9); c=np.array(cols,float)
    rgb=np.where(t[...,None]<0.5,c[0]+(c[1]-c[0])*(t[...,None]*2),c[1]+(c[2]-c[1])*((t[...,None]-0.5)*2))
    gy,gx=np.gradient(h,S/P); sh=np.clip(0.75+0.5*(-gx-gy)/np.sqrt(1+gx*gx+gy*gy)*1.2,0.25,1.35)
    rgb=np.clip(rgb*sh[...,None],0,255)
    if name.startswith("Hügel") or name.startswith("Terr"): rgb[h<(0 if name.startswith('Terr') else water+4)]=(60,120,190)
    ox=10+(i%2)*(P+10); oy=10+(i//2)*(P+170)
    out.paste(Image.fromarray(rgb.astype(np.uint8)),(ox,oy+24))
    d.text((ox,oy+2),name,fill=(255,255,255),font=f)
    # cross section along the middle row
    row=h[P//2]; py=oy+24+P+8; H=120
    d.rectangle((ox,py,ox+P,py+H),fill=(40,44,50))
    sc=H/135.0
    pts=[(ox+k,py+H-(row[k]+8)*sc) for k in range(P)]
    d.polygon(pts+[(ox+P,py+H),(ox,py+H)],fill=tuple(cols[1]))
    d.line((ox,oy+24+P//2,ox+P,oy+24+P//2),fill=(255,255,255),width=1)
    d.text((ox+4,py+2),"Schnitt entlang der weißen Linie, Höhe %d bis %d Blöcke"%(row.min(),row.max()),fill=(230,230,230),font=fs)
out.save(sys.argv[1] if len(sys.argv) > 1 else 'skizze.png')
