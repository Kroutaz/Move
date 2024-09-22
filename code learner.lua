local replicatedStorage = game:GetService("ReplicatedStorage")
local input = replicatedStorage:WaitForChild("Main"):WaitForChild("Input")
local Players = game:GetService("Players")
local player = Players.LocalPlayer 

if not player then
    warn("Player 'Kashmirbrothe' not found!")
    return
end

-- Load Kavo UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Cooldown Moves", "DarkTheme")

-- Function to get all cooldown moves
local function getCooldownMoves()
    local moves = {}
    local backpack = player:WaitForChild("Backpack")

    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("LocalScript") and item.Name ~= "ResetLighting" then
            local cooldowns = item:FindFirstChild("Cooldowns")
            if cooldowns then
                for _, dataStore in ipairs(cooldowns:GetChildren()) do
                    local cleanedName = dataStore.Name:sub(1, -3) -- Remove "CD" if present
                    table.insert(moves, cleanedName)
                end
            end
        end
    end

    return moves
end

local cooldownMoves = getCooldownMoves()

if #cooldownMoves == 0 then
    warn("No cooldown moves found.")
    return
end

-- Create a new section for the buttons
local Section = Window:NewTab("Moves"):NewSection("Cooldown Moves")

for _, move in ipairs(cooldownMoves) do
    -- Create a button for each move
    Section:NewButton(move, "Click to use " .. move, function()
        local args = {
            [1] = "Alternate", -- Fixed first argument
            [2] = move -- Use the move name from the list
        }

        -- Log the script used with formatted output
        local argsString = "local args = {\n" ..
                           "    [1] = \"Alternate\", -- Fixed first argument\n" ..
                           "    [2] = \"" .. move .. "\" -- Use the move name from the list\n" ..
                           "}\n" ..
                           "game:GetService(\"ReplicatedStorage\"):WaitForChild(\"Main\"):WaitForChild(\"Input\"):FireServer(unpack(args))"
        print("Using move: " .. move)
        print(argsString)

        -- Copy the argsString to the clipboard
        setclipboard(argsString)

        -- Execute the server call
        local success, err = pcall(function()
            input:FireServer(unpack(args))
        end)

        if not success then
            warn("Error firing server: " .. tostring(err))
            return
        end
        
        print(move .. ": Executed.")
    end)
end

-- Show the GUI
Window:Toggle()