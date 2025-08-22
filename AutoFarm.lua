return function(Window)
    local Tab = Window:AddTab({ Title = "Autofarm" })

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
            print("Selected Egg:", val)
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
                print("✅ Auto Hatch ON")
                task.spawn(function()
                    while AutoHatch do
                        -- 🔹 Look for the egg by name across all maps
                        local targetEgg = nil
                        for _, map in pairs(workspace.Game.Maps:GetChildren()) do
                            local eggsFolder = map:FindFirstChild("Eggs")
                            if eggsFolder and eggsFolder:FindFirstChild(SelectedEgg) then
                                targetEgg = eggsFolder[SelectedEgg]
                                break
                            end
                        end

                        if targetEgg then
                            print("Trying to hatch:", SelectedEgg)
                            -- 🟢 Interaction logic here:
                            -- Example: fire a proximity prompt or click detector
                            local prompt = targetEgg:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt then
                                fireproximityprompt(prompt) -- Roblox exploit function
                            end
                        end

                        task.wait(1) -- hatch interval
                    end
                end)
            else
                print("❌ Auto Hatch OFF")
            end
        end
    })
end
