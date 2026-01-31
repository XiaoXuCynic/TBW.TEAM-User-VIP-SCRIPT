local LiJianUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

LiJianUI.TransparencyValue = 0.3
LiJianUI:SetTheme("Dark")

local function gradient(text, startColor, endColor)
    local result = ""
    for i = 1, #text do
        local t = (i - 1) / (#text - 1)  
        
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
        
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, text:sub(i, i))
    end
    return result
end

local Window = LiJianUI:CreateWindow({
    Title = "Sword | 最强战场", 
    Icon = "crown", 
    Author = "By TBW.TEAM", 
    Folder = "Sword", 
    Size = UDim2.fromOffset(400, 250), 
    Theme = "Dark", 
    
    User = {
        Enabled = true, 
        Anonymous = false, 
        Callback = function() 
            LiJianUI:Notify({
                Title = "信息",
                Content = "你的信息",
                Duration = 3
            })
        end
    },
    SideBarWidth = 170, 
    ScrollBarEnabled = false 
})

-- 修复：先创建标签页，然后在标签页内创建功能区域
local TabHandles = {
    Main = Window:Tab({ Title = "主要", Icon = "star" }),  -- 主要标签页
    Teleport = Window:Tab({ Title = "传送", Icon = "drama" }),  -- 传送标签页
    Misc = Window:Tab({ Title = "杂项", Icon = "moon" }),  -- 杂项标签页
    ESP = Window:Tab({ Title = "ESP", Icon = "sword" })  -- ESP标签页
}

-- 在标签页内创建功能区域
local Sections = {
    Game = TabHandles.Main:Section({ Title = "功能", Icon = "star", Opened = true }),
    TP = TabHandles.Teleport:Section({ Title = "传送功能", Icon = "drama", Opened = true }),
    THE = TabHandles.Misc:Section({ Title = "杂项功能", Icon = "moon", Opened = true }),
    ESP = TabHandles.ESP:Section({ Title = "ESP功能", Icon = "sword", Opened = true })
}

LiJianUI:Notify({Title = "crown", Content = "最强战场", Duration = 3}) 
task.wait(0.1)

