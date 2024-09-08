-- seperate class to set up extra renderer
-- this allow the render_PlaytimeInfo function to be reloaded at runtime
local BobbyPlaytimeInfo_PostDeathUI_HasSetup = false

local function BobbyPlaytimeInfo_PostDeathUI_Setup()
    if not BobbyPlaytimeInfo_PostDeathUI_HasSetup then
        BobbyPlaytimeInfo_PostDeathUI_HasSetup = true

        local old_render = ISPostDeathUI.render
        function ISPostDeathUI:render()
            local result = old_render(self)
            self:render_BobbyPlaytimeInfo_PostDeathUI()
            return result
        end

    end
end

Events.OnGameStart.Add(BobbyPlaytimeInfo_PostDeathUI_Setup);
