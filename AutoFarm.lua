-- AutoFarm.lua
return function(Window)
    local AutoTab = Window:AddTab({ Name = "Autofamrm", Icon = "zap", Description = "Egg Auto-Hatch Features" })
    local ControlBox = AutoTab:AddLeftGroupbox("Egg Controls", "egg")

    -- 🥚 Function to find all eggs anywhere in Workspace
    local function GetEggs()
        local EggList = {}

        local function Scan(parent)
            for _, child in ipairs(parent:GetChildren()) do
                if child.Name == "Eggs" and child:IsA("Folder") then
                    for _, egg in ipairs(child:GetChildren()) do
                        table.insert(EggList, egg.Name)
                    end
                end
                -- keep scanning deeper
                Scan(child)
            end
        end

        Scan(workspace.Game.Maps) -- start under Maps
        return EggList
    end

    -- Wait until at least one egg is found
    local EggList = GetEggs()
    while #EggList == 0 do
        task.wait(1)
        print("⏳ Waiting for eggs to load...")
        EggList = GetEggs()
    end
    print("✅ Eggs found:", table.concat(EggList, ", "))

    local SelectedEgg = EggList[1] or "None"

    -- Dropdown to pick egg
    ControlBox:AddDropdown("Select Egg", EggList, function(val)
        SelectedEgg = val
        print("🎯 Selected Egg:", val)
    end)

    -- Toggle to auto hatch
    local AutoHatch = false
    ControlBox:AddToggle("Auto Hatch Egg", {
        Text = "Enable Auto Hatch",
        Default = false,
        Callback = function(val)
            AutoHatch = val
            print(AutoHatch and "▶ Auto Hatch ON" or "⏹ Auto Hatch OFF")

            if AutoHatch then
                task.spawn(function()
                    while AutoHatch do
                        print("🥚 Trying to hatch:", SelectedEgg)

                        -- Knit Remote Hatch
                        local args = { SelectedEgg, 1 }
                        local KnitService = game:GetService("ReplicatedStorage")
                            :WaitForChild("Packages")
                            :WaitForChild("Knit")
                            :WaitForChild("Services")
                            :WaitForChild("jag känner en bot, hon heter anna, anna heter hon")

                        local Remote = KnitService.RE["jag känner en bot, hon heter anna, anna heter hon"]
                        if Remote then
                            Remote:FireServer(unpack(args))
                        else
                            warn("⚠ Knit Remote not found")
                        end

                        task.wait(1)
                    end
                end)
            end
        end
    })
end

