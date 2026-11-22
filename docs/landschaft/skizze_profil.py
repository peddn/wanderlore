# Sketch: vertical profile of the Wanderlore world from the start to the sea.
# A discussion aid in Python, not game code. Usage: python3 skizze_profil.py [out.png]
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont
W,H=1100,640; X0,X1=0,14500; YT,YB=160,-520
def px(x): return 60+(x-X0)/(X1-X0)*(W-80)
def py(y): return 40+(YT-y)/(YT-YB)*(H-90)
im=Image.new('RGB',(W,H),(25,28,32)); d=ImageDraw.Draw(im)
try: f=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',14); fs=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',12)
except Exception: f=fs=ImageFont.load_default()
Z=[(0,4000,"Zone 1"),(4000,7500,"Zone 2"),(7500,11500,"Zone 3"),(11500,14500,"Meer")]
rng=np.random.default_rng(3)
xs=np.linspace(X0,X1,W-80)
def surf(x):
    h=18+10*np.sin(x/420)+6*np.sin(x/130+1)
    h=np.where((x>4000)&(x<7500),40+22*np.sign(np.sin(x/500))*0.5+10*np.sin(x/900),h)
    h=np.where((x>=7500)&(x<11500),70+25*np.sin(x/700)-50*np.exp(-((x-9300)/160)**2),h)
    h=h-22*np.exp(-((x-4000)/90)**2)                     # river between zone 1 and 2
    h=h+45*np.exp(-((x-7500)/170)**2)                    # ridge between zone 2 and 3
    h=np.where(x>=11500,np.maximum(-30,70-(x-11500)*0.5),h)
    return h
s=surf(xs)
sky=(60,90,130)
d.rectangle((px(X0),py(YT),px(X1),py(0)),fill=sky)
rock=(88,86,84)
for k,x in enumerate(xs):
    X=px(x); top=s[k]
    d.line((X,py(top),X,py(YB)),fill=rock)
    if x>=11500 and top<0: d.line((X,py(0),X,py(top)),fill=(50,105,170))
    if x<11500:
        d.line((X,py(top),X,py(top-30)),fill=(150,120,80))          # tier 1 everywhere on land
        if x>=4000: d.line((X,py(top-30),X,py(top-120)),fill=(150,150,165))   # tier 2
        if x>=7500: d.line((X,py(top-100),X,py(top-250)),fill=(120,70,150))   # tier 3 (overlaps tier 2 a little)
        d.line((X,py(top),X,py(top-3)),fill=(110,170,90) if x<4000 else ((70,130,80) if x<7500 else (150,62,45)))
# hollow world
for k,x in enumerate(xs):
    X=px(x); roof=-360+12*np.sin(x/600)+6*np.sin(x/170); floor=-455+10*np.sin(x/800+2)
    d.line((X,py(roof),X,py(floor)),fill=(40,60,70))
    d.line((X,py(floor),X,py(floor-4)),fill=(90,170,150))
    if int(x/700)%4==1: d.line((X,py(floor+1),X,py(floor+10)),fill=(60,120,170))
# caves and dungeons
for cx,cy,rx,ry in [(1500,-5,330,10),(3000,-18,260,9),(5200,-25,420,16),(6400,-70,380,18),(8600,-60,460,20),(9900,-150,520,24),(10600,-40,300,14),(5900,-180,300,60),(9200,-270,340,70)]:
    d.ellipse((px(cx-rx),py(cy+ry),px(cx+rx),py(cy-ry)),fill=(30,32,36))
for cx,cy in [(2300,-25),(6900,-95),(10300,-200)]:
    d.rectangle((px(cx-170),py(cy+9),px(cx+170),py(cy-9)),fill=(200,170,90),outline=(60,50,20))
# zone lines and labels
for a,b,n in Z:
    d.line((px(a),py(YT),px(a),py(YB)),fill=(230,230,230))
    d.text((px((a+b)/2)-25,py(YT)+4,),n,fill=(255,255,255),font=f)
def tag(x,y,t,col=(255,255,255)):
    w=d.textlength(t,font=fs); d.rectangle((px(x)-3,py(y)-2,px(x)+w+3,py(y)+15),fill=(0,0,0)); d.text((px(x),py(y)),t,fill=col,font=fs)
tag(300,-2,"Kohle, Kupfer, Zinn",(230,200,150)); tag(4300,-45,"Eisen, Gold",(210,210,230)); tag(7900,-150,"Mese, Diamant",(210,160,240))
tag(300,-120,"taubes Gestein"); tag(4300,-240,"taubes Gestein"); tag(5200,-395,"Zwischenschicht: eine durchgehende Unterwelt",(150,230,210))
tag(5450,-175,"Schacht"); tag(11800,-60,"Meer",(180,210,255)); tag(2500,-48,"Dungeon",(240,210,130))
for y in (0,-100,-200,-300,-400,-500):
    d.line((px(X0)-5,py(y),px(X0),py(y)),fill=(230,230,230)); d.text((8,py(y)-7),"%d"%y,fill=(230,230,230),font=fs)
d.text((60,H-42),"Schnitt vom Startpunkt (links) bis ins Meer. Die Höhe ist etwa zwölffach überhöht, Zahlen in Blöcken relativ zum Meeresspiegel.",fill=(220,220,220),font=fs)
d.text((60,H-24),"Braun, grau, violett: Erzschichten. Dunkle Flecken: Höhlen. Gelb: Dungeons. Alle Tiefen sind Startwerte.",fill=(220,220,220),font=fs)
im.save(sys.argv[1] if len(sys.argv)>1 else 'skizze_profil.png')
