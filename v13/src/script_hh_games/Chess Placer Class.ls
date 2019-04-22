on Init(me, tMem, tlocz, tPieceData, tGameBoardSpr)
  pSpr = sprite(reserveSprite(me.getID()))
  setEventBroker(pSpr.spriteNum, me.getID())
  call(#registerClient, pSpr.scriptInstanceList, me)
  call(#registerProcedure, pSpr.scriptInstanceList, #eventProcChessPlacer, me.getID(), #mouseUp)
  pSpr.ink = 8
  pSpr.locZ = tlocz
  pSpr.member = tMem
  pGameBoardSpr = tGameBoardSpr
  pPieceData = tPieceData
  receiveUpdate(me.getID())
  exit
end

on deconstruct(me)
  removeUpdate(me.getID())
  releaseSprite(pSpr.spriteNum)
  pSpr = void()
  exit
end

on eventProcChessPlacer(me, tEvent, tSprID, tParam)
  pSpr.visible = 0
  tsprite = rollover()
  pSpr.visible = 1
  tid = call(#getID, sprite(tsprite).scriptInstanceList)
  if tid = "close" then
    getThread(#games).getInterface().eventProcChess(tEvent, tid)
  end if
  exit
end

on update(me)
  pSpr.loc = the mouseLoc
  if pSpr.intersects(pGameBoardSpr.spriteNum) then
    pSpr.blend = 100
  else
    pSpr.blend = 40
  end if
  if the mouseDown and pSpr.intersects(pGameBoardSpr.spriteNum) then
    tloc = point(abs(pGameBoardSpr.locH - pSpr.locH), abs(pGameBoardSpr.locV - pSpr.locV))
    if getThread(#games).getInterface().makeMoveChess(tloc, pPieceData) then
      removeObject(me.getID())
    end if
  end if
  exit
end