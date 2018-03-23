pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
// scale up sprites 
// 2x, 3x or 4x with 
// transparency using 
// extend hqx
//
// @casualeffects
// http://casual-effects.com

// num sprites
local n = 12

function _draw()
 cls(0)
 for i = 1,n do
  spr(i, ((i-1) % 4) * 32, flr((i-1)/4) * 8)
  scl_spr(i, ((i-1) % 4) * 32, flr((i-1)/4) * 32 + 24)  
 end
end




-->8
function get(a,x,y,w)
 // return transparent for out of bounds
 if x<0 or x>=w or y<0 or y>=w then return 0
 else return a[x+y*w+1] end
end

// @casualeffects variant of exp/scale2x algorithm
// https://en.wikipedia.org/wiki/pixel-art_scaling_algorithms#epx/scale2%c3%97/advmame2%c3%97
function scl2x(src)
 local w=sqrt(#src)
 local dst={}
 // rows are 2*w wide
 dst[w*w*4] = 0
 
 for y=0,w-1 do for x=0,w-1 do
   local a, c, p, b, d =
    get(src,x,y-1,w),
    get(src,x-1,y,w),
    get(src,x,y,w),
    get(src,x+1,y,w),
    get(src,x,y+1,w)
   
   local e,f,g,h = p,p,p,p
   if (c==a and c!=d and a!=b) e=a
   if (a==b and a!=c and b!=d) f=b 
   if (d==c and d!=b and c!=a) g=c 
   if (b==d and b!=a and d!=c) h=d

   // write four pixels
   local i = x*2+y*4*w+1
   dst[i],dst[i+1]=e,f
   i+=2*w
   dst[i],dst[i+1]=g,h
 end end

 if true then
 // @casualeffects improvements
 for y=0,w-1 do for x=0,w-1 do
   local a,b,c, d,e,f, g,h,i=
    get(src,x-1,y-1,w),
    get(src,x,y-1,w),
    get(src,x+1,y-1,w),

    get(src,x-1,y,w),
    get(src,x,y,w),
    get(src,x+1,y,w),

    get(src,x-1,y+1,w),
    get(src,x,y+1,w),
    get(src,x+1,y+1,w)

    
    // maintain square corners
    local j=1+x*2+y*4*w
    if (g!=e and d!=e and a!=e and b!=e and c!=e) dst[j]=e
    
    j+=1
    if (a!=e and b!=e and c!=e and f!=e and i!=e) dst[j]=e
    
    j+=2*w
    if (g!=e and h!=e and i!=e and f!=e and c!=e) dst[j]=e
    
    j-=1
    if (a!=e and d!=e and g!=e and h!=e and i!=e) dst[j]=e

    // smooth diagonals into transparent
    // (also rounds curves while maintaining 2:1 slopes)
    j=1+x*2+y*4*w
    if (c!=0 and a==0 and b==0 and d==0 and g!=0) dst[j]=e

    j+=1
    if (a!=0 and b==0 and c==0 and f==0 and i!=0) dst[j]=e

    j+=2*w
    if (g!=0 and h==0 and i==0 and f==0 and c!=0) dst[j]=e

    j-=1
    if (a!=0 and d==0 and g==0 and h==0 and i!=0) dst[j]=e

 end end
 end
 
 return dst
end

function scl4x(src)
 return scl2x(scl2x(src))
end

// scale3x algorithm
// https://en.wikipedia.org/wiki/pixel-art_scaling_algorithms#scale3%c3%97/advmame3%c3%97_and_scalefx
function scl3x(src)
 local w=sqrt(#src)
 local dst={}
 // rows are 3*w wide
 dst[w*w*9] = 0
 
 for y=0,w-1 do for x=0,w-1 do
   local a,b,c, d,e,f, g,h,i=
    get(src,x-1,y-1,w),
    get(src,x,y-1,w),
    get(src,x+1,y-1,w),

    get(src,x-1,y,w),
    get(src,x,y,w),
    get(src,x+1,y,w),

    get(src,x-1,y+1,w),
    get(src,x,y+1,w),
    get(src,x+1,y+1,w)
   
    local d1,d2,d3, d4,d5,d6, d7,d8,d9=e,e,e, e,e,e, e,e,e

    if (d==b and d!=h and b!=f) d1=d
    if ((d==b and d!=h and b!=f and e!=c) or (b==f and b!=d and f!=h and e!=a)) d2=b
    if (b==f and b!=d and f!=h) d3=f
    if ((h==d and h!=f and d!=b and e!=a) or (d==b and d!=h and b!=f and e!=g)) d4=d
    if ((b==f and b!=d and f!=h and e!=i) or (f==h and f!=b and h!=d and e!=c)) d6=f
    if (h==d and h!=f and d!=b) d7=d
    if ((f==h and f!=b and h!=d and e!=g) or (h==d and h!=f and d!=b and e!=i)) d8=h
    if (f==h and f!=b and h!=d) d9=f

    // write 9 pixels
    local i = x*3+y*9*w+1
    dst[i],dst[i+1],dst[i+2]=d1,d2,d3
    i+=3*w
    dst[i],dst[i+1],dst[i+2]=d4,d5,d6
    i+=3*w
    dst[i],dst[i+1],dst[i+2]=d7,d8,d9
 end end
 
 return dst
end

function scl_spr(i, x, y)
 local tmp = {}
 tmp[8*8] = 0

 // copy the source to temp memory
 for v=0,7 do for u=0,7 do
   tmp[1+u+v*8]=sget((i%16)*8+u,flr(i/16)*8+v)
 end end
 
 // enlarge to 4x the original size
 // (32x32 pixels)
 tmp = scl4x(tmp)
 
 // debug visualization
 local w=sqrt(#tmp)
 for v=0,w-1 do for u=0,w-1 do
   pset(x+u,y+v,tmp[1+u+v*w])
 end end
end

// rotate source pixels
// by -1 < a < 1, centered
// at (x, y) by gathering
// at the dest on an enlarged
// image. this is the @casualeffects
// version of "rotsprite" using
// improved scaling and simplified
// sampling
function rot_spr(i, x, y, a)
 local tmp = {}
 tmp[8*8] = 0

 // copy the source to temp memory
 for v=0,7 do for u=0,7 do
   tmp[1+u+v*8]=sget((i%16)*8+u,flr(i/16)*8+v)
 end end
 
 // enlarge to 4x the original size
 // (32x32 pixels)
 tmp = scl2x(scl4x(tmp))
 local k = 8

 local c, s = cos(-a) * k, sin(-a) * k
 
 for v = -2, 9 do
  local b = v - 4
  for u = -2, 9 do
   local a = u - 4
   
   local z, w =
    flr(4*k + c * a + s * b),
    flr(4*k - s * a + c * b)
   
   // todo: better filtering
   if (z >= 0) and (z < 8*k) and (w >= 0) and (w < 8*k) then
    local q = tmp[z + w*k*8 + 1]
    pset(x + u - 4, y + v - 4, q)
   end
  end
 end	
end



__gfx__
00000000000770000007000000aaaa00777777777700077000070000888880008087c7c0ccaaaacc000000000080008000444440000000000000000000000000
0000000000088000000700000aaaaaa07888888777707770007770008800880008787c0ccaaaaaac0a00000008880888044fff40000000000000000000000000
0070070000077000007c7000aa1aa1aa78aaaa877777777007777700880088008087c7c0aacaacaaa0a0000008888888044cfc00000000000000000000000000
0007700078777787807c7080aa1aa1aa78acca8777777770000700008800880008787c0caacaacaaa0aaaaaa0888888804ffff00000000000000000000000000
000770007877778780777080aaaaaaaa78acca877707077000070000888880008087c7c0aaaaaaaaa0a00a0a008888804488f800000000000000000000000000
007007000007700088777880aa1111aa78aaaa8777000770000700008888000008787c0caaccccaa0a000a0a0008880048888880000000000000000000000000
0000000000088000887778800aa11aa0788888877700077000070000880880008087c7c0caaccaac00000000000080000fddddf0000000000000000000000000
00000000000770008007008000aaaa007777777777000770000700008800880008787c0cccaaaacc000000000000000000500500000000000000000000000000
