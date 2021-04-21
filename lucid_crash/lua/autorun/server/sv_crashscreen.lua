util.AddNetworkString("lucidcrash_ping")

timer.Create("LucidCrashscreen_Ping",5,0,function()
  for k,v in pairs(player.GetAll()) do
    net.Start("lucidcrash_ping")
    net.Send(v)
  end
end)
