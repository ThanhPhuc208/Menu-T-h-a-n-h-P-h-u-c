-- (Creator = Thanh Phuc)
-- 💟 Thanh Phuc - Chroma Boombox Cầu Vồng Đeo Chéo + Nháy Theo Nhạc (Visualizer) 💟
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

-- TẠO CHROMA BOOMBOX ĐEO CHÉO ẢO + SÓNG NHẠC VISUALIZER
local FakeBoombox = nil
local VisualizerBars = {}
local loopConnection = nil -- Quản lý loop hiệu ứng tránh bị chồng luồng khi reset

local function CreateFakeBoombox()
    -- [SỬA LỖI]: Dọn dẹp cũ triệt để trước khi tạo mới để tránh xung đột khi chuyển bài
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
    
    -- TẠO CÁC THANH SÓNG NHẠC DÁN PHẲNG TRÊN BỀ MẶT NGOÀI BOOMBOX
    local barCount = 5 
    local barWidth = baseSize.X / barCount 
    
    for i = 1, barCount do
        local bar = Instance.new("Part")
        bar.Name = "VisualizerBar" .. i
        bar.Material = Enum.Material.Neon
        -- Khởi tạo thanh dẹt nằm phủ toàn bộ bề mặt ngoài (Y theo chiều cao, Z là độ dày để đập)
        local varSize = Vector3.new(barWidth - 0.02, baseSize.Y - 0.05, 0.02)
        bar.Size = varSize
        bar.CanCollide = false
        bar.Massless = true
        bar.Parent = character
        
        local barWeld = Instance.new("Weld")
        barWeld.Part0 = part
        barWeld.Part1 = bar
        
        -- Định vị đưa ra bề mặt ngoài của khối Boombox (baseSize.Z / 2)
        local xOffset = -(baseSize.X / 2) + (i - 0.5) * barWidth
        barWeld.C0 = CFrame.new(xOffset, 0, baseSize.Z / 2) 
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
        
        -- THUẬT TOÁN KÍCH BASS SIÊU ĐẬP KIỂU LOA MI 10S
        local loudness = LocalSound.PlaybackLoudness
        local rawNorm = math.clamp(loudness / 340, 0, 1) 
        local normLoudness = math.pow(rawNorm, 1.4) -- Lọc âm nhỏ, kích dải Bass đập cực sâu và nhạy
        
        -- Tốc độ chuyển màu Cầu vồng chạy theo nhịp Bass
        local speedMultiplier = 1 + (normLoudness * 4)
        hue = (hue + (0.5 * speedMultiplier)) % 360 
        local mainColor = Color3.fromHSV(hue / 360, 1, 1)
        
        -- Áp màu cầu vồng lên khối chính
        part.Color = mainColor
        
        -- ĐẬP THEO NHẠC: Khối nền co giãn nhẹ theo nhịp trống chung
        local scaleFactor = 1 + (normLoudness * 0.15) 
        part.Size = Vector3.new(baseSize.X * scaleFactor, baseSize.Y * scaleFactor, baseSize.Z)
        
        -- Cập nhật các thanh sóng nhạc dập nổi liên tục ngoài mặt loa
        for _, item in pairs(VisualizerBars) do
            if item.Part and item.Part.Parent then
                -- Tạo nhịp lượn sóng chạy mượt giữa các thanh
                local waveFactor = math.sin(tick() * 18 + item.Index) * 0.04
                -- Nhịp bass căng sẽ đẩy ĐỘ DÀY (Z) lồi ra ngoài mạnh mẽ
                local targetThickness = math.clamp((normLoudness * 0.5) + waveFactor, 0.02, 0.5)
                
                -- Chiều cao luôn nằm gọn trong lòng boombox, chỉ thay đổi độ dày dập ra (Z)
                item.Part.Size = Vector3.new(barWidth * scaleFactor - 0.02, (baseSize.Y * scaleFactor) - 0.05, targetThickness)
                
                -- Ghim chặt thanh led bám sát vào mặt ngoài khi khối chính co giãn
                local currentXOffset = (-(baseSize.X / 2) + (item.Index - 0.5) * barWidth) * scaleFactor
                item.Weld.C0 = CFrame.new(currentXOffset, 0, (baseSize.Z / 2) + (targetThickness / 2))
                
                -- Đổi màu dải cầu vồng lệch nhịp nối tiếp nhau cực đẹp
                local barHue = (hue + (item.Index * 20)) % 360
                item.Part.Color = Color3.fromHSV(barHue / 360, 1, 1)
            end
        end
    end)
end

-- TỰ ĐỘNG ĐEO LẠI KHI DIE (SỬA LỖI: Bỏ điều kiện check Sound đang chạy để luôn bám theo nhân vật)
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
        print("Thanh Phuc đã cập nhật bài hát mới thành công, Boombox vẫn giữ nguyên vị trí!")
    else
        InputBox.Text = ""
        InputBox.PlaceholderText = "ID không hợp lệ!"
    end
end)
