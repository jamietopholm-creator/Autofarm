-- AutoFarm.lua
return function(Window)
    local AutoTab = Window:AddTab({
        Name = "Autofarm",
        Icon = "swords",
        Description = "Enemy autofarm features"
    })

    local FarmBox = AutoTab:AddLeftGroupbox("Enemy Autofarm", "farm")

    FarmBox:AddLabel({ Text = "⚡ Autofarm loaded successfully" })
end


    -- ========= Services / Locals =========
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local MONSTER_ROOT = workspace:FindFirstChild("Debris") and workspace.Debris:FindFirstChild("Monsters")

    -- ========= Enemy discovery (Kriluni via Rank=="E") =========
    local function getAllKriluni()
        local out = {}
        if not MONSTER_ROOT then return out end
        for _, mob in ipairs(MONSTER_ROOT:GetChildren()) do
            if mob and mob:GetAttribute and mob:GetAttribute("Rank") == "E" then
                table.insert(out, mob)
            end
        end
        return out
    end

    -- ========= Utility: distances, HRP, nearest =========
    local function getHRP(char)
        if not char then return nil end
        return char:FindFirstChild("HumanoidRootPart")
    end

    local function nearestTarget(targets)
        local char = LocalPlayer.Character
        local hrp = getHRP(char)
        if not hrp then return nil end
        local best, bestDist = nil, math.huge
        for _, m in ipairs(targets) do
            local primary = m.PrimaryPart or m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
            if primary then
                local d = (primary.Position - hrp.Position).Magnitude
                if d < bestDist then best, bestDist = m, d end
            end
        end
        return best
    end

    -- ========= Positioning helper =========
    local SelectedPos = "Above" -- "Above" | "Behind" | "Under"
    local function offsetCFrame(baseCF, mode)
        mode = mode or SelectedPos
        if mode == "Above" then
            return baseCF * CFrame.new(0, 6, 0)
        elseif mode == "Behind" then
            return baseCF * CFrame.new(0, 0,  -6)
        elseif mode == "Under" then
            return baseCF * CFrame.new(0, -6, 0)
        else
            return baseCF
        end
    end

    local function tpToModel(model)
        local char = LocalPlayer.Character
        local hrp  = getHRP(char)
        if not (model and hrp) then return end
        local p = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
        if not p then return end
        -- face the mob
        local look = CFrame.lookAt(p.Position, p.Position + p.CFrame.LookVector)
        local target = offsetCFrame(look, SelectedPos)
        -- safer than setting CFrame on HRP directly:
        hrp:PivotTo(target)
    end

    -- ========= UI State =========
    local EnemyValues = { "Kriluni" }  -- we’ll add more later as you define them
    local SelectedEnemies = {}         -- multiselect result (table of booleans)
    local AttackNearest  = false
    local AttackSelected = false
    local loopThread

    -- ========= UI Controls =========
    FarmBox:AddDropdown("EnemySelector", {
        Text    = "Select Enemies",
        Values  = EnemyValues,
        Multi   = true,
        Default = {},
        Callback = function(selectedTbl)
            SelectedEnemies = selectedTbl or {}
            -- debug print
            for name, on in pairs(SelectedEnemies) do
                if on then print("🎯 Selected:", name) end
            end
        end
    })

    FarmBox:AddDropdown("AttackPosition", {
        Text    = "Teleport Position",
        Values  = { "Above", "Behind", "Under" },
        Multi   = false,
        Default = SelectedPos,
        Callback = function(pos)
            SelectedPos = pos or "Above"
            print("📍 Teleport position:", SelectedPos)
        end
    })

    FarmBox:AddToggle("AutoAttackNearest", {
        Text = "Auto Attack Nearest",
        Default = false,
        Callback = function(state)
            AttackNearest = state
            print("⚔ Auto Attack Nearest:", state)
        end
    })

    FarmBox:AddToggle("AutoAttackSelected", {
        Text = "Auto Attack Selected",
        Default = false,
        Callback = function(state)
            AttackSelected = state
            print("⚔ Auto Attack Selected:", state)
            -- Start/stop the main TP loop
            if state then
                if loopThread then task.cancel(loopThread) end
                loopThread = task.spawn(function()
                    while AttackSelected do
                        -- Only act if "Kriluni" is selected
                        local kriluniSelected = (SelectedEnemies["Kriluni"] == true)
                        if kriluniSelected then
                            local list = getAllKriluni()
                            local target = nil
                            if AttackNearest then
                                target = nearestTarget(list)
                            else
                                -- fallback: just pick first Kriluni if not using nearest
                                target = list[1]
                            end
                            if target then tpToModel(target) end
                        end
                        task.wait(0.25) -- TP cadence; tweak as needed
                    end
                end)
            else
                if loopThread then task.cancel(loopThread) loopThread = nil end
            end
        end
    })

    FarmBox:AddLabel({ Text = "⚡ Kriluni logic: Monsters with Attribute Rank == \"E\"" })

    -- Optional: a quick “Refresh” button if monster list changes a lot
    FarmBox:AddButton("Refresh (Kriluni Scan)", function()
        local count = #getAllKriluni()
        print(("🔄 Kriluni found: %d"):format(count))
    end)
end


