--########### armor and Debuff Frame
--########### By Atreyyo @ Vanillagaming.org

aDF = CreateFrame('Button', "aDF", UIParent); -- Event Frame
aDF.Options = CreateFrame("Frame",nil,UIParent) -- Options frame

--register events 
aDF:RegisterEvent("ADDON_LOADED")
aDF:RegisterEvent("UNIT_AURA")
aDF:RegisterEvent("PLAYER_TARGET_CHANGED")

-- tables 
aDF_frames = {} -- we will put all debuff frames in here
gui_Options = gui_Options or {} -- checklist options
gui_Optionsxy = gui_Optionsxy or 1
gui_chantbl = {
   "Say",
   "Yell",
   "Party",
   "Raid",
   "Raid_Warning"
 }

-- translation table for debuff check on target

aDFSpells = {
	["Sunder Armor"] = "Sunder Armor",
	["Armor Shatter"] = "Armor Shatter",
	["Faerie Fire"] = "Faerie Fire",
	["Crystal Yield"] = "Crystal Yield",
	["Nightfall"] = "Spell Vulnerability",
	["Scorch"] = "Fire Vulnerability",
	["Ignite"] = "Ignite",
	["Curse of Recklessness"] = "Curse of Recklessness",
	["Curse of the Elements"] = "Curse of the Elements",
	["Curse of Shadows"] = "Curse of Shadow",
	["Shadow Bolt"] = "Shadow Vulnerability",
	["Shadow Weaving"] = "Shadow Weaving",
	["Mage T3 6/9 Bonus"] = "Elemental Vulnerability",
	["Vampiric Embrace"] = "Vampiric Embrace", 
}

-- table with names and textures 

aDFDebuffs = {
	["Sunder Armor"] = "Interface\\Icons\\Ability_Warrior_Sunder",
	["Armor Shatter"] = "Interface\\Icons\\INV_Axe_12",
	["Faerie Fire"] = "Interface\\Icons\\Spell_Nature_FaerieFire",
	["Crystal Yield"] = "Interface\\Icons\\INV_Misc_Gem_Amethyst_01",
	["Elemental Vulnerability"] = "Interface\\Icons\\Spell_Holy_Dizzy",
	["Nightfall"] = "Interface\\Icons\\Spell_Holy_ElunesGrace",
	["Scorch"] = "Interface\\Icons\\Spell_Fire_SoulBurn",
	["Ignite"] = "Interface\\Icons\\Spell_Fire_Incinerate",
	["Curse of Recklessness"] = "Interface\\Icons\\Spell_Shadow_UnholyStrength",
	["Curse of the Elements"] = "Interface\\Icons\\Spell_Shadow_ChillTouch",
	["Curse of Shadows"] = "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde",
	["Shadow Bolt"] = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
	["Shadow Weaving"] = "Interface\\Icons\\Spell_Shadow_BlackPlague",
	["Vampiric Embrace"] = "Interface\\Icons\\Spell_Shadow_UnsummonBuilding",
}

function aDF_Default()
	if gui_Options == nil then
		for k,v in pairs(aDFDebuffs) do
			if gui_Options[k] = nil then
				gui_Options[k] = 1
			end
		end
	end
}

-- the main frame

