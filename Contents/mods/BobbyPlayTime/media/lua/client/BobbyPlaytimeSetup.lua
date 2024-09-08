-- seperate class to set up extra renderer
-- this allow the render_PlaytimeInfo function to be reloaded at runtime
local BobbyPlaytimeInfo_HasSetup = false

local function BobbyPlaytimeInfo_Setup()
    if not BobbyPlaytimeInfo_HasSetup then
        BobbyPlaytimeInfo_HasSetup = true

        local old_render = ISCharacterScreen.render
        function ISCharacterScreen:render()
            local result = old_render(self)
            self:render_BobbyPlaytimeInfo()
            return result
        end

    end
end

Events.OnGameStart.Add(BobbyPlaytimeInfo_Setup);
