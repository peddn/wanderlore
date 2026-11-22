# Sketch: how two landforms meet at a biome border, as cross sections.
# A discussion aid in Python, not game code. Usage: python3 skizze_uebergaenge.py [out.png]
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont
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
W=1200; x=np.arange(W,dtype=float); B=W//2          # border in the middle
def terraces(x,z):   # returns base level and relief (the part that makes the form)
    b=55+48*fbm(x,z,420,11,3); step=11; q=np.floor(b/step); f=b/step-q
    return np.full_like(x,55.0), step*(q+smooth((f-0.82)/0.18))-55
def canyons(x,z):
    plateau=84+8*fbm(x,z,200,21); r=1-np.abs(fbm(x,z,360,25,3)); cut=smooth((r-0.80)/0.12)
    return np.full_like(x,84.0), (plateau-84)-72*cut
# pick a slice where a canyon runs right at the border
best=None
for z in np.arange(0,4000,7.0):
    zz=np.full_like(x,z); _,r2=canyons(x,zz)
    s=-(r2[B+10:B+70].min())-0.3*abs(r2[B+250:].min()+72)
    if best is None or s>best[0]: best=(s,z)
z=np.full_like(x,best[1])
b1,r1=terraces(x,z); b2,r2=canyons(x,z)
left=x<B
hard=np.where(left,b1+r1,b2+r2)
band=220.0; t=smooth((x-(B-band))/(2*band)); w1=1-t; w2=t
naive=w1*(b1+r1)+w2*(b2+r2)
fade=w1*b1+w2*b2+(w1**2.2)*r1*(w1>0)+(w2**2.2)*r2*(w2>0)
d=np.abs(x-B)
ridge=fade+42*np.exp(-(d/55)**2)*(0.75+0.25*np.sin(x/9))
river=fade-np.where(d<70,(fade-6)*smooth(1-d/70),0)
rows=[("1  Ohne Übergang: jedes Biom rechnet für sich",hard),
      ("2  Einfaches Mischen der Höhen über 440 Blöcke",naive),
      ("3  Grundhöhe mischen, Formen zum Rand hin ausblenden",fade),
      ("4  Wie 3, dazu ein Höhenzug auf der Grenze",ridge),
      ("5  Wie 3, dazu ein Fluss auf der Grenze",river)]
try: f=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',15); fs=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',13)
except Exception: f=fs=ImageFont.load_default()
PW=1000; H=150; out=Image.new('RGB',(PW+20,len(rows)*(H+34)+40),(25,28,32)); dr=ImageDraw.Draw(out)
sc=H/140.0
for i,(name,h) in enumerate(rows):
    oy=10+i*(H+34); dr.text((10,oy),name,fill=(255,255,255),font=f)
    py=oy+22; dr.rectangle((10,py,10+PW,py+H),fill=(40,44,50))
    wl=py+H-6*sc
    for k in range(PW):
        xx=int(k*W/PW); col=(110,170,90) if xx<B else (150,62,45)
        if i>=1:
            m=float(np.clip((xx-(B-60))/120,0,1)); col=tuple(int(a*(1-m)+b*m) for a,b in zip((110,170,90),(150,62,45)))
        top=py+H-h[xx]*sc
        if h[xx]<6: dr.line((10+k,wl,10+k,py+H),fill=(60,120,190))
        dr.line((10+k,max(top,py),10+k,py+H),fill=col)
    bx=10+PW//2; dr.line((bx,py,bx,py+H),fill=(255,255,255))
    if i>=1 and i<3:
        for e in (B-band,B+band): ex=10+e*PW/W; dr.line((ex,py,ex,py+H),fill=(120,120,120))
dr.text((10,10+len(rows)*(H+34)+2),"Links Terrassen, rechts Schluchten. Weiße Linie: Biomgrenze. Graue Linien: Rand der Mischzone. Bildbreite 1.200 Blöcke, Höhe bis 140.",fill=(220,220,220),font=fs)
out.save(sys.argv[1] if len(sys.argv)>1 else 'skizze_uebergaenge.png')