function aDF:Init()
	aDF.Drag = { }
	function aDF.Drag:StartMoving()
		this:StartMoving()
	end
	
	function aDF.Drag:StopMovingOrSizing()
		this:StopMovingOrSizing()
		local x, y = this:GetCenter()
		local ux, uy = UIParent:GetCenter()
		aDF_x, aDF_y = floor(x - ux + 0.5), floor(y - uy + 0.5)
	end
	
	local backdrop = {
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			tile="false",
			tileSize="8",
			edgeSize="8",
			insets={
				left="2",
				right="2",
				top="2",
				bottom="2"
			}
	}
	
	self:SetFrameStrata("BACKGROUND")
	self:SetWidth((24+gui_Optionsxy)*7) -- Set these to whatever height/width is needed 
	self:SetHeight(24+gui_Optionsxy) -- for your Texture
	self:SetPoint("CENTER",aDF_x,aDF_y)
	self:SetMovable(1)
	self:EnableMouse(1)
	self:RegisterForDrag("LeftButton")
	self:SetBackdrop(backdrop) --border around the frame
	self:SetBackdropColor(0,0,0,1)
	self:SetScript("OnDragStart", aDF.Drag.StartMoving)
	self:SetScript("OnDragStop", aDF.Drag.StopMovingOrSizing)
	self:SetScript("OnMouseDown", function()
		if (arg1 == "RightButton") then
			if aDF_target ~= nil then
				if UnitAffectingCombat(aDF_target) and UnitCanAttack("player", aDF_target) then	
					SendChatMessage(UnitName(aDF_target).." has ".. UnitResistance(aDF_target,0).." armor", gui_chan) 
				end
			end
		end
	end)
	
	-- Armor text
	self.armor = self:CreateFontString(nil, "OVERLAY")
    self.armor:SetPoint("CENTER", self, "CENTER", 0, 0)
    self.armor:SetFont("Fonts\\FRIZQT__.TTF", 24+gui_Optionsxy)
	self.armor:SetShadowOffset(2,-2)
    self.armor:SetText("aDF")

	-- Resistance text
	self.res = self:CreateFontString(nil, "OVERLAY")
    self.res:SetPoint("CENTER", self, "CENTER", 0, 20+gui_Optionsxy)
    self.res:SetFont("Fonts\\FRIZQT__.TTF", 14+gui_Optionsxy)
	self.res:SetShadowOffset(2,-2)
    self.res:SetText("Resistance")
	
	-- for the debuff check function
	aDF_tooltip = CreateFrame("GAMETOOLTIP", "buffScan")
	aDF_tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	aDF_tooltipTextL = aDF_tooltip:CreateFontString()
	aDF_tooltipTextR = aDF_tooltip:CreateFontString()
	aDF_tooltip:AddFontStrings(aDF_tooltipTextL,aDF_tooltipTextR)
	--R = tip:CreateFontString()
	--
	
	f_ =  0
	for name,texture in pairs(aDFDebuffs) do
		aDFsize = 24+gui_Optionsxy
		aDF_frames[name] = aDF_frames[name] or aDF.Create_frame(name)
		local frame = aDF_frames[name]
		frame:SetWidth(aDFsize)
		frame:SetHeight(aDFsize)
		frame:SetPoint("BOTTOMLEFT",aDFsize*f_,-aDFsize)
		frame.icon:SetTexture(texture)
		frame:SetFrameLevel(2)
		frame:Show()
		frame:SetScript("OnEnter", function() 
			GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT");
			GameTooltip:SetText(this:GetName(), 255, 255, 0, 1, 1);
			GameTooltip:Show()
			end)
		frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
		frame:SetScript("OnMouseDown", function()
			if (arg1 == "RightButton") then
				tdb=this:GetName()
				if aDF_target ~= nil then
					if UnitAffectingCombat(aDF_target) and UnitCanAttack("player", aDF_target) and guiOptions[tdb] ~= nil then
						if not aDF:GetDebuff(aDF_target,aDFSpells[tdb]) then
							SendChatMessage("["..tdb.."] is not active on "..UnitName(aDF_target), gui_chan)
						else
							if aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) == 1 then
								s_ = "stack"
							elseif aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) > 1 then
								s_ = "stacks"
							end
							if aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) >= 1 and aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) < 5 and tdb ~= "Armor Shatter" then
								SendChatMessage(UnitName(aDF_target).." has "..aDF:GetDebuff(aDF_target,aDFSpells[tdb],1).." ["..tdb.."] "..s_, gui_chan)
							end
							if tdb == "Armor Shatter" and aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) >= 1 and aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) < 3 then
								SendChatMessage(UnitName(aDF_target).." has "..aDF:GetDebuff(aDF_target,aDFSpells[tdb],1).." ["..tdb.."] "..s_, gui_chan)
							end
						end
					end
				end
			end
		end)
		f_ = f_+1
	end
end

-- creates the debuff frames on load

function aDF.Create_frame(name)
	local frame = CreateFrame('Button', name, aDF)
	frame:SetBackdrop({ bgFile=[[Interface/Tooltips/UI-Tooltip-Background]] })
	frame:SetBackdropColor(0,0,0,1)
	frame.icon = frame:CreateTexture(nil, 'ARTWORK')
	frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	frame.icon:SetPoint('TOPLEFT', 1, -1)
	frame.icon:SetPoint('BOTTOMRIGHT', -1, 1)
	frame.nr = frame:CreateFontString(nil, "OVERLAY")
	frame.nr:SetPoint("CENTER", frame, "CENTER", 0, 0)
	frame.nr:SetFont("Fonts\\FRIZQT__.TTF", 16+gui_Optionsxy)
	frame.nr:SetTextColor(255, 255, 0, 1)
	frame.nr:SetShadowOffset(2,-2)
	frame.nr:SetText("1")
	--DEFAULT_CHAT_FRAME:AddMessage("----- Adding new frame")
	return frame
end

-- update function for the text/debuff frames

function aDF:Update()
	if aDF_target ~= nil then
