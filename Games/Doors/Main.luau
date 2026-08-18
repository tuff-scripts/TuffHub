local RS = game:GetService("ReplicatedStorage")
local RUNSERV = game:GetService("RunService")
local PLRS = game:GetService("Players")

local plr = PLRS.LocalPlayer
local plrGui = plr.PlayerGui

if not TuffHub then
  getgenv().TuffHub = {
    Ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/tuff-scripts/TuffHub/refs/heads/main/TuffUI.luau"))(),
    Esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/tuff-scripts/TuffHub/refs/heads/main/TuffEsp.luau"))(),
  }
end
local ui = TuffHub.Ui
local esp = TuffHub.Esp

local gameData = RS.GameData
local Floor = gameData.Floor.Value
local CRoom = gameData.LatestRoom

local remotes = false local mods = RS.LiveModifiers or Instance.new("Folder")
if RS:FindFirstChild("RemotesFolder") then remotes = RS.RemotesFolder elseif RS:FindFirstChild("EntityInfo") then remotes = RS.EntityInfo elseif RS:FindFirstChild("Bricks") then remotes = RS.Bricks if Floor == "Hotel" then Floor = "OldHotel" end end

local climbLadder = remotes.ClimbLadder
local crouch = remotes.Crouch
local cutscene = remotes.Cutscene
local useEnemyModule = remotes.UseEnemyModule
local motor = remotes.MotorReplication
local bBoxSolve = remotes.EBF
local padlockCode = remotes.PL

local cRooms = workspace.CurrentRooms

local settings = {
  DoorsEsp = false,
}
local anticheatDisabled = false
local climbingConn = nil
local currentHumanoid = nil
local wspeed = 0
local speedhack = false
local noAcceleration = false
local lookman = true local eyes = true

local hidden = {}
local entityAddConn = workspace.ChildAdded:Connect(function(c)
  if c.Name == "Eyes" and not eyes or c.Name == "BackdoorLookman" and not lookman then
    table.insert(hidden, c) c.Parent = nil end end)
local function copyRemote(r) local c = Instance.new("RemoteEvent") c.Name = r.Name return c end
local function getSpeed(char, hum)
  local cPart = char:FindFirstChild("CollisionPart") or char:FindFirstChild("Collision")
  if not cPart then return 15 end
  local speed = 15
  local sb = char:GetAttribute("SpeedBoost")
  local sbb = char:GetAttribute("SpeedBoostBehind")
  local sbEXTRA = char:GetAttribute("SpeedBoostExtra")
  if sb then speed += sb end if sbb then speed += sbb end if sbEXTRA then speed += sbEXTRA end
  if mods:FindFirstChild("PlayerSlowHealth") then speed -= 0.075 * (hum.MaxHealth - hum.Health) end
  if char:GetAttribute("Crouching") and (Floor == "Fools" or Floor == "OldHotel") or cPart.CollisionGroup == "PlayerCrouching" then
    if mods:FindFirstChild("PlayerCrouchSlow") or mods:FindFirstChild("PlayerSlow") then
      speed -= 8
    else
      speed -= 5
    end
  end
  if Floor == "Party" then speed += 10 end
  if mods:FindFirstChild("PlayerFast") then speed += 3 end
  if mods:FindFirstChild("PlayerFaster") then speed += 6 end
  if mods:FindFirstChild("PlayerFastest") then speed += 20 end
  if mods:FindFirstChild("PlayerSlow") then speed -= 3 end
  return speed
end
local physicProperties = {}
local function applyNoAcceleration(char, toggle)
  if not char then return end
  if not toggle then for part, props in pairs(physicProperties) do part.CustomPhysicalProperties = props end table.clear(physicProperties) return end
  local rootPart = char:FindFirstChild("HumanoidRootPart")
  if not rootPart then return end
  local originalPhysics = rootPart.CustomPhysicalProperties
  if not originalPhysics then return end
  local newPhysics = PhysicalProperties.new(100, originalPhysics.Friction, originalPhysics.Elasticity, originalPhysics.FrictionWeight, originalPhysics.ElasticityWeight)
  for _, part in pairs(char:GetDescendants()) do
    if not part:IsA("BasePart") then continue end
    if not physicProperties[part] then physicProperties[part] = part.CustomPhysicalProperties end
     part.CustomPhysicalProperties = newPhysics
  end
