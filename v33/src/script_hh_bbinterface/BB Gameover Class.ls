property pWriterPlainNormLeft, pWriterLinkRight, pOpenWindow, pScoreData, pWindowID, pTimeOutID, pJoinedPlayers, pCountdownEndTime

on construct me 
  pJoinedPlayers = []
  pWindowID = getText("gs_title_finalscores")
  pTimeOutID = "bb_endgame_resetGameTimeout"
  createWriter("bb_plain_norm_left", getStructVariable("struct.font.plain"))
  pWriterPlainNormLeft = getWriter("bb_plain_norm_left")
  pWriterPlainNormLeft.define([#wordWrap:0, #fixedLineSpace:16])
  createWriter("bb_plain_bold_left", getStructVariable("struct.font.bold"))
  pWriterPlainBoldLeft = getWriter("bb_plain_bold_left")
  createWriter("bb_link_right", getStructVariable("struct.font.link"))
  pWriterLinkRight = getWriter("bb_link_right")
  pWriterLinkRight.setProperty(#alignment, #right)
  registerMessage(#remove_user, me.getID(), #showRemovedPlayer)
  return TRUE
end

on deconstruct me 
  me.removeFinalScores()
  removeWriter("bb_plain_norm_left")
  pWriterPlainNormLeft = void()
  removeWriter("bb_plain_bold_left")
  pWriterPlainBoldLeft = void()
  removeWriter("bb_link_right")
  pWriterLinkRight = void()
  unregisterMessage(#remove_user, me.getID())
  return TRUE
end

on Refresh me, tTopic, tdata 
  if (tTopic = #gameend) then
    pJoinedPlayers = []
    me.saveSortedScores(tdata)
    me.startResetCountdown(tdata.getAt(#time_until_game_reset))
    me.toggleWindowMode()
  else
    if (tTopic = #gamereset) then
      me.removeFinalScores()
    else
      if (tTopic = #playerrejoined) then
        me.showJoinedPlayer(tdata)
      else
        if (tTopic = #numtickets) then
          me.renderNumTickets()
        end if
      end if
    end if
  end if
  return TRUE
end

on toggleWindowMode me 
  if (pOpenWindow = void()) or (pOpenWindow = "bb_score_tiny.window") then
    if not listp(pScoreData) then
      return FALSE
    end if
    tTeamNum = pScoreData.count
    pOpenWindow = "bb_score_big_" & tTeamNum & "t.window"
    if not createWindow(pWindowID, pOpenWindow) then
      return(error(me, "Cannot open score window.", #toggleWindowMode))
    end if
    me.renderFinalScoresText()
    tWndObj = getWindow(pWindowID)
    if me.getGameSystem().getSpectatorModeFlag() then
      tWndObj.moveTo(124, 74)
    else
      tWndObj.moveTo(124, 50)
    end if
  else
    pOpenWindow = "bb_score_tiny.window"
    if not createWindow(pWindowID, pOpenWindow) then
      return(error(me, "Cannot open score window.", #toggleWindowMode))
    end if
    tWndObj = getWindow(pWindowID)
    if me.getGameSystem().getSpectatorModeFlag() then
      tWndObj.moveTo(41, 50)
    else
      tWndObj.moveTo(25, 26)
    end if
  end if
  tWndObj.lock()
  tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
  me.showJoinedPlayersNum()
  me.renderCountdownTimer()
  me.renderNumTickets()
  return TRUE
end

on removeFinalScores me 
  pCountdownEndTime = void()
  pOpenWindow = void()
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  return TRUE
end

on renderNumTickets me 
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("bb_ticketAmount_text")
  if (tElem = 0) then
    return FALSE
  end if
  if (me.getGameSystem() = 0) then
    return FALSE
  end if
  tNumTickets = string(me.getGameSystem().getNumTickets())
  if (tNumTickets.length = 1) then
    tNumTickets = "00" & tNumTickets
  end if
  if (tNumTickets.length = 2) then
    tNumTickets = "0" & tNumTickets
  end if
  tElem.setText(tNumTickets)
end

on saveSortedScores me, tdata 
  pScoreData = tdata.getAt(#gameend_scores)
  tSortedTeams = []
  tTeamNum = pScoreData.count
  tTeamId = 1
  repeat while tTeamId <= tTeamNum
    tdata = pScoreData.getAt(tTeamId)
    tSortedPlayers = []
    tPlayerNum = 1
    repeat while tPlayerNum <= tdata.getAt(#players).count
      tPos = 1
      if tSortedPlayers.count > 0 then
        repeat while tSortedPlayers.getAt(tPos) > tdata.getAt(#players).getAt(tPlayerNum)
          tPos = (tPos + 1)
          if tPos > tSortedPlayers.count then
          else
          end if
        end repeat
      end if
      tSortedPlayers.addAt(tPos, [#id:tdata.getAt(#players).getPropAt(tPlayerNum), #score:tdata.getAt(#players).getAt(tPlayerNum).getAt(#score)])
      tPlayerNum = (1 + tPlayerNum)
    end repeat
    tPos = 1
    if tSortedTeams.count > 0 then
      repeat while tSortedTeams.getAt(tPos).getAt(#score) > tdata.getAt(#score)
        tPos = (tPos + 1)
        if tPos > tSortedTeams.count then
        else
        end if
      end repeat
    end if
    tSortedTeams.addAt(tPos, [#score:tdata.getAt(#score), #id:tTeamId, #players:tSortedPlayers])
    tTeamId = (1 + tTeamId)
  end repeat
  pScoreData = tSortedTeams
  return TRUE
end

on renderFinalScoresText me 
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  if me.getGameSystem().getSpectatorModeFlag() then
    repeat while ["bb_button_playAgn", "bb_button_leaveGam2", "gs_button_buytickets"] <= undefined
      tButtonID = getAt(undefined, undefined)
      tWndObj.getElement(tButtonID).hide()
    end repeat
  end if
  tRoomComponent = getObject(#room_component)
  if (tRoomComponent = 0) then
    return FALSE
  end if
  tTeamNum = pScoreData.count
  tBestPlayer = [#id:0, #score:0]
  tTeamId = 1
  repeat while tTeamId <= tTeamNum
    tdata = pScoreData.getAt(tTeamId)
    tElem = tWndObj.getElement("bb_win_bigScores_ball" & tTeamId)
    tImage = member(getmemnum("bb_ico_ball" & tdata.getAt(#id))).image
    if tElem <> 0 and tImage <> void() then
      tElem.feedImage(tImage)
    end if
    tElem = tWndObj.getElement("bb_score_team" & tTeamId)
    if tElem <> 0 then
      tElem.setText(tdata.getAt(#score))
    end if
    tImage = me.renderFinalScoreItem(tdata)
    tElem = tWndObj.getElement("bb_area_scores" & tTeamId)
    if tImage <> 0 then
      tElem.feedImage(tImage)
    end if
    tPlayerNum = 1
    repeat while tPlayerNum <= tdata.getAt(#players).count
      if tdata.getAt(#players).getAt(tPlayerNum).getAt(#score) > tBestPlayer.getAt(#score) then
        tTie = 0
        tBestPlayer.setAt(#id, tdata.getAt(#players).getAt(tPlayerNum).getAt(#id))
        tBestPlayer.setAt(#score, tdata.getAt(#players).getAt(tPlayerNum).getAt(#score))
      else
        if (tdata.getAt(#players).getAt(tPlayerNum).getAt(#score) = tBestPlayer.getAt(#score)) then
          tTie = 1
        end if
      end if
      tPlayerNum = (1 + tPlayerNum)
    end repeat
    tTeamId = (1 + tTeamId)
  end repeat
  if not tTie then
    tElem = tWndObj.getElement("gs_bestplayer_name")
    if tElem <> 0 then
      tUserObj = tRoomComponent.getUserObject(tBestPlayer.getAt(#id))
      if tUserObj <> 0 then
        tTempImage = tUserObj.getPicture()
        tPlayerImage = image(32, 62, 32)
        if (ilk(tTempImage) = #image) then
          tPlayerImage.copyPixels(tTempImage, (tTempImage.rect + rect(7, -7, 7, -7)), tTempImage.rect)
        end if
        tElem.setText(tUserObj.getName())
        tElem = tWndObj.getElement("gs_bestplayer_score")
        tElem.setText(tBestPlayer.getAt(#score))
      end if
    end if
  else
    tElem = tWndObj.getElement("gs_bestplayer_title")
    if tElem <> 0 then
      tElem.setText(getText("gs_score_tie"))
    end if
  end if
  tElem = tWndObj.getElement("bb_icon_winner")
  if tElem <> 0 then
    if not (ilk(tPlayerImage) = #image) then
      tPlayerImage = member(getmemnum("guide_tie")).image
      tElem.moveBy(0, 6)
    end if
    tElem.feedImage(tPlayerImage)
  end if
  return TRUE
end

on renderFinalScoreItem me, tTeam 
  tRoomComponent = getObject(#room_component)
  if (tRoomComponent = 0) then
    return FALSE
  end if
  tNameTxt = ""
  tScoreTxt = ""
  tImage = image(165, (tTeam.getAt(#players).count * 16), 32)
  tPlayerNum = 1
  repeat while tPlayerNum <= tTeam.getAt(#players).count
    tScoreTxt = tScoreTxt & tTeam.getAt(#players).getAt(tPlayerNum).getAt(#score) & "\r"
    tPlayerObj = tRoomComponent.getUserObject(tTeam.getAt(#players).getAt(tPlayerNum).getAt(#id))
    if tPlayerObj <> 0 then
      tNameTxt = tNameTxt & tPlayerObj.getName() & "\r"
    end if
    tPlayerNum = (1 + tPlayerNum)
  end repeat
  tOffset = 0
  if variableExists("bb_menu_nameandscore_voffset") then
    tOffset = getVariable("bb_menu_nameandscore_voffset")
  end if
  tNameImage = pWriterPlainNormLeft.render(tNameTxt)
  tImage.copyPixels(tNameImage, (tNameImage.rect + rect(6, (-5 + tOffset), 6, (-5 + tOffset))), tNameImage.rect)
  tScoreImage = pWriterPlainNormLeft.render(tScoreTxt)
  tImage.copyPixels(tScoreImage, (tScoreImage.rect + rect(130, (-5 + tOffset), 130, (-5 + tOffset))), tScoreImage.rect)
  return(tImage)
end

on showJoinedPlayer me, tdata 
  tStrId = string(tdata.getAt(#id))
  if (pJoinedPlayers.findPos(tStrId) = 0) then
    pJoinedPlayers.add(tStrId)
  end if
  me.showPlayerIcon(#joined, tdata)
  me.showJoinedPlayersNum()
  return TRUE
end

on showRemovedPlayer me, tStrId 
  if (pJoinedPlayers.findPos(tStrId) = 0) then
    return FALSE
  end if
  pJoinedPlayers.deleteOne(tStrId)
  me.showPlayerIcon(0, [#id:tStrId])
  me.showJoinedPlayersNum()
  return TRUE
end

on showPlayerIcon me, tIcon, tdata 
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tStrId = string(tdata.getAt(#id))
  if (pScoreData = void()) then
    return FALSE
  end if
  tTeamNum = 1
  repeat while tTeamNum <= pScoreData.count
    tPlayerNum = 1
    repeat while tPlayerNum <= pScoreData.getAt(tTeamNum).getAt(#players).count
      if (pScoreData.getAt(tTeamNum).getAt(#players).getAt(tPlayerNum).getAt(#id) = tdata.getAt(#id)) then
        tMyTeamNum = tTeamNum
        tMyPlayerNum = tPlayerNum
      end if
      tPlayerNum = (1 + tPlayerNum)
    end repeat
    tTeamNum = (1 + tTeamNum)
  end repeat
  tElem = tWndObj.getElement("bb_area_scores" & tMyTeamNum)
  if (tElem = 0) then
    return FALSE
  end if
  tImage = tElem.getProperty(#image)
  if (tIcon = #joined) then
    tStarImg = member(getmemnum("bb_ico_star_lt")).image
  else
    tStarImg = image(11, 9, 8)
  end if
  tImage.copyPixels(tStarImg, (tStarImg.rect + rect(109, (1 + (16 * (tMyPlayerNum - 1))), 109, (1 + (16 * (tMyPlayerNum - 1))))), tStarImg.rect)
  tElem.feedImage(tImage)
  return TRUE
end

on showJoinedPlayersNum me 
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("bb_info_joinedPlrs")
  if (tElem = 0) then
    return FALSE
  end if
  return(tElem.setText(replaceChunks(getText("gs_joinedplayers"), "\\x", pJoinedPlayers.count)))
end

on startResetCountdown me, tSecondsLeft 
  if tSecondsLeft <= 0 then
    return FALSE
  end if
  pCountdownEndTime = (the milliSeconds + (tSecondsLeft * 1000))
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  createTimeout(pTimeOutID, 1000, #renderCountdownTimer, me.getID(), pCountdownEndTime, tSecondsLeft)
  me.renderCountdownTimer()
  return TRUE
end

on convertToMinSec me, tTime 
  tMin = (tTime / 60000)
  tSec = ((tTime mod 60000) / 1000)
  if tSec < 10 then
    tSec = "0" & tSec
  end if
  return([tMin, tSec])
end

on renderCountdownTimer me 
  if (pCountdownEndTime = 0) then
    return FALSE
  end if
  tEndTime = pCountdownEndTime
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("bb_info_tmToJoin")
  if (tElem = 0) then
    return FALSE
  end if
  if tEndTime < the milliSeconds then
    return FALSE
  end if
  tTime = me.convertToMinSec((tEndTime - the milliSeconds))
  tTimeStr = tTime.getAt(1) & ":" & tTime.getAt(2)
  tElem.setText(replaceChunks(getText("gs_timetojoin"), "\\x", tTimeStr))
end

on eventProc me, tEvent, tSprID, tParam 
  if (tSprID = "bb_button_playAgn") then
    if (me.getGameSystem() = 0) then
      return FALSE
    end if
    me.getGameSystem().rejoinGame()
  else
    if (tSprID = "bb_button_leaveGam2") then
      if (me.getGameSystem() = 0) then
        return FALSE
      end if
      me.getGameSystem().enterLounge()
    else
      if tSprID <> "bb_link_shrink" then
        if (tSprID = "bb_link_expand") then
          me.toggleWindowMode()
        else
          if (tSprID = "gs_button_buytickets") then
            executeMessage(#show_ticketWindow)
          end if
        end if
      end if
    end if
  end if
end
