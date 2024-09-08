local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

-- Helper function to determine singular/plural form
local function pluralize(value, singular, plural)
    return value <= 1 and singular or plural
end

local add_bobbyplaytime_line = false

function ISPostDeathUI:render_BobbyPlaytimeInfo_PostDeathUI()
    local playerObj = getSpecificPlayer(self.playerIndex)
    local modData = playerObj:getModData()
    if not modData.BobbyPlayTime then
        modData.BobbyPlayTime = {death_time = 0}
    end

    -- Get Playtime text
    local death_time = modData.BobbyPlayTime.death_time
    local hours = math.floor((death_time / 3600))
    local minutes = math.floor((death_time % 3600) / 60)
    local seconds = math.floor(death_time % 60)
    local elapsed_time = ""
    if hours > 0 then
        elapsed_time = elapsed_time .. hours .. " " .. pluralize(hours, getText("IGUI_Gametime_hour") , getText("IGUI_Gametime_hours")) .. ", "
    end
    if minutes > 0 then
        elapsed_time = elapsed_time .. minutes .. " " .. pluralize(minutes, getText("IGUI_Gametime_minute"), getText("IGUI_Gametime_minutes")) .. ", "
    end
    elapsed_time = elapsed_time ..  string.format("%d ", seconds) .. pluralize(seconds, getText("IGUI_Gametime_second"), getText("IGUI_Gametime_secondes"))

    -- get "You Survived for" line index
    local vanillakillsLine = getGameTime():getDeathString(playerObj)
    local killLineIter = nil
    for i=0, #self.lines do
        if vanillakillsLine == self.lines[i] then killLineIter = i end
    end

    -- Check if the line already add
    if not add_bobbyplaytime_line then
        -- Add playtime line after you "You Survived for" line
        table.insert(self.lines, killLineIter + 1, getText("IGUI_BOBBY_Playtime_PostDeath", elapsed_time) )
        add_bobbyplaytime_line = true
    end
end