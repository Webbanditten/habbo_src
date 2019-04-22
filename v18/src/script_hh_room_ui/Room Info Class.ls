on construct(me)
  pWindowID = "RoomInfoWindow"
  registerMessage(#roomRatingChanged, me.getID(), #updateRatingData)
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on showRoomInfo(me)
  if getThread(#room).getComponent().getRoomData().type = #private then
    tWndObj = me.createInfoWindow()
    if tWndObj = 0 then
      return(0)
    end if
    tRoomData = getThread(#room).getComponent().pSaveData
    tWndObj.getElement("room_info_room_name").setText(tRoomData.getAt(#name))
    tWndObj.getElement("room_info_owner").setText(getText("room_owner") && tRoomData.getAt(#owner))
    me.updateRatingData()
  else
    me.hideRoomInfo()
  end if
  exit
end

on hideRoomInfo(me)
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  exit
end

on createInfoWindow(me)
  if not windowExists(pWindowID) then
    tSuccess = createWindow(pWindowID, "room_info.window", 10, 420)
    if tSuccess = 0 then
      return(0)
    else
      tWndObj = getWindow(pWindowID)
      tWndObj.lock()
      tWndObj.registerProcedure(#eventProcInfo, me.getID())
      return(tWndObj)
    end if
  else
    return(getWindow(pWindowID))
  end if
  exit
end

on sendFlatRate(me, tValue)
  getThread(#room).getComponent().getRoomConnection().send("RATEFLAT", [#integer:tValue])
  exit
end

on updateRatingData(me)
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tRoomRatings = getThread(#room).getComponent().getRoomRating()
  if tRoomRatings.getAt(#rate) = -1 then
    tWndObj.getElement("room_info_rate_plus").setProperty(#visible, 1)
    tWndObj.getElement("room_info_rate_minus").setProperty(#visible, 1)
    tWndObj.getElement("room_info_rate_room").setProperty(#visible, 1)
    tWndObj.getElement("room_info_rate_value").setProperty(#visible, 0)
  else
    tWndObj.getElement("room_info_rate_plus").setProperty(#visible, 0)
    tWndObj.getElement("room_info_rate_minus").setProperty(#visible, 0)
    tWndObj.getElement("room_info_rate_room").setProperty(#visible, 0)
    tWndObj.getElement("room_info_rate_value").setProperty(#visible, 1)
    tRateText = getText("room_info_rated") && tRoomRatings.getAt(#rate)
    tWndObj.getElement("room_info_rate_value").setText(tRateText)
  end if
  exit
end

on eventProcInfo(me, tEvent, tSprID, tParam)
  if tEvent <> #mouseUp then
    return(0)
  end if
  if me = "room_info_rate_plus" then
    me.sendFlatRate(1)
  else
    if me = "room_info_rate_minus" then
      me.sendFlatRate(-1)
    end if
  end if
  exit
end