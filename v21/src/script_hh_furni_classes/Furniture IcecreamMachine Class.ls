on prepare(me, tdata)
  pUserClicked = 0
  pLastDir = -1
  pSync = 0
  return(1)
  exit
end

on updateStuffdata(me, tValue)
  pAnimFrame = 1
  pActive = 1
  exit
end

on update(me)
  if pActive then
    pSync = pSync + 1
    if pSync < 3 then
      return(1)
    end if
    pSync = 0
    if me.count(#pSprList) < 5 then
      return(0)
    end if
    if pAnimFrame > 0 then
      if me = 1 then
        me.switchMember("a", "1")
      else
        if me = 2 then
          me.switchMember("d", "1")
        else
          if me = 3 then
            me.switchMember("d", "2")
          else
            if me = 4 then
              me.switchMember("d", "3")
            else
              if me = 5 then
                me.switchMember("d", "4")
              else
                if me = 6 then
                  me.switchMember("d", "5")
                else
                  if me = 7 then
                    me.switchMember("a", "0")
                  else
                    if me = 8 then
                      if pUserClicked then
                        me.giveDrink()
                      end if
                      pUserClicked = 0
                    else
                      if me = 9 then
                        me.switchMember("d", "6")
                      else
                        if me = 15 then
                          me.switchMember("d", "0")
                          pAnimFrame = 0
                          pActive = 0
                          return(1)
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
      pAnimFrame = pAnimFrame + 1
    end if
  end if
  exit
end

on switchMember(me, tPart, tNewMem)
  tSprNum = ["a", "b", "c", "d", "e", "f"].getPos(tPart)
  if me.count(#pSprList) < tSprNum or tSprNum = 0 then
    return(0)
  end if
  tName = member.name
  tName = tName.getProp(#char, 1, tName.length - 1) & tNewMem
  if memberExists(tName) then
    tmember = member(getmemnum(tName))
    me.getPropRef(#pSprList, tSprNum).castNum = tmember.number
    me.getPropRef(#pSprList, tSprNum).width = tmember.width
    me.getPropRef(#pSprList, tSprNum).height = tmember.height
  end if
  exit
end

on select(me)
  tUserObj = getThread(#room).getComponent().getOwnUser()
  if tUserObj = 0 then
    return(1)
  end if
  tCarrying = tUserObj.getProperty(#carrying)
  tloc = tUserObj.getProperty(#loc)
  tLocX = tloc.getAt(1)
  tLocY = tloc.getAt(2)
  if me = 4 then
    if me.pLocX = tLocX and me.pLocY - tLocY = -1 then
      if the doubleClick and not tCarrying then
        me.setAnimation()
      end if
    else
      getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:me.pLocY + 1])
    end if
  else
    if me = 0 then
      if me.pLocX = tLocX and me.pLocY - tLocY = 1 then
        if the doubleClick and not tCarrying then
          me.setAnimation()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:me.pLocY - 1])
      end if
    else
      if me = 2 then
        if me.pLocY = tLocY and me.pLocX - tLocX = -1 then
          if the doubleClick and not tCarrying then
            me.setAnimation()
          end if
        else
          getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX + 1, #short:me.pLocY])
        end if
      else
        if me = 6 then
          if me.pLocY = tLocY and me.pLocX - tLocX = 1 then
            if the doubleClick and not tCarrying then
              me.setAnimation()
            end if
          else
            getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX - 1, #short:me.pLocY])
          end if
        end if
      end if
    end if
  end if
  return(1)
  exit
end

on setAnimation(me)
  if pActive = 1 then
    return(1)
  end if
  pUserClicked = 1
  tConnection = getThread(#room).getComponent().getRoomConnection()
  if tConnection = 0 then
    return(0)
  end if
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:"TRUE"])
  tConnection.send("LOOKTO", me.pLocX && me.pLocY)
  exit
end

on giveDrink(me)
  tConnection = getThread(#room).getComponent().getRoomConnection()
  if tConnection = 0 then
    return(0)
  end if
  tClass = me.pClass
  if tClass contains "*" then
    tClass = tClass.getProp(#char, 1, offset("*", tClass) - 1)
  end if
  tToken = value(getVariable("obj_" & tClass))
  if not listp(tToken) then
    tToken = [4]
  end if
  tToken = tToken.getAt(1)
  tConnection.send("CARRYDRINK", tToken)
  exit
end