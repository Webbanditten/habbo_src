on construct(me)
  pItemList = []
  pTotalCount = 0
  pHandVisID = "Hand_visualizer"
  pAnimMode = #open
  pAnimLocs = [[-54, 27], [-42, 21], [-36, 18], [-28, 14], [-22, 11], [-18, 9], [-12, 6], [-10, 5], [-8, 4]]
  pAnimFrm = 1
  pAppendFlag = 0
  pHandButtonsWnd = "habbo_hand_buttons"
  pNextActive = 1
  pPrevActive = 1
  pIconPlaceholderName = "icon_placeholder"
  registerMessage(#recyclerStateChange, me.getID(), #showContainerItems)
  return(1)
  exit
end

on deconstruct(me)
  i = 1
  repeat while i <= 9
    if memberExists("handcontainer_" & i) then
      removeMember("handcontainer_" & i)
    end if
    i = 1 + i
  end repeat
  unregisterMessage(#recyclerStateChange, me.getID())
  removeWindow(pHandButtonsWnd)
  removeUpdate(me.getID())
  if visualizerExists(pHandVisID) then
    removeVisualizer(pHandVisID)
  end if
  pItemList = []
  pTotalCount = 0
  return(1)
  exit
end

on open(me, tStripInfo)
  if tStripInfo then
    if visualizerExists(pHandVisID) then
      return(0)
    end if
    if not createVisualizer(pHandVisID, "habbo_hand.visual") then
      return(0)
    end if
    tHandVisualizer = getVisualizer(pHandVisID)
    tHandVisualizer.moveTo(694, -137)
    tHandVisualizer.setProperty(#locZ, -1000)
    tSprList = tHandVisualizer.getProperty(#spriteList)
    call(#registerProcedure, tSprList, #eventProcContainer, me.getID(), #mouseDown)
    call(#registerProcedure, tSprList, #eventProcContainer, me.getID(), #mouseUp)
    call(#registerProcedure, tSprList, #eventProcContainer, me.getID(), #mouseUpOutSide)
    pAnimMode = #open
    pAnimFrm = 1
    receiveUpdate(me.getID())
  else
    tConnection = getThread(#room).getComponent().getRoomConnection()
    if tConnection <> 0 then
      tConnection.send("GETSTRIP", "new")
    end if
  end if
  return(1)
  exit
end

on close(me)
  if not visualizerExists(pHandVisID) then
    return(0)
  end if
  pAnimMode = #close
  removeWindow(pHandButtonsWnd)
  receiveUpdate(me.getID())
  return(1)
  exit
end

on openClose(me)
  if visualizerExists(pHandVisID) then
    return(me.close())
  else
    return(me.open())
  end if
  exit
end

on Refresh(me)
  me.hideContainerItems()
  me.showContainerItems()
  return(1)
  exit
end

on updateStripItems(me, tList)
  if pAppendFlag then
    pAppendFlag = 0
  else
    pItemList = []
  end if
  repeat while me <= undefined
    tItem = getAt(undefined, tList)
    me.createStripItem(tItem)
  end repeat
  return(1)
  exit
end

on appendStripItem(me, tdata)
  if pItemList.count = 0 then
    pAppendFlag = 1
    tConnection = getThread(#room).getComponent().getRoomConnection()
    if tConnection <> 0 then
      tConnection.send("GETSTRIP", "new")
    end if
  end if
  return(me.createStripItem(tdata))
  exit
end

on createStripItem(me, tdata)
  tIconClassStr = ""
  if me = "active" then
    if offset("*", tdata.getAt(#class)) > 0 then
      tIconClassStr = tdata.getAt(#class).getProp(#char, 1, offset("*", tdata.getAt(#class)) - 1)
    else
      tIconClassStr = tdata.getAt(#class)
    end if
  else
    if me = "item" then
      tIconClassStr = ""
      if tdata.getAt(#class) = "poster" then
        tIconClassStr = "poster" && tdata.getAt(#props)
      else
        if tdata.getAt(#class) contains "post.it" then
          tPostnums = integer(value(tdata.getAt(#props)) / 0 / 0)
          if tPostnums > 6 then
            tPostnums = 6
          end if
          if tPostnums < 1 then
            tPostnums = 1
          end if
          tdata.setAt(#member, tdata.getAt(#class) & "_" & tPostnums & "_small")
        else
          if tdata.getAt(#class) = "wallpaper" then
            tdata.setAt(#member, "wallpaper_small")
          else
            if tdata.getAt(#class) = "floor" then
              tdata.setAt(#member, "floor_small")
            else
              if memberExists(tdata.getAt(#class) & "_small") then
                tIconClassStr = tdata.getAt(#class)
              else
                tIconClassStr = tdata.getAt(#class)
              end if
            end if
          end if
        end if
      end if
    else
      error(me, "Unknown strip item type:" && tdata.getAt(#striptype), #createStripItem)
      tdata.setAt(#member, "room_object_placeholder")
    end if
  end if
  if not voidp(tdata.getAt(#member)) then
    nothing()
  else
    if memberExists(tIconClassStr & "_small") then
      tdata.setAt(#member, tIconClassStr & "_small")
    else
      if memberExists(tdata.getAt(#class) & "_small") then
        tdata.setAt(#member, tdata.getAt(#class) & "_small")
      else
        tdata.setAt(#member, pIconPlaceholderName)
        tdata.setAt(#truemember, tIconClassStr & "_small")
        tdata.setAt(#downloadLocked, 1)
        tDownloadIdName = tIconClassStr
        tDynThread = getThread(#dynamicdownloader)
        if tDynThread = 0 then
          error(me, "Icon member not found and no dynamic download possibility: " & tdata.getAt(#member), #createStripItem)
        else
          tDynComponent = tDynThread.getComponent()
          tRoomSizePrefix = ""
          tRoomThread = getThread(#room)
          if tRoomThread <> 0 then
            tTileSize = tRoomThread.getInterface().getGeometry().getTileWidth()
            if tTileSize = 32 then
              tRoomSizePrefix = "s_"
            end if
          end if
          tDownloadIdName = tRoomSizePrefix & tDownloadIdName
          tDynComponent.downloadCastDynamically(tDownloadIdName, tdata.getAt(#striptype), me.getID(), #stripItemDownloadCallback, 1)
        end if
      end if
    end if
  end if
  pItemList.setAt(tdata.getAt(#stripId), tdata)
  return(1)
  exit
end

on stripItemDownloadCallback(me, tDownloadedClass)
  tIconSuffix = "_small"
  tSmallScalePrefix = "s_"
  if chars(tDownloadedClass, 1, tSmallScalePrefix.length) = tSmallScalePrefix then
    tDownloadedClass = chars(tDownloadedClass, tSmallScalePrefix.length + 1, tDownloadedClass.length)
  end if
  repeat while me <= undefined
    tItem = getAt(undefined, tDownloadedClass)
    tTrueMem = tItem.getAt(#truemember)
    if not voidp(tTrueMem) then
      if chars(tTrueMem, tTrueMem.length - tIconSuffix.length + 1, tTrueMem.length) = tIconSuffix then
        tTrueMem = chars(tTrueMem, 1, tTrueMem.length - tIconSuffix.length)
      end if
      if tTrueMem = tDownloadedClass then
        tItem.setAt(#member, tItem.getAt(#truemember))
        tItem.setAt(#downloadLocked, 0)
      end if
    end if
  end repeat
  me.showContainerItems()
  exit
end

on removeStripItem(me, tid)
  return(pItemList.deleteProp(tid))
  exit
end

on getStripItem(me, tid)
  if voidp(tid) then
    tid = ""
  end if
  if tid = #list then
    return(pItemList)
  end if
  if voidp(pItemList.getAt(tid)) then
    return(0)
  end if
  return(pItemList.getAt(tid))
  exit
end

on stripItemExists(me, tid)
  return(not voidp(pItemList.getAt(tid)))
  exit
end

on setStripItemCount(me, tCount)
  if integerp(tCount) then
    pTotalCount = tCount
  end if
  if visualizerExists(pHandVisID) then
    if pTotalCount > pItemList.count then
      me.setHandButtonsVisible()
    end if
  end if
  return(1)
  exit
end

on placeItemToRoom(me, tid)
  if getThread(#room).getComponent().getRoomID() <> "private" then
    return(0)
  end if
  if not me.stripItemExists(tid) then
    return(error(me, "Attempted to access unexisting stripitem:" && tid, #placeItemToRoom))
  end if
  tdata = me.getStripItem(tid).duplicate()
  tdata.setAt(#x, 0)
  tdata.setAt(#y, 0)
  tdata.setAt(#h, 0)
  if not voidp(tdata.getAt(#props)) then
    tdata.setAt(#type, tdata.getAt(#props))
  end if
  if tdata.getAt(#striptype) = "active" then
    tdata.setAt(#props, [])
    tdata.setAt(#direction, [0, 0, 0])
    tdata.setAt(#altitude, 0)
    getThread(#room).getComponent().createActiveObject(tdata)
    if getThread(#room).getComponent().getActiveObject(tdata.getAt(#id)) = 0 then
      return(0)
    end if
    getThread(#room).getComponent().getActiveObject(tdata.getAt(#id)).setaProp(#stripId, tdata.getAt(#stripId))
    removeStripItem(me, tid)
    return(1)
  else
    if tdata.getAt(#striptype) = "item" then
      if me <> "poster" then
        if me <> "post.it" then
          if me <> "post.it.vd" then
            if me = "photo" then
              if tdata.getAt(#class) = "post.it" then
                tdata.setAt(#type, "#ffff33")
              end if
              tdata.setAt(#direction, "leftwall")
              if not getThread(#room).getComponent().createItemObject(tdata) then
                return(0)
              end if
              getThread(#room).getComponent().getItemObject(tdata.getAt(#id)).setaProp(#stripId, tdata.getAt(#stripId))
              if not tdata.getAt(#class) contains "post.it" then
                me.removeStripItem(tid)
              end if
              return(1)
            else
              if me <> "floor" then
                if me = "wallpaper" then
                  getThread(#room).getComponent().getRoomConnection().send("FLATPROPBYITEM", tdata.getAt(#class) & "/" & tdata.getAt(#stripId))
                  removeStripItem(me, tid)
                  return(0)
                else
                  if me = "Chess" then
                    tdata.setAt(#direction, [0, 0, 0])
                    getThread(#room).getComponent().createItemObject(tdata)
                    getThread(#room).getComponent().getItemObject(tdata.getAt(#id)).setaProp(#stripId, tdata.getAt(#stripId))
                    removeStripItem(me, tid)
                    return(1)
                  else
                    tdata.setAt(#direction, "leftwall")
                    if not getThread(#room).getComponent().createItemObject(tdata) then
                      return(0)
                    end if
                    getThread(#room).getComponent().getItemObject(tdata.getAt(#id)).setaProp(#stripId, tdata.getAt(#stripId))
                    me.removeStripItem(tid)
                    return(1)
                  end if
                end if
                exit
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on getVisual(me)
  return(getVisualizer(pHandVisID))
  exit
end

on print(me)
  repeat while me <= undefined
    tItem = getAt(undefined, undefined)
    put(tItem)
  end repeat
  exit
end

on setHandButton(me, tButtonID, tActive)
  if voidp(tButtonID) then
    return(0)
  end if
  if me = "next" then
    pNextActive = tActive
  else
    if me = "prev" then
      pPrevActive = tActive
    else
      return(0)
    end if
  end if
  exit
end

on update(me)
  if not visualizerExists(pHandVisID) then
    return(removeUpdate(me.getID()))
  end if
  tHand = getVisualizer(pHandVisID)
  tLocModX = pAnimLocs.getAt(pAnimFrm).getAt(1)
  tLocModY = pAnimLocs.getAt(pAnimFrm).getAt(2)
  if pAnimMode = #open then
    pAnimFrm = pAnimFrm + 1
    tHand.moveBy(tLocModX, tLocModY)
    if pAnimFrm > pAnimLocs.count then
      pAnimFrm = pAnimLocs.count
    end if
    if pAnimFrm = 4 then
      tHand.getSprById("room_hand").setMember(member(getmemnum("room_hand_2")))
      tHand.getSprById("room_hand_mask").blend = 100
    else
      if pAnimFrm = 6 then
        me.showContainerItems()
        tHand.getSprById("room_hand").setMember(member(getmemnum("room_hand_3")))
        tHand.getSprById("room_hand_mask").visible = 0
      end if
    end if
    if pAnimFrm = pAnimLocs.count then
      if pTotalCount > pItemList.count then
        me.setHandButtonsVisible()
      end if
      removeUpdate(me.getID())
    end if
  else
    pAnimFrm = pAnimFrm - 1
    if pAnimFrm < 1 then
      pAnimFrm = 1
    end if
    tHand.moveBy(-tLocModX, -tLocModY)
    if pAnimFrm = 4 then
      tHand.getSprById("room_hand").setMember(member(getmemnum("room_hand_1")))
      tHand.getSprById("room_hand_mask").visible = 0
      me.hideContainerItems()
    else
      if pAnimFrm = 6 then
        tHand.getSprById("room_hand").setMember(member(getmemnum("room_hand_2")))
        tHand.getSprById("room_hand_mask").visible = 1
      end if
    end if
    if pAnimFrm = 1 then
      removeVisualizer(pHandVisID)
      removeUpdate(me.getID())
    end if
  end if
  exit
end

on showContainerItems(me)
  if not visualizerExists(pHandVisID) then
    return(0)
  end if
  tHand = getVisualizer(pHandVisID)
  tList = me.getStripItem(#list)
  tCount = tList.count
  tAddRecyclerTags = 0
  tRecyclerThread = getThread(#recycler)
  if not tRecyclerThread = 0 and memberExists("recycler_icon_tag") then
    if tRecyclerThread.getComponent().isRecyclerOpenAndVisible() then
      tAddRecyclerTags = 1
    end if
  end if
  i = 1
  repeat while i <= 9
    if getmemnum("handcontainer_" & i) < 1 then
      createMember("handcontainer_" & i, #bitmap)
    end if
    tMem = getmemnum("handcontainer_" & i)
    tVisible = 1
    if i <= tCount then
      tItem = tList.getAt(i)
      tPreviewImage = getObject("Preview_renderer").renderPreviewImage(tItem.getAt(#member), void(), tItem.getAt(#colors), tItem.getAt(#class))
      tTempImage = image(tPreviewImage.width, tPreviewImage.height, 32)
      tTempImage.copyPixels(tPreviewImage, tPreviewImage.rect, tPreviewImage.rect)
      if voidp(tPreviewImage) then
        error(me, "Preview image was void!", #showContainerItems)
        return(0)
      end if
      if tAddRecyclerTags and integer(tItem.getAt(#isRecyclable)) = 1 then
        tRecyclableTagImg = getMember("recycler_icon_tag").image
        tRect = tRecyclableTagImg.rect
        tTempImage.copyPixels(tRecyclableTagImg, tRect, tRect, [#ink:36])
      end if
      member(tMem).image = tTempImage
      tInTrade = getThread(#room).getInterface().getSafeTrader().isUnderTrade(pItemList.getPropAt(i))
      tInRecycler = getThread(#recycler).getComponent().isFurniInRecycler(pItemList.getPropAt(i))
      tVisible = not tInTrade or tInRecycler
      if tVisible then
        if not tItem.getAt(#class) contains "post.it" then
          tVisible = not getThread(#room).getInterface().getObjectMover().pClientID = pItemList.getPropAt(i)
        end if
      end if
    else
      tMem = member(getmemnum("room_object_placeholder_sd"))
      tVisible = 0
    end if
    tSpr = tHand.getSprById("room_hand_item_" & i)
    if not voidp(tSpr) then
      tSpr.setMember(tMem)
      tSpr.blend = 100
      tSpr.visible = tVisible
      tSpr.ink = 8
    end if
    i = 1 + i
  end repeat
  me.setHandButtonsVisible()
  return(1)
  exit
end

on hideContainerItems(me)
  if not visualizerExists(pHandVisID) then
    return(0)
  end if
  tHand = getVisualizer(pHandVisID)
  i = 1
  repeat while i <= 9
    tSpr = tHand.getSprById("room_hand_item_" & i)
    if not voidp(tSpr) then
      tSpr.setMember(member(getmemnum("room_object_placeholder_sd")))
      tSpr.visible = 0
    end if
    i = 1 + i
  end repeat
  return(1)
  exit
end

on eventProcContainer(me, tEvent, tSprID, tParam)
  if tEvent <> #mouseUp then
    return(0)
  end if
  if me <> "placeActive" then
    if me = "placeItem" then
      getThread(#room).getInterface().stopObjectMover()
      return(getThread(#room).getComponent().getRoomConnection().send("GETSTRIP", "update"))
    else
      if me <> "moveActive" then
        if me = "moveItem" then
          if not getObject(#session).get("room_owner") then
            return(0)
          end if
          ttype = ["active":"stuff", "item":"item"].getAt(getThread(#room).getInterface().pSelectedType)
          tObj = getThread(#room).getInterface().pSelectedObj
          getThread(#room).getInterface().stopObjectMover()
          return(getThread(#room).getComponent().getRoomConnection().send("ADDSTRIPITEM", "new" && ttype && tObj))
        end if
        if tSprID contains "room_hand_item" then
          tItemNum = integer(tSprID.getProp(#char, 16))
          tStripList = me.getStripItem(#list)
          if tItemNum > tStripList.count then
            return(error(me, "Attempted to place unexisting strip item!", #eventProcContainer))
          end if
          tdata = tStripList.getAt(tItemNum)
          tItemID = tdata.getAt(#stripId)
          if tdata.getAt(#downloadLocked) then
            return(0)
          end if
          if getThread(#room).getInterface().getSafeTrader().isUnderTrade(tItemID) then
            return(0)
          end if
          if variableExists("handitem." & tdata.getAt(#class) & ".select_handler") then
            tSpecialHandler = symbol(getVariable("handitem." & tdata.getAt(#class) & ".select_handler"))
            if objectExists(tSpecialHandler) then
              call(#handItemSelect, getObject(tSpecialHandler), tdata)
              return()
            end if
          end if
          if me.placeItemToRoom(tItemID) then
            me.setItemPlacingMode(tdata)
          else
            getThread(#room).getInterface().pSelectedObj = ""
            getThread(#room).getInterface().pSelectedType = ""
            getThread(#room).getInterface().setProperty(#clickAction, "moveHuman")
          end if
          me.Refresh()
        end if
        exit
      end if
    end if
  end if
end

on startItemPlacing(me, tdata)
  if me.placeItemToRoom(tdata.getAt(#stripId)) then
    me.setItemPlacingMode(tdata)
    me.Refresh()
  end if
  exit
end

on setItemPlacingMode(me, tdata)
  tRoomInterface = getThread(#room).getInterface()
  tRoomInterface.pSelectedObj = tdata.getAt(#id)
  tRoomInterface.pSelectedType = tdata.getAt(#striptype)
  if tdata.getAt(#striptype) = "active" then
    tRoomInterface.startObjectMover(tdata.getAt(#id), tdata.getAt(#stripId), tdata)
    tRoomInterface.setProperty(#clickAction, "placeActive")
  else
    if tdata.getAt(#striptype) = "item" then
      tRoomInterface.startObjectMover(tdata.getAt(#id), tdata.getAt(#stripId), tdata)
      tRoomInterface.setProperty(#clickAction, "placeItem")
    end if
  end if
  exit
end

on setHandButtonsVisible(me, tVisible)
  if voidp(tVisible) then
    tVisible = 1
  end if
  if not windowExists(pHandButtonsWnd) then
    if not createWindow(pHandButtonsWnd, "habbo_hand_buttons.window") then
      return(0)
    end if
  end if
  tWndObj = getWindow(pHandButtonsWnd)
  if not tWndObj.elementExists("habbo_hand_next") or not tWndObj.elementExists("habbo_hand_next") then
    return(0)
  end if
  if tVisible then
    tWndObj.setProperty(#visible, 1)
    tStageRight = the stageRight - the stageLeft
    tTopOffset = 5
    tWndObj.moveTo(tStageRight - tWndObj.getProperty(#width) - 5, tTopOffset)
    if pNextActive then
      tWndObj.getElement("habbo_hand_next").Activate()
    else
      tWndObj.getElement("habbo_hand_next").deactivate()
    end if
    if pPrevActive then
      tWndObj.getElement("habbo_hand_prev").Activate()
    else
      tWndObj.getElement("habbo_hand_prev").deactivate()
    end if
    tWndObj.registerProcedure(#eventProcHandButtons, me.getID())
  else
    tWndObj.setProperty(#visible, 0)
  end if
  exit
end

on eventProcHandButtons(me, tEvent, tSprID, tParam)
  if tEvent <> #mouseUp then
    return(0)
  end if
  if me = "habbo_hand_next" then
    getThread(#room).getComponent().getRoomConnection().send("GETSTRIP", "next")
  else
    if me = "habbo_hand_prev" then
      getThread(#room).getComponent().getRoomConnection().send("GETSTRIP", "prev")
    else
      if me = "habbo_hand_close" then
        me.close()
      else
        return(0)
      end if
    end if
  end if
  exit
end