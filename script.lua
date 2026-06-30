-- (Creator = Thanh Phuc)
-- 💟 Thanh Phuc - Chroma Boombox + Nháy Theo Nhạc + Hiệu Ứng Ngôi Sao Lấp Lánh 💟
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

-- TẠO CHROMA BOOMBOX ĐEO CHÉO ẢO + SÓNG NHẠC + NGÔI SAO
local FakeBoombox = nil
local VisualizerBars = {}
local StarEmitter = nil -- Quản lý hiệu ứng ngôi sao phát sáng
local loopConnection = nil 

local function CreateFakeBoombox()
    -- Dọn dẹp cũ triệt để trước khi tạo mới để tránh xung đột
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
    weld.C0 = CFrame.new(0, -0.2, 0.65) * CFrame.Angles(0, math.rad(180), math.rad(25))
    weld.Parent = part
    
    -- =======================================================
    -- [TÍNH NĂNG MỚI]: TẠO HIỆU ỨNG NGÔI SAO PHÁT SÁNG (STAR EMITTER)
    -- =======================================================
    StarEmitter = Instance.new("ParticleEmitter")
    StarEmitter.Texture = "rbxassetid://10849912115" -- ID kết cấu hình Ngôi sao lấp lánh chuẩn Roblox
    StarEmitter.LightEmission = 1 -- Tạo độ phát sáng rực rỡ (Glow)
    StarEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),    -- Hiện rõ lúc đầu
        NumberSequenceKeypoint.new(0.8, 0.2),-- Mờ dần
        NumberSequenceKeypoint.new(1, 1)     -- Biến mất hẳn
    })
    StarEmitter.Lifetime = NumberRange.new(0.4, 0.9) -- Tối ưu thời gian sao tồn tại để bay gọn gàng hơn
    StarEmitter.Speed = NumberRange.new(3, 8) -- Tốc độ bay tỏa ra ngoài mạnh mẽ theo Bass
    StarEmitter.SpreadAngle = Vector2.new(50, 50) -- Góc tỏa rộng ra xung quanh
    StarEmitter.Parent = part
    -- =======================================================

    -- TẠO CÁC THANH SÓNG NHẠC DÁN PHẲNG TRÊN BỀ MẶT NGOÀI CỦA LOA
    local barCount = 5 
    local barWidth = (baseSize.X - 0.05) / barCount 
    
    for i = 1, barCount do
        local bar = Instance.new("Part")
        bar.Name = "VisualizerBar" .. i
        bar.Material = Enum.Material.Neon
        -- Khởi tạo thanh dẹt phủ kín bề ngoài của Boombox (Z ban đầu mỏng để dập lồi ra)
        bar.Size = Vector3.new(barWidth - 0.02, baseSize.Y - 0.05, 0.02)
        bar.CanCollide = false
        bar.Massless = true
        bar.Parent = character
        
        local barWeld = Instance.new("Weld")
        barWeld.Part0 = part
        barWeld.Part1 = bar
        
        -- Căn tọa độ Z dán đè lên mặt ngoài (bằng một nửa chiều sâu loa)
        local xOffset = -(baseSize.X / 2) + (i - 0.5) * barWidth
        barWeld.C0 = CFrame.new(xOffset, 0, baseSize.Z / 2) 
        barWeld.Parent = bar
        
        table.insert(VisualizerBars, {Part = bar, Weld = barWeld, Index = i})
    end
    
    -- Hiệu ứng chạy màu cầu vồng + KHỐI CẦU VỒNG ĐẬP + NGÔI SAO BIẾN ĐỔI THEO NHẠC
    local hue = 0
    loopConnection = RunService.RenderStepped:Connect(function()
        if not part or not part.Parent or not part:IsDescendantOf(workspace) then
            if loopConnection then loopConnection:Disconnect() end
            return
        end
        
        -- THUẬT TOÁN KÍCH BASS CỰC ĐẠI THEO PHONG CÁCH LOA MI 10S
        local loudness = LocalSound.PlaybackLoudness
        local rawNorm = math.clamp(loudness / 340, 0, 1) 
        local normLoudness = math.pow(rawNorm, 1.4) -- Đẩy dải Bass cao hẳn lên, dập cực sâu
        
        -- Tốc độ chuyển màu Cầu vồng chạy theo nhịp Bass
        local speedMultiplier = 1 + (normLoudness * 4)
        hue = (hue + (0.5 * speedMultiplier)) % 360 
        local mainColor = Color3.fromHSV(hue / 360, 1, 1)
        
        -- Áp màu cầu vồng lên khối chính
        part.Color = mainColor
        
        -- ĐẬP THEO NHẠC: Khối nền chính co giãn mượt mà theo nhịp điệu chung
        local scaleFactor = 1 + (normLoudness * 0.15) 
        part.Size = Vector3.new(baseSize.X * scaleFactor, baseSize.Y * scaleFactor, baseSize.Z)
        
        -- [CẬP NHẬT HIỆU ỨNG NGÔI SAO]: Nhịp nhạc càng căng sao bắn càng dày
        if StarEmitter then
            StarEmitter.Rate = normLoudness * 90 
            StarEmitter.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.2 * scaleFactor), 
                NumberSequenceKeypoint.new(1, 0.6 * scaleFactor)
            })
            StarEmitter.Color = ColorSequence.new(mainColor) 
        end
        
        -- Cập nhật các thanh sóng nhạc dập nổi liên tục ngoài mặt loa
        for _, item in pairs(VisualizerBars) do
            if item.Part and item.Part.Parent then
                -- Tạo hiệu ứng lượn sóng nhẹ nhàng chạy mượt
                local waveFactor = math.sin(tick() * 18 + item.Index) * 0.04
                -- Nhịp bass đập mạnh sẽ đẩy ĐỘ DÀY (chiều sâu Z) lồi ra ngoài cực mạnh
                local targetThickness = math.clamp((normLoudness * 0.45) + waveFactor, 0.02, 0.5)
                
                -- Chiều cao (Y) luôn nằm gọn trong thân loa không vượt quá đầu, chỉ dập nảy ra mặt ngoài (Z)
                item.Part.Size = Vector3.new(barWidth * scaleFactor - 0.02, (baseSize.Y * scaleFactor) - 0.05, targetThickness)
                
                -- Điều chỉnh vị trí Weld liên tục để thanh bám sát bề mặt ngoài khi dập
                local currentXOffset = (-(baseSize.X / 2) + (item.Index - 0.5) * barWidth) * scaleFactor
                item.Weld.C0 = CFrame.new(currentXOffset, 0, (baseSize.Z / 2) + (targetThickness / 2))
                
                -- Màu sắc chạy dải led ma trận cầu vồng tuyệt đẹp
                local barHue = (hue + (item.Index * 20)) % 360
                item.Part.Color = Color3.fromHSV(barHue / 360, 1, 1)
            end
        end
    end)
end

-- TỰ ĐỘNG ĐEO LẠI KHI DIE (Bám dính vĩnh viễn vào nhân vật sau khi hồi sinh)
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5) -- Chờ nhân vật ổn định khớp xương
    CreateFakeBoombox() 
end)

-- GIAO DIỆN GUI (Giữ nguyên cấu trúc cũ của bạn)
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
        CreateFakeBoombox()
        print("Thanh Phuc đã cập nhật bài hát mới thành công kèm hiệu ứng Ngôi sao!")
    else
        InputBox.Text = ""
        InputBox.PlaceholderText = "ID không hợp lệ!"
    end
end)
