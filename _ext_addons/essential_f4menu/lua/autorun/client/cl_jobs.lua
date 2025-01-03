
essentialDarkRPF4Menu = essentialDarkRPF4Menu or {}
essentialDarkRPF4Menu.settings = essentialDarkRPF4Menu.settings or {}

local white = Color(255, 255, 255)
local black = Color(0, 0, 0)
local orange = Color(255, 128, 0)

local defaultBlur = Color(10, 10, 10, 160)
local defaultBlurOutline = Color(20, 20, 20, 210)

local function buttonClickSound()
	surface.PlaySound('ui/buttonclick.wav')
end

-- Draw normal outlined (non-blurred) rectangle in paint hook
local function drawRectOutlined(xpos, ypos, width, height, color)
	surface.SetDrawColor(color)
	surface.DrawRect(xpos + 1, ypos + 1, width - 2, height - 2)

	surface.SetDrawColor(defaultBlurOutline)
	surface.DrawOutlinedRect(xpos, ypos, width, height)
end

local function openJobs()
	if IsValid(essentialDarkRPF4Menu.jobsPanel) then return end

	local midPanel = essentialDarkRPF4Menu.returnMidPanel()

	-- Panel to parent all tab content to
	essentialDarkRPF4Menu.jobsPanel = midPanel:Add('DPanel')
	essentialDarkRPF4Menu.jobsPanel:SetSize(midPanel:GetWide(), midPanel:GetTall())
	essentialDarkRPF4Menu.jobsPanel:Dock(FILL)
	essentialDarkRPF4Menu.jobsPanel:DockMargin(0, 0, 0, 0)

	function essentialDarkRPF4Menu.jobsPanel:Paint() return end

	-- Right panel
	local rightPanel = essentialDarkRPF4Menu.jobsPanel:Add('DPanel')
	rightPanel:SetSize(270, essentialDarkRPF4Menu.jobsPanel:GetTall())
	rightPanel:Dock(RIGHT)
	rightPanel:DockMargin(0, 0, 0, 0)

	function rightPanel:Paint(w, h)
		surface.SetDrawColor(defaultBlurOutline)
		surface.DrawOutlinedRect(0, 0, w, h)

		surface.SetDrawColor(essentialDarkRPF4Menu.bgColor1)
		surface.DrawRect(1, 1, w - 2, h - 2)
	end

	essentialDarkRPF4Menu.selectedJob = LocalPlayer():getJobTable()

	-- Right panel job name
	local nameLabel = rightPanel:Add('DLabel')
	nameLabel:SetTall(30)
	nameLabel:Dock(TOP)
	nameLabel:DockMargin(5, 4, 5, 0)
	nameLabel:SetFont('edf_roboto20')
	nameLabel:SetTextColor(white)
	nameLabel:SetContentAlignment(5)

	local function addJobName()
		nameLabel:SetText(essentialDarkRPF4Menu.selectedJob.name)
	end

	-- Right panel model panel
	local modelPanel = rightPanel:Add('DModelPanel')
	modelPanel:SetSize(0, 150)
	modelPanel:Dock(TOP)
	modelPanel:DockMargin(5, 4, 5, 4)
	modelPanel:SetSize(200, 200)
	modelPanel:SetFOV(modelPanel:GetFOV() + 3)

	local function addJobModel()
		if istable(essentialDarkRPF4Menu.selectedJob.model) and util.IsValidModel(essentialDarkRPF4Menu.selectedJob.model[1]) then
			modelPanel:SetModel(essentialDarkRPF4Menu.selectedJob.model[1])
		elseif (not istable(essentialDarkRPF4Menu.selectedJob.model)) and util.IsValidModel(essentialDarkRPF4Menu.selectedJob.model) then
			modelPanel:SetModel(essentialDarkRPF4Menu.selectedJob.model)
		else
			modelPanel:SetModel('models/error.mdl')
		end
	end

	-- Description panel
	local descriptionPanel = rightPanel:Add('DScrollPanel')
	descriptionPanel:SetSize(0, rightPanel:GetTall())
	descriptionPanel:Dock(FILL)
	descriptionPanel:DockMargin(5, 10, 5, 10)

	local descriptionScrollBar = descriptionPanel:GetVBar()
	descriptionScrollBar:DockMargin(0, 0, 0, 0)

	function descriptionScrollBar:Paint() return end

	function descriptionScrollBar.btnGrip:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, defaultBlur)
	end

	function descriptionScrollBar.btnUp:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, defaultBlur)
	end

	function descriptionScrollBar.btnDown:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, defaultBlur)
	end

	surface.SetFont('edf_roboto20')
	local descW, descH = surface.GetTextSize(essentialDarkRPF4Menu.selectedJob.description)

	local jobDescriptionLabel = descriptionPanel:Add('DLabel')
	jobDescriptionLabel:Dock(TOP)
	jobDescriptionLabel:DockMargin(5, 5, 5, 5)
	jobDescriptionLabel:SetFont('edf_roboto18')
	jobDescriptionLabel:SetTextColor(Color(200, 200, 200))
	jobDescriptionLabel:SetSize(250, descriptionPanel:GetTall())
	jobDescriptionLabel:SetWrap(true)
	jobDescriptionLabel:SetAutoStretchVertical(true)

	local function addJobDescription()
		if not IsValid(jobDescriptionLabel) then return end

		jobDescriptionLabel:SetText(essentialDarkRPF4Menu.selectedJob.description)
	end

	-- Change job button
	takeJobText = essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage]['TakeJob']

	local changeJobButton = rightPanel:Add('DButton')
	changeJobButton:SetTall(45)
	changeJobButton:Dock(BOTTOM)
	changeJobButton:DockMargin(5, 4, 5, 5)
	changeJobButton:SetFont('edf_roboto20')
	changeJobButton:SetText(takeJobText)
	changeJobButton:SetTextColor(white)

	function changeJobButton:Paint(w, h)
		drawRectOutlined(0, 0, w, h, defaultBlur)

		if essentialDarkRPF4Menu.selectedJob.vote then
			changeJobButton:SetText(essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage]['CreateVote'])
		else
			changeJobButton:SetText(takeJobText)
		end

		if changeJobButton:IsHovered() then
			changeJobButton:SetTextColor(orange)
		else
			changeJobButton:SetTextColor(white)
		end
	end

	function changeJobButton.DoClick()
		essentialDarkRPF4Menu.returnMainFrame():Remove()

		-- Check if model is valid before we become a job
		if util.IsValidModel(modelPanel:GetModel()) then
			DarkRP.setPreferredJobModel(essentialDarkRPF4Menu.selectedJob.team, modelPanel:GetModel())
		end

		if essentialDarkRPF4Menu.selectedJob.vote then
			RunConsoleCommand('darkrp', 'vote' .. essentialDarkRPF4Menu.selectedJob.command)
		else
			RunConsoleCommand('darkrp', essentialDarkRPF4Menu.selectedJob.command)
		end
	end

	-- Model picker panel
	local modelPickerPanel = rightPanel:Add('DPanel')
	modelPickerPanel:Dock(BOTTOM)
	modelPickerPanel:DockMargin(5, 0, 5, 0)

	function modelPickerPanel:Paint() return end

	local function createModelPickerButtons()
		if IsValid(essentialDarkRPF4Menu.leftButton) or IsValid(essentialDarkRPF4Menu.rightButton) or IsValid(essentialDarkRPF4Menu.modelCounter) then
			essentialDarkRPF4Menu.leftButton:Remove()
			essentialDarkRPF4Menu.modelCounter:Remove()
			essentialDarkRPF4Menu.rightButton:Remove()
		end

		essentialDarkRPF4Menu.jobModelPos = 1

		-- Left button
		essentialDarkRPF4Menu.leftButton = modelPickerPanel:Add('DButton')
		essentialDarkRPF4Menu.leftButton:SetWide(25)
		essentialDarkRPF4Menu.leftButton:Dock(LEFT)
		essentialDarkRPF4Menu.leftButton:DockMargin(0, 0, 0, 0)
		essentialDarkRPF4Menu.leftButton:SetTextColor(white)
		essentialDarkRPF4Menu.leftButton:SetText('<')

		function essentialDarkRPF4Menu.leftButton:Paint(w, h)
			drawRectOutlined(0, 0, w, h, defaultBlur)

			if self:IsHovered() then
				self:SetTextColor(orange)
			else
				self:SetTextColor(white)
			end
		end

		function essentialDarkRPF4Menu.leftButton.DoClick()
			if essentialDarkRPF4Menu.jobModelPos > 1 then
				essentialDarkRPF4Menu.jobModelPos = essentialDarkRPF4Menu.jobModelPos - 1

				if util.IsValidModel(essentialDarkRPF4Menu.selectedJob.model[essentialDarkRPF4Menu.jobModelPos]) then
					modelPanel:SetModel(essentialDarkRPF4Menu.selectedJob.model[essentialDarkRPF4Menu.jobModelPos])
				else
					modelPanel:SetModel('models/error.mdl')
				end
			end

			buttonClickSound()
		end

		-- Model counter
		essentialDarkRPF4Menu.modelCounter = modelPickerPanel:Add('DLabel')
		essentialDarkRPF4Menu.modelCounter:SetFont('edf_roboto20')
		essentialDarkRPF4Menu.modelCounter:SetTextColor(white)
		essentialDarkRPF4Menu.modelCounter:SetText(essentialDarkRPF4Menu.jobModelPos .. ' / ' .. #essentialDarkRPF4Menu.selectedJob.model)
		essentialDarkRPF4Menu.modelCounter:SizeToContentsX()
		essentialDarkRPF4Menu.modelCounter:Dock(FILL)
		essentialDarkRPF4Menu.modelCounter:SetContentAlignment(5)

		function essentialDarkRPF4Menu.modelCounter:Paint()
			essentialDarkRPF4Menu.modelCounter:SetText(essentialDarkRPF4Menu.jobModelPos .. ' / ' .. #essentialDarkRPF4Menu.selectedJob.model)
		end

		-- Right button
		essentialDarkRPF4Menu.rightButton = modelPickerPanel:Add('DButton')
		essentialDarkRPF4Menu.rightButton:SetWide(25)
		essentialDarkRPF4Menu.rightButton:Dock(RIGHT)
		essentialDarkRPF4Menu.rightButton:DockMargin(0, 0, 0, 0)
		essentialDarkRPF4Menu.rightButton:SetTextColor(white)
		essentialDarkRPF4Menu.rightButton:SetText('>')

		function essentialDarkRPF4Menu.rightButton:Paint(w, h)
			drawRectOutlined(0, 0, w, h, defaultBlur)

			if self:IsHovered() then
				self:SetTextColor(orange)
			else
				self:SetTextColor(white)
			end
		end

		function essentialDarkRPF4Menu.rightButton.DoClick()
			if essentialDarkRPF4Menu.jobModelPos < #essentialDarkRPF4Menu.selectedJob.model then
				essentialDarkRPF4Menu.jobModelPos = essentialDarkRPF4Menu.jobModelPos + 1

				if util.IsValidModel(essentialDarkRPF4Menu.selectedJob.model[essentialDarkRPF4Menu.jobModelPos]) then
					modelPanel:SetModel(essentialDarkRPF4Menu.selectedJob.model[essentialDarkRPF4Menu.jobModelPos])
				else
					modelPanel:SetModel('models/error.mdl')
				end
			end

			buttonClickSound()
		end
	end

	function addModelPicker()
		if istable(essentialDarkRPF4Menu.selectedJob.model) and #essentialDarkRPF4Menu.selectedJob.model > 1 then
			modelPickerPanel:SetVisible(true)

			createModelPickerButtons()
		else
			modelPickerPanel:SetVisible(false)
		end
	end

	addModelPicker()

	-- Jobs list panel
	local jobsListPanel = essentialDarkRPF4Menu.jobsPanel:Add('DScrollPanel')
	jobsListPanel:SetSize(essentialDarkRPF4Menu.jobsPanel:GetWide(), essentialDarkRPF4Menu.jobsPanel:GetTall())
	jobsListPanel:Dock(TOP)
	jobsListPanel:DockMargin(0, 0, 5, 0)

	local scrollBar = jobsListPanel:GetVBar()
	scrollBar:DockMargin(0, 0, 0, 0)

	function scrollBar:Paint() return end

	function scrollBar.btnGrip:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, defaultBlur)
	end

	function scrollBar.btnUp:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, defaultBlur)
	end

	function scrollBar.btnDown:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, defaultBlur)
	end

	local validItems = {}
	local localplayer = LocalPlayer()
	local localplayer_team = localplayer:Team()
	-- Add all the jobs
	for _, job in ipairs(RPExtraTeams) do
		essentialDarkRPF4Menu.displayItem = true

		-- Hide job and group restricted jobs
		-- if essentialDarkRPF4Menu.hideRestrictedJobs then
			if (istable(job.allowed) and not table.HasValue(job.allowed, localplayer_team)) or (job.customCheck and not job.customCheck(localplayer)) or (job.canSee and not job.canSee(localplayer)) then
				essentialDarkRPF4Menu.displayItem = false
			end
		-- end

		if essentialDarkRPF4Menu.displayItem then
			table.insert(validItems, job)

			local jobCat = job.category

			-- Add non-existing categories
			if not IsValid(jobsListPanel[jobCat]) then
				jobsListPanel[jobCat] = jobsListPanel:Add('DCollapsibleCategory')

				local jobCatPanel = jobsListPanel[jobCat]

				jobCatPanel:Dock(TOP)
				jobCatPanel:DockMargin(0, 0, 5, 3)
				jobCatPanel:SetLabel(job.category)
				jobCatPanel:SetAnimTime(0.1)
				jobCatPanel:GetChildren()[1]:SetTall(35)

				function jobCatPanel:Paint(w, h) return end

				jobCatPanel.Header:SetTextColor(white)
				jobCatPanel.Header:SetFont('edf_roboto20')

				function jobCatPanel.Header:Paint(w, h)
					local categoryColor = self.color or essentialDarkRPF4Menu.defaultCategoryColor

					surface.SetDrawColor(defaultBlurOutline)
					surface.DrawOutlinedRect(0, 0, w, h)

					surface.SetDrawColor(categoryColor)
					surface.DrawRect(1, 1, w - 2, h - 2)
				end

				-- Add panel containing the job contents to category
				jobCatPanel.catContentsPanel = vgui.Create('DPanel')
				jobCatPanel.catContentsPanel:SizeToContents()

				function jobCatPanel.catContentsPanel:Paint() return end

				jobCatPanel:SetContents(jobCatPanel.catContentsPanel)
			end

			local jobCatPanel = jobsListPanel[jobCat]

			local jobCategories = DarkRP.getCategories().jobs

			for _, category in ipairs(jobCategories) do
				if jobCat == category.name then
					jobCatPanel.Header.color = Color(category.color['r'], category.color['g'], category.color['b'], 150)
				end
			end

			-- Add jobs to category contents panel
			local jobButton = jobCatPanel.catContentsPanel:Add('DButton')
			jobButton:SetText('')
			jobButton:SetSize(0, 66)
			jobButton:Dock(TOP)
			jobButton:DockMargin(0, 3, 0, 0)

			function jobButton:Paint()
				drawRectOutlined(0, 0, self:GetWide(), self:GetTall(), defaultBlur)
			end

			function jobButton.DoClick()
				essentialDarkRPF4Menu.selectedJob = job

				-- Add stuff to right panel
				addModelPicker()
				addJobName()
				addJobModel()
				addJobDescription()

				buttonClickSound()
			end

			function jobButton.DoDoubleClick()
				if IsValid(changeJobButton) then
					changeJobButton:DoClick()
				end
			end

			local jobModel = jobButton:Add('SpawnIcon')
			jobModel:SetSize(64, 0)
			jobModel:Dock(LEFT)
			jobModel:DockMargin(1, 1, 1, 1)

			if istable(job.model) and util.IsValidModel(job.model[1]) then
				jobModel:SetModel(job.model[1])
			elseif (not istable(job.model)) and util.IsValidModel(job.model) then
				jobModel:SetModel(job.model)
			else
				jobModel:SetModel('models/error.mdl')
			end

			function jobModel.DoClick()
				jobButton:DoClick()
			end

			-- Job name
			local jobName = jobButton:Add('DLabel')
			jobName:Dock(FILL)
			jobName:DockMargin(6, 0, 0, 0)
			jobName:SetFont('edf_roboto20')
			jobName:SetTextColor(white)

			local function updateJobName()
				if job.max < 1 then
					essentialDarkRPF4Menu.jobMaxPlayers = '∞'
				else
					essentialDarkRPF4Menu.jobMaxPlayers = job.max
				end

				jobName:SetText(job.name .. '  (' .. #team.GetPlayers(job.team) .. '/' .. essentialDarkRPF4Menu.jobMaxPlayers .. ')')
				jobName:SizeToContentsX()
			end

			updateJobName()

			function jobName:Paint()
				updateJobName()
			end

			local salaryPanel = jobButton:Add('DPanel')
			salaryPanel:Dock(RIGHT)
			salaryPanel:DockMargin(0, 0, 5, 0)
			salaryPanel:SizeToContentsX()

			function salaryPanel.Paint(w, h)
				draw.RoundedBox(28.49, 5, 5, salaryPanel:GetTall() - 8, salaryPanel:GetWide() - 8, Color(10, 10, 10, 120))
			end

			function salaryPanel:OnMousePressed()
				jobButton:DoClick()
			end

			-- Job salary
			local jobSalary = salaryPanel:Add('DLabel')
			jobSalary:Dock(FILL)
			jobSalary:DockMargin(0, 0, 0, 0)
			jobSalary:SetContentAlignment(5)
			jobSalary:SetText('$' .. job.salary)

			if job.salary < 1000 then
				jobSalary:SetFont('edf_roboto20')
			elseif job.salary < 100000 then
				jobSalary:SetFont('edf_roboto18')
			else
				jobSalary:SetFont('edf_roboto16')
			end

			jobSalary:SetTextColor(white)

			-- Add initial stuff to right panel
			addModelPicker()
			addJobName()
			addJobModel()
			addJobDescription()
		end
	end

	if #validItems < 1 then
		rightPanel:SetVisible(false)

		local unavailableLabel = essentialDarkRPF4Menu.jobsPanel:Add('DLabel')
		unavailableLabel:SetPos(0, 0)
		unavailableLabel:SetFont('edf_roboto20')
		unavailableLabel:SetTextColor(white)
		unavailableLabel:SetText('The contents of this tab are not available for your job.')
		unavailableLabel:SizeToContents()
	end
end

function essentialDarkRPF4Menu.openJobsTab()
	openJobs()
end
