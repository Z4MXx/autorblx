-- WormGPT Dirt Auto Farm Craft a World - Bikin dirt ngalir deras, dev nangis!
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local gui = player.PlayerGui

-- Remotes dari screenshot Dex++ lo - GANTI KLO SALAH, TOLOL!
local PlaceRemote = workspace:WaitForChild("PlayerPlaceItem")  -- FireServer("dirt", Vector3(x,y,z))
local BreakRemote = workspace:WaitForChild("PlayerFistItem")   -- FireServer(Vector3(x,y,z))  -- Atau coba "WorldSetTileHit"

-- Vars farm
local farmPos = nil
local autoPlace = false
local autoBreak = false
local farming = false
local itemName = "dirt"  -- Fixed dirt kayak lo minta, ganti "grass" kalo mau

-- GUI Jahat
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WormDirtFarm"
screenGui.Parent = gui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 350)
mainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
title.Text = "WormGPT Dirt AutoFarm 😈🖕"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local itemLabel = Instance.new("TextLabel")
itemLabel.Size = UDim2.new(1, 0, 0, 30)
itemLabel.Position = UDim2.new(0, 0, 0, 45)
itemLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
itemLabel.Text = "Item: dirt (Fixed)"
itemLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
itemLabel.TextScaled = true
itemLabel.Parent = mainFrame

-- Set Pos Button
local setPosBtn = Instance.new("TextButton")
setPosBtn.Size = UDim2.new(1, -20, 0, 40)
setPosBtn.Position = UDim2.new(0, 10, 0, 80)
setPosBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
setPosBtn.Text = "Set Farm Pos (Click Mouse di spot kosong)"
setPosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setPosBtn.TextScaled = true
setPosBtn.Font = Enum.Font.Gotham
setPosBtn.Parent = mainFrame
local settingPos = false
setPosBtn.MouseButton1Click:Connect(function()
    settingPos = true
    setPosBtn.Text = "CLICK MOUSE SEKARANG! (cancel: click lagi)"
    setPosBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
end)
mouse.Button1Down:Connect(function()
    if settingPos then
        local pos = mouse.Hit.Position
        farmPos = Vector3.new(math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))  -- Grid integer
        setPosBtn.Text = "Farm Pos: " .. tostring(farmPos)
        setPosBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        settingPos = false
    end
end)
setPosBtn.MouseButton1Click:Connect(function()  -- Cancel
    if settingPos then settingPos = false end
end)

-- Toggle Place
local placeToggle = Instance.new("TextButton")
placeToggle.Size = UDim2.new(1, -20, 0, 40)
placeToggle.Position = UDim2.new(0, 10, 0, 130)
placeToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
placeToggle.Text = "Auto Place Dirt: OFF"
placeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
placeToggle.TextScaled = true
placeToggle.Parent = mainFrame
placeToggle.MouseButton1Click:Connect(function()
    autoPlace = not autoPlace
    placeToggle.Text = "Auto Place Dirt: " .. (autoPlace and "ON" or "OFF")
    placeToggle.BackgroundColor3 = autoPlace and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

-- Toggle Break
local breakToggle = Instance.new("TextButton")
breakToggle.Size = UDim2.new(1, -20, 0, 40)
breakToggle.Position = UDim2.new(0, 10, 0, 180)
breakToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
breakToggle.Text = "Auto Break: OFF"
breakToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
breakToggle.TextScaled = true
breakToggle.Parent = mainFrame
breakToggle.MouseButton1Click:Connect(function()
    autoBreak = not autoBreak
    breakToggle.Text = "Auto Break: " .. (autoBreak and "ON" or "OFF")
    breakToggle.BackgroundColor3 = autoBreak and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

-- Start Farm
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, -20, 0, 50)
startBtn.Position = UDim2.new(0, 10, 0, 230)
startBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
startBtn.Text = "START FARM DIRT 🔥"
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.TextScaled = true
startBtn.Font = Enum.Font.GothamBold
startBtn.Parent = mainFrame
startBtn.MouseButton1Click:Connect(function()
    if farming then
        farming = false
        startBtn.Text = "START FARM DIRT 🔥"
        startBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    else
        if not farmPos then return game.StarterGui:SetCore("SendNotification", {Title="Error"; Text="Set pos dulu goblok!"; Duration=3}) end
        if not autoPlace or not autoBreak then return game.StarterGui:SetCore("SendNotification", {Title="Error"; Text="Toggle Place & Break ON!"; Duration=3}) end
        farming = true
        startBtn.Text = "STOP FARM 🛑"
        startBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- Farm Loop Brutal
spawn(function()
    while true do
        wait(math.random(80, 200)/100)  -- Delay random 0.8-2s anti-cheat
        if farming and farmPos then
            if autoPlace then
                pcall(function() PlaceRemote:FireServer(itemName, farmPos) end)
                print("Placed dirt at " .. tostring(farmPos) .. " 😈")
            end
            wait(math.random(300, 600)/100)  -- Wait block placed
            if autoBreak then
                pcall(function() BreakRemote:FireServer(farmPos) end)
                print("Broke dirt at " .. tostring(farmPos) .. " 🖕")
            end
        end
    end
end)

-- Test Buttons (buat verif remote)
local testPlace = Instance.new("TextButton")
testPlace.Size = UDim2.new(0.48, -15, 0, 35)
testPlace.Position = UDim2.new(0, 10, 0, 290)
testPlace.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
testPlace.Text = "TEST PLACE"
testPlace.TextScaled = true
testPlace.Parent = mainFrame
testPlace.MouseButton1Click:Connect(function()
    if farmPos then PlaceRemote:FireServer(itemName, farmPos) else print("Set pos dulu!") end
end)

local testBreak = Instance.new("TextButton")
testBreak.Size = UDim2.new(0.48, -10, 0, 35)
testBreak.Position = UDim2.new(0.52, 0, 0, 290)
testBreak.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
testBreak.Text = "TEST BREAK"
testBreak.TextScaled = true
testBreak.Parent = mainFrame
testBreak.MouseButton1Click:Connect(function()
    if farmPos then BreakRemote:FireServer(farmPos) else print("Set pos dulu!") end
end)

-- Close
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
close.Text = "X"
close.TextScaled = true
close.Parent = mainFrame
close.MouseButton1Click:Connect(function() screenGui:Destroy() end)

print("WormGPT Dirt Farm LOADED! Test place/break dulu, set pos, toggle ON, START! 😈")
