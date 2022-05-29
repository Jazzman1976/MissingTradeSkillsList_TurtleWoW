----------------------
-- Global Variables --
----------------------

-- Holds all the data filled by the data luas
MTSLDATA = {
	-- Primary Professions (no skinning, herbalism because they don't have a tradeskillframe)
	["Alchemy"] = {},
	["Blacksmithing"] = {},
	["Enchanting"] = {},		-- craft
	["Engineering"] = {},
	["Leatherworking"] = {},
	["Mining"] = {},
	["Tailoring"] = {},
	-- Secundary professions (no fishing because it doesn't have atradeskillframe)
	["Cooking"] = {},
	["First Aid"] = {},
	-- all game items/objects we need in 1 array
	["objects"] = {},
	["npcs"] = {},
	["quests"] = {},
}

-- holds all info about the addon itself
MTSLADDON = {
	AUTHOR = "Thumbkin",
	NAME = "MissingTradeSkillsList",
	VERSION = "TWoW_0.0.0",
}

-- Holds all info about variables used in this addon
MTSL = {
	-- Holds information about the player
	-- Set when addon is loaded event happens
	PLAYER_FACTION,
	-- default 0 (= unknown)
	PLAYER_XP_LEVEL = 0,
	-- Holds missing skills for current tradeskill
	MISSING_SKILLS_AMOUNT,
	MISSING_SKILLS = {},
	-- Holds information on the opened trade skill
	CURRENT_TRADESKILL = {
		NAME,
		AMOUNT_LEARNED,
		SKILL_LEVEL,
		MAX_LEVEL,
		SKILL,
		LEVELS,
		NPCS
	},
	-- array holding all reputation levels
	REPUTATION_LEVELS = {
		Unknown = 0,
		Hated = 1,
		Hostile = 2,
		Unfriendly = 3,
		Neutral= 4,
		Friendly = 5,
		Honored = 6,
		Revered = 7,
		Exalted = 8
	},
	-- Each profession has 4 levels to learn (1-75, 75-150, 150-225, 225-300)
	TRADESKILL_LEVELS = 4,

	---------------------------------------------------------------------------------------
	-- Counts the maximum amount of skills each tradeskill has (DEBUGGING ONLY)
	----------------------------------------------------------------------------------------
	CountTotalSkillsForEachtTradeskill = function (self) 
		for key in MTSL_Tools:GiveKeysSorted(MTSLDATA) do
			-- ignore NPC, objects or quest array
			local amount = 0
			if MTSLDATA[key].skills ~= nil then
				for i in pairs(MTSLDATA[key].skills) do
					amount = amount + 1
				end
				for i in pairs(MTSLDATA[key].levels) do
					amount = amount + 1
				end
				
				-- Count the amount of different type of sources
				MTSLDATA[key].total_skills = amount
			end
		end
	end,
	
	---------------------------------------------------------------------------------------
	-- Gets the number of total skills for a Tradeskill
	--
	-- return		number		Total skills to be  learned for the tradeskill
	---------------------------------------------------------------------------------------
	GetTotalNumberOfSkillsCurrentTradeskill = function(self)
		return MTSLDATA[self.CURRENT_TRADESKILL.NAME].total_skills
	end,
	
	---------------------------------------------------------------------------------------
	-- Gets the XP level of the current logged in player
	--
	-- return		number		The xp level of the player
	---------------------------------------------------------------------------------------
	GetPlayerXpLevel = function (self)
		if self.PLAYER_XP_LEVEL == 0 then
			self.PLAYER_XP_LEVEL = UnitLevel("player")
			retries = 0
			while retries <= 10 and self.PLAYER_XP_LEVEL == 0 do
				self.PLAYER_XP_LEVEL = UnitLevel("player")
				retries = retries + 1
			end
			if retries == 10 then
				MTSLUI_Core:PrintMessage(MTSLUI_Fonts.colors.available.no .. "Could not determine XP level of player! Using 0 as XP level")
				self.PLAYER_XP_LEVEL = 0
			end
		end
		return self.PLAYER_XP_LEVEL
	end,
	
	---------------------------------------------------------------------------------------
	-- Gets the faction of the current logged in player
	--
	-- return		string		The faction of the player
	---------------------------------------------------------------------------------------
	GetPlayerFaction = function (self)
		if self.PLAYER_FACTION == nil or self.PLAYER_FACTION == "Neutral" then
			self.PLAYER_FACTION = UnitFactionGroup("player")
			retries = 0
			while retries <= 10 and (self.PLAYER_FACTION == nil or self.PLAYER_FACTION == "Neutral") do
				self.PLAYER_FACTION = UnitFactionGroup("player")
				retries = retries + 1
			end
			if retries == 10 then
				MTSLUI_Core:PrintMessage(MTSLUI_Fonts.colors.available.no .. "Could not determine faction of player! Faction set to Neutral")
				self.PLAYER_FACTION = "Neutral"
			end
		end
		return self.PLAYER_FACTION
	end,
	
	
	----------------------------------------------------------------------------------------
	-- Gives the level of the standing (0-8) with a certain faction
	--
	-- @faction_name	String		The name of the faction
	--
	-- return			number		The standing with the rep (0-8) for the faction
	-----------------------------------------------------------------------------------------
	GetReputationLevelWithFaction = function (self, faction_name)
		for factionIndex = 1, GetNumFactions() do
			name, description, standingId, bottomValue, topValue, earnedValue, atWarWith,
				canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(factionIndex)
			if isHeader == nil and name == faction_name then	
				return standingId
			end
		end
		-- Not found so return 0 = "Unknown"
		return 0
	end,
	
	----------------------------------------------------------------------------------------
	-- Gives the name of the replevel based on the standing (0-8)
	--
	-- @rep_id		number		The standing with the rep (0-8)
	--
	-- return		String		The name of the replevel
	-----------------------------------------------------------------------------------------
	GetReputationLevelNameById = function (self, rep_id)		
		for k, v in pairs(MTSL.REPUTATION_LEVELS) do
			if v == rep_id then
				return k
			end
		end
		-- Not found so return "Unknown"
		return "Unknown"
	end,
	
	----------------------------------------------------------------------------------------
	-- Gives the level of the standing (0-8) based on the name of the level	
	--
	-- @rep_name	String		The name of the replevel
	--
	-- return		number		The standing with the rep (0-8)
	-----------------------------------------------------------------------------------------
	GetReputationLevelByLevelName = function (self, rep_name)		
		if MTSL.REPUTATION_LEVELS[rep_name] ~= nil then
			return MTSL.REPUTATION_LEVELS[rep_name]
		end
		-- Not found so return 0 = "Unknown"
		return 0
	end,

	----------------------------------------------------------------------------------------
	-- Searches for tradeskills the player hasn't learned yet and add them to list	
	-----------------------------------------------------------------------------------------
	SearchMissingTradeSkills = function (self)
		-- Clear the current list
		self.MISSING_SKILLS = {}
		self.MISSING_SKILLS_AMOUNT = 0
		-- Loop all available skills
		for i=1,self:GetTotalNumberOfSkillsCurrentTradeskill() do
			local skill = self:GetSkillCurrentTradeSkillByIndex(i)
			-- There is a skill and we dont know it yet
			if skill ~= nil and self:IsTradeSkillKnown(skill.name) == 0 then
				local skill = self:GetSkillCurrentTradeSkillById(skill.id)
				table.insert(self.MISSING_SKILLS, skill)
				self.MISSING_SKILLS_AMOUNT = self.MISSING_SKILLS_AMOUNT + 1
			end	
		
		end
		-- Search for the missing levels
		local levels = self:GetLevelsCurrentTradeskill()
		-- Skip the known levels
		for i=1,self.TRADESKILL_LEVELS do
			-- Level not learned so add to tabel
			if levels[i].max_skill > self.CURRENT_TRADESKILL.MAXLEVEL then
				-- Insert at the right index
				local j = 1
				while j <= self.MISSING_SKILLS_AMOUNT and self.MISSING_SKILLS[j].min_skill < levels[i].min_skill do
					j = j + 1
				end
				table.insert(self.MISSING_SKILLS, j, levels[i])
				self.MISSING_SKILLS_AMOUNT = self.MISSING_SKILLS_AMOUNT + 1
			end
		end
	end,
	
	----------------------------------------------------------------------------------------
	-- Searches for craftskills the player hasn't learned yet and add them to list	
	-----------------------------------------------------------------------------------------
	SearchMissingCraftSkills = function (self)
		-- Clear the current list
		self.MISSING_SKILLS = {}
		self.MISSING_SKILLS_AMOUNT = 0
		-- Loop all available skills
		for i=1,self:GetTotalNumberOfSkillsCurrentTradeskill() do
			local skill = self:GetSkillCurrentTradeSkillByIndex(i)
			-- There is a skill and we dont know it yet
			if skill ~= nil and self:IsCraftSkillKnown(skill.name) == 0 then
				local skill = self:GetSkillCurrentTradeSkillById(skill.id)
				table.insert(self.MISSING_SKILLS, skill)
				self.MISSING_SKILLS_AMOUNT = self.MISSING_SKILLS_AMOUNT + 1
			end	
		
		end
		-- Search for the missing levels
		local levels = self:GetLevelsCurrentTradeskill()
		-- Skip the known levels
		for i=1,self.TRADESKILL_LEVELS do
			-- Level not learned so add to tabel
			if levels[i].max_skill > self.CURRENT_TRADESKILL.MAXLEVEL then
				-- Insert at the right index
				local j = 1
				while j <= self.MISSING_SKILLS_AMOUNT and self.MISSING_SKILLS[j].min_skill < levels[i].min_skill do
					j = j + 1
				end
				table.insert(self.MISSING_SKILLS, j, levels[i])
				self.MISSING_SKILLS_AMOUNT = self.MISSING_SKILLS_AMOUNT + 1
			end
		end
	end,

	-------------------------------------------------------------------------------
	-- Refreshes the info for the current opened tradeskill frame
	-------------------------------------------------------------------------------
	UpdateCurrentTradeSkillInfo = function (self)
		local trade_skill_name, current_level, max_level = GetTradeSkillLine()
		self.CURRENT_TRADESKILL.NAME = trade_skill_name
		self.CURRENT_TRADESKILL.SKILL_LEVEL = current_level
		self.CURRENT_TRADESKILL.MAXLEVEL = max_level
	end,
	
	-------------------------------------------------------------------------------
	-- Refreshes the info for the current opened craftskill frame
	-------------------------------------------------------------------------------
	UpdateCurrentCraftInfo = function (self)
		local trade_skill_name, current_level, max_level = GetCraftDisplaySkillLine()
		self.CURRENT_TRADESKILL.NAME = trade_skill_name
		self.CURRENT_TRADESKILL.SKILL_LEVEL = current_level
		self.CURRENT_TRADESKILL.MAXLEVEL = max_level
	end,
	
	-----------------------------------------------------------------------------------------------
	-- Checks if a certain skill is learned for the current tradeskil
	--
	-- @search_skill_name	String		The name of the skill to search
	--
	-- return				number		Flag that indicates if skill is learned (1 = yes, 0 = no)
	------------------------------------------------------------------------------------------------
	IsTradeSkillKnown = function (self, search_skill_name)
		local skillName, skillType
		-- Loop all known skills until we find it
		for i=1,GetNumTradeSkills() do
			skillName, skillType = GetTradeSkillInfo(i)
			-- Skip the headers, only check real skills
			if skillName ~= nil and skillType ~= "header" and 
				search_skill_name == skillName then
				return 1
			end
		end
		-- Skill not found so return false
		return 0
	end,
	
	
	-----------------------------------------------------------------------------------------------
	-- Checks if a certain skill is learned for the current craftskill
	--
	-- @search_skill_name	String		The name of the skill to search
	--
	-- return				number		Flag that indicates if skill is learned (1 = yes, 0 = no)
	------------------------------------------------------------------------------------------------
	IsCraftSkillKnown = function (self, search_skill_name)
		local skillName, skillType
		-- Loop all known skills until we find it
		for i=1,GetNumCrafts() do
			skillName, skillType = GetCraftInfo(i)
			-- Skip the headers, only check real skills
			if skillName ~= nil and skillType ~= "header" and 
				search_skill_name == skillName then
				return 1
			end
		end
		-- Skill not found so return false
		return 0
	end,

	----------------------------------------------------------------------------
	-- Gets the number of current learned skils in the tradeskill window that is opened
	--
	-- return				Number		Amount of learned skills
	------------------------------------------------------------------------------------------------
	GetAmountOfTradeSkillsLearned = function(self)
		local skillName, skillType
		local amount = 0
		for i=1,GetNumTradeSkills() do
			skillName, skillType = GetTradeSkillInfo(i)
			-- Skip the headers, only count real skills
			if (skillName and skillType ~= "header") then
				amount = amount + 1
			end
		end

		return amount
	end,

	-----------------------------------------------------------------------------------------------
	-- Gets a list of all skills  for the current Tradeskill
	--
	-- return				Array		List of skills for current tradeskill
	------------------------------------------------------------------------------------------------
	GetSkillsCurrentTradeskill = function (self)
		return MTSLDATA[self.CURRENT_TRADESKILL.NAME].skills
	end,
	
	-----------------------------------------------------------------------------------------------
	-- Gets a list of all levels for the current Tradeskill
	--
	-- return				Array		List of levels for current tradeskill
	------------------------------------------------------------------------------------------------
	GetLevelsCurrentTradeskill = function (self)
		return MTSLDATA[self.CURRENT_TRADESKILL.NAME].levels
	end,
	
	-----------------------------------------------------------------------------------------------
	-- Gets a list of all recipes for the current Tradeskill
	--
	-- return				Array		List of skills for recipes tradeskill
	------------------------------------------------------------------------------------------------
	GetRecipesCurrentTradeskill = function (self)
		return MTSLDATA[self.CURRENT_TRADESKILL.NAME].recipes
	end,
	
	-----------------------------------------------------------------------------------------------
	-- Gets a list of all npcs (based on their ids) available to the player's faction
	--
	-- @ids					Array		The ids of NPCs to search
	--
	-- return				Array		List of found NPCs
	------------------------------------------------------------------------------------------------
	GetNpcsByIds = function(self, ids)
		local npcs = {}
				
		local i = 1
		while ids[i] ~= nil do
			local npc = self:GetNpcById(ids[i])
			-- If we found one, check if the faction is valid (= neutral OR the same faction as player
			if npc ~= nil then
				if self.PLAYER_FACTION == npc.reacts or npc.reacts == "Neutral" then
					table.insert(npcs, npc)
				end
			end

			-- Check next id
			i = i + 1
		end
		
		-- Sort the mobs by name in the table
		table.sort(npcs, function(a,b) return a.name < b.name end)

		-- Return the found npcs
		return npcs
	end,
	
	-----------------------------------------------------------------------------------------------
	-- Gets a list of all items (based on their ids) 
	--
	-- @ids					Array		The ids of items to search
	--
	-- return				Array		List of found items
	------------------------------------------------------------------------------------------------
	GetItemsCurrentTradeSkillByIds = function(self, ids)
		local items = {}
				
		local i = 1
		while ids[i] ~= nil do
			local item = self:GetItemCurrentTradeSkillById(ids[i])
			-- If we found one add to list
			if item ~= nil then
				table.insert(items, item)
			end

			-- Check next id
			i = i + 1
		end
		
		-- Sort the items by name in the table
		table.sort(items, function(a,b) return a.name < b.name end)

		-- Return the found items
		return items
	end,
	
	-----------------------------------------------------------------------------------------------
	-- Gets a list of all objects (based on their ids) 
	--
	-- @ids					Array		The ids of objects to search
	--
	-- return				Array		List of found items
	------------------------------------------------------------------------------------------------
	GetObjectsByIds = function(self, ids)
		local objects = {}
				
		local i = 1
		while ids[i] ~= nil do
			local object = self:GetObjectById(ids[i])
			-- If we found one add to list
			if object ~= nil then
				table.insert(objects, object)
			end

			-- Check next id
			i = i + 1
		end
		
		-- Sort the objects by name in the table
		table.sort(objects, function(a,b) return a.name < b.name end)

		-- Return the found objects
		return objects
	end,

	-----------------------------------------------------------------------------------------------
	-- Gets a list of all drop mobs (based on their ids) for the current Tradeskill
	--
	-- @ids					Array		The ids of mobs to search
	--
	-- return				Array		List of found mobs
	------------------------------------------------------------------------------------------------
	GetMobsByIds = function(self, ids)
		local mobs = {}

		local i = 1

		while ids[i] ~= nil do
			local mob = self:GetNpcById(ids[i])
			-- Check if we found one
			if mob ~= nil then
				-- only add mob if player can attack it
				if mob.reacts ~= self.PLAYER_FACTION then
					table.insert(mobs, mob)
				end
			end
			-- Check next id
			i = i + 1
		end

		-- Sort the mobs by name in the table
		table.sort(mobs, function(a,b) return a.name < b.name end)

		-- Return the found npcs
		return mobs
	end,
		
	-----------------------------------------------------------------------------------------------
	-- Gets an NPC (based on it's id) for the current Tradeskill
	--
	-- @id				Number		The id of the NPC to search
	--
	-- return			Object		Found NPC (nil if not found)
	------------------------------------------------------------------------------------------------
	GetNpcById = function(self, id)
		return MTSL_Tools:GetItemFromSortedListById(MTSLDATA.npcs, id)
	end,
			
	-----------------------------------------------------------------------------------------------
	-- Gets an object (based on it's id)
	--
	-- @id				Number		The id of the item to search
	--
	-- return			Object		Found item (nil if not found)
	------------------------------------------------------------------------------------------------
	GetObjectById = function(self, id)
		return MTSL_Tools:GetItemFromSortedListById(MTSLDATA.objects, id)
	end,

	-----------------------------------------------------------------------------------------------
	-- Gets a quest available to the player's faction (based on it's ids)
	--
	-- @id				Number		The ids of the quests to search
	--
	-- return			Object		Found quest (nil if not found)
	------------------------------------------------------------------------------------------------
	GetQuestByIds = function(self, ids)
		local i = 1

		while ids[i] ~= nil do
			quest = MTSL_Tools:GetItemFromSortedListById(MTSLDATA.quests, ids[i])
			-- Check if q started from NPC
			if quest ~= nil then
				if quest.npcs ~= nil then
					npcs = self:GetNpcsByIds(quest.npcs)
					if npcs == nil  then 
						MTSLUI_Core:PrintMessage(MTSLUI_Fonts.colors.text.error .. "NPC for Quest with id " .. ids[i] .. " not found! Report this error!")
					else
						-- only 1 NPC possible
						local npc = npcs[1]
						-- check if we are able to interact with npc
						if npc ~= nil then
							if npc.reacts == "Neutral" or npc.reacts == self:GetPlayerFaction() then
								return quest
							end
						end
					end
				-- Started from item/object so available to all
				else
					return quest
				end
			else
				MTSLUI_Core:PrintMessage(MTSLUI_Fonts.colors.text.error .. "Quest with id " .. ids[i] .. " not found! Report this error!")
			end

			i = i + 1
		end		

		return nil
	end,
	
	----------------------------------------------------------------------------------------------
	-- Gets an item (based on it's id) for the current Tradeskill
	--
	-- @id				Number		The id of the recipe to search
	--
	-- return			Object		Found item (nil if not found)
	------------------------------------------------------------------------------------------------
	GetItemCurrentTradeSkillById = function(self, id)
		return MTSL_Tools:GetItemFromSortedListById(MTSLDATA[self.CURRENT_TRADESKILL.NAME].items, id)
	end,
	
	-----------------------------------------------------------------------------------------------
	-- Gets a skill (based on it's index in list of all skills) for the current Tradeskill
	--
	-- @index			Number		The index of the skill to search
	--
	-- return			Object		Found skill (nil if not  in list)
	------------------------------------------------------------------------------------------------
	GetSkillCurrentTradeSkillByIndex = function(self, index)
		local all_skills = self:GetSkillsCurrentTradeskill()
		return all_skills[index]
	end,

	-----------------------------------------------------------------------------------------------
	-- Gets a missing skill (based on it's index in list of all skills) for the current Tradeskill
	--
	-- @index			Number		The index of the skill to search
	--
	-- return			Object		Found skill (nil if not  in list)
	------------------------------------------------------------------------------------------------
	GetMissingSkillCurrentTradeSkillByIndex = function(self, index)
		return self.MISSING_SKILLS[index]
	end,

	-----------------------------------------------------------------------------------------------
	-- Gets a skill (based on it's id) for the current Tradeskill
	--
	-- @id				Number		The id of the skill to search
	--
	-- return			Object		Found skill (nil if not  in list)
	------------------------------------------------------------------------------------------------
	GetSkillCurrentTradeSkillById = function(self, skill_id)
		local total_number_skills = self:GetTotalNumberOfSkillsCurrentTradeskill()
		local all_skills = self:GetSkillsCurrentTradeskill()
		for i=1,total_number_skills do
			if all_skills ~= nil and all_skills[i].id == skill_id then
				return all_skills[i]
			end
		end
	end,
}