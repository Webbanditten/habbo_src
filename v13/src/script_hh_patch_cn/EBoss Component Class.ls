property pUserId

on construct me 
  registerMessage(#partnerRegistrationRequired, me.getID(), #partnerRegistrationRequired)
  registerMessage(#partnerRegistration, me.getID(), #partnerRegistration)
  pUserId = ""
  return TRUE
end

on deconstruct me 
  unregisterMessage(#partnerRegistrationRequired, me.getID())
  unregisterMessage(#partnerRegistration, me.getID())
  return TRUE
end

on login me 
  if not connectionExists(getVariable("connection.info.id")) then
    executeMessage(#openConnection)
  else
    tConn = getConnection(getVariable("connection.info.id"))
    executeMessage(#performLogin, tConn)
  end if
end

on handlePartnerRegistration me, tMsg 
  executeMessage(#hideLogin)
  me.partnerRegistration(tMsg)
  executeMessage(#closeConnection)
end

on partnerRegistrationRequired me, tArg 
  tSession = getObject(#session)
  tPartnerRegistration = tSession.get("conf_partner_integration")
  if (ilk(tArg) = #propList) then
    tArg.setAt("retval", tPartnerRegistration)
  end if
  return(tPartnerRegistration)
end

on partnerRegistration me, tUserID 
  pUserId = tUserID
  me.showDialog()
end

on showDialog me 
  me.getInterface().showDialog()
end

on userID me 
  return(pUserId)
end
