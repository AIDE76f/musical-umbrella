local player = game.Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

-- تنظيف الواجهة السابقة
if guiParent:FindFirstChild("CarRadarFinal") then
    guiParent.CarRadarFinal:Destroy()
end

--------------------------------------------------
-- 1. تصميم واجهة المعلومات (UI)
--------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CarRadarFinal"
screenGui.Parent = guiParent

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 250)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "📡 رادار كشف السيارات"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = mainFrame

local infoBox = Instance.new("Frame")
infoBox.Size = UDim2.new(1, -30, 0, 120)
infoBox.Position = UDim2.new(0, 15, 0, 55)
infoBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
infoBox.Parent = mainFrame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 8)
boxCorner.Parent = infoBox

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 1, -20)
infoLabel.Position = UDim2.new(0, 10, 0, 10)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "اضغط على زر التحديث لجلب أغلى سيارة حالياً..."
infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 15
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Right
infoLabel.Parent = infoBox

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0, 200, 0, 40)
refreshBtn.Position = UDim2.new(0.5, -100, 1, -55)
refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
refreshBtn.Text = "تحديث البيانات 🔄"
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 16
refreshBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = refreshBtn

--------------------------------------------------
-- 2. دوال معالجة الأرقام والبحث
--------------------------------------------------
local function convertNumbers(str)
    local map = {["٠"]="0", ["١"]="1", ["٢"]="2", ["٣"]="3", ["٤"]="4", ["٥"]="5", ["٦"]="6", ["٧"]="7", ["٨"]="8", ["٩"]="9", [","]="", [" "]="", ["\n"]=""}
    local res = str
    for ar, en in pairs(map) do res = string.gsub(res, ar, en) end
    return res
end

local function scanForCars()
    local highestPrice = 0
    local carName = "غير معروف"
    local area = "غير محدد"
    
    -- المسارات التي وجدناها في صورتك
    local paths = {
        {name = "HarajPage", area = "الحي الشريطي (الحراج)"},
        {name = "SaleUI", area = "معرض السيارات الرئيسي"},
        {name = "SaleUI2", area = "المعرض (قائمة 2)"},
        {name = "CarSellConfirmation", area = "منطقة البيع المباشر"},
        {name = "Desktop", area = "تطبيق الجوال / الحراج"}
    }

    for _, pathData in ipairs(paths) do
        local ui = guiParent:FindFirstChild(pathData.name)
        if ui then
            for _, obj in pairs(ui:GetDescendants()) do
                if obj:IsA("TextLabel") and obj.Text ~= "" then
                    pcall(function()
                        local cleanText = convertNumbers(obj.Text)
                        local price = tonumber(string.match(cleanText, "%d+"))
                        
                        -- نبحث عن سعر حقيقي (أكبر من 50 ألف وأكبر من السعر السابق)
                        if price and price > 50000 and price > highestPrice then
                            highestPrice = price
                            area = pathData.area
                            
                            -- محاولة جلب الاسم (عادة يكون في الـ Parent أو بجوار السعر)
                            local p = obj.Parent
                            if p then
                                for _, child in pairs(p:GetChildren()) do
                                    if child:IsA("TextLabel") and child ~= obj and string.len(child.Text) > 2 then
                                        if not string.find(child.Text, "ريال") then
                                            carName = child.Text
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
    
    return highestPrice, carName, area
end

--------------------------------------------------
-- 3. تشغيل التحديث
--------------------------------------------------
refreshBtn.MouseButton1Click:Connect(function()
    infoLabel.Text = "جاري الفحص..."
    task.wait(0.5)
    
    local price, name, area = scanForCars()
    
    if price > 0 then
        infoLabel.Text = 
            "🏆 أغلى سيارة تم رصدها:\n\n" ..
            "🏷️ الاسم: " .. name .. "\n" ..
            "💰 السعر: " .. price .. " ريال\n" ..
            "📍 المكان: " .. area
    else
        infoLabel.Text = "❌ لم يتم رصد سيارات غالية في القوائم حالياً.\nتأكد من فتح تطبيق الجوال أو الاقتراب من اللوحة لتظهر البيانات."
    end
end)
