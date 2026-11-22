# Sketch of the world layout of Wanderlore: zones, biome cells, islands.
# A discussion aid in Python, not game code. Usage: python3 skizze.py [out.png]
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont
SEED=7; R=20000; N=1000              # world shown: +-R nodes, N px
rng=np.random.default_rng(SEED)
def vnoise(x,y,scale,seed):
    # smooth value noise
    r=np.random.default_rng(seed); g=r.random((64,64))
    xs=x/scale; ys=y/scale; x0=np.floor(xs).astype(int); y0=np.floor(ys).astype(int)
    fx=xs-x0; fy=ys-y0; fx=fx*fx*(3-2*fx); fy=fy*fy*(3-2*fy)
    a=g[x0%64,y0%64]; b=g[(x0+1)%64,y0%64]; c=g[x0%64,(y0+1)%64]; d=g[(x0+1)%64,(y0+1)%64]
    return (a*(1-fx)+b*fx)*(1-fy)+(c*(1-fx)+d*fx)*fy
def fbm(x,y,scale,seed,oct=3):
    v=0;amp=1;tot=0
    for o in range(oct):
        v+=amp*vnoise(x,y,scale/(2**o),seed+o); tot+=amp; amp*=0.5
    return v/tot*2-1
def h2(i,j,k):  # hash -> [0,1)
    return ((np.sin(i*127.1+j*311.7+k*74.7)*43758.5453)%1.0)
WARP=170
Z1,Z2,Z3=4000,7500,11500
def cells(wx,wz,CELL,salt):
    ci=np.floor(wx/CELL).astype(int); cj=np.floor(wz/CELL).astype(int)
    best=np.full(wx.shape,1e18); bi=np.zeros(wx.shape,int); bj=np.zeros(wx.shape,int); bx=np.zeros(wx.shape); bz=np.zeros(wx.shape)
    for di in (-1,0,1):
        for dj in (-1,0,1):
            i=ci+di; j=cj+dj
            sx=(i+0.15+0.7*h2(i,j,salt+1))*CELL; sz=(j+0.15+0.7*h2(i,j,salt+2))*CELL
            d=(wx-sx)**2+(wz-sz)**2; m=d<best
            best=np.where(m,d,best); bi=np.where(m,i,bi); bj=np.where(m,j,bj); bx=np.where(m,sx,bx); bz=np.where(m,sz,bz)
    return bi,bj,bx,bz
xs=np.linspace(-R,R,N); px,pz=np.meshgrid(xs,xs[::-1])
wx=px+WARP*fbm(px,pz,600,11); wz=pz+WARP*fbm(px,pz,600,23)
# coarse cells (1000) decide the zone; only the sea and the islands use fine cells (800)
Ci,Cj,Cx,Cz=cells(wx,wz,1000,0)
Fi,Fj,Fx,Fz=cells(wx,wz,800,50)
dist=np.hypot(Cx,Cz)*(1+0.22*fbm(Cx,Cz,5500,31))
zone=np.where(dist<Z1,1,np.where(dist<Z2,2,np.where(dist<Z3,3,0)))
fd=np.hypot(Fx,Fz)*(1+0.22*fbm(Fx,Fz,5500,31))
isl=fbm(Fx,Fz,1700,47,2)
zone=np.where((zone==0)&(fd>Z3*1.22)&(fd<Z3*1.52)&(isl>0.30),4,zone)
fine=(zone==4)|(zone==0)
bi=np.where(fine,Fi,Ci); bj=np.where(fine,Fj,Cj); bx=np.where(fine,Fx,Cx); bz=np.where(fine,Fz,Cz)
cid=(bi*100003+bj)*2+fine
nb={1:3,2:5,3:4,4:3}
pal={1:[(126,200,80),(160,214,96),(232,170,190),(190,205,110)],
     2:[(40,120,60),(88,150,70),(196,170,90),(60,140,120),(150,120,70),(110,170,60)],
     3:[(150,60,40),(220,230,240),(110,80,110),(90,90,95),(170,100,50)],
     4:[(120,220,220),(230,120,200),(240,210,120)]}
img=np.zeros((N,N,3),np.uint8); img[:]=(38,84,140)
rs=np.random.default_rng(SEED)
for z in (1,2,3,4):
    m=zone==z
    ids,first=np.unique(cid[m],return_index=True)
    cx=bx[m][first]; cz=bz[m][first]; ang=np.arctan2(cz,cx)
    n=len(ids)
    if z==1:
        order=np.argsort(ang); biome=np.empty(n,int); biome[order]=(np.arange(n)+rs.integers(9))%nb[z]   # dealt in turn
    else:
        key=(ang+0.9*z+rs.normal(0,0.33,n))%(2*np.pi)     # direction with some mixing
        order=np.argsort(key); biome=np.empty(n,int); biome[order]=(np.arange(n)*nb[z])//n   # equal shares
    look=dict(zip(ids.tolist(),biome.tolist()))
    k=np.vectorize(look.get)(cid[m])
    sub=img[m]
    for b in range(nb[z]): sub[k==b]=pal[z][b]
    img[m]=sub
    print('zone',z,'cells',n,'per biome',np.bincount(biome,minlength=nb[z]).tolist())
# cell borders
edge=np.zeros((N,N),bool)
edge[:,1:]|=cid[:,1:]!=cid[:,:-1]; edge[1:,:]|=cid[1:,:]!=cid[:-1,:]
img[edge&(zone>0)]=(img[edge&(zone>0)]*0.6).astype(np.uint8)
zed=np.zeros((N,N),bool); zed[:,1:]|=zone[:,1:]!=zone[:,:-1]; zed[1:,:]|=zone[1:,:]!=zone[:-1,:]
for d in (0,1):
    zz=np.roll(zed,d,0)|np.roll(zed,d,1); img[zz]=(20,20,20)
im=Image.fromarray(img); d=ImageDraw.Draw(im)
try: f=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',17); fs=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',14)
except Exception: f=fs=ImageFont.load_default()
c=N//2; d.ellipse((c-6,c-6,c+6,c+6),fill=(255,255,255),outline=(0,0,0))
def lab(x,z,t,font=f):
    X=c+x/R*c; Y=c-z/R*c; w=d.textlength(t,font=font)
    d.rectangle((X-w/2-4,Y-2,X+w/2+4,Y+20),fill=(0,0,0)); d.text((X-w/2,Y),t,fill=(255,255,255),font=font)
lab(0,1300,"Start"); lab(0,-2300,"Zone 1"); lab(0,-5600,"Zone 2"); lab(0,-9300,"Zone 3"); lab(0,-18000,"Meer und Inseln")
# scale bar 1000 nodes
L=2000/R*c; d.rectangle((30,N-40,30+L,N-34),fill=(255,255,255)); d.text((30,N-30),"2000 Blöcke (ca. 8 Minuten zu Fuß)",fill=(255,255,255),font=fs)
im.save(sys.argv[1] if len(sys.argv) > 1 else 'skizze.png')
