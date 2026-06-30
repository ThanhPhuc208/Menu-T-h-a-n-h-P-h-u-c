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
    
    -- Kích thước gốc chuẩn (gọn gàng như trong ảnh 1000056621.jpg)
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
    StarEmitter.Lifetime = NumberRange.new(0.4, 1.0) -- Thời gian tồn tại của ngôi sao (giảm nhẹ để bay nhanh gọn)
    StarEmitter.Speed = NumberRange.new(4, 10) -- Tăng tốc độ bay tỏa ra cho mạnh mẽ theo Bass
    StarEmitter.SpreadAngle = Vector2.new(60, 60) -- Góc tỏa rộng ra xung quanh
    StarEmitter.Parent = part
    -- =======================================================

    -- TẠO CÁC THANH SÓNG NHẠC (VISUALIZER BARS) XẾP LIỀN KHÍT NHAU
    local barCount = 5 
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
    
    -- Hiệu ứng chạy màu cầu vồng + KHỐI CẦU VỒNG ĐẬP + NGÔI SAO BIẾN ĐỔI THEO NHẠC
    local hue = 0
    loopConnection = RunService.RenderStepped:Connect(function()
        if not part or not part.Parent or not part:IsDescendantOf(workspace) then
            if loopConnection then loopConnection:Disconnect() end
            return
        end
        
        -- LẤY ĐỘ LỚN ÂM THANH & TỐI ƯU NHỊP BASS KIỂU LOA MI 10S
        local loudness = LocalSound.PlaybackLoudness
        local rawNorm = math.clamp(loudness / 350, 0, 1) 
        -- Sử dụng hàm mũ để lọc âm nhỏ, đẩy âm Bass mạnh lên cực đại
        local normLoudness = math.pow(rawNorm, 1.5) 
        
        -- Tốc độ chuyển màu Cầu vồng chạy cực gắt theo nhịp Bass
        local speedMultiplier = 1 + (normLoudness * 4)
        hue = (hue + (0.5 * speedMultiplier)) % 360 
        local mainColor = Color3.fromHSV(hue / 360, 1, 1)
        
        -- Áp màu cầu vồng lên khối chính
        part.Color = mainColor
        
        -- SIÊU BASS ĐẬP MẠNH: Tăng hệ số co giãn lên 0.5 để loa dập nảy mạnh mẽ
        local scaleFactor = 1 + (normLoudness * 0.5) 
        part.Size = Vector3.new(baseSize.X * scaleFactor, baseSize.Y * (1 + normLoudness * 0.3), baseSize.Z * scaleFactor)
        
        -- [CẬP NHẬT HIỆU ỨNG NGÔI SAO MẠNH MẼ]:
        if StarEmitter then
            StarEmitter.Rate = normLoudness * 120 -- Nhạc đập mạnh sao bắn ra dày đặc như pháo hoa
            StarEmitter.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.2 * scaleFactor), 
                NumberSequenceKeypoint.new(1, 0.7 * scaleFactor)
            })
            StarEmitter.Color = ColorSequence.new(mainColor) 
        end
        
        -- Cập nhật các thanh sóng nhạc giật tung nóc theo nhịp
        for _, item in pairs(VisualizerBars) do
            if item.Part and item.Part.Parent then
                local waveFactor = math.sin(tick() * 20 + item.Index) * 0.08 -- Tăng tần số sóng nhấp nhô
                local targetHeight = math.clamp((normLoudness * 1.4) + waveFactor, 0.05, 1.5) -- Cho phép đẩy cao hẳn lên
                
                item.Part.Size = Vector3.new(barWidth * scaleFactor, targetHeight, item.Part.Size.Z)
                
                local currentTop = (part.Size.Y) / 2
                local currentXOffset = (-(baseSize.X / 2) + (item.Index - 0.5) * barWidth) * scaleFactor
                item.Weld.C0 = CFrame.new(currentXOffset, currentTop + (targetHeight / 2), 0)
                
                local barHue = (hue + (item.Index * 20)) % 360
                item.Part.Color = Color3.fromHSV(barHue / 360, 1, 1)
            end
        end
    end)

