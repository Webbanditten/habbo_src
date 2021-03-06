on render me 
  me.ancestor.render(me)
  tService = me.getIGComponent("GameList")
  if (tService = 0) then
    return FALSE
  end if
  tItemRef = tService.getObservedGame()
  if (tItemRef = 0) then
    return FALSE
  end if
  tWndObj = getWindow(me.getWindowId("btm"))
  if (tWndObj = 0) then
    return FALSE
  end if
  tWndObj.unmerge()
  tWndObj.resizeTo(0, 0)
  tWndObj = getWindow(me.getWindowId("spec"))
  if (tWndObj = 0) then
    return FALSE
  end if
  tWndObj.unmerge()
  tWndObj.merge("ig_duration.window")
  me.renderDuration((tItemRef.getProperty(#duration) / 60))
  tWrapObjRef = me.getWindowWrapper()
  if (tWrapObjRef = 0) then
    return FALSE
  end if
  tWrapObjRef.render()
  return TRUE
end

on renderDuration me, tValue 
  tWndObj = getWindow(me.getWindowId("spec"))
  if (tWndObj = 0) then
    return FALSE
  end if
  repeat while [2, 3, 5] <= undefined
    i = getAt(undefined, tValue)
    tElement = tWndObj.getElement("ig_game_drt_" & i)
    if tElement <> 0 then
      tElement.setProperty(#blend, (0 + ((i = tValue) * 100)))
    end if
  end repeat
end
