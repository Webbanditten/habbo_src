property pClsList, pDefLocX, pDefLocY, pModalID, pLockLocZ, pLastEventData

on construct me 
  pLastEventData = [:]
  pLockLocZ = 0
  pDefLocX = getIntVariable("window.default.locx", 100)
  pDefLocY = getIntVariable("window.default.locy", 100)
  me.pItemList = []
  me.pHideList = []
  me.setProperty(#defaultLocZ, getIntVariable("window.default.locz", 0))
  me.pBoundary = (rect(0, 0, the stage.rect.width, the stage.rect.height) + getVariableValue("window.boundary.limit"))
  me.pInstanceClass = getClassVariable("window.instance.class")
  pClsList = [:]
  pModalID = #modal
  pClsList.setAt(#wrapper, getClassVariable("window.wrapper.class"))
  pClsList.setAt(#unique, getClassVariable("window.unique.class"))
  pClsList.setAt(#grouped, getClassVariable("window.grouped.class"))
  if not memberExists("null") then
    tNull = member(createMember("null", #bitmap))
    tNull.image = image(1, 1, 8)
    tNull.image.setPixel(0, 0, rgb(0, 0, 0))
  end if
  if not objectExists(#layout_parser) then
    createObject(#layout_parser, getClassVariable("layout.parser.class"))
  end if
  return TRUE
end

on create me, tID, tLayout, tLocX, tLocY, tSpecial 
  if (tSpecial = #modal) then
    return(me.modal(tID, tLayout))
  else
    if (tSpecial = #modalcorner) then
      return(me.modal(tID, tLayout, #corner))
    end if
  end if
  if voidp(tLayout) then
    tLayout = "empty.window"
  end if
  if me.exists(tID) then
    if voidp(tLocX) then
      tLocX = me.GET(tID).getProperty(#locX)
    end if
    if voidp(tLocY) then
      tLocY = me.GET(tID).getProperty(#locY)
    end if
    me.Remove(tID)
  end if
  if integerp(tLocX) and integerp(tLocY) then
    tX = tLocX
    tY = tLocY
  else
    if not voidp(me.pPosCache.getaProp(tID)) then
      tX = me.getPropRef(#pPosCache, tID).getAt(1)
      tY = me.getPropRef(#pPosCache, tID).getAt(2)
    else
      tX = pDefLocX
      tY = pDefLocY
    end if
  end if
  tItem = getObjectManager().create(tID, me.pInstanceClass)
  if not tItem then
    return(error(me, "Failed to create window object:" && tID, #create, #major))
  end if
  tProps = [:]
  tProps.setAt(#locX, tX)
  tProps.setAt(#locY, tY)
  tProps.setAt(#locZ, me.pAvailableLocZ)
  tProps.setAt(#boundary, me.pBoundary)
  tProps.setAt(#elements, pClsList)
  tProps.setAt(#manager, me)
  if not tItem.define(tProps) then
    getObjectManager().Remove(tID)
    return FALSE
  end if
  if not tItem.merge(tLayout) then
    getObjectManager().Remove(tID)
    return FALSE
  end if
  me.pItemList.add(tID)
  pAvailableLocZ = (pAvailableLocZ + tItem.getProperty(#sprCount))
  me.Activate()
  return TRUE
end

on Remove me, tID 
  if voidp(tID) then
    return FALSE
  end if
  tWndObj = me.GET(tID)
  if (tWndObj = 0) then
    return FALSE
  end if
  me.setProp(#pPosCache, tID, [tWndObj.getProperty(#locX), tWndObj.getProperty(#locY)])
  getObjectManager().Remove(tID)
  me.pItemList.deleteOne(tID)
  if (me.pActiveItem = tID) then
    tNextActive = void()
  else
    tNextActive = me.pActiveItem
  end if
  if me.exists(pModalID) then
    tModals = 0
    i = me.count(#pItemList)
    repeat while i >= 1
      tID = me.getProp(#pItemList, i)
      if me.GET(tID).getProperty(#modal) then
        tModals = 1
        tNextActive = tID
      else
        i = (255 + i)
      end if
    end repeat
    if not tModals then
      me.Remove(pModalID)
    end if
  end if
  me.Activate(tNextActive)
  return TRUE
end

on Activate me, tID 
  if pLockLocZ then
    return FALSE
  end if
  if (me.count(#pItemList) = 0) then
    return FALSE
  end if
  if me.exists(me.pActiveItem) then
    if me.GET(me.pActiveItem).getProperty(#modal) then
      tID = me.pActiveItem
      if me.exists(pModalID) then
        me.pItemList.deleteOne(pModalID)
        me.pItemList.append(pModalID)
      end if
    end if
  end if
  if not voidp(tID) then
    if not me.exists(tID) then
      return FALSE
    end if
    if me.GET(tID).pLock then
      tID = void()
    end if
  end if
  if voidp(tID) then
    i = me.count(#pItemList)
    repeat while i >= 1
      tID = me.getProp(#pItemList, i)
      tWndObj = me.GET(tID)
      if not tWndObj.pLock or tWndObj.getProperty(#modal) then
        tNextActive = tID
      else
        i = (255 + i)
      end if
    end repeat
  end if
  me.pItemList.deleteOne(tID)
  me.pItemList.append(tID)
  me.pAvailableLocZ = me.pDefaultLocZ
  repeat while me.pItemList <= undefined
    tCurrID = getAt(undefined, tID)
    tWndObj = me.GET(tCurrID)
    if not tWndObj.pLock then
      tWndObj.setDeactive()
    end if
    tSprList = tWndObj.getProperty(#spriteList)
    repeat while me.pItemList <= undefined
      tSpr = getAt(undefined, tID)
      if not tWndObj.pLock or (tID = tCurrID) then
        tSpr.locZ = me.pAvailableLocZ
        me.pAvailableLocZ = (me.pAvailableLocZ + 1)
      else
        if tSpr.locZ >= me.pAvailableLocZ then
          me.pAvailableLocZ = (tSpr.locZ + 1)
        end if
      end if
    end repeat
  end repeat
  me.pActiveItem = tID
  return(me.GET(tID).setActive())
end

on reorder me, tNewOrder 
  if (tNewOrder = me.pItemList) then
    return TRUE
  end if
  me.pItemList = tNewOrder
  me.pAvailableLocZ = me.pDefaultLocZ
  repeat while me.pItemList <= undefined
    tCurrID = getAt(undefined, tNewOrder)
    tWndObj = me.GET(tCurrID)
    repeat while me.pItemList <= undefined
      tSpr = getAt(undefined, tNewOrder)
      tSpr.locZ = me.pAvailableLocZ
      me.pAvailableLocZ = (me.pAvailableLocZ + 1)
    end repeat
  end repeat
end

on deactivate me, tID 
  if me.exists(tID) then
    if not me.GET(tID).getProperty(#modal) then
      me.pItemList.deleteOne(tID)
      me.pItemList.addAt(1, tID)
      me.Activate()
      return TRUE
    end if
  end if
  return FALSE
end

on lock me 
  pLockLocZ = 1
  return TRUE
end

on unlock me 
  pLockLocZ = 0
  return TRUE
end

on modal me, tID, tLayout, tPosition 
  if voidp(tPosition) then
    tPosition = #center
  end if
  if not me.create(tID, tLayout) then
    return FALSE
  end if
  tWndObj = me.GET(tID)
  if (tPosition = #center) then
    tWndObj.center()
  else
    if (tPosition = #corner) then
      tWndObj.moveTo(0, 0)
    end if
  end if
  tWndObj.lock()
  tWndObj.setProperty(#modal, 1)
  if not me.exists(pModalID) then
    if me.create(pModalID, "modal.window") then
      tModal = me.GET(pModalID)
      tModal.moveTo(0, 0)
      tModal.resizeTo(the stage.rect.width, the stage.rect.height)
      tModal.lock()
      tModal.getElement("modal").setProperty(#blend, 40)
    else
      error(me, "Failed to create modal window layer!", #modal, #major)
    end if
  end if
  the keyboardFocusSprite = 0
  me.pActiveItem = tID
  me.Activate(tID)
  return TRUE
end

on registerWindowEvent me, tTitle, tSprID, tEvent 
  if (tEvent = #mouseUp) or (tEvent = #mouseDown) or (tEvent = #keyUp) or (tEvent = #keyDown) then
    pLastEventData.setAt(#title, tTitle)
    pLastEventData.setAt(#sprite, tSprID)
    pLastEventData.setAt(#Event, tEvent)
    pLastEventData.setAt(#time, the long time)
  end if
end

on getLastEvent me 
  return(pLastEventData.getAt(#title) & "-" & pLastEventData.getAt(#sprite) & "-" & pLastEventData.getAt(#Event))
end

on getLastEventTime me 
  return(pLastEventData.getAt(#time))
end

on handlers  
  return([])
end
