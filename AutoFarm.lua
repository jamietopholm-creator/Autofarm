-- AutoFarm.lua
print("📥 AutoFarm.lua script loaded!")

return function(Window)
    print("📦 AutoFarm function executed, adding tab...")

    local Tab = Window:AddTab({ Title = "Autofarm" })
    print("✅ Autofarm tab created!")

    -- 🥚 Gather all egg names dynamically
    local EggList = {}
    for _, map in pairs(workspace.Game.Maps:GetChildren()) do
        local eggsFolder = map:FindFirstChild("Eggs")
        if eggsFolder then
            for _, egg in pairs(eggsFolder:GetChildren()) do
                table.insert(EggList, egg.Name)
            end
        end
    end

    print("📋 Eggs found:", #EggList, table.concat(EggList, ", "))

    -- Default selection
    local SelectedEgg = EggList[1] or "None"

    -- Dropdown: Egg selection
    Tab:AddDropdown({
        Title = "Select Egg",
        Values = EggList,
        Multi = false,
        Default = SelectedEgg,
        Callback = function(val)
            SelectedEgg = val
            print("🎯 Selected Egg:", val)
        end
    })

    -- Toggle: Auto Hatch
    local AutoHatch = false
    Tab:AddToggle({
        Title = "Auto Hatch Egg",
        Default = false,
        Callback = function(val)
            AutoHatch = val
            if AutoHatch then
                print("▶️ Auto Hatch ON")
                task.spawn(function()
                    while AutoHatch do
                        local targetEgg = nil
                        for _, map in pairs(workspace.Game.Maps:GetChildren()) do
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
                            end
                        else
                            print("⚠️ Could not find egg:", SelectedEgg)
                        end

                        task.wait(1)
                    end
                end)
            else
                print("⏹ Auto Hatch OFF")
            end
        end
    })
end
