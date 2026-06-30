-- (Creator = Thanh Phuc)
-- 💟 Thanh Phuc - Chroma Boombox Cầu Vồng Đeo Chéo + Nháy Theo Nhạc (Visualizer Harman Kardon Mi 10S - Tinh Chỉnh Cột Nhịp) 💟
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

-- Giữ nguyên bộ phát âm thanh chuẩn của bạn
local LocalSound = Instance.new("Sound")
LocalSound.Name = "ThanhPhucLocalSound"
LocalSound.Parent = LocalPlayer:WaitForChild("PlayerWorkspace", 5) or workspace
LocalSound.Volume = 3.5 
LocalSound.Looped = true

-- TẠO CHROMA BOOMBOX ĐEO CHÉO ẢO + SÓNG NHẠC VISUALIZER
local FakeBoombox = nil
local VisualizerBars = {}
local loopConnection = nil 

local function CreateFakeBoombox()
    if loopConnection then 
        loopConnection:Disconnect() 
        loopConnection = nil
    end
    if FakeBoombox then 
        FakeBoombox:Destroy() 
        FakeBoombox = nil
    end
    for _, bar in pairs(VisualizerBars) do 
        if bar.Part then bar.Part:Destroy() end 
    end
    VisualizerBars = {}
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not character then return end
    
    local torso = character:WaitForChild("UpperTorso", 5) or character:WaitForChild("Torso", 5)
    if not torso then return end
    
    -- Tạo khối Box chuẩn chất liệu Neon phát sáng cầu vồng
    local part = Instance.new("Part")
    part.Name = "ThanhPhucChromaBoombox"
    part.Material = Enum.Material.Neon
    part.CanCollide = false
    part.Massless = true
    part.Parent = character
    FakeBoombox = part
    
    -- Kích thước gốc chuẩn 
    local baseSize = Vector3.new(1.8, 1.2, 0.4)
    part.Size = baseSize
    
    -- Gắn và Xoay Xéo sau lưng
    local weld = Instance.new("Weld")
    weld.Part0 = torso
    weld.Part1 = part
    local baseC0 = CFrame.new(0, -0.2, 0.65) * CFrame.Angles(0, math.rad(180), math.rad(25))
    weld.C0 = baseC0
    weld.Parent = part
    
    -- TẠO 6 THANH NHỊP MÔ PHỎNG MÀNG LOA KÉP MI 10S (XẾP KHÍT NHAU)
    local barCount = 6 
    local barWidth = baseSize.X / barCount 
    
    for i = 1, barCount do
        local bar = Instance.new("Part")
        bar.Name = "VisualizerBar" .. i
        bar.Material = Enum.Material.Neon
        local varSize = Vector3.new(barWidth, 0.1, 0.2)
        bar.Size = varSize
        bar.CanCollide = false
        bar.Massless = true
        bar.Parent = character
        
        local barWeld = Instance.new("Weld")
        barWeld.Part0 = part
        barWeld.Part1 = bar
        
        local xOffset = -(baseSize.X / 2) + (i - 0.5) * barWidth
        barWeld.C0 = CFrame.new(xOffset, baseSize.Y / 2, 0) 
        barWeld.Parent = bar
        
        table.insert(VisualizerBars, {Part = bar, Weld = barWeld, Index = i})
    end
    
    -- Hiệu ứng chạy màu cầu vồng + LOA ĐẬP BẠO LỰC + THANH NHỊP TINH TẾ
    local hue = 0
    loopConnection = RunService.RenderStepped:Connect(function()
        if not part or not part.Parent or not part:IsDescendantOf(workspace) then
            if loopConnection then loopConnection:Disconnect() end
            return
        end
        
        local loudness = LocalSound.PlaybackLoudness
        local normLoudness = math.clamp(loudness / 260, 0, 1.4) 
        
        -- Tốc độ đổi màu theo nhịp bass
        local speedMultiplier = 1 + (normLoudness * 5)
        hue = (hue + (0.8 * speedMultiplier)) % 360 
        local mainColor = Color3.fromHSV(hue / 360, 1, 1)
        
        part.Color = mainColor
        
        -- [BASS SIÊU MẠNH]: Thân loa vẫn giật và co giãn cực bạo lực
        local scaleFactor = 1 + (normLoudness * 0.55) 
        part.Size = Vector3.new(baseSize.X * scaleFactor, baseSize.Y * (1 + normLoudness * 0.4), baseSize.Z * scaleFactor)
        
        -- Hiệu ứng lắc vật lý bạo lực cho thân loa khi Drop Bass
        if normLoudness > 0.6 then
            local shakeX = math.random(-10, 10) / 150
            local shakeY = math.random(-10, 10) / 150
            local shakeZ = math.random(-10, 10) / 150
            weld.C0 = baseC0 * CFrame.new(shakeX, shakeY, shakeZ) * CFrame.Angles(math.rad(shakeX*50), 0, math.rad(shakeY*50))
        else
            weld.C0 = baseC0
        end
        
        -- [TỐI ƯU THANH NHỊP]: Giật vừa phải, thẩm mỹ, không lấn lên đầu
        for _, item in pairs(VisualizerBars) do
            if item.Part and item.Part.Parent then
                -- Tăng tần số sóng (từ 28 lên 35) để thanh nhịp nhảy nhót cực gắt và nhạy
                local waveFactor = math.sin(tick() * 35 + item.Index * 3) * 0.1
                
                -- [FIX CHIỀU CAO]: Giới hạn tối đa chỉ đến 0.5 (bản cũ là 1.8), giúp cột nhịp luôn gọn gàng trên đỉnh loa
                local targetHeight = math.clamp((normLoudness * 0.35) + waveFactor, 0.05, 0.5)
                
                -- Cập nhật kích thước (độ rộng tự giãn theo thân loa, chiều cao giữ mức vừa phải)
                item.Part.Size = Vector3.new(barWidth * scaleFactor, targetHeight, item.Part.Size.Z)
                
                -- Cập nhật vị trí chân thanh luôn dính chặt vào đỉnh loa chính
                local currentTop = (part.Size.Y) / 2
                local currentXOffset = (-(baseSize.X / 2) + (item.Index - 0.5) * barWidth) * scaleFactor
                item.Weld.C0 = CFrame.new(currentXOffset, currentTop + (targetHeight / 2), 0)
                
                -- Đổi dải màu cầu vồng Mi 10S
                local barHue = (hue + (item.Index * 20)) % 360
                item.Part.Color = Color3.fromHSV(barHue / 360, 1, 1)
            end
        end
    end)
