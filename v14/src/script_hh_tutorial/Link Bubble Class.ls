property pLinkWriter

on construct me 
  me.pWindowType = "bubble_links.window"
  me.pTextWidth = 160
  me.Init()
  me.pLinksOffset = 0
  me.pWindow.registerProcedure(#blendHandler, me.getID(), #mouseEnter)
  me.pWindow.registerProcedure(#blendHandler, me.getID(), #mouseLeave)
  me.pWindow.registerProcedure(#eventHandler, me.getID(), #mouseUp)
  tLinkFont = getStructVariable("struct.font.link")
  me.pLinkLineHeight = 16
  tLinkFont.setaProp(#lineHeight, me.pLinkLineHeight)
  tWriterID = getUniqueID()
  createWriter(tWriterID, tLinkFont)
  me.pLinkWriter = getWriter(tWriterID)
  me.pLinkWriter.define([#bgColor:rgb("#F0F0F0")])
  me.pResizeOffset = 0
  me.pLinkPosOrigX = me.pWindow.getElement("bubble_links").getProperty(#locH)
  me.pLinkPosOrigY = me.pWindow.getElement("bubble_links").getProperty(#locV)
  me.pWidthOrig = me.pWindow.getProperty(#width)
  me.pHeightOrig = me.pWindow.getProperty(#height)
  me.hideLinks()
  return TRUE
end

on deconstruc me 
  removeWindow(me.pWindow.getProperty(#id))
end

on setText me, tText 
  callAncestor(#setText, [me], tText)
  me.setLinks(me.pLinkList)
end

on setLinks me, tLinkList, tStatusList 
  me.pLinkList = tLinkList
  tElem = me.pWindow.getElement("bubble_links")
  if voidp(me.pLinkList) then
    me.hideLinks()
    return TRUE
  end if
  if (me.count(#pLinkList) = 0) then
    me.hideLinks()
    return TRUE
  end if
  tListString = ""
  repeat while tLinkList <= 1
    tLink = getAt(1, count(tLinkList))
    tListString = tListString & getText(tLink) & "\r"
  end repeat
  tListString = tListString.getProp(#line, 1, (tListString.count(#line) - 1))
  tLinkImage = me.pLinkWriter.render(tListString).duplicate()
  if not voidp(tStatusList) then
    tColorOrig = pLinkWriter.pMember.color
    i = 1
    repeat while i <= tLinkList.count
      tID = tLinkList.getPropAt(i)
      if tStatusList.getaProp(tID) then
        me.pLinkWriter.pMember.getPropRef(#line, i).color = rgb(150, 150, 150)
      end if
      i = (1 + i)
    end repeat
    tLinkImage = me.pLinkWriter.pMember.image.duplicate()
    me.pLinkWriter.pMember.color = tColorOrig
  end if
  tElem.show()
  tElem.feedImage(tLinkImage)
  tElem.resizeTo(tLinkImage.width, tLinkImage.height, 1)
  tTextH = me.pWindow.getElement("bubble_text").getProperty(#height)
  tElem.moveTo(0, (tTextH + me.pLinksOffset))
  tSizeY = (((me.pEmptySizeY + tTextH) + me.pLinksOffset) + tElem.getProperty(#height))
  me.pWindow.resizeTo(me.pEmptySizeX, tSizeY)
  me.updatePointer()
  if not voidp(tStatusList) then
    me.setCheckmarks(tStatusList, 1)
  end if
end

on hideLinks me 
  tElem = me.pWindow.getElement("bubble_links")
  tElem.hide()
  tTextH = me.pWindow.getElement("bubble_text").getProperty(#height)
  me.pWindow.resizeTo(me.pEmptySizeX, (me.pEmptySizeY + tTextH))
  me.updatePointer()
end

on setCheckmarks me, tStatusList, tBlockTextReset 
  tMarkImage = member("checkmark").image
  tLinkElem = me.pWindow.getElement("bubble_links")
  tLinkImage = tLinkElem.getProperty(#image)
  tMarkOffset = 4
  tVerticalOffset = 8
  tImage = image(((tLinkImage.width + tMarkImage.width) + tMarkOffset), tLinkImage.height, 8)
  tTargetRect = rect(((tImage.width - tLinkImage.width) + 1), 0, tImage.width, tImage.height)
  tImage.copyPixels(tLinkImage, tTargetRect, tLinkImage.rect)
  tLinkNum = 1
  repeat while tLinkNum <= me.count(#pLinkList)
    tID = me.pLinkList.getPropAt(tLinkNum)
    if tStatusList.getaProp(tID) then
    else
      tY1 = ((me.pLinkLineHeight * (tLinkNum - 1)) + tVerticalOffset)
      tY2 = (tY1 + tMarkImage.height)
      tImage.copyPixels(tMarkImage, rect(0, tY1, tMarkImage.width, tY2), tMarkImage.rect)
    end if
    tLinkNum = (1 + tLinkNum)
  end repeat
  tLinkElem.feedImage(tImage)
  tLinkElem.resizeTo(tImage.width, tImage.height, 1)
  if not tBlockTextReset then
    me.setLinks(me.pLinkList, tStatusList)
  end if
end

on blendHandler me, tEvent, tSpriteID, tParam 
  if voidp(me.pLinkList) then
    callAncestor(#blendHandler, [me], tEvent, tSpriteID, tParam)
  end if
end

on eventHandler me, tEvent, tSpriteID, tParam 
  if me.pLinkList.ilk <> #propList then
    return FALSE
  end if
  if (tSpriteID = "bubble_links") then
    tLineNum = ((tParam.getAt(2) / 16) + 1)
    tTopicID = me.pLinkList.getPropAt(tLineNum)
    getThread(#tutorial).getComponent().selectTopic(tTopicID)
  end if
end
