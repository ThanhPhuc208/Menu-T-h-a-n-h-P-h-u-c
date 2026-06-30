-- (Creator = Thanh Phuc)
-- 💟 Thanh Phuc - Chroma Boombox Mi 10S Kép Đối Xứng 6 Thanh Siêu Bass - Không Delay 💟
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

-- Giữ nguyên bộ phát âm thanh chuẩn của bạn
local LocalSound = Instance.new("Sound")
LocalSound.Name = "ThanhPhucLocalSound"
LocalSound.Parent = LocalPlayer:WaitForChild("PlayerWorkspace", 5) or workspace
LocalSound.Volume = 2
LocalSound.Looped = true

local FakeBoombox = nil
local VisualizerBars = {}
local loopConnection = nil 

local function CreateFakeBoombox()
    -- Xóa triệt để đồ cũ ngay lập tức
    if loopConnection then loopConnection:Disconnect() loopConnection = nil end
    if FakeBoombox then FakeBoombox:Destroy() FakeBoombox = nil end
    for _, bar in pairs(VisualizerBars) do if bar.Part then bar.Part:Destroy() end end
    VisualizerBars = {}
    
    local character = LocalPlayer.Character
    if not character then return end
    
    -- Lấy nhanh Torso, không dùng WaitForChild thời gian dài gây trễ
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    if not torso then return end
    
    -- Tạo khối Box chính
    local part = Instance.new("Part")
    part.Name = "ThanhPhucChromaBoombox"
    part.Material = Enum.Material.Neon
    part.CanCollide = false
    part.Massless = true
    part.Parent = character
    FakeBoombox = part
    
    local baseSize = Vector3.new(1.8, 1.2, 0.4)
    part.Size = baseSize
    
    local weld = Instance.new("Weld")
    weld.Part0 = torso
    weld.Part1 = part
    weld.C0 = CFrame.new(0, -0.2, 0.65) * CFrame.Angles(0, math.rad(180), math.rad(25))
    weld.Parent = part
    
    -- TẠO 6 THANH NHỊP ĐỐI XỨNG PHÂN BỔ CHUẨN (KHÔNG BỊ LỘ CÒN 5 THANH)
    local barCount = 6 
    -- Giảm nhẹ một chút độ rộng để tạo khe hở siêu nhỏ giữa các thanh, giúp nhìn rõ đủ 6 thanh riêng biệt
    local barWidth = (baseSize.X / barCount) * 0.96 
    local totalWidthOfBars = barCount * barWidth
    
    for i = 1, barCount do
        local bar = Instance.new("Part")
        bar.Name = "VisualizerBar" .. i
        bar.Material = Enum.Material.Neon
        bar.Size = Vector3.new(barWidth, 0.1, 0.2)
        bar.CanCollide = false
        bar.Massless = true
        bar.Parent = character
        
        local barWeld = Instance.new("Weld")
        barWeld.Part0 = part
        barWeld.Part1 = bar
        
        -- Công thức căn lề chuẩn xác từ trái sang phải dựa trên tâm loa
        local xOffset = -(totalWidthOfBars / 2) + (i - 0.5) * barWidth
        barWeld.C0 = CFrame.new(xOffset, baseSize.Y / 2, 0) 
        barWeld.Parent = bar
        
        table.insert(VisualizerBars, {Part = bar, Weld = barWeld, Index = i})
    end
    
    local hue = 0
    loopConnection = RunService.RenderStepped:Connect(function()
        if not part or not part.Parent or not part:IsDescendantOf(workspace) then
            if loopConnection then loopConnection:Disconnect() end
            return
        end
        
        local loudness = LocalSound.PlaybackLoudness
        -- Đẩy cực hạn độ nhạy Bass (Chia 210 thay vì 260) giúp tiếng Bass nhỏ cũng giật rất mạnh
        local normLoudness = math.clamp(loudness / 210, 0, 1) 
        
        local speedMultiplier = 1 + (normLoudness * 5)
        hue = (hue + (0.8 * speedMultiplier)) % 360 
        local mainColor = Color3.fromHSV(hue / 360, 1, 1)
        part.Color = mainColor
        
        -- BASS SIÊU BẠO LỰC: Đập phồng cực đại lên tới 65% kích thước gốc, giật nảy tanh tách
        local scaleFactor = 1 + (normLoudness * 0.65) 
        part.Size = Vector3.new(baseSize.X * scaleFactor, baseSize.Y * (1 + normLoudness * 0.35), baseSize.Z * scaleFactor)
        
        -- Cập nhật nhịp nháy 6 thanh đối xứng Harman Kardon
        for _, item in pairs(VisualizerBars) do
            if item.Part and item.Part.Parent then
                -- Khoảng cách đối xứng chuẩn từ trục giữa (giữa thanh 3 và 4)
                local centerOffset = math.abs(item.Index - 3.5) 
                local waveFactor = math.sin(tick() * 26 + centerOffset * 2.5) * 0.2 -- Tăng tốc độ sóng nhịp
                
                -- Thanh nhịp giật cao vút theo tiếng Bass căng
                local targetHeight = math.clamp((normLoudness * 1.5) - (centerOffset * 0.12) + waveFactor, 0.05, 1.6)
                
                item.Part.Size = Vector3.new(barWidth * scaleFactor, targetHeight, item.Part.Size.Z)
                
                local currentTop = (part.Size.Y) / 2
                local currentXOffset = (-(totalWidthOfBars / 2) + (item.Index - 0.5) * barWidth) * scaleFactor
                item.Weld.C0 = CFrame.new(currentXOffset, currentTop + (targetHeight / 2), 0)
                
                local barHue = (hue + (centerOffset * 40)) % 360
                item.Part.Color = Color3.fromHSV(barHue / 360, 1, 1)
            end
        end
    end)
