on construct(me)
  pConnectionId = getVariable("connection.mus.id", #mus)
  pTimeOutID = "mus_close_delay"
  pCallBacks = []
  pQueue = []
  return(me.registerCmds(1))
  exit
end

on deconstruct(me)
  me.registerCmds(0)
  return(removeMultiuser(pConnectionId))
  exit
end

on retrieveData(me, tid, tAuth, tCallBackObj)
  pQueue.add([#type:#retrieve, #id:tid, #auth:tAuth, #callback:tCallBackObj])
  if count(pQueue) = 1 or not multiuserExists(pConnectionId) then
    me.next()
  end if
  exit
end

on storeData(me, tdata, tCallBackObj)
  pQueue.add([#type:#store, #data:tdata, #callback:tCallBackObj])
  if count(pQueue) = 1 or not multiuserExists(pConnectionId) then
    me.next()
  end if
  exit
end

on addMessageToQueue(me, tMsg)
  pQueue.add([#type:#fusemsg, #message:tMsg])
  if count(pQueue) = 1 or not multiuserExists(pConnectionId) then
    me.next()
  end if
  exit
end

on checkConnection(me)
  if not multiuserExists(pConnectionId) then
    return(error(me, "MUS connection not found:" && pConnectionId, #checkConnection))
  end if
  if getMultiuser(pConnectionId).connectionReady() then
    getMultiuser(pConnectionId).send("LOGIN" && getObject(#session).get(#userName) && getObject(#session).get(#password))
    me.next()
  else
    me.delay(1000, #checkConnection)
  end if
  exit
end

on next(me)
  if not multiuserExists(pConnectionId) then
    createMultiuser(pConnectionId, getVariable("connection.mus.host"), getIntVariable("connection.mus.port"))
    getMultiuser(pConnectionId).registerBinaryDataHandler(me.getID(), #binaryDataReceived)
    me.delay(1000, #checkConnection)
  else
    if getMultiuser(pConnectionId).connectionReady() then
      if timeoutExists(pTimeOutID) then
        removeTimeout(pTimeOutID)
      end if
      if count(pQueue) > 0 then
        tTask = pQueue.getAt(1)
        if me = #store then
          return(getMultiuser(pConnectionId).sendBinary(tTask.data))
        else
          if me = #retrieve then
            return(getMultiuser(pConnectionId).send("GETBINDATA" && tTask.id && tTask.auth))
          else
            if me = #fusemsg then
              pQueue.deleteAt(1)
              getMultiuser(pConnectionId).send(tTask.message)
              me.next()
              return(1)
            end if
          end if
        end if
      else
        createTimeout(pTimeOutID, 30000, #delayedClosing, me.getID(), void(), 1)
      end if
    end if
  end if
  exit
end

on binaryDataStored(me, tMsg)
  tTask = pQueue.getAt(1)
  if tTask.getAt(#callback) <> void() then
    tObject = getObject(tTask.getAt(#callback))
    if tObject.ilk = #instance then
      call(#binaryDataStored, tObject, tMsg.getaProp(#content))
    end if
  end if
  pQueue.deleteAt(1)
  me.next()
  exit
end

on binaryDataAuthKeyError(me)
  pQueue.deleteAt(1)
  me.next()
  exit
end

on binaryDataReceived(me, tdata)
  tTask = pQueue.getAt(1)
  pQueue.deleteAt(1)
  if tTask.getAt(#callback) <> void() then
    tObject = getObject(tTask.getAt(#callback))
    if tObject.ilk = #instance then
      call(#binaryDataReceived, tObject, tdata, tTask.getAt(#id))
    end if
  end if
  me.next()
  exit
end

on delayedClosing(me)
  if multiuserExists(pConnectionId) and count(pQueue) = 0 then
    removeMultiuser(pConnectionId)
  end if
  exit
end

on registerCmds(me, tBool)
  tList = []
  tList.setAt("BINDATA_SAVED", #binaryDataStored)
  tList.setAt("BINDATA_AUTHKEYERROR", #binaryDataAuthKeyError)
  tList.setAt("DISCONNECT", #deconstruct)
  tList.setAt("HELLO", #foo)
  tList.setAt("U_RTS", #foo)
  if tBool then
    return(getMultiuserManager().registerListener(pConnectionId, me.getID(), tList))
  else
    return(getMultiuserManager().unregisterListener(pConnectionId, me.getID(), tList))
  end if
  exit
end

on foo(me)
  exit
end