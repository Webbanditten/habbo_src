on prepare(me, tdata)
  pUpdateCount = 0
  pAnimFrame = 0
  pAnimLoop = 1
  pUpdatesToWaitOnLastFrame = 1
  if me.pXFactor = 32 then
    pAnimFrameDuration = 1
    pTotalLoopCount = 0
  else
    pAnimFrameDuration = 15
    pTotalLoopCount = 1
  end if
  pAnimFrameCounter = pAnimFrameDuration
  pTotalFrameCount = 1
  tValue = integer(tdata.getAt(#stuffdata))
  if tValue = 0 then
    me.setOff()
  else
    me.setOn()
  end if
  return(1)
  exit
end

on updateStuffdata(me, tValue)
  tValue = integer(tValue)
  if tValue = 0 then
    me.setOff()
  else
    me.setOn()
  end if
  exit
end

on update(me)
  if me.count(#pSprList) < 4 then
    return(0)
  end if
  pUpdateCount = pUpdateCount + 1
  if pUpdateCount < 3 then
    return(1)
  end if
  pUpdateCount = 0
  tName = member.name
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tName = tName.getProp(#item, 1, tName.count(#item) - 1) & "_"
  the itemDelimiter = tDelim
  if pProgramOn then
    if pAnimLoop >= 1 then
      pAnimFrameCounter = pAnimFrameCounter + 1
      if pAnimFrameCounter < pAnimFrameDuration then
        return(1)
      end if
      pAnimFrameCounter = 0
      tNewName = tName & pAnimFrame
      pAnimFrame = pAnimFrame + 1
      if pTotalFrameCount <= pAnimFrame and memberExists(tName & pAnimFrame + 1) then
        pTotalFrameCount = pAnimFrame + 1
      end if
      if pAnimFrame = pTotalFrameCount then
        if pAnimLoop < pTotalLoopCount then
          pAnimFrame = 1
          pAnimLoop = pAnimLoop + 1
        else
          pAnimLoop = 0
          tNewName = tName & pAnimFrame
          pUpdatesToWaitOnLastFrame = 30 + random(40)
        end if
      end if
    else
      if pAnimLoop = 0 then
        if pAnimFrame <= pUpdatesToWaitOnLastFrame then
          pAnimFrame = pAnimFrame + 1
          return(1)
        else
          pAnimFrame = 1
          pAnimLoop = 1
          return(1)
        end if
      end if
    end if
  else
    tNewName = tName & "0"
  end if
  if memberExists(tNewName) then
    tmember = member(getmemnum(tNewName))
    me.getPropRef(#pSprList, 4).castNum = tmember.number
    me.getPropRef(#pSprList, 4).width = tmember.width
    me.getPropRef(#pSprList, 4).height = tmember.height
  end if
  me.getPropRef(#pSprList, 4).locZ = me.getPropRef(#pSprList, 1).locZ + 2
  exit
end

on setOn(me)
  pFramesToWaitOnLastFrame = 0
  pAnimFrameCounter = pAnimFrameDuration
  if me.pXFactor = 32 then
    pTotalLoopCount = 4 + random(6)
  else
    pTotalLoopCount = 1
  end if
  pAnimLoop = 1
  pAnimFrame = 1
  pProgramOn = 1
  exit
end

on setOff(me)
  pProgramOn = 0
  exit
end

on select(me)
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer:integer(me.getID()), #integer:0])
  end if
  exit
end