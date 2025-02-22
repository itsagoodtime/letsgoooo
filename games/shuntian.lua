local library = letsdoit('ui.lua','misc')
local Services = letsdoit('s1.lua','models')
local Utility = letsdoit('u1.lua','models')
local Maid = letsdoit('m1.lua','models')
local ControlModule = letsdoit('c1.lua','models')

local Players,RunService,UserInputService,Lighting = Services:Get('Players','RunService','UserInputService','Lighting')
local maid = Maid.new()

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local cjumpvalue
local djumpvalue

if hum.UseJumpPower == true then
    cjumpvalue = 'JumpPower'
    djumpvalue = 50
else
    cjumpvalue = 'JumpHeight'
    djumpvalue = 7
end
local functions = {}

do
	function functions.speedHack(toggle)
		if (not toggle) then
			maid.speedHack = nil;
			maid.speedHackBv = nil;

			return;
		end;

		maid.speedHack = RunService.Heartbeat:Connect(function()
			local playerData = Utility:getPlayerData()
			local humanoid, rootPart = playerData.humanoid, playerData.primaryPart;
			if (not humanoid or not rootPart) then return end;

			maid.speedHackBv = maid.speedHackBv or Instance.new('BodyVelocity');
			maid.speedHackBv.MaxForce = Vector3.new(100000, 0, 100000);

			maid.speedHackBv.Parent = rootPart or nil;
			maid.speedHackBv.Velocity = (humanoid.MoveDirection.Magnitude ~= 0 and humanoid.MoveDirection or gethiddenproperty(humanoid, 'WalkDirection')) * library.Flags.speedHackValue.CurrentValue;
		end);
	end;

    function functions.infiniteJump(toggle)
        if (not toggle) then
            maid.infjump = nil
        end

        maid.infjump = UserInputService.JumpRequest:Connect(function()
            local playerData = Utility:getPlayerData()
            local rootPart,humanoid = playerData.rootPart,playerData.humanoid
            if rootPart and library.Flags.infiniteJump.CurrentValue then
                humanoid[cjumpvalue] = library.Flags.infiniteJumpHeight.CurrentValue
                humanoid:ChangeState("Jumping")
            else
                humanoid[cjumpvalue] = djumpvalue
                maid.infjump = nil
            end
        end)
    end;
    
    function functions.noClip(toggle)
        if (not toggle or not library.Flags.noclip.CurrentValue) then
            maid.noClip = nil
    
            local humanoid = Utility:getPlayerData().humanoid
            if (not humanoid) then return end
    
            humanoid:ChangeState('Physics')
            task.wait()
            humanoid:ChangeState('RunningNoPhysics')
    
            return
        end
    
        maid.noClip = RunService.Stepped:Connect(function()
            local myCharacterParts = Utility:getPlayerData().parts
    
            for _, v in next, myCharacterParts do
                v.CanCollide = false
            end
        end)
    end
    
    local lastFogDensity = 0

    function functions.noFog(t)
        if not t then Lighting.Atmosphere.Density = lastFogDensity; maid.noFog = nil; return; end
    
        maid.noFog = Lighting.Atmosphere:GetPropertyChangedSignal('Density'):Connect(function()
            Lighting.Atmosphere.Density = 0;
        end);
    
        lastFogDensity = Lighting.Atmosphere.Density;
        Lighting.Atmosphere.Density = 0;
    end
    
    function functions.noBlur(t)
        local dof = Lighting.DepthOfField;
        if not t then maid.noBlur = nil; dof.Enabled = true; return; end
    
        maid.noBlur = Lighting.DepthOfField:GetPropertyChangedSignal('Enabled'):Connect(function()
            if not dof.Enabled then return; end
            dof.Enabled = false;
        end);
    
        dof.Enabled = false;
    end
    
    local oldAmbient, oldBritghtness = Lighting.Ambient, Lighting.Brightness;
    
    function functions.fullBright(toggle)
        if(not toggle) then
            maid.fullBright = nil;
            Lighting.Ambient, Lighting.Brightness = oldAmbient, oldBritghtness;
            return
        end;
    
        oldAmbient, oldBritghtness = Lighting.Ambient, Lighting.Brightness;
        maid.fullBright = Lighting:GetPropertyChangedSignal('Ambient'):Connect(function()
            Lighting.Ambient = Color3.fromRGB(255, 255, 255);
            Lighting.Brightness = 1;
        end);
        Lighting.Ambient = Color3.fromRGB(255, 255, 255);
    end;
end

do     
    function functions.simulateTouch(part)
        if part and part:IsA("BasePart") then
            firetouchinterest(root, part, 0)
            firetouchinterest(root, part, 1)
        end
    end
    
    function functions.equipthings(a)
        if not char:FindFirstChild(a) and lp.Backpack:FindFirstChild(a) then
            hum:EquipTool(lp.Backpack:WaitForChild(a))
        end
    end
    
    function functions.unequipthings(a)
        if char:FindFirstChild(a) and not lp.Backpack:FindFirstChild(a) then
            hum:UnequipTools(char:WaitForChild(a))
        end
    end
end

