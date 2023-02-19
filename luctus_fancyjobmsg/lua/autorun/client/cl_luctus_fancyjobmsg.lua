--Luctus Fancy Job Message
--Made by OverlordAkise

surface.CreateFont("LuctusAnnounce", {
    font = "Verdana",
    size = 48,
    weight = 900,
    antialias = true,
})

local color_white = Color(255,255,255,255)
local color_black = Color(0,0,0,255)

LuctusAnnounceText = nil
LuctusAnnounceShadow = nil
LuctusAnnounceLine = nil

function LuctusAnnounceClear()
    if LuctusAnnounceText then LuctusAnnounceText:Remove() end
    if LuctusAnnounceShadow then LuctusAnnounceShadow:Remove() end
    if LuctusAnnounceLine then LuctusAnnounceLine:Remove() end
end

function LuctusAnnounce(text)
    LuctusAnnounceClear()
    surface.SetFont("LuctusAnnounce")
    local w,h = surface.GetTextSize(text)
    w = w + 5
    LuctusAnnounceLine = vgui.Create("DPanel")
    LuctusAnnounceLine:SetPos(ScrW()/2-(w/2), ScrH()/5+43) 
    LuctusAnnounceLine:SetText("")
    LuctusAnnounceLine:SetSize(1,2)
    LuctusAnnounceLine.stime = SysTime()
    function LuctusAnnounceLine:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,color_white)
    end
    function LuctusAnnounceLine:Think()
        self:SetSize(Lerp(SysTime() - self.stime, 0, w),2)
    end
    timer.Simple(6,function()
        LuctusAnnounceClear()
    end)
    timer.Simple(1,function()
        luctusCreateAnnounceText(text,w,h)
    end)
end

function luctusCreateAnnounceText(text,w,h)
    LuctusAnnounceShadow = vgui.Create("DTextEntry")
    LuctusAnnounceShadow:SetPos(ScrW()/2-(w/2)+1, ScrH()/5+1) 
    LuctusAnnounceShadow:SetText(text)
    LuctusAnnounceShadow:SetFont("LuctusAnnounce")
    LuctusAnnounceShadow:SetTextColor(color_black)
    LuctusAnnounceShadow:SetPaintBackground(false)
    LuctusAnnounceShadow:SetEditable(false)
    LuctusAnnounceShadow.stime = SysTime()
    function LuctusAnnounceShadow:Think()
        self:SetSize(Lerp( SysTime() - self.stime, 0, w ),h)
    end  

    LuctusAnnounceText = vgui.Create("DTextEntry")
    LuctusAnnounceText:SetPos(ScrW()/2-(w/2), ScrH()/5) 
    LuctusAnnounceText:SetText(text)
    LuctusAnnounceText:SetFont("LuctusAnnounce")
    LuctusAnnounceText:SetTextColor(color_white)
    LuctusAnnounceText:SetPaintBackground(false)
    LuctusAnnounceText:SetEditable(false)
    LuctusAnnounceText.stime = SysTime()
    function LuctusAnnounceText:Think()
        self:SetSize(Lerp( SysTime() - self.stime, 0, w ),h)
    end
end

hook.Add("OnPlayerChangedTeam","luctus_fancyjobmsg",function(ply, before, after)
    local name = team.GetName(after)
    LuctusAnnounce(name)
end)

print("[luctus_fancyjobmsg] cl loaded!")
