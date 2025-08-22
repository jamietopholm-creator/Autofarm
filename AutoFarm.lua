-- Autofarm.lua
return function(Window)
    -- Create Autofarm tab
    local AutoTab = Window:AddTab({
        Name = "Autofarm",
        Icon = "swords",
        Description = "Enemy autofarm features"
    })

    -- Main groupbox
    local FarmBox = AutoTab:AddLeftGroupbox("Enemy Autofarm", "farm")

    ----------------------------------------------------------------------
    -- Enemy dropdown (multi-select, empty values for now)
    ----------------------------------------------------------------------
    local EnemyList = {} -- will be filled later

    local SelectedEnemies = {}

    FarmBox:AddDropdown("EnemySelector", {
        Text = "Select Enemies",
        Values = EnemyList,
        Multi = true,
        Default = {},
        Callback = function(selected)
            SelectedEnemies = selected
            print("🎯 Selected enemies:", table.concat(selected, ", "))
        end
    })

    ----------------------------------------------------------------------
    -- Auto attack toggles
    ----------------------------------------------------------------------
    FarmBox:AddToggle("AutoAttackNearest", {
        Text = "Auto Attack Nearest",
        Default = false,
        Callback = function(state)
            print("⚔ Auto Attack Nearest:", state)
            -- placeholder: attack nearest enemy logic here
        end
    })

    FarmBox:AddToggle("AutoAttackSelected", {
        Text = "Auto Attack Selected",
        Default = false,
        Callback = function(state)
            print("⚔ Auto Attack Selected:", state)
            -- placeholder: attack only enemies in SelectedEnemies
        end
    })

    ----------------------------------------------------------------------
    -- Positioning dropdown (above, behind, under)
    ----------------------------------------------------------------------
    local PositionOptions = { "Above", "Behind", "Under" }
    local SelectedPosition = "Above"

    FarmBox:AddDropdown("AttackPosition", {
        Text = "Teleport Position",
        Values = PositionOptions,
        Multi = false,
        Default = "Above",
        Callback = function(pos)
            SelectedPosition = pos
            print("📍 Teleport position set to:", pos)
        end
    })

    ----------------------------------------------------------------------
    -- Info label
    ----------------------------------------------------------------------
    FarmBox:AddLabel({ Text = "⚡ Autofarm tab loaded (logic WIP)" })
end