do
    function functions.autofarmbox(toggle)
        if not toggle then
            maid.autofarmbox = nil
            return
        end

        maid.autofarmbox = RunService.Stepped:Connect(function()
            if not char:FindFirstChild('箱子') and not lp.Backpack:FindFirstChild('箱子') then
                root.CFrame = game.Workspace.Deliverys.Get.GLoc.CFrame
                fireproximityprompt(game.Workspace.Deliverys.Get.GLoc.Attachment.ProximityPrompt)
            else
                for i,v in next,game.Workspace.Deliverys.Random:GetChildren() do
                    if v:FindFirstChild(lp.Name) then
                        functions.equipthings('箱子')
                        root.CFrame = v.CFrame
                        fireproximityprompt(v.ProximityPrompt)
                    end
                end
            end
        end)
    end
end

local Window = library:CreateWindow({
    Name = "Mohun-Ware-"..tostring(moversion)..'-'..gamename,
    Icon = 0,
    LoadingTitle = "欢迎使用魔魂脚本",
    LoadingSubtitle = "玩的开心",
    Theme = "Bloom",

    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,

    ConfigurationSaving = {
    Enabled = true,
    FolderName = nil,
    FileName = "Mohun-Ware"
    },

    Discord = {
    Enabled = true,
    Invite = "gCcExNxhjQ",
    RememberJoins = false
    },

    KeySystem = false,
    KeySettings = {
    Title = "Mohun-Ware",
    Subtitle = "密钥系统",
    Note = "加入Discord服务器购买密钥",
    FileName = "Mohun-Ware-KEY",
    SaveKey = true,
    GrabKeyFromSite = false,
    Key = {"Hello"}
    }
}) 
local Tab = Window:CreateTab("杂项", 4483362458)
local Tab2 = Window:CreateTab('玩家类', 4483362458)
local Tab3 = Window:CreateTab('环境类', 4483362458)
local Tab4 = Window:CreateTab('自动刷钱', 4483362458)
local Tab5 = Window:CreateTab('辅助', 4483362458)
Tab:CreateSection("双重防挂机检测已自动开启")
Tab:CreateButton({
    Name = "传送到黑市",
    Callback = function()
        root.CFrame = game.Workspace.WeaponVender.VenderRig.HumanoidRootPart.CFrame
    end,
})
Tab:CreateButton({
    Name = "传送到奇怪集装箱",
    Callback = function()
        root.CFrame = game.Workspace["\229\165\135\230\128\170\233\155\134\232\163\133\231\174\177"].l1.CFrame
    end,
})
Tab2:CreateButton({
    Name = "重生",
    Callback = function()
        Utility:getPlayerData().character:BreakJoints()
        Utility:getPlayerData().humanoid.Health = 0
    end,
})
Tab2:CreateToggle({
    Name = "移速更改",
    CurrentValue = false,
    Flag = "speedHack",
    Callback = function(Value)
        functions.speedHack(Value)
    end,
})
Tab2:CreateSlider({
    Name = "移速",
    Range = {16, 200},
    Increment = 10,
    Suffix = "移速",
    CurrentValue = 16,
    Flag = "speedHackValue",
    Callback = function(Value)
    end,
})
Tab2:CreateToggle({
    Name = "无限跳跃",
    CurrentValue = false,
    Flag = "infiniteJump",
    Callback = function(Value)
        functions.infiniteJump(Value)
    end,
})
Tab2:CreateSlider({
    Name = "跳跃高度",
    Range = {djumpvalue, 200},
    Increment = 10,
    Suffix = "高度",
    CurrentValue = djumpvalue,
    Flag = "infiniteJumpHeight",
    Callback = function(Value)
    end,
})
Tab2:CreateToggle({
    Name = "穿墙",
    CurrentValue = false,
    Flag = "noclip",
    Callback = function(Value)
        functions.noClip(Value)
    end,
})
Tab3:CreateToggle({
    Name = "没有雾霾",
    CurrentValue = false,
    Flag = "noFog",
    Callback = function(Value)
        functions.noFog(Value)
    end,
})
Tab3:CreateToggle({
    Name = "没有模糊",
    CurrentValue = false,
    Flag = "noBlur",
    Callback = function(Value)
        functions.noBlur(Value)
    end,
})
Tab3:CreateToggle({
    Name = "亮度拉高",
    CurrentValue = false,
    Flag = "fullBright",
    Callback = function(Value)
        functions.fullBright(Value)
    end,
})
Tab4:CreateToggle({
    Name = "自动刷钱",
    CurrentValue = false,
    Flag = "autofarmbox",
    Callback = function(Value)
        functions.autofarmbox(Value)
    end,
})
Tab5:CreateToggle({
    Name = "没有跳跃冷却",
    CurrentValue = false,
    Flag = "noJumpCD",
    Callback = function(Value)
        root.CanJump.Disabled = Value
    end,
})
Tab5:CreateToggle({
    Name = "黑市秒交互",
    CurrentValue = false,
    Flag = "noBlackCD",
    Callback = function(Value)
        if Value then
            game.Workspace.Shops["\233\187\145\229\184\130"].Interaction.HoldDuration = 0
        else
            game.Workspace.Shops["\233\187\145\229\184\130"].Interaction.HoldDuration = 0.3
        end
    end,
})

if getgenv().moconfig == true then
    library:LoadConfiguration()
end
