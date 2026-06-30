-- (Creator = Thanh Phuc)
-- 💟 Thanh Phuc - Chroma Boombox Cầu Vồng Đeo Chéo + Nháy Theo Nhạc (Visualizer Max Bass Harman Kardon Mi 10S) 💟
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

-- Giữ nguyên bộ phát âm thanh chuẩn của bạn
local LocalSound = Instance.new("Sound")
LocalSound.Name = "ThanhPhucLocalSound"
LocalSound.Parent = LocalPlayer:WaitForChild("PlayerWorkspace", 5) or workspace
LocalSound.Volume = 3.5 -- [UPGRADE]: Tăng volume gốc lên cho uy lực
LocalSound.Looped = true

-- TẠO CHROMA BOOMBOX ĐEO CHÉO ẢO + SÓNG NHẠC VISUALIZER
local FakeBoombox = nil
local VisualizerBars = {}
local loopConnection = nil -- Quản lý loop hiệu ứng tránh bị chồng luồng khi reset

local function CreateFakeBoombox()
    -- Dọn dẹp cũ triệt để trước khi tạo mới để tránh xung đột khi chuyển bài
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
    
    -- Chờ đợi chắc chắn bộ phận thân (Torso) xuất hiện để tránh lỗi khi hồi sinh
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
    
    -- Kích thước gốc chuẩn (gọn gàng như trong ảnh)
    local baseSize = Vector3.new(1.8, 1.2, 0.4)
    part.Size = baseSize
    
    -- Gắn và Xoay Xéo như đeo Balo Quai Chéo sau lưng
    local weld = Instance.new("Weld")
    weld.Part0 = torso
    weld.Part1 = part
    -- Lưu vị trí gốc của Weld để làm hiệu ứng giật rung lắc
    local baseC0 = CFrame.new(0, -0.2, 0.65) * CFrame.Angles(0, math.rad(180), math.rad(25))
    weld.C0 = baseC0
    weld.Parent = part
    
    -- TẠO CÁC THANH SÓNG NHẠC (VISUALIZER BARS) XẾP LIỀN KHÍT NHAU (FIX RĂNG THƯA)
    local barCount = 6 -- [FIX]: Cập nhật chuẩn 6 thanh nhịp theo yêu cầu của bạn
    local barWidth = baseSize.X / barCount -- Chia đều theo chiều dài khối hộp
    
    for i = 1, barCount do
        local bar = Instance.new("Part")
        bar.Name = "VisualizerBar" .. i
        bar.Material = Enum.Material.Neon
        -- Giữ nguyên barWidth, không trừ bớt để các thanh khít sát vào nhau hoàn hảo
        local varSize = Vector3.new(barWidth, 0.1, 0.2)
        bar.Size = varSize
        bar.CanCollide = false
        bar.Massless = true
        bar.Parent = character
        
        local barWeld = Instance.new("Weld")
        barWeld.Part0 = part
        barWeld.Part1 = bar
        
        -- Căn chỉnh vị trí xuất phát từ cạnh trái sang cạnh phải của khối hộp
        local xOffset = -(baseSize.X / 2) + (i - 0.5) * barWidth
        barWeld.C0 = CFrame.new(xOffset, baseSize.Y / 2, 0) 
        barWeld.Parent = bar
        
        table.insert(VisualizerBars, {Part = bar, Weld = barWeld, Index = i})
    end
    
    -- Hiệu ứng chạy màu cầu vồng + KHỐI CẦU VỒNG ĐẬP THEO ÂM THANH
    local hue = 0
    loopConnection = RunService.RenderStepped:Connect(function()
        if not part or not part.Parent or not part:IsDescendantOf(workspace) then
            if loopConnection then loopConnection:Disconnect() end
            return
        end
        
        -- [MAX BASS TUNING]: Thuật toán ép xung bạo lực nhịp bass của loa Harman Kardon Mi 10S
        local loudness = LocalSound.PlaybackLoudness
        local normLoudness = math.clamp(loudness / 260, 0, 1.4) -- Hạ ngưỡng giới hạn xuống 260 để Bass nhạy hơn, đẩy max lên 1.4 lần
        
        -- Tốc độ chuyển màu Cầu vồng chạy cực gắt theo nhịp Bass bạo lực
        local speedMultiplier = 1 + (normLoudness * 5)
        hue = (hue + (0.8 * speedMultiplier)) % 360 
        local mainColor = Color3.fromHSV(hue / 360, 1, 1)
        
        -- Áp màu cầu vồng lên khối chính
        part.Color = mainColor
        
        -- [SIÊU BẠO LỰC]: Khối loa co giãn cực mạnh (Scale Factor từ 0.22 -> 0.55) và giật nảy vị trí ngẫu nhiên khi có Bass
        local scaleFactor = 1 + (normLoudness * 0.55) 
        part.Size = Vector3.new(baseSize.X * scaleFactor, baseSize.Y * (1 + normLoudness * 0.4), baseSize.Z * scaleFactor)
        
        -- Tạo hiệu ứng giật (Shake) vật lý bạo lực cho cả khối loa đeo sau lưng
        if normLoudness > 0.6 then
            local shakeX = math.random(-10, 10) / 150
            local shakeY = math.random(-10, 10) / 150
            local shakeZ = math.random(-10, 10) / 150
            weld.C0 = baseC0 * CFrame.new(shakeX, shakeY, shakeZ) * CFrame.Angles(math.rad(shakeX*50), 0, math.rad(shakeY*50))
        else
            weld.C0 = baseC0
        end
        
        -- Cập nhật 6 thanh sóng nhạc giật nảy điên cuồng, nhấp nhô biên độ lớn
        for _, item in pairs(VisualizerBars) do
            if item.Part and item.Part.Parent then
                -- Đẩy tần số sóng và biên độ (waveFactor) lên cao để nhấp nhô sắc nét
                local waveFactor = math.sin(tick() * 28 + item.Index * 2) * 0.25
                -- Tăng targetHeight cực đại lên tới 1.8 (bản cũ là 0.7) giúp cột nhịp phóng cao hết cỡ
                local targetHeight = math.clamp((normLoudness * 1.4) + waveFactor, 0.05, 1.8)
                
                -- Cập nhật kích thước thanh (độ rộng tự động giãn đều theo scale khối chính)
                item.Part.Size = Vector3.new(barWidth * scaleFactor, targetHeight, item.Part.Size.Z)
                
                -- Định vị lại chân thanh luôn bám sát mặt trên khi khối hộp đập to nhỏ
                local currentTop = (part.Size.Y) / 2
                local currentXOffset = (-(baseSize.X / 2) + (item.Index - 0.5) * barWidth) * scaleFactor
                item.Weld.C0 = CFrame.new(currentXOffset, currentTop + (targetHeight / 2), 0)
                
                -- Đổi màu dải cầu vồng lệch nhịp nối tiếp nhau cực đẹp
                local barHue = (hue + (item.Index * 25)) % 360
                item.Part.Color = Color3.fromHSV(barHue / 360, 1, 1)
            end
        end
    end)
end

-- TỰ ĐỘNG ĐEO LẠI KHI DIE
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5) -- Chờ nhân vật tải xong hoàn toàn
    CreateFakeBoombox() -- Tự động tạo lại loa dính sau lưng mãi mãi
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

-- Kích hoạt phát nhạc và gọi Loa Đeo Chéo xuất hiện
PlayBtn.MouseButton1Click:Connect(function()
    local cleanID = InputBox.Text:match("%d+")
    if cleanID then
        LocalSound.SoundId = "rbxassetid://" .. cleanID
        LocalSound:Play()
        
        -- Thực hiện tạo mới / cập nhật lại loa ngay lập tức
        CreateFakeBoombox()
        print("Thanh Phuc đã cập nhật bài hát mới thành công, Boombox Harman Kardon đã sẵn sàng nổ tung!")
    else
        InputBox.Text = ""
        InputBox.PlaceholderText = "ID không hợp lệ!"
    end
end)
