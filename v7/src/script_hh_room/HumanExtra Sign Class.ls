on construct(me)
  pSignSpr = sprite(reserveSprite(me.getID()))
  return(1)
  exit
end

on deconstruct(me)
  releaseSprite(pSignSpr.spriteNum)
  pSignSpr = void()
  return(1)
  exit
end

on refresh(me)
  pSignSpr.visible = 0
  exit
end

on show_sign(me, tProps)
  tSignMem = tProps.getAt("signmember")
  tHumanSpr = tProps.getAt("sprite")
  tDirection = tProps.getAt("direction")
  if pSignMem <> tSignMem then
    pSignSpr.ink = 8
    pSignSpr.member = member(getmemnum(tSignMem))
    pSignMem = tSignMem
  end if
  tSignLoc = tHumanSpr.loc
  if tDirection = 0 then
    tSignLoc.locH = tSignLoc.locH - 16
  else
    if tDirection = 4 then
      tSignLoc.locH = tSignLoc.locH + 2
    else
      if tDirection = 6 then
        tSignLoc.locH = tSignLoc.locH - 18
      end if
    end if
  end if
  pSignSpr.loc = tSignLoc
  pSignSpr.locZ = tHumanSpr.locZ + 1
  pSignSpr.visible = 1
  exit
end