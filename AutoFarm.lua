-- AutoFarm.lua (external tab)
return function(Window)
    local AutoTab = Window:AddTab({ Name = "Autofarm", Icon = "zap", Description = "Egg Auto-Hatch" })
    local Box = AutoTab:AddLeftGroupbox("Egg Controls", "egg")

    -- Knit + Remote
    local Rep = game:GetService("ReplicatedStorage")
    local Knit = require(Rep.Packages.Knit)
    Knit.OnStart():await() -- ✅ ensure services are ready

    local EggService = Knit.GetService("EggService")
    -- openEgg is a Knit method; _re is the underlying RemoteEvent bound by Knit
    local OpenEggRemote = EggService and EggService.openEgg and EggService.openEgg._re

    -- Defensive check
    if not OpenEggRemote then
        warn("AutoFarm: openEgg remote not found (EggService.openEgg._re)")
        Box:AddLabel({ Text = "openEgg remote not found. Join a server/world first." })
        return
    end

    -- Find eggs anywhere: every folder named "Eggs" → direct children are egg models (display names)
    local function collectEggs()
        local names, seen = {}, {}
        local function scan(node)
            for _, ch in ipairs(node:GetChildren()) do
                if ch:IsA("Folder") and ch.Name == "Eggs" then
                    for _, egg in ipairs(ch:GetChildren()) do
                        if not seen[egg.Name] then
                            seen[egg.Name] = true
                            table.insert(names, egg.Name)
                        end
                    end
                end
                scan(ch)
            end
        end
        -- Prefer Maps if present; otherwise whole workspace
        local ok, maps = pcall(function() return workspace.Game.Maps end)
        if ok and maps then scan(maps) else scan(workspace) end
        return names
    end

    -- Map display -> server arg (strip trailing " Egg")
    local function toServerName(display)
        return display:gsub("%s+[Ee][Gg][Gg]$", "")
    end

    local eggs = collectEggs()
    if #eggs == 0 then
        -- fallback options if map didn’t load yet
        eggs = { "Basic Egg", "Golden Egg", "Mythic Egg" }
    end

    local selectedDisplay = eggs[1]
    local hatchDelay = 0.30
    local amount = 1
    local running = false
    local loopThread

    -- UI
    Box:AddDropdown("Select Egg", eggs, function(v)
        selectedDisplay = v
        print("🎯 Selected:", v, "→ server:", toServerName(v))
    end)

    Box:AddSlider("Hatch Interval (s)", {
        Text = "Hatch Interval (s)",
        Default = hatchDelay,
        Min = 0.1, Max = 3, Rounding = 2,
        Callback = function(v) hatchDelay = v end
    })

    Box:AddDropdown("Amount", { "1", "2", "3" }, function(v)
        amount = tonumber(v) or 1
    end)

    Box:AddToggle("Auto Hatch", {
        Text = "Enable Auto Hatch",
        Default = false,
        Callback = function(on)
            running = on
            if on then
                -- start loop
                loopThread = task.spawn(function()
                    -- tiny warm-up so first call isn’t racing asset loads
                    task.wait(0.05)
                    while running do
                        local eggArg = toServerName(selectedDisplay)
                        local ok, err = pcall(function()
                            OpenEggRemote:FireServer(eggArg, amount)
                        end)
                        if not ok then
                            warn("AutoFarm hatch error:", err)
                        end
                        task.wait(hatchDelay)
                    end
                end)
            else
                -- stop loop
                if loopThread then
                    task.cancel(loopThread)
                    loopThread = nil
                end
            end
        end
    })
end
