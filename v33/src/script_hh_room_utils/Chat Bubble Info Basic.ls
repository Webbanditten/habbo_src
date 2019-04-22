on construct(me)
  pItemId = void()
  pBgSprite = sprite(reserveSprite(me.getID()))
  pUserName = ""
  pUserId = ""
  pSourceLocation = void()
  pMargins = []
  pMargins.setAt(#left, 5)
  pMargins.setAt(#right, 6)
  pMargins.setAt(#textleft, 30)
  pBgMemName = ""
  tVariations = ["CUSTOM":"bold"]
  pTextParams = []
  i = 1
  repeat while i <= tVariations.count
    tFontStruct = getStructVariable("struct.font." & tVariations.getAt(i))
    tMemName = "balloon.text." & tVariations.getPropAt(i)
    if not memberExists(tMemName) then
      tmember = member(createMember(tMemName, #text))
    else
      tmember = member(getmemnum(tMemName))
    end if
    tmember.wordWrap = 0
    tmember.boxType = #adjust
    tmember.antialias = 0
    tmember.font = tFontStruct.getaProp(#font)
    tmember.fontSize = tFontStruct.getaProp(#fontSize)
    tmember.fontStyle = tFontStruct.getaProp(#fontStyle)
    pTextParams.setAt(tVariations.getPropAt(i), [#member:tmember, #font:tFontStruct.getaProp(#font), #fontStyle:tFontStruct.getaProp(#fontStyle)])
    i = 1 + i
  end repeat
  pBalloonImg = []
  #left.addProp(member(getmemnum("chat_bubble_left")), image.duplicate())
  #middle.addProp(member(getmemnum("chat_bubble_middle")), image.duplicate())
  #right.addProp(member(getmemnum("chat_bubble_right")), image.duplicate())
  if variableExists("balloons.leftmargin") then
    pBalloonLeftMarg = getIntVariable("balloons.leftmargin", 0)
  else
    pBalloonLeftMarg = 0
  end if
  if variableExists("balloons.rightmargin") then
    pBalloonRightMarg = getIntVariable("balloons.rightmargin", 0)
  else
    pBalloonRightMarg = the stageRight - the stageLeft
  end if
  exit
end

on deconstruct(me)
  if ilk(pBgSprite) = #sprite then
    releaseSprite(pBgSprite.spriteNum)
    pBgSprite = void()
  end if
  if memberExists(pBgMemName) then
    removeMember(pBgMemName)
  end if
  exit
end

on defineBalloon(me, tMode, tColor, tMessage, tItemID, tSourceLoc)
  tNewBgMemName = "chat_item_background_" & tItemID
  pBgMemName = tNewBgMemName
  if not memberExists(pBgMemName) then
    createMember(pBgMemName, #bitmap)
  end if
  pItemId = tItemID
  tTextImg = me.renderText(tMessage, tMode)
  tTextWidth = tTextImg.width
  if tColor = void() then
    tColor = rgb(255, 255, 255)
  end if
  tBalloonWidth = pMargins.getAt(#left) + tTextWidth + pMargins.getAt(#right)
  tBackgroundImg = me.renderBackground(tBalloonWidth, tColor)
  tTextOffH = pMargins.getAt(#left)
  tTextOffV = pBalloonImg.getAt(#middle).height - tTextImg.height / 2 + 1
  tTextDestRect = rect(tTextOffH, tTextOffV, tTextOffH + tTextWidth, tTextOffV + tTextImg.height)
  tBackgroundImg.copyPixels(tTextImg, tTextDestRect, tTextImg.rect)
  tBgMem = getMember(pBgMemName)
  tBgMem.image = tBackgroundImg
  tBgMem.regPoint = point(0, 0)
  pBgSprite.member = tBgMem
  pBgSprite.ink = 8
  return(1)
  exit
end

on showBalloon(me, tVisible)
  if voidp(tVisible) then
    tVisible = 1
  end if
  if ilk(pBgSprite) = #sprite then
    pBgSprite.visible = tVisible
  end if
  exit
end

on moveVerticallyBy(me, tMoveAmount)
  tNewLocation = pLocation + point(0, tMoveAmount)
  me.setLocation(tNewLocation)
  return(tNewLocation.getAt(2))
  exit
end

on setLocation(me, tloc)
  if ilk(tloc) <> #point and ilk(tloc) <> #list then
    return(0)
  end if
  tMem = getMember(pBgMemName)
  if tMem.type = #bitmap then
    tMemWidth = image.width
  else
    return(0)
  end if
  tRelativeLocH = tloc.getAt(1) - tMemWidth / 2
  tRelativeLocH = max(tRelativeLocH, pBalloonLeftMarg)
  tRelativeLocH = min(pBgSprite, member - image.width)
  pLocation = tloc
  pBgSprite.loc = point(tRelativeLocH, pLocation.getAt(2))
  pBgSprite.locZ = getIntVariable("window.default.locz") - 2000 + pLocation.getAt(2) / 10
  return(point(tRelativeLocH, pLocation.getAt(2)))
  exit
end

on getLowPoint(me)
  return(pLocation.getAt(2))
  exit
end

on getItemId(me)
  return(pItemId)
  exit
end

on getType(me)
  return("CUSTOM")
  exit
end

on renderBackground(me, tWidth, tBalloonColor)
  if tBalloonColor.red + tBalloonColor.green + tBalloonColor.blue >= 600 then
    tBalloonColorDarken = rgb(0, 0, 0)
    tBalloonColorDarken.red = tBalloonColor.red * 0.9
    tBalloonColorDarken.green = tBalloonColor.green * 0.9
    tBalloonColorDarken.blue = tBalloonColor.blue * 0.9
    tBalloonColor = tBalloonColorDarken
  end if
  if tBalloonColor.red + tBalloonColor.green + tBalloonColor.blue <= 100 then
    tBalloonColorDarken = rgb(0, 0, 0)
    tBalloonColorDarken.red = tBalloonColor.red * 3
    tBalloonColorDarken.green = tBalloonColor.green * 3
    tBalloonColorDarken.blue = tBalloonColor.blue * 3
    tBalloonColor = tBalloonColorDarken
  end if
  tNewImg = image(tWidth, pBalloonImg.getAt(#left).height + pBalloonImg.getAt(#left).height, 32)
  tStartPointY = 0
  tEndPointY = pBalloonImg.getAt(#left).height
  tStartPointX = 0
  tEndPointX = 0
  repeat while me <= tBalloonColor
    i = getAt(tBalloonColor, tWidth)
    tStartPointX = tEndPointX
    if me = #left then
      tEndPointX = tEndPointX + pBalloonImg.getProp(i).width
      tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
      tNewImg.copyPixels(pBalloonImg.getProp(i), tdestrect, pBalloonImg.getProp(i).rect)
    else
      if me = #middle then
        tEndPointX = tEndPointX + tWidth - pBalloonImg.getProp(#left).width - pBalloonImg.getProp(#right).width
        tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
        tNewImg.copyPixels(pBalloonImg.getProp(i), tdestrect, pBalloonImg.getProp(i).rect)
      else
        if me = #right then
          tEndPointX = tEndPointX + pBalloonImg.getProp(i).width
          tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
          tNewImg.copyPixels(pBalloonImg.getProp(i), tdestrect, pBalloonImg.getProp(i).rect)
        end if
      end if
    end if
  end repeat
  return(tNewImg)
  exit
end

on renderText(me, tChatMessage, tChatMode)
  tTextParams = pTextParams.getAt(tChatMode)
  tmember = tTextParams.getAt(#member)
  tText = tChatMessage
  tmember.text = tText
  tmember.font = tTextParams.getAt(#font)
  tmember.fontStyle = tTextParams.getAt(#fontStyle)
  tTextWidth = tmember.charPosToLoc(tmember.count(#char)).locH
  tmember.rect = rect(0, 0, tTextWidth, tmember.height)
  tTextImg = image.duplicate()
  return(tTextImg)
  exit
end