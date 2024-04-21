RegisterCommand('status', function(src, args, raw)
  local status = raw:sub(8)

  if args[1] == 'reset' then
    LocalPlayer.state:set('PlayerStatus', nil, true)
    return
  end

  if args[1] == '' then
    LocalPlayer.state:set('PlayerStatus', nil, true)
    -- Put your notification export or framework notification event here
    return
  end

  -- Length max 20 characters
  if string.len(status) > 20 then
    -- Put your notification export or framework notification event here
    return
  end

  if status == nil then
      -- Put your notification export or framework notification event here
      return
  else
    LocalPlayer.state:set('PlayerStatus', status, true)
    myStatus = status
  end
end)

local playersStatuses = {}

Citizen.CreateThread(function()
  while true do
    local players = ESX.Game.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 6.0)

    playersStatuses = {}

    for i=1, #players, 1 do
      local player = GetPlayerServerId(players[i])
      local pedId = GetPlayerPed(GetPlayerFromServerId(player))
      local status = Player(player).state.PlayerStatus

      if status ~= nil or status ~= '' then
        playersStatuses[player] = {
          status = status,
          ped = pedId
        }
      end
    end
    Citizen.Wait(1500)
  end
end)

-- Function to draw 3D Text
-- Source: https://forum.cfx.re/t/help-drawtext3d/668117/2
function DrawText3Ds(coords, text)
  local x,y,z = table.unpack(coords)
  local onScreen,_x,_y=World3dToScreen2d(x,y,z)
  local px,py,pz=table.unpack(GetGameplayCamCoords())

  SetTextScale(0.30, 0.30)
  SetTextFont(4)
  -- Text border
  SetTextDropshadow(2, 0, 0, 0, 255)
  SetTextProportional(1)
  SetTextColour(255, 255, 255, 215)
  SetTextEntry("STRING")
  SetTextCentre(1)
  AddTextComponentString(text)
  DrawText(_x,_y)
  local factor = (string.len(text)) / 370
  -- Uncomment the line below here to add a semi transparent background to the 3D Text
  -- DrawRect(_x,_y+0.0095, 0.010+ factor, 0.025, 41, 11, 41, 68)
end

Citizen.CreateThread(function()
  while true do
    local sleep = 1000

    local myStatus = LocalPlayer.state.PlayerStatus
    local pCoords = GetEntityCoords(PlayerPedId())

    if next(playersStatuses) ~= nil then
      -- IMPORTANT
      -- If you or some of your players are experiencing the text to flicker, reduce the sleep below!
      sleep = 5

      for k,v in pairs(playersStatuses) do
        local ped = v.ped
        local status = v.status

        if not status then goto continue end

        if status ~= nil or status ~= '' then
          local pCoords = GetEntityCoords(ped)
          DrawText3Ds(pCoords, status)
        end

        ::continue::
      end
    end

    if myStatus ~= nil then
      sleep = 5
      DrawText3Ds(pCoords, myStatus)
    end

    Citizen.Wait(sleep)
  end
end)
