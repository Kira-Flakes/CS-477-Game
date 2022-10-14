pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--variables--

function _init()
  player={
    sp=1,
    x=15,
    y=94,
    w=8,
    h=8,
    flp=false,
    dx=0,
    dy=0,
    max_dx=2,
    max_dy=3,
    acc=0.5,
    boost=4,
    anim=0,
    running=false,
    jumping=false,
    falling=false,
    sliding=false,
    landed=false
  }
  
  gravity=0.3
  friction=0.85
  
  --simple camera
  cam_x=0
  
  --map limits
  map_start=0
  map_end=384
end
-->8
--update and draw--
function _update()
  player_update()
  player_animate()
  
  --simple camera
  cam_x=player.x-64+(player.w/2)
  if cam_x<map_start then
    cam_x=map_start
  end
  if cam_x>map_end-128 then
    cam_x=map_end-128
  end
  camera(cam_x,0)
end  

function _draw()
  cls()
  map(0,0)
  spr(player.sp,player.x,player.y,1,1,player.flp)
end
-->8
--collisions--

function collide_map(obj,aim,flag)
  --obj = table needs x,y,w,h
  --aim = left,right,up,down
  
  --dimensions of object
  local x=obj.x  local y=obj.y
  local w=obj.w  local h=obj.h
  
  --what positions to check
  local x1=0  local y1=0
  local x2=0  local y2=0
  
  --aim=direction object is moving
  --below are the hitboxes for
  --each respective movement type
  if aim=="left" then
    x1=x-1  y1=y
    x2=x    y2=y+h-1
    
  elseif aim=="right" then
    x1=x+w-1    y1=y
    x2=x+w  y2=y+h-1
    
  elseif aim=="up" then
    x1=x+2    y1=y-1
    x2=x+w-3  y2=y
  
  elseif aim=="down" then
    x1=x+2    y1=y+h
    x2=x+w-3  y2=y+h
  end --endif
  
  --convert pixels to tiles
  x1/=8  y1/=8
  x2/=8  y2/=8
  
  --if any corners of the rectangle
  --are a map tile, return true
  if fget(mget(x1,y1), flag)
  or fget(mget(x1,y2), flag)
  or fget(mget(x2,y1), flag)
  or fget(mget(x2,y2), flag) then
    return true
  else
    return false
  end --endif
end --end collide_map
-->8
--player functions--

function player_update()
  --physics
  player.dy+=gravity
  player.dx*=friction
  
  --controls
  if btn(⬅️) then
    player.dx-=player.acc
    player.running=true
    player.flp=true
  end
  
  if btn(➡️) then
    player.dx+=player.acc
    player.running=true
    player.flp=false
  end
  
  --sliding
  if player.running
  and not btn(⬅️)
  and not btn(➡️)
  and not player.falling
  and not player.jumping then
    player.running=false
    player.sliding=true
  end
  
  --jump
  if btnp(⬆️)
  and player.landed then
    player.dy-=player.boost
    player.landed=false
  end
  
  --check collision up and down
  if player.dy>0 then
    player.falling=true
    player.landed=false
    player.jumping=false
    
    player.dy=limit_speed(player.dy,player.max_dy)
    
    if collide_map(player,"down",0) then
      player.landed=true
      player.falling=false
      player.dy=0
      player.y-=(player.y+player.h)%8
    end
  elseif player.dy<0 then
    player.jumping=true
    if collide_map(player,"up",1) then
      player.dy=o
    end
  end
  
  --check collision left and right
  if player.dx<0 then
  
    player.dx=limit_speed(player.dx,player.max_dx)
  
    if collide_map(player,"left",1) then
      player.dx=0
    end
  elseif player.dx>0 then
  
    player.dx=limit_speed(player.dx,player.max_dx)
  
    if collide_map(player,"right",1) then
      player.dx=0
    end
  end
  
  --stop sliding
  if player.sliding then
    if abs(player.dx)<.2
    or player.running then
      player.dx=0
      player.sliding=false
    end
  end
  
  player.x+=player.dx
  player.y+=player.dy

  --limit player to map
  if player.x<map_start then
    player.x=map_start
  end
  if player.x>map_end-player.w then
    player.x=map_end-player.w
  end
end --end player_update


function player_animate()
  if player.jumping then
    player.sp=7
  elseif player.falling then
    player.sp=8
  elseif player.sliding then
    player.sp=9
  elseif player.running then
    if time() - player.anim>.15 then
      player.sp += 1
      player.anim=time()
      
      if player.sp > 6 then
        player.sp = 3
      end
    end
  else --player idle
    if time()-player.anim>.4 then
      player.sp+=1
      player.anim=time()
      
      if player.sp>2 then
        player.sp=1
      end
    end
  end
end --end player_animate

function limit_speed(num,maximum)
  return mid(-maximum,num,maximum)
end --end limit_speed
__gfx__
00000000005000000050000000050000000500000005000000050000000500000005000000000000000000000000000000000000000000000000000000000000
00000000009555000095570000099550000995500009955000099550000995500009955005000000000000000000000000000000000000000000000000000000
00700700009555000095550000099550000995500009955000099550000995500009955009555000000000000000000000000000000000000000000000000000
00077000009999000099990000099990000999900009999000099990000999900009999009555000000000000000000000000000000000000000000000000000
00077000000550000005500000995500000955000044550000045500000955000000559009999000000000000000000000000000000000000000000000000000
00700700009999000099990000009944000099400000999900009990009099000000990900955440000000000000000000000000000000000000000000000000
00000000090990900909909000990400000940000044090000049000000490000000094009099400000000000000000000000000000000000000000000000000
00000000009009000090090000000400000940000000090000049000004900000000009400009944000000000000000000000000000000000000000000000000
00000000000005000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000005955550000000000595566000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000005955555000000000595555600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000009955555000000000995555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000009995555000000000999555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000009999999000000000999999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000999990000000000099999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000055500000000000005550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000055999995500000005599999550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000995999995990000099599999599000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000990999990990000099099999099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000990599950990000099059995099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000959590000000000095959000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000990990000000000099099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000990990000000000099099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000550550000000000055055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666577777750000000055555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666756666670000000055555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666775666660000000055555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65555556767566660000000055555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65555556766756660000000055555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65555556766675660000000055555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65555556766667560000000055555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666576666750000000055555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003010003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000414141410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000004242424242420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000004141414141410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004040434300000000000042424242424242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000424242404043434300000000000042414141414141410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004242424240404343434342000000000042000000000042420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004242424040434343434342420000000042000000000042000000000040404040400000004242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
