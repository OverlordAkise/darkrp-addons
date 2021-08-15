--Roll-Command
--Made by OverlordAkise

local roll_message = " has rolled "

hook.Add("PostGamemodeLoaded","luctus_roll",function()
  if not DarkRP then return end
  DarkRP.declareChatCommand{
    command = "roll",
    description = "Roll a random number.",
    delay = 1.5
  }
  if SERVER then
    local function roll_cmd(ply, args)
      local DoSay = function()
        if GAMEMODE.Config.alltalk then
          for k,target in pairs(player.GetAll()) do
            DarkRP.talkToPerson(target, team.GetColor(ply:Team()), ply:Nick()..roll_message..math.random(1,100)..".")
	  end
	else
          DarkRP.talkToRange(ply,ply:Nick()..roll_message..math.random(1,100)..".","",GAMEMODE.Config.talkDistance)
        end
      end
      return args, DoSay
    end
    DarkRP.defineChatCommand("roll", roll_cmd, true, 1.5)
  else
    --CLIENT
    DarkRP.addChatReceiver("/roll", "roll a dice", function(ply) return true end)
  end
end)

