   0 rem raster interrupt demo
  10 if z=0 then z=1:load"ras64.bin",8,1
  20 print"{clr}"
  30 sys 49152
  40 poke 49408+33,0:poke 49455+33,0
  50 for a=832 to 896:poke a,255:next
  60 for a=2040 to 2047:poke a,13:next
  70 poke 49408+21,255:poke 49455+21,255
  80 for a=49408 to 49422 step 2:poke a,b*25+50:poke a+47,b*25+50:b=b+1:next
  90 for a=49409 to 49423 step 2:poke a,100:poke a+47,200:next
