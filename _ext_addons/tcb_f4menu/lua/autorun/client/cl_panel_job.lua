/*---------------------------------------------------------------------------
	
	Creator: TheCodingBeast - TheCodingBeast.com
	This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
	To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
	
---------------------------------------------------------------------------*/

-- Variables
local PANEL = {}
local TCB_Scroll

-- Panel
function PANEL:Init()

	-- Main Frame
	self:SetSize( 608, 76 )
	self.Paint = function( pnl, w, h )

		draw.RoundedBox( 0, 0, 0, w - 0, h - 0, Color( 0, 0, 0, 100 ) )
		draw.RoundedBox( 0, 2, 2, w - 4, h - 4, Color( 60, 60, 60, 255 ) )

	end

	-- Model View
	self.model = vgui.Create( "ModelImage", self )
	self.model:SetSize( 72, 72 )
	self.model:SetPos( 2, 2 )
	self.model:SetModel( "models/player/alyx.mdl" )

	-- Job Name
	self.info = vgui.Create( "DPanel", self )
	self.info:SetSize( 310, 56 )
	self.info:SetPos( 80, 10 )
	self.info.name 	= "-"
	self.info.wep 	= ""
	self.info.Paint = function( pnl, w, h )

		--draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 20 ) )

		draw.DrawText( self.info.name, "Trebuchet24", w / 2 + 1, 5 + 1, Color( 0, 0, 0, 255 ), 1 )
		draw.DrawText( self.info.name, "Trebuchet24", w / 2 + 0, 5 + 0, Color( 255, 255, 255, 255 ), 1 )

		draw.DrawText( self.info.wep, "Trebuchet18", w / 2 + 1, 34 + 1, Color( 0, 0, 0, 255 ), 1 )
		draw.DrawText( self.info.wep, "Trebuchet18", w / 2 + 0, 34 + 0, Color( 255, 255, 255, 255 ), 1 )

	end

	-- Join Button
	self.join = vgui.Create( "DButton", self )
	self.join:SetSize( 200, 34 )
	self.join:SetPos( self:GetWide() - 200 - 10, 10 )
	self.join:SetText( "" )
	self.join.Hover 	= false
	self.join.Status 	= false
	self.join.OnCursorEntered	= function() self.join.Hover = true  end
	self.join.OnCursorExited 	= function() self.join.Hover = false end
	self.join.DoClick = function() end
	self.join.Paint = function( pnl, w, h )

		draw.RoundedBox( 0, 0, 0, w - 0, h - 0, Color( 0, 0, 0, 100 ) )
		draw.RoundedBox( 0, 2, 2, w - 4, h - 4, Color( 46, 204, 113, 255 ) )
		draw.RoundedBox( 0, 4, 4, w - 8, h - 8, Color( 39, 174, 96, 255 ) )

		if self.join.Hover == true then
			draw.RoundedBox( 0, 4, 4, w - 8, h - 8, Color( 0, 0, 0, 50 ) )
		end

		if self.join.Status == true then
			draw.RoundedBox( 0, 2, 2, w - 4, h - 4, Color( 149, 165, 166, 255 ) )
			draw.RoundedBox( 0, 4, 4, w - 8, h - 8, Color( 127, 140, 141, 255 ) )
		end

		draw.DrawText( "Become Job", "Trebuchet24", w / 2 + 1, 5 + 1, Color( 0, 0, 0, 255 ), 1 )
		draw.DrawText( "Become Job", "Trebuchet24", w / 2 + 0, 5 + 0, Color( 255, 255, 255, 255 ), 1 )

	end

	-- Slots
	self.slots = vgui.Create( "DPanel", self )
	self.slots:SetSize( 200, 20 )
	self.slots:SetPos( self:GetWide() - 200 - 10, 50 )
	self.slots.text = "0 / 0"
	self.slots.Paint = function( pnl, w, h )

		draw.DrawText( self.slots.text, "Trebuchet18", w/ 2, 0, Color( 255, 255, 255, 255 ), 1 )

	end
end

-- Update
function PANEL:UpdateInfo( job, team, name, model, max, players, description, vote, cmd )

	self.info.name 		= name
	self.info.wep 		= description
	self.slots.text 	= players.." / "..max

	if max != 0 and max != "#" and tonumber(players) >= max then
		self.join.Status = true
	end

	if team == LocalPlayer():Team() then
		self.join.Status = true
	end

	if job['NeedToChangeFrom'] and LocalPlayer():Team() != job['NeedToChangeFrom'] then
		self.join.Status = true
	end

	local closeFunc = function() RunConsoleCommand( "tcb_f4menu_close" ) end
	if self.join.Status != true then
		if vote then
			self.join.DoClick = fn.Compose{closeFunc, fn.Partial(RunConsoleCommand, "darkrp", "vote" .. cmd)}
		else
			self.join.DoClick = fn.Compose{closeFunc, fn.Partial(RunConsoleCommand, "darkrp", cmd)}
		end
	end
	
	self.model:SetModel( model )

end

-- Derma
vgui.Register( "tcb_panel_jobs_item", PANEL, "DPanel" )

-- Variables
local PANEL = {}

-- Panel
function PANEL:Init()

	-- Main Frame
	self:SetSize( 650 - 2, 620 - 2 )
	self:SetPos( 250, 2 )
	self.Paint = function()

		draw.RoundedBoxEx( 0, 0, 0, self:GetWide(), self:GetTall(), Color( 0, 0, 0, 0 ), false, true, false, false )

	end

	TCB_Scroll = vgui.Create( "tcb_panel_scroll", self )

	-- Fill Data
	self:FillData( TCB_Scroll )

end

-- Fill Data
function PANEL:FillData( parent )

	local StartYPos = 0

	for i, job in ipairs(RPExtraTeams) do
		
		local ShowThisItem = true
		if TCB_Settings.HideWrongJob == true then

			if job.customCheck 		and not job.customCheck(LocalPlayer()) 				then ShowThisItem = false end
			if job.NeedToChangeFrom and job.NeedToChangeFrom != LocalPlayer():Team() 	then ShowThisItem = false end

		end
		
		if ShowThisItem == true then
			CurrentJob = vgui.Create( "tcb_panel_jobs_item", parent )
			CurrentJob:SetPos( 0, StartYPos )

			-- Update
			local job_team 	= job['team'] 			or ""
			local job_name 	= job['name']			or ""
			local job_desc	= job['description']	or ""
			local job_max	= job['max'] 			or 0
			local job_vote	= job['vote']			or false
			local job_cmd	= job['command']		or ""

			local job_ply	= team.NumPlayers( job['team'] ) or 0
			local job_mdl	= ""

			if job_max == 0 then job_max = "#" end 		// ∞

			if istable( job['model'] ) then job_mdl = job['model'][1] else job_mdl = job['model'] end

			CurrentJob:UpdateInfo( job, job_team, job_name, job_mdl, job_max, job_ply, job_desc, job_vote, job_cmd )

			StartYPos = StartYPos + CurrentJob:GetTall() + 11
		end

	end

	if TCB_Settings.HideWrongJob == true then
		
		local HideElementsMsg = vgui.Create( "tcb_panel_hidden", parent )
		HideElementsMsg:SetPos( 0, StartYPos )

	end

end

-- Refill Data
function PANEL:RefillData()

	-- Remove Items
	TCB_Scroll:Clear()

	-- Scroll Fix
	TCB_Scroll:ScrollFix()
	
	-- Fill Items
	self:FillData( TCB_Scroll )

end

-- Derma
vgui.Register( "tcb_panel_jobs", PANEL, "DPanel" )