on construct(me)
  pWindowID = "ig_tooltip"
  return(1)
  exit
end

on deconstruct(me)
  me.removeTooltipWindow()
  return(1)
  exit
end

on handleEvent(me, tEvent, tSprID, tWndID, tKey)
  if tEvent = #mouseLeave then
    return(me.removeTooltipWindow())
  end if
  if tEvent <> #mouseEnter then
    return(1)
  end if
  if voidp(tKey) then
    tText = me.getTooltipText(tSprID)
    if tText = 0 then
      return(1)
    end if
  else
    tText = getText(tKey)
  end if
  tWndObj = getWindow(tWndID)
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement(tSprID)
  if tElem = 0 then
    return(0)
  end if
  tsprite = tElem.getProperty(#sprite)
  if tsprite = 0 then
    return(0)
  end if
  tLocX = tsprite.locH + tsprite.width / 2
  tLocY = tsprite.locV
  me.createTooltipWindow(tText, tLocX, tLocY)
  return(1)
  exit
end

on getTooltipText(me, tSprID)
  if tSprID.length < 4 then
    return(0)
  end if
  tKey = "ig_tooltip_" & tSprID.getProp(#char, 4, tSprID.length)
  if textExists(tKey) then
    return(getText(tKey))
  end if
  if tKey.getProp(#char, tKey.length - 1) = "_" then
    tKey = tKey.getProp(#char, 1, tKey.length - 2)
  end if
  if textExists(tKey) then
    return(getText(tKey))
  end if
  return(0)
  exit
end

on createTooltipWindow(me, tText, tLocX, tLocY)
  if windowExists(pWindowID) then
    me.removeTooltipWindow(pWindowID)
  end if
  createWindow(pWindowID, "ig_tooltip.window")
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("ig_tt_text")
  if tElem = 0 then
    return(0)
  end if
  tElem.setText(tText)
  tWndObj.moveTo(100, 100)
  tWndObj.moveTo(tLocX - tWndObj.getProperty(#width) / 2, tLocY - tWndObj.getProperty(#height))
  -- UNK_80 16898
  return(1)
  exit
end

on removeTooltipWindow(me)
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  exit
end