--		aDF.armor:SetText(UnitResistance(aDF_target,0).." ["..math.floor(((UnitResistance(aDF_target,0) / (467.5 * UnitLevel("player") + UnitResistance(aDF_target,0) - 22167.5)) * 100),1).."%]")
		aDF.armor:SetText(UnitResistance(aDF_target,0))
		if gui_Options["Resistances"] == 1 then
			aDF.res:SetText("|cffFF0000FR "..UnitResistance(aDF_target,2).." |cff00FF00NR "..UnitResistance(aDF_target,3).." |cff4AE8F5FrR "..UnitResistance(aDF_target,4).." |cff800080SR "..UnitResistance(aDF_target,5))
		else
			aDF.res:SetText("")
		end
		for i,v in pairs(guiOptions) do
			if aDF:GetDebuff(aDF_target,aDFSpells[i]) then
				aDF_frames[i]["icon"]:SetAlpha(1)
				if aDF:GetDebuff(aDF_target,aDFSpells[i],1) > 1 then
					aDF_frames[i]["nr"]:SetText(aDF:GetDebuff(aDF_target,aDFSpells[i],1))
				end
			else
				aDF_frames[i]["icon"]:SetAlpha(0.3)
				aDF_frames[i]["nr"]:SetText("")
			end		
		end
	else
		aDF.armor:SetText("")
		aDF.res:SetText("")
		for i,v in pairs(guiOptions) do
			aDF_frames[i]["icon"]:SetAlpha(0.3)
			aDF_frames[i]["nr"]:SetText("")
		end
	end
end

function aDF:UpdateCheck()
	if utimer == nil or (GetTime() - utimer > 0.8) and UnitIsPlayer("target") then
		utimer = GetTime()
		aDF:Update()
	end
end

-- Sort function to show/hide frames aswell as positioning them correctly

function aDF:Sort()
	for name,_ in pairs(aDFDebuffs) do
		if guiOptions[name] == nil then
			aDF_frames[name]:Hide()
		else
			aDF_frames[name]:Show()
		end
	end
	local aDFTempTable = {}
	for dbf,_ in pairs(guiOptions) do
		table.insert(aDFTempTable,dbf)
	end
	table.sort(aDFTempTable, function(a,b) return a<b end)
	for n, v in pairs(aDFTempTable) do
			if n > 7 then
			y_=-((24+gui_Optionsxy)*2)
			x_=(n-1)-7
			aDF_frames[v]:SetPoint('BOTTOMLEFT',(24+gui_Optionsxy)*x_,y_)
		else
			y_=-(24+gui_Optionsxy)
			aDF_frames[v]:SetPoint('BOTTOMLEFT',(24+gui_Optionsxy)*(n-1),y_)
		end
	end
end

-- Options frame