-- 主要功能标签页
Sections.Game:Toggle({
    Title = "无晕值",
    Value = false,
    Callback = function(enabled)
        _G.antifreeze = enabled
        if enabled then
            task.spawn(function()
                while _G.antifreeze do
                    local character = game.Players.LocalPlayer.Character
                    if character then
                        local freeze = character:FindFirstChild("Freeze")
                        if freeze then
                            freeze:Destroy()
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

Sections.Game:Toggle({
    Title = "自动锁敌",
    Value = false,
    Callback = function(enabled)
        local autoAimConnection
        local RunService = game:GetService("RunService")
        local PlayerService = game:GetService("Players")
        local CurrentUser = game.Players.LocalPlayer
        
        if enabled then
            local Heartbeat = RunService.Heartbeat
            local enabledFlag = true
            
            autoAimConnection = Heartbeat:Connect(function()
                if not enabledFlag then return end
                
                local localCharacter = CurrentUser.Character
                if not localCharacter then return end
                
                local localHumanoidRootPart = localCharacter:FindFirstChild("HumanoidRootPart")
                if not localHumanoidRootPart then return end
                
                local closestPlayer = nil
                local closestDistance = math.huge
                
                for _, player in ipairs(PlayerService:GetPlayers()) do
                    if player ~= CurrentUser then
                        local targetCharacter = player.Character
                        if targetCharacter then
                            local targetHumanoidRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
                            if targetHumanoidRootPart then
                                local distance = (localHumanoidRootPart.Position - targetHumanoidRootPart.Position).Magnitude
                                if distance < closestDistance then
                                    closestDistance = distance
                                    closestPlayer = player
                                end
                            end
                        end
                    end
                end
                
                if closestPlayer and closestDistance < 50 then
                    print("锁定目标:", closestPlayer.Name, "距离:", math.floor(closestDistance))
                end
            end)
            
            LiJianUI:Notify({
                Duration = 3,
                Title = "自动锁敌已开启",
                Content = "打死别人"
            })
        else
            if autoAimConnection then
                autoAimConnection:Disconnect()
                autoAimConnection = nil
            end
        end
    end
})

Sections.Game:Toggle({
    Title = "靠近假防",
    Value = false,
    Callback = function(enabled)
        local fakeDefenseAnimation
        local fakeDefenseConnection
        local RunService = game:GetService("RunService")
        local PlayerService = game:GetService("Players")
        local CurrentUser = game.Players.LocalPlayer
        
        if enabled then
            local character = CurrentUser.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    local animation = Instance.new("Animation")
                    animation.AnimationId = "rbxassetid://10470389827"
                    fakeDefenseAnimation = humanoid:LoadAnimation(animation)
                end
            end
            
            local enabledFlag = true
            local Heartbeat = RunService.Heartbeat
            fakeDefenseConnection = Heartbeat:Connect(function()
                if not enabledFlag or not CurrentUser.Character then return end
                
                local localCharacter = CurrentUser.Character
                local localHumanoidRootPart = localCharacter:FindFirstChild("HumanoidRootPart")
                if not localHumanoidRootPart then return end
                
                local someoneNearby = false
                
                for _, player in ipairs(PlayerService:GetPlayers()) do
                    if player ~= CurrentUser then
                        local targetCharacter = player.Character
                        if targetCharacter then
                            local targetHumanoidRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
                            if targetHumanoidRootPart then
                                local distance = (localHumanoidRootPart.Position - targetHumanoidRootPart.Position).Magnitude
                                if distance <= 30 then
                                    someoneNearby = true
                                    break
                                end
                            end
                        end
                    end
                end
                
                if fakeDefenseAnimation then
                    if someoneNearby and not fakeDefenseAnimation.IsPlaying then
                        fakeDefenseAnimation:Play()
                    elseif not someoneNearby and fakeDefenseAnimation.IsPlaying then
                        fakeDefenseAnimation:Stop()
                    end
                end
            end)
        else
            if fakeDefenseAnimation and fakeDefenseAnimation.IsPlaying then
                fakeDefenseAnimation:Stop()
            end
            if fakeDefenseConnection then
                fakeDefenseConnection:Disconnect()
                fakeDefenseConnection = nil
            end
        end
    end
})

Sections.Game:Toggle({
    Title = "朝向自瞄",
    Value = false,
    Callback = function(enabled)
        local aimAssistConnection
        local RunService = game:GetService("RunService")
        local PlayerService = game:GetService("Players")
        local CurrentUser = game.Players.LocalPlayer
        
        if enabled then
            local enabledFlag = true
            local Heartbeat = RunService.Heartbeat
            aimAssistConnection = Heartbeat:Connect(function()
                if not enabledFlag or not CurrentUser.Character then return end
                
                local localCharacter = CurrentUser.Character
                local localHumanoidRootPart = localCharacter:FindFirstChild("HumanoidRootPart")
                if not localHumanoidRootPart then return end
                
                local closestPlayer = nil
                local closestDistance = math.huge
                
                for _, player in ipairs(PlayerService:GetPlayers()) do
                    if player ~= CurrentUser then
                        local targetCharacter = player.Character
                        if targetCharacter then
                            local targetHumanoidRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
                            if targetHumanoidRootPart then
                                local distance = (localHumanoidRootPart.Position - targetHumanoidRootPart.Position).Magnitude
                                if distance < closestDistance then
                                    closestDistance = distance
                                    closestPlayer = player
                                end
                            end
                        end
                    end
                end
                
                if closestPlayer and closestDistance < 100 then
                    local targetCharacter = closestPlayer.Character
                    if targetCharacter then
                        local targetHumanoidRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
                        if targetHumanoidRootPart then
                            local direction = (targetHumanoidRootPart.Position - localHumanoidRootPart.Position)
                            localHumanoidRootPart.CFrame = CFrame.lookAt(
                                localHumanoidRootPart.Position,
                                localHumanoidRootPart.Position + direction
                            )
                        end
                    end
                end
            end)
        else
            if aimAssistConnection then
                aimAssistConnection:Disconnect()
                aimAssistConnection = nil
            end
        end
    end
})

Sections.Game:Toggle({
    Title = "靠近自动攻击",
    Value = false,
    Callback = function(enabled)
        local autoAttackConnection
        local RunService = game:GetService("RunService")
        local PlayerService = game:GetService("Players")
        local CurrentUser = game.Players.LocalPlayer
        
        if enabled then
            local enabledFlag = true
            local Heartbeat = RunService.Heartbeat
            autoAttackConnection = Heartbeat:Connect(function()
                if not enabledFlag or not CurrentUser.Character then return end
                
                local localCharacter = CurrentUser.Character
                local localHumanoidRootPart = localCharacter:FindFirstChild("HumanoidRootPart")
                if not localHumanoidRootPart then return end
                
                for _, player in ipairs(PlayerService:GetPlayers()) do
                    if player ~= CurrentUser then
                        local targetCharacter = player.Character
                        if targetCharacter then
                            local targetHumanoidRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
                            if targetHumanoidRootPart then
                                local distance = (localHumanoidRootPart.Position - targetHumanoidRootPart.Position).Magnitude
                                
                                if distance < 20 then
                                    print("自动攻击目标:", player.Name, "距离:", math.floor(distance))
                                end
                            end
                        end
                    end
                end
            end)
        else
            if autoAttackConnection then
                autoAttackConnection:Disconnect()
                autoAttackConnection = nil
            end
        end
    end
})

-- 传送功能标签页
Sections.TP:Button({
    Title = "传送到墙上",
    Callback = function()
        local CurrentUser = game.Players.LocalPlayer
        local character = CurrentUser.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.CFrame = CFrame.new(302.3, 671.1, 384.1)
                LiJianUI:Notify({
                    Duration = 3,
                    Title = "传送成功",
                    Content = "已传送到墙上"
                })
            else
                LiJianUI:Notify({
                    Duration = 3,
                    Title = "传送失败",
                    Content = "找不到HumanoidRootPart"
                })
            end
        else
            LiJianUI:Notify({
                Duration = 3,
                Title = "传送失败",
                Content = "找不到角色"
            })
        end
    end
})

Sections.TP:Button({
    Title = "传送到中间",
    Callback = function()
        local CurrentUser = game.Players.LocalPlayer
        local character = CurrentUser.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.CFrame = CFrame.new(124.2, 440.8, -29.9)
                LiJianUI:Notify({
                    Duration = 3,
                    Title = "传送成功",
                    Content = "已传送到中间"
                })
            else
                LiJianUI:Notify({
                    Duration = 3,
                    Title = "传送失败",
                    Content = "找不到HumanoidRootPart"
                })
            end
        else
            LiJianUI:Notify({
                Duration = 3,
                Title = "传送失败",
                Content = "找不到角色"
            })
        end
    end
})

Sections.TP:Button({
    Title = "传送到安全点",
    Callback = function()
        local CurrentUser = game.Players.LocalPlayer
        local character = CurrentUser.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.CFrame = CFrame.new(0, 100, 0)
                LiJianUI:Notify({
                    Duration = 3,
                    Title = "传送成功",
                    Content = "已传送到安全点"
                })
            else
                LiJianUI:Notify({
                    Duration = 3,
                    Title = "传送失败",
                    Content = "找不到HumanoidRootPart"
                })
            end
        else
            LiJianUI:Notify({
                Duration = 3,
                Title = "传送失败",
                Content = "找不到角色"
            })
        end
    end
})

-- 杂项功能标签页
Sections.THE:Slider({
    Title = "速度",
    Default = 16,
    Min = 0,
    Max = 100,
    Icon = "gauge",
    Callback = function(value)
        local CurrentUser = game.Players.LocalPlayer
        local character = CurrentUser.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
})

Sections.THE:Slider({
    Title = "高度",
    Default = 50,
    Min = 0,
    Max = 200,
    Icon = "chevron-up",
    Callback = function(value)
        local CurrentUser = game.Players.LocalPlayer
        local character = CurrentUser.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = value
            end
        end
    end
})

Sections.THE:Toggle({
    Title = "无限跳",
    Value = false,
    Callback = function(enabled)
        local CurrentUser = game.Players.LocalPlayer
        local UserInputService = game:GetService("UserInputService")
        
        if enabled then
            local spacePressed = false
            
            local inputConnection = UserInputService.InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Space then
                    spacePressed = true
                    while spacePressed and enabled do
                        local character = CurrentUser.Character
                        if character then
                            local humanoid = character:FindFirstChild("Humanoid")
                            if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
                                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                        end
                        task.wait(0.1)
                    end
                end
            end)
            
            local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Space then
                    spacePressed = false
                end
            end)
            
            _G.infiniteJumpConnections = {
                inputConnection,
                inputEndedConnection
            }
        else
            if _G.infiniteJumpConnections then
                for _, conn in ipairs(_G.infiniteJumpConnections) do
                    conn:Disconnect()
                end
                _G.infiniteJumpConnections = nil
            end
        end
    end
})

Sections.THE:Toggle({
    Title = "穿墙",
    Value = false,
    Callback = function(enabled)
        local CurrentUser = game.Players.LocalPlayer
        _G.noclipEnabled = enabled
        
        if enabled then
            local character = CurrentUser.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                
                _G.noclipConnection = character.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("BasePart") then
                        descendant.CanCollide = false
                    end
                end)
            end
            
            _G.characterAddedConnection = CurrentUser.CharacterAdded:Connect(function(newCharacter)
                if _G.noclipEnabled then
                    for _, part in ipairs(newCharacter:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                    
                    if _G.noclipConnection then
                        _G.noclipConnection:Disconnect()
                    end
                    
                    _G.noclipConnection = newCharacter.DescendantAdded:Connect(function(descendant)
                        if descendant:IsA("BasePart") then
                            descendant.CanCollide = false
                        end
                    end)
                end
            end)
        else
            local character = CurrentUser.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
            
            if _G.noclipConnection then
                _G.noclipConnection:Disconnect()
                _G.noclipConnection = nil
            end
            
            if _G.characterAddedConnection then
                _G.characterAddedConnection:Disconnect()
                _G.characterAddedConnection = nil
            end
        end
    end
})

-- ESP功能标签页
Sections.ESP:Toggle({
    Title = "ESP Player",
    Value = false,
    Callback = function(enabled)
        local PlayerService = game:GetService("Players")
        local CurrentUser = game.Players.LocalPlayer
        _G.espEnabled = enabled
        
        if enabled then
            for _, player in ipairs(PlayerService:GetPlayers()) do
                if player ~= CurrentUser then
                    task.spawn(function()
                        local character = player.Character
                        if character then
                            local highlight = Instance.new("Highlight")
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.FillTransparency = 0.5
                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            highlight.Parent = character
                            
                            _G["esp_" .. player.UserId] = highlight
                            
                            player.CharacterAdded:Connect(function(newCharacter)
                                task.wait(1)
                                if _G["esp_" .. player.UserId] then
                                    _G["esp_" .. player.UserId]:Destroy()
                                end
                                
                                if _G.espEnabled then
                                    local newHighlight = Instance.new("Highlight")
                                    newHighlight.FillColor = Color3.fromRGB(255, 0, 0)
                                    newHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                    newHighlight.FillTransparency = 0.5
                                    newHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    newHighlight.Parent = newCharacter
                                    
                                    _G["esp_" .. player.UserId] = newHighlight
                                end
                            end)
                        end
                    end)
                end
            end
            
            _G.playerAddedConnection = PlayerService.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(character)
                    if _G.espEnabled then
                        task.wait(1)
                        local highlight = Instance.new("Highlight")
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.5
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Parent = character
                        
                        _G["esp_" .. player.UserId] = highlight
                    end
                end)
            end)
        else
            for _, player in ipairs(PlayerService:GetPlayers()) do
                if player ~= CurrentUser then
                    local character = player.Character
                    if character then
                        for _, child in ipairs(character:GetChildren()) do
                            if child:IsA("Highlight") then
                                child:Destroy()
                            end
                        end
                    end
                    _G["esp_" .. player.UserId] = nil
                end
            end
            
            if _G.playerAddedConnection then
                _G.playerAddedConnection:Disconnect()
                _G.playerAddedConnection = nil
            end
        end
    end
})