-- Auto-accept first quest where Right.Completed.Visible == false

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local ToServer = RS:WaitForChild("Events"):WaitForChild("To_Server")

-- Path
local pg = LocalPlayer:WaitForChild("PlayerGui")
local Quests = pg:WaitForChild("Quests")
local Def = Quests:WaitForChild("Quests_Default")
local SF = Def:WaitForChild("ScrollingFrame")

-- Check completion state
local function isQuestCompleted(id)
    local q = SF:FindFirstChild(tostring(id))
    if not q then return false end
    local main = q:FindFirstChild("Main"); if not main then return false end
    local right = main:FindFirstChild("Right"); if not right then return false end
    local completed = right:FindFirstChild("Completed")
    return (completed and completed.Visible) or false
end

-- Scan 1..6 and accept first not completed
local accepted = false
for id = 1, 6 do
    local done = isQuestCompleted(id)
    print(("Quest %d -> %s"):format(id, done and "Completed" or "Not Completed"))
    if not done and not accepted then
        local args = {
            {
                Id = tostring(id),
                Type = "Accept",
                Action = "_Quest"
            }
        }
        ToServer:FireServer(unpack(args))
        print("[Inject] Accepted Quest " .. id)
        accepted = true
    end
end

if not accepted then
    print("[Inject] All quests 1..6 are completed.")
end