function aDF.Options:Gui()

	aDF.Options.Drag = { }
	function aDF.Options.Drag:StartMoving()
		this:StartMoving()
	end
	
	function aDF.Options.Drag:StopMovingOrSizing()
		this:StopMovingOrSizing()
	end

	local backdrop = {
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			tile="false",
			tileSize="4",
			edgeSize="8",
			insets={
				left="2",
				right="2",
				top="2",
				bottom="2"
			}
	}
	
	self:SetFrameStrata("BACKGROUND")
	self:SetWidth(400) -- Set these to whatever height/width is needed 
	self:SetHeight(450) -- for your Texture
	self:SetPoint("CENTER",0,0)
	self:SetMovable(1)
	self:EnableMouse(1)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", aDF.Options.Drag.StartMoving)
	self:SetScript("OnDragStop", aDF.Options.Drag.StopMovingOrSizing)
	self:SetBackdrop(backdrop) --border around the frame
	self:SetBackdropColor(0,0,0,1);
	
	-- Options text
	
	self.text = self:CreateFontString(nil, "OVERLAY")
    self.text:SetPoint("CENTER", self, "CENTER", 0, 180)
    self.text:SetFont("Fonts\\FRIZQT__.TTF", 25)
	self.text:SetTextColor(255, 255, 0, 1)
	self.text:SetShadowOffset(2,-2)
    self.text:SetText("Options")
	
	-- mid line
	
	self.left = self:CreateTexture(nil, "BORDER")
	self.left:SetWidth(125)
	self.left:SetHeight(2)
	self.left:SetPoint("CENTER", -62, 160)
	self.left:SetTexture(1, 1, 0, 1)
	self.left:SetGradientAlpha("Horizontal", 0, 0, 0, 0, 102, 102, 102, 0.6)

	self.right = self:CreateTexture(nil, "BORDER")
	self.right:SetWidth(125)
	self.right:SetHeight(2)
	self.right:SetPoint("CENTER", 63, 160)
	self.right:SetTexture(1, 1, 0, 1)
	self.right:SetGradientAlpha("Horizontal", 255, 255, 0, 0.6, 0, 0, 0, 0)
	
	-- slider

	self.Slider = CreateFrame("Slider", "aDF Slider", self, 'OptionsSliderTemplate')
	self.Slider:SetWidth(200)
	self.Slider:SetHeight(20)
	self.Slider:SetPoint("CENTER", self, "CENTER", 0, 140)
	self.Slider:SetMinMaxValues(1, 10)
	self.Slider:SetValue(gui_Optionsxy)
	self.Slider:SetValueStep(1)
	getglobal(self.Slider:GetName() .. 'Low'):SetText('1')
	getglobal(self.Slider:GetName() .. 'High'):SetText('10')
	--getglobal(self.Slider:GetName() .. 'Text'):SetText('Frame size')
	self.Slider:SetScript("OnValueChanged", function() 
		gui_Optionsxy = this:GetValue()
		for _, frame in pairs(aDF_frames) do
			frame:SetWidth(24+gui_Optionsxy)
			frame:SetHeight(24+gui_Optionsxy)
			frame.nr:SetFont("Fonts\\FRIZQT__.TTF", 16+gui_Optionsxy)
		end
		aDF:SetWidth((24+gui_Optionsxy)*7)
		aDF:SetHeight(24+gui_Optionsxy)
		aDF.armor:SetFont("Fonts\\FRIZQT__.TTF", 24+gui_Optionsxy)
		aDF.res:SetFont("Fonts\\FRIZQT__.TTF", 14+gui_Optionsxy)
		aDF.res:SetPoint("CENTER", aDF, "CENTER", 0, 20+gui_Optionsxy)
		aDF:Sort()
	end)
	self.Slider:Show()
	
	-- checkboxes
	
	--Sunder
	self.SunderCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
	self.SunderCheckbox:SetPoint("TOPLEFT",130,-80)
	self.SunderCheckbox:SetFrameStrata("LOW")
	self.SunderCheckbox:SetScript("OnClick", function () 
		if self.SunderCheckbox:GetChecked() == nil then 
			guiOptions["Sunder Armor"] = nil
		elseif self.SunderCheckbox:GetChecked() == 1 then 
			guiOptions["Sunder Armor"] = 1 
			table.sort(guiOptions)
		end
		aDF:Sort()
		aDF:Update()
		end)
	self.SunderCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(self.SunderCheckbox, "ANCHOR_RIGHT");
		GameTooltip:SetText("Sunder Armor", 255, 255, 0, 1, 1);
		GameTooltip:Show()
	end)
	self.SunderCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.SunderCheckbox:SetChecked(guiOptions["Sunder Armor"])
	self.SunderIcon = self.SunderCheckbox:CreateTexture(nil, 'ARTWORK')
	self.SunderIcon:SetTexture(aDFDebuffs["Sunder Armor"])
	self.SunderIcon:SetWidth(25)
	self.SunderIcon:SetHeight(25)
	self.SunderIcon:SetPoint("CENTER",-30,0)
	
	--Armor Shatter
	self.AnniCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
	self.AnniCheckbox:SetPoint("TOPLEFT",130,-120)
	self.AnniCheckbox:SetFrameStrata("LOW")
	self.AnniCheckbox:SetScript("OnClick", function () 
		if self.AnniCheckbox:GetChecked() == nil then 
			guiOptions["Armor Shatter"] = nil
		elseif self.AnniCheckbox:GetChecked() == 1 then 
			guiOptions["Armor Shatter"] = 1 
			table.sort(guiOptions)
		end
		aDF:Sort()
		aDF:Update()
		end)
	self.AnniCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(self.AnniCheckbox, "ANCHOR_RIGHT");
		GameTooltip:SetText("Armor Shatter", 255, 255, 0, 1, 1);
		GameTooltip:Show()
	end)
	self.AnniCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.AnniCheckbox:SetChecked(guiOptions["Armor Shatter"])
	self.AnniIcon = self.AnniCheckbox:CreateTexture(nil, 'ARTWORK')
	self.AnniIcon:SetTexture(aDFDebuffs["Armor Shatter"])
	self.AnniIcon:SetWidth(25)
	self.AnniIcon:SetHeight(25)
	self.AnniIcon:SetPoint("CENTER",-30,0)
	
	--Faerie Fire
	self.FFCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
	self.FFCheckbox:SetPoint("TOPLEFT",130,-160)
	self.FFCheckbox:SetFrameStrata("LOW")
	self.FFCheckbox:SetScript("OnClick", function () 
		if self.FFCheckbox:GetChecked() == nil then 
			guiOptions["Faerie Fire"] = nil
		elseif self.FFCheckbox:GetChecked() == 1 then 
			guiOptions["Faerie Fire"] = 1 
			table.sort(guiOptions)
		end
		aDF:Sort()
		aDF:Update()
		end)
	self.FFCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(self.FFCheckbox, "ANCHOR_RIGHT");
		GameTooltip:SetText("Faerie Fire", 255, 255, 0, 1, 1);
		GameTooltip:Show()
	end)
	self.FFCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.FFCheckbox:SetChecked(guiOptions["Faerie Fire"])
	self.FFIcon = self.FFCheckbox:CreateTexture(nil, 'ARTWORK')
	self.FFIcon:SetTexture(aDFDebuffs["Faerie Fire"])
	self.FFIcon:SetWidth(25)
	self.FFIcon:SetHeight(25)
	self.FFIcon:SetPoint("CENTER",-30,0)
	
	--Crystal Yield
	self.CrystalCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
	self.CrystalCheckbox:SetPoint("TOPLEFT",130,-200)
	self.CrystalCheckbox:SetFrameStrata("LOW")
	self.CrystalCheckbox:SetScript("OnClick", function () 
		if self.CrystalCheckbox:GetChecked() == nil then 
			guiOptions["Crystal Yield"] = nil
		elseif self.CrystalCheckbox:GetChecked() == 1 then 
			guiOptions["Crystal Yield"] = 1 
			table.sort(guiOptions)
		end
		aDF:Sort()
		aDF:Update()
		end)
	self.CrystalCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(self.CrystalCheckbox, "ANCHOR_RIGHT");
		GameTooltip:SetText("Crystal Yield", 255, 255, 0, 1, 1);
		GameTooltip:Show()
	end)
	self.CrystalCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.CrystalCheckbox:SetChecked(guiOptions["Crystal Yield"])
	self.CrystalIcon = self.CrystalCheckbox:CreateTexture(nil, 'ARTWORK')
	self.CrystalIcon:SetTexture(aDFDebuffs["Crystal Yield"])
	self.CrystalIcon:SetWidth(25)
	self.CrystalIcon:SetHeight(25)
	self.CrystalIcon:SetPoint("CENTER",-30,0)

	--Nightfall
	self.NfallCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
	self.NfallCheckbox:SetPoint("TOPLEFT",130,-240)
	self.NfallCheckbox:SetFrameStrata("LOW")
	self.NfallCheckbox:SetScript("OnClick", function () 
		if self.NfallCheckbox:GetChecked() == nil then 
			guiOptions["Nightfall"] = nil
		elseif self.NfallCheckbox:GetChecked() == 1 then 
			guiOptions["Nightfall"] = 1 
			table.sort(guiOptions)
		end
		aDF:Sort()
		aDF:Update()
		end)
	self.NfallCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(self.NfallCheckbox, "ANCHOR_RIGHT");
		GameTooltip:SetText("Nightfall", 255, 255, 0, 1, 1);
		GameTooltip:Show()
	end)
	self.NfallCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.NfallCheckbox:SetChecked(guiOptions["Nightfall"])
	self.NfallIcon = self.NfallCheckbox:CreateTexture(nil, 'ARTWORK')
	self.NfallIcon:SetTexture(aDFDebuffs["Nightfall"])
	self.NfallIcon:SetWidth(25)
	self.NfallIcon:SetHeight(25)
	self.NfallIcon:SetPoint("CENTER",-30,0)

	--Scorch
	self.ScorchCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
	self.ScorchCheckbox:SetPoint("TOPLEFT",130,-280)
	self.ScorchCheckbox:SetFrameStrata("LOW")
	self.ScorchCheckbox:SetScript("OnClick", function () 
		if self.ScorchCheckbox:GetChecked() == nil then 
			guiOptions["Scorch"] = nil
		elseif self.ScorchCheckbox:GetChecked() == 1 then 
			guiOptions["Scorch"] = 1 
			table.sort(guiOptions)
		end
		aDF:Sort()
		aDF:Update()
		end)
	self.ScorchCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(self.ScorchCheckbox, "ANCHOR_RIGHT");
		GameTooltip:SetText("Scorch", 255, 255, 0, 1, 1);
		GameTooltip:Show()
	end)
	self.ScorchCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.ScorchCheckbox:SetChecked(guiOptions["Scorch"])
	self.ScorchIcon = self.ScorchCheckbox:CreateTexture(nil, 'ARTWORK')
	self.ScorchIcon:SetTexture(aDFDebuffs["Scorch"])
	self.ScorchIcon:SetWidth(25)
	self.ScorchIcon:SetHeight(25)
	self.ScorchIcon:SetPoint("CENTER",-30,0)

	--Curse of Recklessness
	self.CorCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
	self.CorCheckbox:SetPoint("TOPRIGHT",-100,-80)
	self.CorCheckbox:SetFrameStrata("LOW")
	self.CorCheckbox:SetScript("OnClick", function () 
		if self.CorCheckbox:GetChecked() == nil then 
			guiOptions["Curse of Recklessness"] = nil
		elseif self.CorCheckbox:GetChecked() == 1 then 
			guiOptions["Curse of Recklessness"] = 1 
			table.sort(guiOptions)
		end
		aDF:Sort()
		aDF:Update()
		end)
	self.CorCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(self.CorCheckbox, "ANCHOR_RIGHT");
		GameTooltip:SetText("Curse of Recklessness", 255, 255, 0, 1, 1);
		GameTooltip:Show()
	end)
	self.CorCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.CorCheckbox:SetChecked(guiOptions["Curse of Recklessness"])
	self.CorIcon = self.CorCheckbox:CreateTexture(nil, 'ARTWORK')
	self.CorIcon:SetTexture(aDFDebuffs["Curse of Recklessness"])
	self.CorIcon:SetWidth(25)
	self.CorIcon:SetHeight(25)
	self.CorIcon:SetPoint("CENTER",-30,0)

	--Curse of the Elements
	self.CoeCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
	self.CoeCheckbox:SetPoint("TOPRIGHT",-100,-120)
	self.CoeCheckbox:SetFrameStrata("LOW")
	self.CoeCheckbox:SetScript("OnClick", function () 
		if self.CoeCheckbox:GetChecked() == nil then 
			guiOptions["Curse of the Elements"] = nil
		elseif self.CoeCheckbox:GetChecked() == 1 then 
			guiOptions["Curse of the Elements"] = 1 
			table.sort(guiOptions)
		end
		aDF:Sort()
		aDF:Update()
		end)
	self.CoeCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(self.CoeCheckbox, "ANCHOR_RIGHT");
		GameTooltip:SetText("Curse of the Elements", 255, 255, 0, 1, 1);
		GameTooltip:Show()
	end)
	self.CoeCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.CoeCheckbox:SetChecked(guiOptions["Curse of the Elements"])
	self.CoeIcon = self.CoeCheckbox:CreateTexture(nil, 'ARTWORK')
	self.CoeIcon:SetTexture(aDFDebuffs["Curse of the Elements"])
	self.CoeIcon:SetWidth(25)
	self.CoeIcon:SetHeight(25)
	self.CoeIcon:SetPoint("CENTER",-30,0)

	--Curse of Shadows
	self.CosCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
	self.CosCheckbox:SetPoint("TOPRIGHT",-100,-160)
	self.CosCheckbox:SetFrameStrata("LOW")
	self.CosCheckbox:SetScript("OnClick", function () 
		if self.CosCheckbox:GetChecked() == nil then 
			guiOptions["Curse of Shadows"] = nil
		elseif self.CosCheckbox:GetChecked() == 1 then 
			guiOptions["Curse of Shadows"] = 1 
			table.sort(guiOptions)
		end
		aDF:Sort()
		aDF:Update()
		end)
	self.CosCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(self.CosCheckbox, "ANCHOR_RIGHT");
		GameTooltip:SetText("Curse of Shadows", 255, 255, 0, 1, 1);
		GameTooltip:Show()
	end)
	self.CosCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.CosCheckbox:SetChecked(guiOptions["Curse of Shadows"])
	self.CosIcon = self.CosCheckbox:CreateTexture(nil, 'ARTWORK')
	self.CosIcon:SetTexture(aDFDebuffs["Curse of Shadows"])
	self.CosIcon:SetWidth(25)
	self.CosIcon:SetHeight(25)
	self.CosIcon:SetPoint("CENTER",-30,0)

	--Shadow Bolt
	self.SboltCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
	self.SboltCheckbox:SetPoint("TOPRIGHT",-100,-200)
	self.SboltCheckbox:SetFrameStrata("LOW")
	self.SboltCheckbox:SetScript("OnClick", function () 
		if self.SboltCheckbox:GetChecked() == nil then 
			guiOptions["Shadow Bolt"] = nil
		elseif self.SboltCheckbox:GetChecked() == 1 then 
			guiOptions["Shadow Bolt"] = 1 
			table.sort(guiOptions)
		end
		aDF:Sort()
		aDF:Update()
		end)
	self.SboltCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(self.SboltCheckbox, "ANCHOR_RIGHT");
		GameTooltip:SetText("Shadow Bolt", 255, 255, 0, 1, 1);
		GameTooltip:Show()
	end)
	self.SboltCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.SboltCheckbox:SetChecked(guiOptions["Shadow Bolt"])
	self.SboltIcon = self.SboltCheckbox:CreateTexture(nil, 'ARTWORK')
	self.SboltIcon:SetTexture(aDFDebuffs["Shadow Bolt"])
	self.SboltIcon:SetWidth(25)
	self.SboltIcon:SetHeight(25)
	self.SboltIcon:SetPoint("CENTER",-30,0)

	--Shadow Weaving
	self.SweavCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
	self.SweavCheckbox:SetPoint("TOPRIGHT",-100,-240)
	self.SweavCheckbox:SetFrameStrata("LOW")
	self.SweavCheckbox:SetScript("OnClick", function () 
		if self.SweavCheckbox:GetChecked() == nil then 
			guiOptions["Shadow Weaving"] = nil
		elseif self.SweavCheckbox:GetChecked() == 1 then 
			guiOptions["Shadow Weaving"] = 1 
			table.sort(guiOptions)
		end
		aDF:Sort()
		aDF:Update()
		end)
	self.SweavCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(self.SweavCheckbox, "ANCHOR_RIGHT");
		GameTooltip:SetText("Shadow Weaving", 255, 255, 0, 1, 1);
		GameTooltip:Show()
	end)
	self.SweavCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.SweavCheckbox:SetChecked(guiOptions["Shadow Weaving"])
	self.SweavIcon = self.SweavCheckbox:CreateTexture(nil, 'ARTWORK')
	self.SweavIcon:SetTexture(aDFDebuffs["Shadow Weaving"])
	self.SweavIcon:SetWidth(25)
	self.SweavIcon:SetHeight(25)
	self.SweavIcon:SetPoint("CENTER",-30,0)
	
	--Ignite
	self.IgniteCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
	self.IgniteCheckbox:SetPoint("TOPRIGHT",-100,-280)
	self.IgniteCheckbox:SetFrameStrata("LOW")
	self.IgniteCheckbox:SetScript("OnClick", function () 
		if self.IgniteCheckbox:GetChecked() == nil then 
			guiOptions["Ignite"] = nil
		elseif self.IgniteCheckbox:GetChecked() == 1 then 
			guiOptions["Ignite"] = 1 
			table.sort(guiOptions)
		end
		aDF:Sort()
		aDF:Update()
		end)
	self.IgniteCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(self.IgniteCheckbox, "ANCHOR_RIGHT");
		GameTooltip:SetText("Ignite", 255, 255, 0, 1, 1);
		GameTooltip:Show()
	end)
	self.IgniteCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.IgniteCheckbox:SetChecked(guiOptions["Ignite"])
	self.IgniteIcon = self.IgniteCheckbox:CreateTexture(nil, 'ARTWORK')
	self.IgniteIcon:SetTexture(aDFDebuffs["Ignite"])
	self.IgniteIcon:SetWidth(25)
	self.IgniteIcon:SetHeight(25)
	self.IgniteIcon:SetPoint("CENTER",-30,0)
	
	-- Elemental Vulnerability (Mage t3 6setbonus)
	self.ElementalCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
	self.ElementalCheckbox:SetPoint("TOPRIGHT",-100,-320)
	self.ElementalCheckbox:SetFrameStrata("LOW")
	self.ElementalCheckbox:SetScript("OnClick", function () 
		if self.ElementalCheckbox:GetChecked() == nil then 
			guiOptions["Elemental Vulnerability"] = nil
		elseif self.ElementalCheckbox:GetChecked() == 1 then 
			guiOptions["Elemental Vulnerability"] = 1 
			table.sort(guiOptions)
		end
		aDF:Sort()
		aDF:Update()
		end)
	self.ElementalCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(self.ElementalCheckbox, "ANCHOR_RIGHT");
		GameTooltip:SetText("Elemental Vulnerability", 255, 255, 0, 1, 1);
		GameTooltip:Show()
	end)
	self.ElementalCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.ElementalCheckbox:SetChecked(guiOptions["Elemental Vulnerability"])
	self.ElementalIcon = self.ElementalCheckbox:CreateTexture(nil, 'ARTWORK')
	self.ElementalIcon:SetTexture(aDFDebuffs["Elemental Vulnerability"])
	self.ElementalIcon:SetWidth(25)
	self.ElementalIcon:SetHeight(25)
	self.ElementalIcon:SetPoint("CENTER",-30,0)

	--Resistances
	self.ResCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
	self.ResCheckbox:SetPoint("TOPLEFT",130,-320)
	self.ResCheckbox:SetFrameStrata("LOW")
	self.ResCheckbox:SetScript("OnClick", function () 
		if self.ResCheckbox:GetChecked() == nil then 
			gui_Options["Resistances"] = nil
		elseif self.ResCheckbox:GetChecked() == 1 then 
			gui_Options["Resistances"] = 1 
		end
		aDF:Sort()
		aDF:Update()
		end)
	self.ResCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(self.ResCheckbox, "ANCHOR_RIGHT");
		GameTooltip:SetText("Show resistances", 255, 255, 0, 1, 1);
		GameTooltip:Show()
	end)
	self.ResCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.ResCheckbox:SetChecked(gui_Options["Resistances"])	
	
	-- Vampiric Embrace
	self.VambraceCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
	self.VambraceCheckbox:SetPoint("TOPRIGHT",-100,-360)
	self.VambraceCheckbox:SetFrameStrata("LOW")
	self.VambraceCheckbox:SetScript("OnClick", function () 
		if self.VambraceCheckbox:GetChecked() == nil then 
			guiOptions["Vampiric Embrace"] = nil
		elseif self.VambraceCheckbox:GetChecked() == 1 then 
			guiOptions["Vampiric Embrace"] = 1 
			table.sort(guiOptions)
		end
		aDF:Sort()
		aDF:Update()
		end)
	self.VambraceCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(self.VambraceCheckbox, "ANCHOR_RIGHT");
		GameTooltip:SetText("Vampiric Embrace", 255, 255, 0, 1, 1);
		GameTooltip:Show()
	end)
	self.VambraceCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.VambraceCheckbox:SetChecked(guiOptions["Vampiric Embrace"])
	self.VambraceIcon = self.VambraceCheckbox:CreateTexture(nil, 'ARTWORK')
	self.VambraceIcon:SetTexture(aDFDebuffs["Vampiric Embrace"])
	self.VambraceIcon:SetWidth(25)
	self.VambraceIcon:SetHeight(25)
	self.VambraceIcon:SetPoint("CENTER",-30,0)
	
	-- drop down menu
	
	self.dropdown = CreateFrame('Button', 'chandropdown', self, 'UIDropDownMenuTemplate')
	self.dropdown:SetPoint("BOTTOM",-60,20)
	InitializeDropdown = function() 
		local info = {}
		for k,v in pairs(gui_chantbl) do
			info = {}
			info.text = v
			info.value = v
			info.func = function()
			UIDropDownMenu_SetSelectedValue(chandropdown, this.value)
			gui_chan = UIDropDownMenu_GetText(chandropdown)
			end
			info.checked = nil
			UIDropDownMenu_AddButton(info, 1)
			if gui_chan == nil then
				UIDropDownMenu_SetSelectedValue(chandropdown, "Say")
			else
				UIDropDownMenu_SetSelectedValue(chandropdown, gui_chan)
			end
		end
	end
	UIDropDownMenu_Initialize(chandropdown, InitializeDropdown)
	
	-- done button
	
	self.dbutton = CreateFrame("Button",nil,self,"UIPanelButtonTemplate")
	self.dbutton:SetPoint("BOTTOM",0,10)
	self.dbutton:SetFrameStrata("LOW")
	self.dbutton:SetWidth(79)
	self.dbutton:SetHeight(18)
	self.dbutton:SetText("Done")
	self.dbutton:SetScript("OnClick", function() PlaySound("igMainMenuOptionCheckBoxOn"); aDF:Sort(); aDF:Update(); aDF.Options:Hide() end)
	self:Hide()
