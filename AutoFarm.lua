-- AutoFarm.lua
return function(Window)
    local AutoTab = Window:AddTab({ Name = "Autofarm", Icon = "zap", Description = "Egg Auto-Hatch Features" })
    local ControlBox = AutoTab:AddLeftGroupbox("Egg Controls", "egg")

    -- Gather egg names dynamically
    local EggList = {}
    for _, map in ipairs(workspace.Game.Maps:GetChildren()) do
        local eggsFolder = map:FindFirstChild("Eggs")
        if eggsFolder then
            for _, egg in ipairs(eggsFolder:GetChildren()) do
                table.insert(EggList, egg.Name)
            end
        end
    end

    local SelectedEgg = EggList[1] or "None"
    local HatchDelay = 1

    -- Dropdown: select egg
    ControlBox:AddDropdown("Select Egg", EggList, function(val)
        SelectedEgg = val
        print("🎯 Selected Egg:", val)
    end)

    -- Slider: hatch speed
    ControlBox:AddSlider("Hatch Delay", {
        Text = "Hatch Interval (s)",
        Default = 1,
        Min = 0.2,
        Max = 5,
        Rounding = 1,
        Callback = function(val)
            HatchDelay = val
            print("⏱ Hatch interval set to:", HatchDelay)
        end
    })

    -- Toggle: auto hatch
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
                        if SelectedEgg and SelectedEgg ~= "None" then
                            print("🥚 Hatching:", SelectedEgg)

                            -- 🔥 Knit Remote Hatch
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
                        end

                        task.wait(HatchDelay)
                    end
                end)
            end
        end
    })
end