end

-- FIX LỖI DELAY KHI DIE/HỒI SINH: Gọi ngay lập tức, không chờ wait dài dòng
LocalPlayer.CharacterAdded:Connect(function(char)
    -- Chờ Humanoid xuất hiện là kích hoạt luôn, loại bỏ task.wait(0.5) gây trễ
    char:WaitForChild("Humanoid", 5)
    CreateFakeBoombox() 
end)

-- GIAO DIỆN GUI (Giữ nguyên toàn bộ cấu trúc cũ)
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Draggable = true
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Nút ẨN MENU
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

-- Nút MỞ MENU
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

-- Tiêu đề Menu
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(0.8, 0, 0, 30)
Title.Position = UDim2.new(0.05, 0, 0.05, 0)
Title.Text = "🎵 THANH PHÚC MUSIC"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Ô nhập ID Nhạc
local InputBox = Instance.new("TextBox", MainFrame)
InputBox.Size = UDim2.new(0.9, 0, 0, 40)
InputBox.Position = UDim2.new(0.05, 0, 0.25, 0)
InputBox.PlaceholderText = "Nhập ID nhạc..."
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InputBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", InputBox)

-- Nút PHÁT NHẠC
local PlayBtn = Instance.new("TextButton", MainFrame)
PlayBtn.Size = UDim2.new(0.9, 0, 0, 40)
PlayBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
PlayBtn.Text = "PHÁT NHẠC"
PlayBtn.TextColor3 = Color3.new(1, 1, 1)
PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
Instance.new("UICorner", PlayBtn)

-- FIX LỖI TRỄ ĐỔI NHẠC: Tạo lại loa tức thì khi bấm nút
PlayBtn.MouseButton1Click:Connect(function()
    local cleanID = InputBox.Text:match("%d+")
    if cleanID then
        LocalSound.SoundId = "rbxassetid://" .. cleanID
        LocalSound:Play()
        
        -- Kích hoạt loa ngay lập tức không thông qua delay
        CreateFakeBoombox()
        print("Thanh Phuc đã kích hoạt Bass Mi 10S tức thì, đủ 6 thanh nhịp chuẩn!")
    else
        InputBox.Text = ""
        InputBox.PlaceholderText = "ID không hợp lệ!"
    end
end)
