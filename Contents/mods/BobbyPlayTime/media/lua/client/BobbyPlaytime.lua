local Json = require("Json")
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local total_playtime = 0
local start_session_time = os.time()
local end_time = os.time()
local theTable = {}
local on_death_screen = false

-- Helper function to determine singular/plural form
local function pluralize(value, singular, plural)
    return value <= 1 and singular or plural
end

function ISCharacterScreen:BobbyPlaytime_getTraitBottom()
    -- Get "trait bottom" height, so "Playtime" text on character screen doesn't get cut
    -- reference to function ISCharacterScreen:render()
    local z = 25
    z = z + FONT_HGT_MEDIUM
    z = z + 10
    local smallFontHgt = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
    z = z + smallFontHgt;
    z = z + smallFontHgt;
	local traitBottom = z
	-- local finalY = z + (math.max(FONT_HGT_SMALL, 18) - 18) / 2 + 2;
	if #self.traits > 0 then
        -- comment out, so it doesn't duplicate text "Traits"
		-- self:drawTextRight(getText("IGUI_char_Traits"), self.xOffset, z, 1,1,1,1, UIFont.Small);
		local x = self.xOffset + 10;
		local y = z + (math.max(FONT_HGT_SMALL, 18) - 18) / 2 + 2
		for i,v in ipairs(self.traits) do
			v:setY(y);
			v:setX(x);
            -- comment out, so it doesn't duplicate texture picture "Trait"
            -- v:setVisible(true);
			traitBottom = y + v:getTexture():getHeightOrig() + 2
			x = x + v:getTexture():getWidthOrig() + 6;
			if (i < #self.traits) and (x + v:getTexture():getWidthOrig() > self:getWidth() - 20) then
				x = self.xOffset + 10
				y = y + v:getTexture():getHeightOrig() + 2
			end
		end
		-- finalY = y + self.traits[1]:getTexture():getHeightOrig();
	end

	-- finalY = finalY + 20;
    return traitBottom
end

function ISCharacterScreen:render_BobbyPlaytimeInfo()
    local smallFontHgt = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
    local textWid1 = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_char_Favourite_Weapon"))
    local textWid2 = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_char_Zombies_Killed"))
    local textWid3 = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_char_Survived_For"))
    local x = 20 + math.max(textWid1, math.max(textWid2, textWid3))
    local elapsed_seconds = end_time - start_session_time + total_playtime
    -- Calculate hours, minutes, and seconds
    local hours = math.floor((elapsed_seconds / 3600))
    local minutes = math.floor((elapsed_seconds % 3600) / 60)
    local seconds = math.floor(elapsed_seconds % 60)
    local elapsed_time = ""

    if hours > 0 then
        elapsed_time = elapsed_time .. hours .. " " .. pluralize(hours, getText("IGUI_Gametime_hour") , getText("IGUI_Gametime_hours"))
        if minutes > 0 then
            elapsed_time = elapsed_time .. ", " .. minutes .. " " .. pluralize(minutes, getText("IGUI_Gametime_minute"), getText("IGUI_Gametime_minutes"))
        end
    elseif minutes > 0 then
        elapsed_time = elapsed_time .. minutes .. " " .. pluralize(minutes, getText("IGUI_Gametime_minute"), getText("IGUI_Gametime_minutes"))
        if seconds > 0 then
            elapsed_time = elapsed_time .. ", " .. string.format("%d ", seconds) .. pluralize(seconds, getText("IGUI_Gametime_second"), getText("IGUI_Gametime_secondes"))
        end
    else
        -- If no larger units are present, only show seconds
        elapsed_time = elapsed_time .. string.format("%d ", seconds) .. pluralize(seconds, getText("IGUI_Gametime_second"), getText("IGUI_Gametime_secondes"))
    end
    local traitBottom = self:BobbyPlaytime_getTraitBottom()
    local z = self.literatureButton:getBottom();
	z = math.max(z + 16, traitBottom);
	z = math.max(z, self.avatarY + self.avatarHeight + 25)
    z = z - smallFontHgt

    -- local z = self.height - 80 + smallFontHgt;
    self:drawTextRight(getText("IGUI_BOBBY_Playtime"), x, z, 1, 1, 1, 1, UIFont.Small);
    self:drawText(elapsed_time, x + 10, z, 1, 1, 1, 0.5, UIFont.Small);
end

function BobbyPlaytime_getPlaytimeData()
    local modData = getPlayer():getModData()
	if not modData.BobbyPlayTime then
		modData.BobbyPlayTime = {}
	end
    return modData.BobbyPlayTime
end

function BobbyPlaytime_updateplaytime()
    end_time = os.time()
end

function BobbyPlaytime_saveJsonData()
    local fileWriterObj = getFileWriter("bobby_playtime_data.json", true, false)
    local json = Json.Encode(theTable);
    fileWriterObj:write(json);
    fileWriterObj:close();
end

function BobbyPlaytime_loadJsonData()
    local fileReaderObj = getFileReader("bobby_playtime_data.json", true);
    local json = "";
    local line = fileReaderObj:readLine();
    while line ~= nil do
        json = json .. line;
        line = fileReaderObj:readLine()
    end
    fileReaderObj:close();

    if json and json ~= "" then
        theTable = Json.Decode(json);
    end
end

Events.OnGameStart.Add(function()
    local username = getPlayer():getUsername()
    BobbyPlaytime_loadJsonData()
    total_playtime = theTable[username] or 0
end
)
Events.EveryTenMinutes.Add(BobbyPlaytime_updateplaytime)

Events.OnPlayerDeath.Add(function(_player)
    -- Last save playtime for the died player character (for Death screen)
    end_time = os.time()
    local username = _player:getUsername()
    BobbyPlaytime_loadJsonData()
    theTable[username] = end_time - start_session_time  + total_playtime
    BobbyPlaytime_saveJsonData()
    on_death_screen = true
    local data = BobbyPlaytime_getPlaytimeData()
    data.death_time = end_time - start_session_time  + total_playtime
end)

Events.OnCreatePlayer.Add(function(_playerIndex, _player)
    -- reset time when create new player character
    local username = _player:getUsername()
    BobbyPlaytime_loadJsonData()
    theTable[username] = 0
    BobbyPlaytime_saveJsonData()
    total_playtime = 0
    start_session_time = os.time()
    end_time = os.time()
    -- print("create new player and playtime"..username)
    on_death_screen = false
end)

Events.OnSave.Add(function ()
    if not on_death_screen then
        -- print('not on death screen, so update playtime')
        end_time = os.time()
    end
    local username = getPlayer():getUsername()
    BobbyPlaytime_loadJsonData()
    theTable[username] = end_time - start_session_time  + total_playtime
    BobbyPlaytime_saveJsonData()
end
)