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

    -- Dropdown: select egg
    ControlBox:AddDropdown("Select Egg", EggList, function(val)
        SelectedEgg = val
        print("🎯 Selected Egg:", val)
    end)

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
                        local targetEgg
                        for _, map in ipairs(workspace.Game.Maps:GetChildren()) do
                            local eggsFolder = map:FindFirstChild("Eggs")
                            if eggsFolder and eggsFolder:FindFirstChild(SelectedEgg) then
                                targetEgg = eggsFolder[SelectedEgg]
                                break
                            end
                        end

                        if targetEgg then
                            print("🥚 Hatching:", SelectedEgg)
                            local prompt = targetEgg:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt then
                                fireproximityprompt(prompt)
                            elseif targetEgg:FindFirstChild("ClickDetector") then
                                fireclickdetector(targetEgg.ClickDetector)
                            end
                        else
                            print("⚠ Could not find egg:", SelectedEgg)
                        end

                        task.wait(1)
                    end
                end)
            end
        end
    })
end