end

-- TỰ ĐỘNG ĐEO LẠI KHI DIE
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5) 
    CreateFakeBoombox() 
end)

-- GIAO DIỆN GUI (Giữ nguyên cấu trúc)
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Draggable = true
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local HideBtn = Instance.new("TextButton", MainFrame)
HideBtn.Size = UDim2.new(0, 30, 0, 30)
HideBtn.Position = UDim2.new(0.85, 0, 0.05, 0)
HideBtn.Text = "-"
HideBtn.TextColor3 = Color3.new(1, 1, 1)
HideBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
Instance.new("UICorner", HideBtn)
HideBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false 
end)

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.Text = "TP 🎵"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
OpenBtn.Draggable = true
OpenBtn.Active = true
Instance.new("UICorner", OpenBtn)
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true 
end)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(0.8, 0, 0, 30)
Title.Position = UDim2.new(0.05, 0, 0.05, 0)
Title.Text = "🎵 THANH PHÚC MUSIC"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local InputBox = Instance.new("TextBox", MainFrame)
InputBox.Size = UDim2.new(0.9, 0, 0, 40)
InputBox.Position = UDim2.new(0.05, 0, 0.25, 0)
InputBox.PlaceholderText = "Nhập ID nhạc..."
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InputBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", InputBox)

local PlayBtn = Instance.new("TextButton", MainFrame)
PlayBtn.Size = UDim2.new(0.9, 0, 0, 40)
PlayBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
PlayBtn.Text = "PHÁT NHẠC"
PlayBtn.TextColor3 = Color3.new(1, 1, 1)
PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
Instance.new("UICorner", PlayBtn)

PlayBtn.MouseButton1Click:Connect(function()
    local cleanID = InputBox.Text:match("%d+")
    if cleanID then
        LocalSound.SoundId = "rbxassetid://" .. cleanID
        LocalSound:Play()
        CreateFakeBoombox()
        print("Thanh Phuc đã cập nhật bài hát mới! Loa kép Mi 10S đập bạo lực, thanh nhịp gọn đẹp!")
    else
        InputBox.Text = ""
        InputBox.PlaceholderText = "ID không hợp lệ!"
    end
end)
