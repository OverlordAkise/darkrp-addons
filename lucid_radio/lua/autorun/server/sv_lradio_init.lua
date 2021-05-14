--Lucid's Radio
--Made by OverlordAkise

util.AddNetworkString("lucid_radio_frequency")

lucid_radio_teams = {}

hook.Add("postLoadCustomDarkRPItems", "lucid_radio_detouring",function()
  
  -- IsInRoom function to see if the player is in the same room.
  local roomTrResult = {}
  local roomTr = { output = roomTrResult }
  local function IsInRoom(listenerShootPos, talkerShootPos, talker)
    roomTr.start = talkerShootPos
    roomTr.endpos = listenerShootPos
    -- Listener needs not be ignored as that's the end of the trace
    roomTr.filter = talker
    roomTr.collisiongroup = COLLISION_GROUP_WORLD
    roomTr.mask = MASK_SOLID_BRUSHONLY
    util.TraceLine(roomTr)

    return not roomTrResult.HitWorld
  end

  local threed = GM.Config.voice3D
  local vrad = GM.Config.voiceradius
  local dynv = GM.Config.dynamicvoice
  local deadv = GM.Config.deadvoice
  local voiceDistance = GM.Config.voiceDistance * GM.Config.voiceDistance
  DrpCanHear = {}

  -- Recreate DrpCanHear after Lua Refresh
  -- This prevents an indexing nil error in PlayerCanHearPlayersVoice
  for _, ply in pairs(player.GetAll()) do
      DrpCanHear[ply] = {}
  end

  local gridSize = GM.Config.voiceDistance -- Grid cell size is equal to the size of the radius of player talking
  local floor = math.floor -- Caching floor as we will need to use it a lot

  -- Grid based position check
  local grid
  -- Translate player to grid coordinates. The first table maps players to x
  -- coordinates, the second table maps players to y coordinates.
  local plyToGrid = {
      {},
      {}
  }

  -- Set DarkRP.voiceCheckTimeDelay before DarkRP is loaded to set the time
  -- between player voice radius checks.
  DarkRP.voiceCheckTimeDelay = DarkRP.voiceCheckTimeDelay or 0.3
  timer.Remove("DarkRPCanHearPlayersVoice")
  
  timer.Simple(1,function()
  timer.Create("DarkRPCanHearPlayersVoice", DarkRP.voiceCheckTimeDelay, 0, function()
      -- Voiceradius is off, everyone can hear everyone
      if not vrad then
          return
      end

      local players = player.GetHumans()

      -- Clear old values
      plyToGrid[1] = {}
      plyToGrid[2] = {}
      grid = {}

      local plyPos = {}
      local eyePos = {}

      -- Get the grid position of every player O(N)
      for _, ply in ipairs(players) do
          local pos = ply:GetPos()
          plyPos[ply] = pos
          eyePos[ply] = ply:EyePos()
          local x = floor(pos.x / gridSize)
          local y = floor(pos.y / gridSize)

          local row = grid[x] or {}
          local cell = row[y] or {}

          table.insert(cell, ply)
          row[y] = cell
          grid[x] = row

          plyToGrid[1][ply] = x
          plyToGrid[2][ply] = y

          DrpCanHear[ply] = {} -- Initialize output variable
          for kk,ply2 in pairs(player.GetAll()) do
            if(ply.lradioOn and ply2.lradioOn) then

              if(ply.lradioFrequency == ply2.lradioFrequency) then
                print("Both players in same group")
                if (ply2:GetActiveWeapon():GetClass() == "lucid_radio") then
                  print("Setting to yes")
                  DrpCanHear[ply][ply2] = true and (deadv or ply2:Alive())
                end
                if (ply:GetActiveWeapon():GetClass() == "lucid_radio") then
                  print("Setting to yes")
                  DrpCanHear[ply2][ply] = true and (deadv or ply:Alive())
                end
                break
              end
            end
          end
      end

      -- Check all neighbouring cells for every player.
      -- We are only checking in 1 direction to avoid duplicate check of cells
      for _, ply1 in ipairs(players) do
          local gridX = plyToGrid[1][ply1]
          local gridY = plyToGrid[2][ply1]
          local ply1Pos = plyPos[ply1]
          local ply1EyePos = eyePos[ply1]

          for i = 0, 3 do
              local vOffset = 1 - ((i >= 3) and 1 or 0)
              local hOffset = -(i % 3-1)
              local x = gridX + hOffset
              local y = gridY + vOffset

              local row = grid[x]
              if not row then continue end

              local cell = row[y]
              if not cell then continue end

              for _, ply2 in ipairs(cell) do
                  local canTalk =
                      ply1Pos:DistToSqr(plyPos[ply2]) < voiceDistance and
                          (not dynv or IsInRoom(ply1EyePos, eyePos[ply2], ply2))
                  DrpCanHear[ply1][ply2] = canTalk and (deadv or ply2:Alive())
                  DrpCanHear[ply2][ply1] = canTalk and (deadv or ply1:Alive())
                  
              end
          end
      end

      -- Doing a pass-through inside every cell to compute the interactions inside of the cells.
      -- Each grid check is O(N(N+1)/2) where N is the number of players inside the cell.
      for _, row in pairs(grid) do
          for _, cell in pairs(row) do
              local count = #cell
              for i = 1, count do
                  local ply1 = cell[i]
                  for j = i + 1, count do
                      local ply2 = cell[j]
                      local canTalk =
                          plyPos[ply1]:DistToSqr(plyPos[ply2]) < voiceDistance and
                              (not dynv or IsInRoom(eyePos[ply1], eyePos[ply2], ply2))
                      
                      DrpCanHear[ply1][ply2] = canTalk and (deadv or ply2:Alive())
                      DrpCanHear[ply2][ply1] = canTalk and (deadv or ply1:Alive())
                      
                  end
              end
          end
      end
  end)
  end)
  hook.Add("PlayerDisconnect", "DarkRPCanHear", function(ply)
      DrpCanHear[ply] = nil -- Clear to avoid memory leaks
  end)

  function GM:PlayerCanHearPlayersVoice(listener, talker)
      if not deadv and not talker:Alive() then return false end

      if (listener.lradioOn and talker.lradioOn and listener:GetPos():DistToSqr(talker:GetPos()) > voiceDistance) then
        return not vrad or DrpCanHear[listener][talker] == true, false
      end
      return not vrad or DrpCanHear[listener][talker] == true, threed
  end
  print("----------")
  print("KRASSES RADIO SYSTEM GELADEN!")
  print("----------")
  
end)

hook.Add("PlayerInitialSpawn", "lucid_radio_spawnset", function(ply)
  ply.lradioOn = false
  ply.lradioCooldown = CurTime() + 0.5
  ply.lradioFrequency = 0
end)


function lucidAddRadioReceiver(ply,bol)
  if ply:IsPlayer() then
    if ply.lradioCooldown > CurTime() then return end
    ply.lradioCooldown = CurTime() + 0.5
    ply.lradioOn = bol
    if(bol)then
      DarkRP.notify(ply,0,5,"You logged into the radio channel!")
    else
      DarkRP.notify(ply,1,5,"You logged out of the radio channel!")
    end
  end
end

function LucidAddRadioTeam(name, ...)
  lucid_radio_teams[name] = {}
  for k,v in pairs({...}) do
    lucid_radio_teams[name][v] = true
  end
end

net.Receive("lucid_radio_frequency", function(len,ply)
  local freq = net.ReadString()
  if(tonumber(freq))then
    ply.lradioFrequency = tonumber(freq)
    DarkRP.notify(ply,0,5,"Frequency updated to "..freq)
  else
    DarkRP.notify(ply,1,5,"Frequency wasn't a number!")
  end
end)
