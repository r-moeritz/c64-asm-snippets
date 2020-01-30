    1 rem a 1351 mouse demo for the c64
    2 rem 10/16/86 fred bowen
   10 if z=0 thenz=1:load"sprites.0e*",8,1
   20 if z=1 thenz=2:load"mouse64.bin",8,1
   30 print"{clr}":v=13*4096:pokev+21,255
   35 pokev+29,254:pokev+23,254:pokev+16,0
   40 fori=0to7: s=i*2: poke2040+i,56+i
   41 readx,y,c,s$(i)
   42 pokev+s,x:pokev+s+1,y:pokev+39+i,c
   43 next
   50 sys12*4096+256
   60 t=0
   70 s=int(rnd(1)*7+1):ift>15then200
   80 print"{clr}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{gry3}     which of these is a {wht}";s$(s);"?"
   85 print"{down}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}";
   90 if(peek(v+12*256+1)and17)=17thenx=peek(v+30):goto90
  100 if(peek(v+30)<>(2^s+1))then120
  110 fori=0to96:poke646,iand15:print"right!{left}{left}{left}{left}{left}{left}";:next:t=t+1:goto70
  120 print"{yel}wrong!{left}{left}{left}{left}{left}{left}";:fori=0to400:next:print"      {left}{left}{left}{left}{left}{left}";:goto90
  200 :
  210 t=0:fori=0to9:reads$(i):next
  220 pokev+21,1:print"{clr}{down}{down}{down}{down}{down}{down}{yel}      0  1  2  3  4  5  6  7  8  9"
  230 s=int(rnd(0)*10):ift>15thenrestore:goto30
  240 print"{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{down}{rght}{rght}{rght}{gry3} point & click on the number {wht}";s$(s)
  250 print"{down}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}{rght}";
  260 if(peek(v+12*256+1)and17)=17then260
  270 x=int((peek(v)+(peek(v+16)and1)*256-24)/8):y=int((peek(v+1)-50)/8)
  280 ifpeek(1024+y*40+x)<>48+sthen300
  290 fori=0to96:poke646,iand15:print"right!{left}{left}{left}{left}{left}{left}";:next:t=t+1:goto220
  300 print"{yel}wrong!{left}{left}{left}{left}{left}{left}";:fori=0to400:next:print"      {left}{left}{left}{left}{left}{left}";:goto260
  310 :
 1000 data 100,100,1 ,pointer
 1001 data 60 ,60 ,10,circle
 1002 data 160,62 ,4 ,triangle
 1003 data 255,62 ,13,elipse
 1004 data 160,110,7 ,square
 1005 data 60 ,160,5 ,rectangle
 1006 data 160,160,3 ,diamond
 1007 data 255,160,14,cross
 2000 data zero,one,two,three,four,five,six,seven,eight,nine
