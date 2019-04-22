on constructTimeoutManager()
  return(createManager(#timeout_manager, getClassVariable("timeout.manager.class")))
  exit
end

on deconstructTimeoutManager()
  return(removeManager(#timeout_manager))
  exit
end

on getTimeoutManager()
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#timeout_manager) then
    return(constructTimeoutManager())
  end if
  return(tObjMngr.getManager(#timeout_manager))
  exit
end

on createTimeout(tid, tTime, tHandler, tClientID, tArguments, tIterations)
  return(getTimeoutManager().create(tid, tTime, tHandler, tClientID, tArguments, tIterations))
  exit
end

on removeTimeout(tid)
  return(getTimeoutManager().remove(tid))
  exit
end

on getTimeout(tid)
  return(getTimeoutManager().get(tid))
  exit
end

on timeoutExists(tid)
  return(getTimeoutManager().exists(tid))
  exit
end

on printTimeouts()
  return(getTimeoutManager().print())
  exit
end