end

local function bypassDisabledNotification()
    print("Anticheat bypass disabled. It will auto re-enable soon")
end

local function bypassEnabledNotification()
    print("Anticheat bypass enabled")
end

local deb = false
local function applyBypass()
  if deb then return end deb = true
  local char = plr.Character 
  if not char then deb = false return end
  climbLadder:FireServer() task.wait(0.25) 
  char:SetAttribute("Climbing", false) crouch:FireServer(true, true)
  anticheatDisabled = true  deb = false
  bypassEnabledNotification()
end
local function forceCrouch() if anticheatDisabled then crouch:FireServer(true, true) end end

local oldCrouchFire
oldCrouchFire = hookfunction(crouch.FireServer, function(self, state, ...) if anticheatDisabled then return oldCrouchFire(self, true, true) end return oldCrouchFire(self, state, ...) end)

local function addLadderConn(char)
  if climbingConn then climbingConn:Disconnect() climbingConn = false end
  if not char then return end
  climbingConn = char:GetAttributeChangedSignal("Climbing"):Connect(function()
    if char:GetAttribute("Climbing") and not anticheatDisabled then
      bypassDisabledNotification() 
      task.wait(0.25) 
      char:SetAttribute("Climbing", false) 
      applyBypass()
    end
  end)
end

local function bypassChar(char)
  if not char then return end table.clear(physicProperties) wait() applyBypass() addLadderConn(char)
  local hum = char:FindFirstChildOfClass("Humanoid")
  currentHumanoid = hum
  if noAcceleration then applyNoAcceleration(char, true) end
end


cutscene.OnClientEvent:Connect(function(name)
    if not anticheatDisabled then return end
    if name:find("SewerSeek") then return end
    anticheatDisabled = false 
    bypassDisabledNotification() 
    applyBypass()
end)

useEnemyModule.OnClientEvent:Connect(function(name)
    if not anticheatDisabled then return end
    if name ~= "Void" and name ~= "Glitch" then return end
    anticheatDisabled = false 
    bypassDisabledNotification() 
    applyBypass()
end)
--👁️🚪🫪RUNSERVICE⚠️⚠️⚠️⚠️⚠️
RUNSERV.RenderStepped:Connect(function()
  local char = plr.Character if char then if anticheatDisabled then crouch:FireServer(true, true) end
  if speedhack and currentHumanoid then currentHumanoid.WalkSpeed = wspeed + getSpeed(char, currentHumanoid) end end
  if not (lookman and eyes) then if Floor == "Fools" or Floor == "OldHotel" then motor:FireServer(0, 65, 0, false) else motor:FireServer(-650) end end
end)

bypassChar(plr.Character or plr.CharacterAdded:Wait()) 
local addConn = plr.CharacterAdded:Connect(bypassChar)

local gif = loadstring(game:HttpGet("https://raw.githubusercontent.com/GIFKITS/gifkits/refs/heads/main/lib/GIFui.luau"))()
local window = gif:CreateWindow("👁️🚪DOORS 🗿TUFF HUB🔥", function()
  addConn:Disconnect() entityAddConn:Disconnect() local char = plr.Character if not char then return end
  applyNoAcceleration(char, false) local hum = char:FindFirstChildOfClass("Humanoid")
  speedhack = false if hum then hum.WalkSpeed = getSpeed(char, hum) end
end)

--Main
local mainTab = window:CreateTab("Main")
mainTab:CreateLabel("This is very tuff doors hub🗿🔥", Color3.fromRGB(230, 130, 0))
--Character
local charTab = window:CreateTab("Character")
charTab:CreateToggle("Speedhack", "Toggle Speedhack", false, function(v)
  local char = plr.Character if not char then return end
  if v then speedhack = true return end
  speedhack = false if currentHumanoid then currentHumanoid.WalkSpeed = getSpeed(char, currentHumanoid) end
end)
charTab:CreateToggle("No Accel", "Disable acceleration", false, function(v) noAcceleration = v local char = plr.Character if not char then return end applyNoAcceleration(char, v) end)
charTab:CreateSlider("Speed Boost", "Adjust speedhack speed boost", 0, 100, 0, function(v) wspeed = v end)
--Entities
local entTab = window:CreateTab("Entities")
local disableable = {{"Screech", "Screech"}, {"A-90", "A90"}, {"Surge", "SurgeRemote"}, {"Halt", "ShadeResult"}}
for _, dRemData in disableable do
  local rOrig = remotes[dRemData[2]] local rFake = copyRemote(rOrig) local eName = dRemData[1]
  entTab:CreateToggle(eName, "Disable "..eName.." damage.", true, function(v) if v then rOrig.Parent = remotes rFake.Parent = nil return end rFake.Parent = remotes rOrig.Parent = nil end)
