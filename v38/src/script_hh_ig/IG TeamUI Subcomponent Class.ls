property pFlagManagerId, pFlagIdPrefix

on construct me 
  pFlagIdPrefix = "fg"
  return(me.ancestor.construct())
end

on deconstruct me 
  tFlagManager = me.getFlagManager()
  if tFlagManager <> 0 then
    tFlagManager.removeFlagSet(me.pID)
  end if
  return(me.ancestor.deconstruct())
end

on setInfoFlag me, tID, tWndID, tElemID, tFlagType, tColor, tItemInfo 
  tFlagManager = me.getFlagManager()
  if (tFlagManager = 0) then
    return FALSE
  end if
  return(tFlagManager.setInfoFlag(me.pID, tID, tWndID, tElemID, tFlagType, tColor, tItemInfo))
end

on existsFlagObject me, tID 
  tFlagManager = me.getFlagManager()
  if (tFlagManager = 0) then
    return FALSE
  end if
  return(tFlagManager.exists(tID))
end

on removeFlagObject me, tID 
  tFlagManager = me.getFlagManager()
  if (tFlagManager = 0) then
    return FALSE
  end if
  return(tFlagManager.Remove(tID))
end

on getFlagManager me 
  if (pFlagManagerId = void()) then
    return FALSE
  end if
  return(getObject(pFlagManagerId))
end

on getBasicFlagId me 
  return(me.getWindowId() & "_" & pFlagIdPrefix)
end

on setTeamColorBackground me, tWndID, tTeamIndex 
  tWndObj = getWindow(tWndID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("ig_title_bg_dark")
  if tElem <> 0 then
    tColor = me.getTeamColorDark(tTeamIndex)
    if (tColor.ilk = #color) then
      tElem.setProperty(#bgColor, tColor)
    end if
  end if
  tElem = tWndObj.getElement("ig_title_bg_light")
  if tElem <> 0 then
    tColor = me.getTeamColorLight(tTeamIndex)
    if (tColor.ilk = #color) then
      tElem.setProperty(#bgColor, tColor)
    end if
  end if
  return TRUE
end

on getTeamColorDark me, tTeamIndex 
  if (tTeamIndex = 1) then
    return(rgb("#c64000"))
  else
    if (tTeamIndex = 2) then
      return(rgb("#1971c3"))
    else
      if (tTeamIndex = 3) then
        return(rgb("#659217"))
      else
        if (tTeamIndex = 4) then
          return(rgb("#e19f00"))
        end if
      end if
    end if
  end if
end

on getTeamColorLight me, tTeamIndex 
  if (tTeamIndex = 1) then
    return(rgb("#e86a3c"))
  else
    if (tTeamIndex = 2) then
      return(rgb("#4696e1"))
    else
      if (tTeamIndex = 3) then
        return(rgb("#91b159"))
      else
        if (tTeamIndex = 4) then
          return(rgb("#fcc02d"))
        end if
      end if
    end if
  end if
end
