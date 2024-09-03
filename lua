-- RoShazam: A Simulated Music Identification System for Roblox with Enhanced Audio Controls

-- Setup: Mock Database of Songs with Additional Information
local songDatabase = {
    ["rbxassetid://1234567890"] = {name = "Song A", artist = "Artist 1", favorites = 1200, uploader = "Uploader1"},
    ["rbxassetid://2345678901"] = {name = "Song B", artist = "Artist 2", favorites = 850, uploader = "Uploader2"},
    ["rbxassetid://3456789012"] = {name = "Song C", artist = "Artist 3", favorites = 500, uploader = "Uploader3"},
}

-- Variables to manage audio playback
local currentSoundId = nil
local soundPlayer = nil

-- Function to notify the player
local function notifyPlayer(title, text, duration)
    game.StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5,
    })
end

-- Function to handle audio playback
local function playAudio(soundId)
    -- Stop any currently playing sound
    if soundPlayer then
        soundPlayer:Stop()
    end

    -- Create a new sound instance
    soundPlayer = Instance.new("Sound")
    soundPlayer.SoundId = soundId
    soundPlayer.Parent = workspace
    soundPlayer:Play()

    -- Notify the player that the audio is playing
    notifyPlayer("RoShazam", "Playing audio: " .. soundId, 30)
    
    -- Wait for 30 seconds
    wait(30)
    
    -- Stop the sound after 30 seconds
    if soundPlayer then
        soundPlayer:Stop()
    end

    -- Notify that playback has stopped
    notifyPlayer("RoShazam", "Playback stopped.", 5)
end

-- Function to handle player input for audio controls
local function handleInput(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.R then -- Press 'R' to repeat the current song
        if currentSoundId then
            playAudio(currentSoundId)
            notifyPlayer("RoShazam", "Repeat keybind activated. Playing the song again.", 80)
        end
    elseif input.KeyCode == Enum.KeyCode.S then -- Press 'S' to skip the current song
        -- Stop the current playback
        if soundPlayer then
            soundPlayer:Stop()
        end
        -- Notify the player that the song was skipped
        notifyPlayer("RoShazam", "Skip keybind activated. Song skipped.", 90)
        currentSoundId = nil
    elseif input.KeyCode == Enum.KeyCode.D then -- Press 'D' to disable the RoShazam
        -- Stop listening for new audios
        notifyPlayer("RoShazam", "RoShazam disabled.", 5)
        script:Destroy() -- Or use another method to stop the script
    end
end

-- Error handling function using xpcall
local function safeExecute(func, ...)
    local success, result = xpcall(func, function(err)
        warn("RoShazam Error:", err)
    end, ...)
    return success, result
end

-- Function to detect and log playing audios
local function detectAndLogAudios()
    local processedSounds = {}

    while true do
        -- Wait for a short duration before checking for new sounds
        wait(5)

        notifyPlayer("RoShazam", "Listening for audio in the game...", 5)

        local playingSounds = {}

        -- Use pcall to catch errors while searching for sound objects
        pcall(function()
            for _, sound in pairs(workspace:GetDescendants()) do
                if sound:IsA("Sound") and sound.IsPlaying then
                    local soundId = sound.SoundId
                    if not processedSounds[soundId] then
                        processedSounds[soundId] = true
                        table.insert(playingSounds, soundId)
                    end
                end
            end
        end)

        -- Identify Playing Sounds
        local identifiedSongs = {}

        for _, soundId in ipairs(playingSounds) do
            local matchedSong = songDatabase[soundId]
            if matchedSong then
                local songInfo = string.format("Name: %s\nArtist: %s\nID: %s\nFavorites: %d\nUploader: %s", 
                                matchedSong.name, matchedSong.artist, soundId, matchedSong.favorites, matchedSong.uploader)
                table.insert(identifiedSongs, songInfo)
            else
                table.insert(identifiedSongs, "Unknown Song\nID: " .. soundId)
            end
        end

        -- Notify results
        if #identifiedSongs > 0 then
            -- Notify user of the found song and start playback
            notifyPlayer("RoShazam Found", "Playing: " .. table.concat(identifiedSongs, "\n\n"), 10)
            
            -- Start playing the first identified song
            currentSoundId = playingSounds[1]
            playAudio(currentSoundId)
        else
            notifyPlayer("RoShazam", "No songs identified.", 5)
        end
    end
end

-- Initialization notifications
notifyPlayer("RoShazam Loaded", "Press 'F' to start listening!\nPress 'R' to repeat, 'S' to skip, 'D' to disable.", 900)
notifyPlayer("Discord", "Contact: meowbucks", 900)
notifyPlayer("RoShazam!", "RoShazam script has started and is actively listening.", 900)

-- Bind to a Key Press to start detection
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(handleInput)

-- Start the detection process
safeExecute(detectAndLogAudios)

-- Parent the script to StarterPlayerScripts
script.Parent = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
