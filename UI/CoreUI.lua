---------------------------------------------------
-- Name: CoreUI								     --
-- Description: Contains all core UI functions   --
---------------------------------------------------

---------------------------------------------------------
-- Get values depending on ATSW Addon is installed or not
---------------------------------------------------------
function GetWidthMTSL()
	local w = 825
	if ATSWFrame ~= nil then w = 675 end
	return w
end
function GetWidthSubframe()
	local w = 815
	if ATSWFrame ~= nil then w = 665 end
	return w
end
function GetWidthRightframe()
	local w = 512
	if ATSWFrame ~= nil then w = 362 end
	return w
end

--------------------------------------------------------------------------
-- Core object
--------------------------------------------------------------------------
MTSLUI_Core = {
	-- Addon frame
	FRAME_WIDTH_MTSL = GetWidthMTSL(),
	FRAME_HEIGHT_MTSL = 429,
	-- SUBFRAME of the split (= width of main frame - 10 for borders)
	FRAME_WIDTH_SUBFRAME = GetWidthSubframe(),
	-- Widths of the splitframes (300/450)
	FRAME_WIDTH_LEFTFRAME = 305,
	FRAME_WIDTH_RIGHTFRAME = GetWidthRightframe(),
	-- Height of the detail frame when its using all the space
	FRAME_HEIGHT_DETAILFRAME = 240,
	-- Height of the detail frame when using split (so 2 detail frames shown)
	FRAME_HEIGHT_DETAILFRAME_SPLIT = 120,
	-- used for every profession except enchanting
	TOGGLE_BUTTON_TRADESKILL,
	-- used for enchanting
	TOGGLE_BUTTON_CRAFTSKILL,
	MTSLF_TRADESKILL,
	MTSLF_CRAFTSKILL,
	
	---------------------------------------------------------------------------------------
	-- Handles an event thrown by the game
	--
	-- @event			string		The name of the event
	-- @arg1			string		Argument1 of the event (can be nil)
	----------------------------------------------------------------------------------------
	HandleEvent = function (self, event, arg1)
		if event == "ADDON_LOADED" then
			if arg1 == MTSLADDON.NAME then
				self:PrintMessage(MTSLUI_Fonts.colors.text.title .. MTSLADDON.NAME .. MTSLUI_Fonts.colors.text.normal .. " (by " .. MTSLADDON.AUTHOR .. ")" .. MTSLUI_Fonts.colors.text.title .. " v" .. MTSLADDON.VERSION .. " loaded!")
				-- count the total skills loaded from files
				MTSL:CountTotalSkillsForEachtTradeskill()
			end
		-- Save the faction of the player
		elseif event == "PLAYER_ENTERING_WORLD" then
			MTSL:GetPlayerFaction()
		-- we opened a craft skill window (enchanting)
		elseif event == "CRAFT_SHOW" then
			local trade_skill_name = GetCraftName()
			-- only act on enchanting
			if trade_skill_name == "Enchanting" then
				-- We opened window for a different trade skill so hide current skillframe
				if trade_skill_name ~= MTSL.CURRENT_TRADESKILL.NAME then		
					MTSL.CURRENT_TRADESKILL.NAME = trade_skill_name
					self:HideCurrentOpenedMTSLFrame()
				end
	
				-- Hide the toggle button if needed
				if self.TOGGLE_BUTTON_CRAFTSKILL ~= nil then
					self.TOGGLE_BUTTON_CRAFTSKILL:Show()
					MTSLUI_MissingTradeSkillsListFrame:Hide()
				else
					self:CreateToggleButtonAndCraftFrame()
				end
			end
		-- We opened a tradeskill window
		elseif event == "TRADE_SKILL_SHOW" then
			local trade_skill_name = GetTradeSkillLine()
			
			-- We opened window for a different trade skill so hide current skillframe
			if trade_skill_name ~= MTSL.CURRENT_TRADESKILL.NAME then	
				MTSL.CURRENT_TRADESKILL.NAME = trade_skill_name
				self:HideCurrentOpenedMTSLFrame()
			end

			-- Hide the toggle button if needed
			if self.TOGGLE_BUTTON_TRADESKILL ~= nil then
				self.TOGGLE_BUTTON_TRADESKILL:Show()
			-- Create the toggle button
			else
				self:CreateToggleButtonAndTradeSkillFrame()
			end
		-- closing a tradeskill
		elseif event == "TRADE_SKILL_CLOSE" then
			if self.TOGGLE_BUTTON_TRADESKILL ~= nil then
				self.TOGGLE_BUTTON_TRADESKILL:Hide()
			end
			if self.MTSLF_TRADESKILL ~= nil then
				self.MTSLF_TRADESKILL:Hide()
			end
		-- closing craftskill (enchanting)
		elseif event == "CRAFT_CLOSE" then	
			if self.TOGGLE_BUTTON_CRAFTSKILL ~= nil then
				self.TOGGLE_BUTTON_CRAFTSKILL:Hide()
			end
			if self.MTSLF_CRAFTSKILL ~= nil then
				self.MTSLF_CRAFTSKILL:Hide()
			end
		-- Learned a new skill or gained a skill point
		elseif event == "TRAINER_UPDATE" or event == "SKILL_LINES_CHANGED" 
				or event == "TRADESKILL_UPDATE" or event == "CRAFT_UPDATE" then
			-- Only refresh if frame is created and is visible
			if self.MTSLF_CRAFTSKILL ~= nil and self.MTSLF_CRAFTSKILL:IsVisible() == 1 then
				self.MTSLF_CRAFTSKILL:Refresh()
			end
			if self.MTSLF_TRADESKILL ~= nil and self.MTSLF_TRADESKILL:IsVisible() == 1 then
				self.MTSLF_TRADESKILL:Refresh()
			end
		end
	end,

	HideCurrentOpenedMTSLFrame = function (self)
		if self.MTSLF_CRAFTSKILL ~= nil then
			self.MTSLF_CRAFTSKILL:Hide()
		end
		if self.MTSLF_TRADESKILL ~= nil then
			self.MTSLF_TRADESKILL:Hide()
		end
	end,

	CreateToggleButtonAndCraftFrame = function(self)
		self.TOGGLE_BUTTON_CRAFTSKILL = MTSL_Tools:CopyObject(MTSLUI_ToggleButton)
		self.MTSLF_CRAFTSKILL = MTSL_Tools:CopyObject(MTSLUI_MissingTradeSkillsListFrame)
		if ATSWFrame ~= nil then
			self.TOGGLE_BUTTON_CRAFTSKILL:Initialise(ATSWFrame, "CraftSkill")
			self.MTSLF_CRAFTSKILL:Initialise(ATSWFrame, "CraftSkill")
		else
			self.TOGGLE_BUTTON_CRAFTSKILL:Initialise(CraftFrame, "CraftSkill")
			self.MTSLF_CRAFTSKILL:Initialise(CraftFrame, "CraftSkill")
		end
	end,
	
	CreateToggleButtonAndTradeSkillFrame = function(self)
		self.TOGGLE_BUTTON_TRADESKILL = MTSL_Tools:CopyObject(MTSLUI_ToggleButton)
		self.MTSLF_TRADESKILL = MTSL_Tools:CopyObject(MTSLUI_MissingTradeSkillsListFrame)
		if ATSWFrame ~= nil then
			self.TOGGLE_BUTTON_TRADESKILL:Initialise(ATSWFrame, "TradeSkill")
			self.MTSLF_TRADESKILL:Initialise(ATSWFrame, "TradeSkill")
		else
			self.TOGGLE_BUTTON_TRADESKILL:Initialise(TradeSkillFrame, "TradeSkill")
			self.MTSLF_TRADESKILL:Initialise(TradeSkillFrame, "TradeSkill")
		end		
	end,

	---------------------------------------------------------------------------------------
	-- Create a generic MTSLUI_FRAME
	--
	-- @type:			string		Type of the frame ("Frame", "Button", "Slider"
	-- @name:			string		The name of the frame
	-- @parent:			ojbect		The parentframe (can be nil)
	-- @template:		string		The name of the template to follow (can be nil)
	-- @width:			number		The width of the frame
	-- @height:			number		The height of the frame
	-- @has_backdrop	boolean		Frame has backgroound or not (can be nil)
	--
	-- returns			Frame		Returns the created frame
	----------------------------------------------------------------------------------------
	CreateBaseFrame = function (self, type, name, parent, template, width, height, has_backdrop)
		local generic_frame = CreateFrame(type, name, parent, template)
		generic_frame:SetWidth(width)
		generic_frame:SetHeight(height)
		generic_frame:SetParent(parent)
		-- Add a background to the frame if we want it
		if has_backdrop ~= nil and has_backdrop == true then
			generic_frame:SetBackdrop({
				bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
				edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
				tile = true,
				tileSize = 16,
				edgeSize = 16, 
				insets = { left = 4, right = 4, top = 4, bottom = 4 }
			})
			--  Black background
			generic_frame:SetBackdropColor(0,0,0,1)
		end
		-- make sure mouse is captured on our window (NO clicking through)
		generic_frame:EnableMouse(1)
		-- Disable zooming in/out		
		generic_frame:EnableMouseWheel(true)
		generic_frame:Show()
		-- return the frame
		return generic_frame
	end,

	-----------------------------------------------------------------------------------------
	-- Create a generic ScrollFrame
	--
	-- @parent_class		ojbect		The parentclass
	-- @parent_frame		ojbect		The parentframe
	-- @width				number		The width of the frame
	-- @height				number		The height of the frame
	-- @has_backdrop		boolean		Frame has backgroound or not (can be nil)
	-- @slider_steps		number		The amount of steps the slider has
	-- @height_slider_step	number		The height of 1 step in the slider
	--
	-- returns				Frame		Returns the created frame
	----------------------------------------------------------------------------------------
	CreateScrollFrame = function (self, parent_class, parent_frame, width, height, has_backdrop, slider_steps, height_slider_step)
		local scroll_frame = MTSLUI_Core:CreateBaseFrame("Frame", "", parent_frame, nil, width, height, has_backdrop)
		-- Make the frame scrollable
		scroll_frame:EnableMouseWheel(true)	
		-- Move the vertical slider if mouse wheel on the frame itself
		scroll_frame:SetScript("OnMouseWheel", function()
			-- scroll up on positive delta
			if arg1 > 0 then
				scroll_frame.slider:ScrollUp()
			else
				scroll_frame.slider:ScrollDown()
			end
		end)	
		-- add the vertical slider on the right to the frame
		scroll_frame.slider = MTSL_Tools:CopyObject(MTSLUI_VerticalSlider)
		scroll_frame.slider:Initialise(parent_class, scroll_frame, slider_steps, height_slider_step)
		-- return the frame
		return scroll_frame
	end,
		
	---------------------------------------------------------------------------
	-- Creates a label for the given frame
	--
	-- @owner		Frame		The frame for which to create the label
	-- @text		String		The text to show on the label
	-- @left		Number		The left position where the label starts
	-- @top			Number		The top position where the label starts
	--
	-- returns		Object		The created label
	---------------------------------------------------------------------------
	CreateLabel = function (self, owner, text, left, top, font_size, position)
		local new_label = owner:CreateFontString(nil,"ARTWORK")
		new_label:SetFont(MTSLUI_Fonts.name, font_size)
		new_label:SetPoint(position, left, top)
		if text ~= nil or text ~= "" then
			new_label:SetText(MTSLUI_Fonts.colors.text.title .. text)
		end
		return new_label
	end,
	
	---------------------------------------------------------------------------------------
	-- Conver a number to xx g xx s xx c
	--
	-- @money:			number		The amount expressed in coppers (e.g.: 10000 = 1g 00 s 00c)
	--
	-- returns			String		Number converted to xx g xx s xx c
	----------------------------------------------------------------------------------------
	GetNumberAsMoneyString = function (self, money_number)
		if type(money_number) ~= "number" then return "-" end
		
		-- Calculate the amount of gold, silver and copper 
		local gold = floor(money_number/10000)
		local silver = floor(mod((money_number/100),100))
		local copper = mod(money_number,100)

		local money_string = ""
		-- Add gold if we have
		if gold > 0 then 
			money_string = money_string .. MTSLUI_Fonts.colors.text.normal .. gold .. MTSLUI_Fonts.colors.money.gold .. "g " 
		end
		-- Add silver if we have
		if silver > 0 then 
			money_string = money_string .. MTSLUI_Fonts.colors.text.normal .. silver .. MTSLUI_Fonts.colors.money.silver .. "s "
		end
		-- Always show copper even if 0
		money_string = money_string .. MTSLUI_Fonts.colors.text.normal .. copper .. MTSLUI_Fonts.colors.money.copper .. "c"

		return money_string
	end,

	---------------------------------------------------------------------------------------
	-- Print a message in the chatframe
	--
	-- @msg:			string		The message to show, takes colors
	---------------------------------------------------------------------------------------
	PrintMessage = function(self, msg)
		if DEFAULT_CHAT_FRAME then
			DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 1, 0)
		end
	end,
	
	---------------------------------------------------------------------------------------
	-- Print out an array to the chatframe
	--
	-- @array:			array		The array to show
	---------------------------------------------------------------------------------------
		-- Prints out all info on a skill (DEBUGGING)
	PrintArray = function (self, array)
		if array == nil then
			self:PrintMessage("Array is empty")
		else
			for i in pairs(array) do
				if type(array[i]) == "table" then
					self:PrintArray(array[i])
				else
					self:PrintMessage(i .. ": " .. array[i])
				end
			end
		end
	end,
	
	---------------------------------------------------------------------------------------
	-- Initialise the core UI
	----------------------------------------------------------------------------------------
	Initialise = function (self)
		local event_frame = CreateFrame("FRAME")
		-- Event thrown when player enters world
		event_frame:RegisterEvent("PLAYER_ENTERING_WORLD")
		-- Event thrown when addon is fully loaded
		event_frame:RegisterEvent("ADDON_LOADED")
		-- Event thrown when a tradeskill window is opened
		event_frame:RegisterEvent("TRADE_SKILL_SHOW")
		-- Event thrown when a tradeskill window is closed
		event_frame:RegisterEvent("TRADE_SKILL_CLOSE")
		-- Event thrown when a skill up is earned for a tradeskill OR new level is learned
		-- Learned Skill from recipe or other update
		event_frame:RegisterEvent("TRADE_SKILL_UPDATE")
		-- Learned Skill from trainer
		event_frame:RegisterEvent("TRAINER_UPDATE")
		-- gained a skill point
		event_frame:RegisterEvent("SKILL_LINES_CHANGED")
		-- For crafts (= Enchanting)
		event_frame:RegisterEvent("CRAFT_UPDATE")	
		event_frame:RegisterEvent("CRAFT_SHOW")
		event_frame:RegisterEvent("CRAFT_CLOSE")
		-- Set function to react on event
		event_frame:SetScript("OnEvent", function ()
			self:HandleEvent(event, arg1)
		end)
	end,
	
	---------------------------------------------------------------------------------------
	-- Toggle visibility of our main frame
	----------------------------------------------------------------------------------------
	ToggleMissingTradeSkillsListFrame = function(self, type)
		if type == "CraftSkill" then
			self.MTSLF_CRAFTSKILL:Toggle()
			-- hide the MTSLF_TRADESKILL if opened and we opeend the craftskill as well
			if self.MTSLF_TRADESKILL ~= nil and self.MTSLF_TRADESKILL:IsVisible() == 1
				and self.MTSLF_CRAFTSKILL:IsVisible() == 1 then
				self.MTSLF_TRADESKILL:Hide()
			end
		else
			self.MTSLF_TRADESKILL:Toggle()
			-- hide the MTSLF_CRAFTSKILL if opened and we opened the TradeSkill as well
			if self.MTSLF_CRAFTSKILL ~= nil and self.MTSLF_CRAFTSKILL:IsVisible() == 1
				and self.MTSLF_TRADESKILL:IsVisible() == 1 then
				self.MTSLF_CRAFTSKILL:Hide()
			end
		end
	end,
}

---------------------------------------------------------------------------------------
-- Start the addon
----------------------------------------------------------------------------------------
MTSLUI_Core:Initialise()
