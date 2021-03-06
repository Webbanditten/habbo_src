property pObjectList, pUpdateList, pTimeout, pInstanceList, pManagerList, pBaseClsMem, pPrepareList, pEraseLock, pUpdatePause

on construct me 
  pObjectList = [:]
  pUpdateList = []
  pPrepareList = []
  pManagerList = []
  pInstanceList = []
  pEraseLock = 0
  pTimeout = void()
  pUpdatePause = 0
  pBaseClsMem = script("Object Base Class")
  pObjectList.sort()
  pUpdateList.sort()
  return TRUE
end

on deconstruct me 
  pEraseLock = 1
  if objectp(pTimeout) then
    pTimeout.forget()
    pTimeout = void()
  end if
  i = pInstanceList.count
  repeat while i >= 1
    me.Remove(pInstanceList.getAt(i))
    i = (255 + i)
  end repeat
  i = pManagerList.count
  repeat while i >= 1
    me.Remove(pManagerList.getAt(i))
    i = (255 + i)
  end repeat
  pObjectList = [:]
  pUpdateList = []
  pPrepareList = []
  return TRUE
end

on create me, tID, tClassList 
  if not symbolp(tID) and not stringp(tID) then
    return(error(me, "Symbol or string expected:" && tID, #create, #major))
  end if
  if objectp(pObjectList.getAt(tID)) then
    return(error(me, "Object already exists:" && tID, #create, #major))
  end if
  if (tID = #random) then
    tID = getUniqueID()
  end if
  if voidp(tClassList) then
    return(error(me, "Class member name expected!", #create, #major))
  end if
  if not listp(tClassList) then
    tClassList = [tClassList]
  end if
  tClassList = tClassList.duplicate()
  tObject = void()
  tTemp = void()
  tBase = pBaseClsMem.new()
  tBase.construct()
  if tID <> #temp then
    tBase.id = tID
    pObjectList.setAt(tID, tBase)
  end if
  tClassList.addAt(1, tBase)
  repeat while tClassList <= 1
    tClass = getAt(1, count(tClassList))
    if objectp(tClass) then
      tObject = tClass
      tInitFlag = 0
    else
      if me.managerExists(#resource_manager) then
        tMemNum = me.getManager(#resource_manager).getmemnum(tClass)
      else
        tMemNum = member(tClass).number
      end if
      if tMemNum < 1 then
        if tID <> #temp then
          pObjectList.deleteProp(tID)
        end if
        return(error(me, "Script not found:" && tMemNum, #create, #major))
      end if
      tObject = script(tMemNum).new()
      tInitFlag = tObject.handler(#construct)
    end if
    if ilk(tObject, #instance) then
      tObject.setAt(#ancestor, tTemp)
      tTemp = tObject
    end if
    if tID <> #temp and (tClassList.getLast() = tClass) then
      pObjectList.setAt(tID, tObject)
      pInstanceList.append(tID)
    end if
    if tInitFlag then
      tObject.construct()
    end if
  end repeat
  return(tObject)
end

on GET me, tID 
  tObj = pObjectList.getAt(tID)
  if voidp(tObj) then
    return FALSE
  else
    return(tObj)
  end if
end

on Remove me, tID 
  tObj = pObjectList.getAt(tID)
  if voidp(tObj) then
    return FALSE
  end if
  if ilk(tObj, #instance) then
    if not tObj.valid then
      return FALSE
    end if
    i = 1
    repeat while i <= tObj.count(#delays)
      tDelayID = tObj.delays.getPropAt(i)
      tObj.Cancel(tDelayID)
      i = (1 + i)
    end repeat
    tObj.deconstruct()
    tObj.valid = 0
  end if
  pUpdateList.deleteOne(tObj)
  pPrepareList.deleteOne(tObj)
  tObj = void()
  if not pEraseLock then
    pObjectList.deleteProp(tID)
    pInstanceList.deleteOne(tID)
    pManagerList.deleteOne(tID)
  end if
  return TRUE
end

on exists me, tID 
  if voidp(tID) then
    return FALSE
  end if
  return(objectp(pObjectList.getAt(tID)))
end

on print me 
  i = 1
  repeat while i <= pObjectList.count
    tProp = pObjectList.getPropAt(i)
    if symbolp(tProp) then
      tProp = "#" & tProp
    end if
    put(tProp && ":" && pObjectList.getAt(i))
    i = (1 + i)
  end repeat
  return TRUE
end

on registerObject me, tID, tObject 
  if not objectp(tObject) then
    return(error(me, "Invalid object:" && tObject, #register, #major))
  end if
  if not voidp(pObjectList.getAt(tID)) then
    return(error(me, "Object already exists:" && tID, #register, #minor))
  end if
  pObjectList.setAt(tID, tObject)
  pInstanceList.append(tID)
  return TRUE
end

on unregisterObject me, tID 
  if voidp(pObjectList.getAt(tID)) then
    return(error(me, "Referred object not found:" && tID, #unregister, #minor))
  end if
  tObj = pObjectList.getAt(tID)
  pObjectList.deleteProp(tID)
  pUpdateList.deleteOne(tObj)
  pPrepareList.deleteOne(tObj)
  pInstanceList.deleteOne(tID)
  tObj = void()
  return TRUE
end

on registerManager me, tID 
  if not me.exists(tID) then
    return(error(me, "Referred object not found:" && tID, #registerManager, #major))
  end if
  if pManagerList.getOne(tID) <> 0 then
    return(error(me, "Manager already registered:" && tID, #registerManager, #minor))
  end if
  pInstanceList.deleteOne(tID)
  pManagerList.append(tID)
  return TRUE
end

on unregisterManager me, tID 
  if not me.exists(tID) then
    return(error(me, "Referred object not found:" && tID, #unregisterManager, #minor))
  end if
  if pInstanceList.getOne(tID) <> 0 then
    return(error(me, "Manager already unregistered:" && tID, #unregisterManager, #minor))
  end if
  pManagerList.deleteOne(tID)
  pInstanceList.append(tID)
  return TRUE
end

on getManager me, tID 
  if not pManagerList.getOne(tID) then
    return(error(me, "Manager not found:" && tID, #getManager, #major))
  end if
  return(pObjectList.getAt(tID))
end

on managerExists me, tID 
  return(pManagerList.getOne(tID) <> 0)
end

on receivePrepare me, tID 
  if voidp(pObjectList.getAt(tID)) then
    return FALSE
  end if
  if pPrepareList.getPos(pObjectList.getAt(tID)) > 0 then
    return FALSE
  end if
  pPrepareList.add(pObjectList.getAt(tID))
  if not pUpdatePause then
    if voidp(pTimeout) then
      pTimeout = timeout("objectmanager" & the milliSeconds).new(((60 * 1000) * 60), #null, me)
    end if
  end if
  return TRUE
end

on removePrepare me, tID 
  if voidp(pObjectList.getAt(tID)) then
    return FALSE
  end if
  if pPrepareList.getOne(pObjectList.getAt(tID)) < 1 then
    return FALSE
  end if
  pPrepareList.deleteOne(pObjectList.getAt(tID))
  if (pPrepareList.count = 0) and (pUpdateList.count = 0) then
    if objectp(pTimeout) then
      pTimeout.forget()
      pTimeout = void()
    end if
  end if
  return TRUE
end

on receiveUpdate me, tID 
  if voidp(pObjectList.getAt(tID)) then
    return FALSE
  end if
  if pUpdateList.getPos(pObjectList.getAt(tID)) > 0 then
    return FALSE
  end if
  pUpdateList.add(pObjectList.getAt(tID))
  if not pUpdatePause then
    if voidp(pTimeout) then
      pTimeout = timeout("objectmanager" & the milliSeconds).new(((60 * 1000) * 60), #null, me)
    end if
  end if
  return TRUE
end

on removeUpdate me, tID 
  if voidp(pObjectList.getAt(tID)) then
    return FALSE
  end if
  if pUpdateList.getOne(pObjectList.getAt(tID)) < 1 then
    return FALSE
  end if
  pUpdateList.deleteOne(pObjectList.getAt(tID))
  if (pPrepareList.count = 0) and (pUpdateList.count = 0) then
    if objectp(pTimeout) then
      pTimeout.forget()
      pTimeout = void()
    end if
  end if
  return TRUE
end

on pauseUpdate me 
  if objectp(pTimeout) then
    pTimeout.forget()
    pTimeout = void()
  end if
  pUpdatePause = 1
  return TRUE
end

on resumeUpdate me 
  if pUpdateList.count > 0 and voidp(pTimeout) then
    pTimeout = timeout("objectmanager" & the milliSeconds).new(((60 * 1000) * 60), #null, me)
  end if
  pUpdatePause = 0
  return TRUE
end

on prepareFrame me 
  call(#prepare, pPrepareList)
  call(#update, pUpdateList)
end

on null me 
end