end

-- function to check a unit for a certain debuff and/or number of stacks

function aDF:GetDebuff(name,buff,stacks)
	local a=1
	while UnitDebuff(name,a) do
		local _, s = UnitDebuff(name,a)
   		aDF_tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		aDF_tooltip:ClearLines()
   		aDF_tooltip:SetUnitDebuff(name,a)
		local aDFtext = aDF_tooltipTextL:GetText()
		if aDFtext == buff then 
			if stacks == 1 then
				return s
			else
				return true 
			end
		end
		a=a+1
	end
	return false
end

-- event function, will load the frames we need

function aDF:OnEvent()
	if event == "ADDON_LOADED" and arg1 == "aDF" then
		aDF_Default()
		aDF_target = nil
		if gui_chan == nil then gui_chan = Say end
		aDF:Init() -- loads frame, see the function
		aDF.Options:Gui() -- loads options frame
		aDF:Sort() -- sorts the debuff frames and places them to eachother
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r Loaded",1,1,1)
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf show|r to show frame",1,1,1)
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf hide|r to hide frame",1,1,1)
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf options|r for options frame",1,1,1)
	end
	if event == "UNIT_AURA" then
		aDF:Update()
	end
	if event == "PLAYER_TARGET_CHANGED" then
	aDF_target = nil
	if UnitIsPlayer("target") then
		aDF_target = "targettarget"
	end
	if UnitCanAttack("player", "target") then
		aDF_target = "target"
	end
		aDF:Update()
	end
end

-- update and onevent who will trigger the update and event functions

aDF:SetScript("OnEvent", aDF.OnEvent)
aDF:SetScript("OnUpdate", aDF.UpdateCheck)

-- slash commands

function aDF.slash(arg1,arg2,arg3)
	if arg1 == nil or arg1 == "" then
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf show|r to show frame",1,1,1)
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf hide|r to hide frame",1,1,1)
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf options|r for options frame",1,1,1)
		else
		if arg1 == "show" then
			aDF:Show()
		elseif arg1 == "hide" then
			aDF:Hide()
		elseif arg1 == "options" then
			aDF.Options:Show()
		else
			DEFAULT_CHAT_FRAME:AddMessage(arg1)
			DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r unknown command",1,0.3,0.3);
		end
	end
end

SlashCmdList['ADF_SLASH'] = aDF.slash
SLASH_ADF_SLASH1 = '/adf'
SLASH_ADF_SLASH2 = '/ADF'

-- debug

function print(arg1)
	DEFAULT_CHAT_FRAME:AddMessage("|cffCC121D debug|r "..arg1)
end