end
entTab:CreateToggle("Lookman", "Toggle Lookman entity.", true, function(v) lookman = v if v then local n = #hidden if n > 0 then for i = n, 1, -1 do local c = hidden[i] if c.Name == "BackdoorLookman" then c.Parent = workspace hidden[i] = nil end end end return end for _, c in pairs(workspace:GetChildren()) do if c.Name == "BackdoorLookman" then table.insert(hidden, c) c.Parent = nil end end end) entTab:CreateToggle("Eyes", "Toggle Eyes entity.", true, function(v) eyes = v if v then local n = #hidden if n > 0 then for i = n, 1, -1 do local c = hidden[i] if c.Name == "Eyes" then c.Parent = workspace hidden[i] = nil end end end return end for _, c in pairs(workspace:GetChildren()) do if c.Name == "Eyes" then table.insert(hidden, c) c.Parent = nil end end end)
--Visuals👁️
local function doorVisible(n)
  return n ~= 100
end
local vsTab = window:CreateTab("Visuals")
vsTab:CreateLabel("Esp", Color3.new(1, 1, 0))
vsTab:CreateToggle("Rainbow", "Toggle rainbow effect", false, function(v) esp.Rainbow = v end)
vsTab:CreateToggle("Tracer", "Toggle tracing lines", false, function(v) esp.Tracers = v end)
local latest = {}
local function updRoomEsp()
  local rIdx = plr:GetAttribute("CurrentRoom")
  local nidx  = 1+rIdx
  local room = cRooms:FindFirstChild(""..rIdx)
  if settings.DoorsEsp then
  local nextRoom = cRooms:FindFirstChild(""..nidx)
  local cdoor = room:WaitForChild("Door")
  cdoor:WaitForChild("Hidden").Transparency = 1
  if latest[cdoor] then latest[cdoor] = nil esp:UpdateText(cdoor, "Door "..rIdx+1) else esp:AddEsp({Obj = cdoor, Name = "Door "..rIdx+1, Color = Color3.new(1, 1, 0)}) end
  if not (nextRoom and doorVisible(nidx)) then if #latest == 1 then esp:RemoveEsp(latest[1]) end latest = {[cdoor] = true} return end
  local ndoor = nextRoom:WaitForChild("Door")
  ndoor:WaitForChild("Hidden").Transparency = 1
  if latest[ndoor] then latest[ndoor] = nil esp:UpdateText(ndoor, "Door "..nidx+1) else esp:AddEsp({Obj = ndoor, Name = "Door "..nidx+1, Color = Color3.new(1, 1, 0)}) end
  for c, _ in pairs(latest) do esp:RemoveEsp(c) end
  latest = {[cdoor] = true, [ndoor] = true}
  end
end updRoomEsp() plr:GetAttributeChangedSignal("CurrentRoom"):Connect(updRoomEsp)
vsTab:CreateToggle("Doors", "Highlight next door", false, function(v)
  if v then settings.DoorsEsp = true updRoomEsp() return end settings.DoorsEsp = false for c, _ in pairs(latest) do esp:RemoveObjectData(c) end table.clear(latest)
end)
--Puzzles✌️⚠️💥🫪😡🐱🤑🔑🛢️😎💥🔥💀👁️👌
local pzTab = window:CreateTab("Puzzles")
if true then pzTab:CreateLabel("Puzzles options are WIP at this moment") return end
if Floor == "Hotel" then
local autoPadlock = false local padlockPassed = false
local known = {false, false, false, false, false} local noHints = true
local function processPadlock(c)
  local fullyKnown = false
  if Floor == "Fools" then for i = 6, 10 do known[i] = false end end
  local lastPaper = false
  local hintsList = plrGui.PermUI.Hints
  local function updKnown(paper)
    if paper then lastPaper = paper else paper = lastPaper end
    local hints = hintsList:GetChildren() local paperUi = paper.UI:GetChildren()
    local totalHints = 0
    for _, hint in hints do
      for _, ui in paperUi do
        if hint:IsA("ImageLabel") and ui:IsA("ImageLabel") and hint.ImageRectOffset == ui.ImageRectOffset then known[tonumber(ui.Name)] = tonumber(hint.TextLabel.Text) totalHints += 1 noHints = false end
      end
    end
    fullyKnown = totalHints == #known
  end
  hintsList.ChildAdded:Connect(updKnown)
  local function updPaper(char)
    local backpack = plr.Backpack
    local paper = char:FindFirstChild("LibraryHintPaper") or char:FindFirstChild("LibraryHintPaperHard") or backpack:FindFirstChild("LibraryHintPaper") or backpack:FindFirstChild("LibraryHintPaperHard")
    if paper then updKnown(paper) return end
    local pc1 = false local pc2 = false
    pc1 = char.ChildAdded:Connect(function(t) if t.Name == "LibraryHintPaper" or t.Name == "LibraryHintPaperHard" then if pc1 then pc1:Disconnect() pc1 = false end if pc2 then pc2:Disconnect() pc2 = false end updKnown(t) end end)
    pc2 = backpack.ChildAdded:Connect(function(t) if t.Name == "LibraryHintPaper" or t.Name == "LibraryHintPaperHard" then if pc1 then pc1:Disconnect() pc1 = false end if pc2 then pc2:Disconnect() pc2 = false end updKnown(t) end end)
  end updPaper(plr.Character or plr.CharacterAdded:Wait()) local caUpdK = plr.CharacterAdded:Connect(updPaper)
  local plConn = RUNSERV.Heartbeat:Connect(function()
    if not (autoPadlock and fullyKnown) then return end
    if plr:DistanceFromCharacter(c:GetPivot().Position) > 10 then return end
    padlockCode:FireServer(tonumber(table.concat(known))) 
  end)
  c:GetAttributeChangedSignal("Activated"):Once(function() plConn:Disconnect() caUpdK:Disconnect() padlockPassed = true end)
end
if cRooms:FindFirstChild("50") then processPadlock(cRooms["50"].Door.Padlock) else local r50c r50c = cRooms.ChildAdded:Connect(function(c) if c.Name == "50" then r50c:Disconnect() processPadlock(c.Door.Padlock) end end) end
pzTab:CreateToggle("Padlock", "Auto-complete padlock", false, function(v) autoPadlock= v end)
if Floor == "Fools" then pzTab:CreateLabel("Bruteforce padlock code is disabled in SUPER HARD MODE", Color3.new(1, 0, 0)) else pzTab:CreateLabel("[Note] You need at least 1 known code digit to bruteforce.", Color3.fromRGB(230, 130, 0)) pzTab:CreateButton("Bruteforce", "Bruteforce padlock code", function() if padlockPassed or noHints then return end for a = 0, 9 do local ka = known[1] if ka and a ~= ka then continue end for b = 0, 9 do local kb = known[2] if kb and b ~= kb then continue end for c = 0, 9 do local kc = known[3] if kc and c ~= kc then continue end for d = 0, 9 do local kd = known[4] if kd and d ~= kd then continue end for e = 0, 9 do local ke = known[5] if ke and e ~= ke then continue end if padlockPassed then return end padlockCode:FireServer(10000*a+1000*b+100*c+10*d+e) end end end end end end) end

local bBox = false local ibbox = false local autoBBox
pzTab:CreateToggle("Breaker", "Auto-solve breaker box puzzle", false, function(v) autoBBox = v if ibbox then bBoxSolve:FireServer() end end)
pzTab:CreateLabel("Interact with breaker box and script will auto-solve it!")
local room100 = cRooms:FindFirstChild("100")
local function passElectricalRoom(c)
  bBox = c.ElevatorBreaker
  local pcs pcs = bBox.SurfaceGui.Frame.Code:GetPropertyChangedSignal("Text"):Connect(function() ibbox = true if autoBBox then pcs:Disconnect() bBoxSolve:FireServer() end end)
end if room100 then passElectricalRoom(room100) else
  local r100c r100c = cRooms.ChildAdded:Connect(function(c) if "100" ~= c.Name then return end r100c:Disconnect() passElectricalRoom(c) end)
end
end
