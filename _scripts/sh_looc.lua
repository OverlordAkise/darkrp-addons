--Local-OOC-Command
--Made by OverlordAkise, ported from FPTje's OOC

hook.Add("PostGamemodeLoaded","chef_looc",function()
  if not DarkRP then return end
  DarkRP.declareChatCommand{
    command = "looc",
    description = "local out-of-character chat.",
    delay = 1.5
  }
  if SERVER then
    local function looc(ply, args)
      local DoSay = function(text)
          if text == "" then
              DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", DarkRP.getPhrase("arguments"), ""))
              return ""
          end
          local col = team.GetColor(ply:Team())
          local col2 = Color(255, 255, 255, 255)
          if not ply:Alive() then
              col2 = Color(255, 200, 200, 255)
              col = col2
          end

          local name = ply:Nick()
          for _, v in ipairs(player.GetAll()) do
              DarkRP.talkToPerson(v, col, "[looc] " .. name, col2, text, ply)
          end
      end
      return args, DoSay
    end
    DarkRP.defineChatCommand("looc", looc, true, 1.5)
  else
    --CLIENT
    DarkRP.addChatReceiver("/looc", "speak in local ooc", function(ply) return true end)
  end
end)
