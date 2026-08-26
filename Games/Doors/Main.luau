local RS = game:GetService("ReplicatedStorage")
local RUNSERV = game:GetService("RunService")
local PLRS = game:GetService("Players")
local SGUI = game:GetService("StarterGui")
local PRS = game:GetService("ProximityPromptService")

local plr = PLRS.LocalPlayer
local plrGui = plr.PlayerGui

local ui = TuffHub.Ui
local esp = TuffHub.Esp

local gameData = RS.GameData
local fRep = RS.FloorReplicated
local Floor = gameData.Floor.Value
local CRoom = gameData.LatestRoom

local doorOffset = 1
if Floor == "Mines" then doorOffset = 101 elseif Floor == "Backdoor" then doorOffset = -50 elseif fRep:FindFirstChild("KrampusIntro") then doorOffset = 50 end
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

local function notify(title, text)
  SGUI:SetCore("SendNotification", {Title = title, Text = text, Duration = 5})
end
local settings = {
  DoorsEsp = false,
  ObjectivesEsp = false,
  ItemsEsp = false,
  EntitiesEsp = false,
  HideSpotsEsp = false,
  Misc1Esp = false,
  Misc2Esp = false,
  InstantPrompts = false,
  wspeed = 0,
  speedhack = false,
  noAccel = false,
  MoreData = false,
}
local anticheatDisabled = false
local climbingConn = nil

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
  if settings.noAccel then applyNoAcceleration(char, true) end
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
  local char = plr.Character if char then if anticheatDisabled then crouch:FireServer(true, true) local hum = char:FindFirstChildOfClass("Humanoid")
  if settings.speedhack and hum then hum.WalkSpeed = settings.wspeed + getSpeed(char, hum) end end end
  if not (lookman and eyes) then if Floor == "Fools" or Floor == "OldHotel" then motor:FireServer(0, 65, 0, false) else motor:FireServer(-650) end end
end)

bypassChar(plr.Character or plr.CharacterAdded:Wait()) 
local addConn = plr.CharacterAdded:Connect(bypassChar)

local gif = loadstring(game:HttpGet("https://raw.githubusercontent.com/GIFKITS/gifkits/refs/heads/main/lib/GIFui.luau"))()
local window = gif:CreateWindow("👁️🚪DOORS 🗿TUFF HUB🔥", function()
  addConn:Disconnect() entityAddConn:Disconnect() local char = plr.Character if not char then return end
  applyNoAcceleration(char, false) local hum = char:FindFirstChildOfClass("Humanoid")
  settings.speedhack = false if hum then hum.WalkSpeed = getSpeed(char, hum) end
end)

--Main
local mainTab = window:CreateTab("Main")
mainTab:CreateLabel("This is very tuff doors hub🗿🔥", Color3.fromRGB(230, 130, 0))
PRS.PromptButtonHoldBegan:Connect(function(prompt, p) if not (settings.InstantPrompts and p == plr) then return end fireproximityprompt(prompt) end)
mainTab:CreateToggle("Prompts", "Toggle instant proximity prompts", false, function(v) settings.InstantPrompts = v end)
--Character
local charTab = window:CreateTab("Character")
charTab:CreateToggle("Speedhack", "Toggle Speedhack", false, function(v)
  local char = plr.Character if not char then return end
  if v then settings.speedhack = true return end
  local hum = char:FindFirstChildOfClass("Humanoid")
  settings.speedhack = false if hum then hum.WalkSpeed = getSpeed(char, hum) end
end)
charTab:CreateToggle("No Accel", "Disable acceleration", false, function(v) settings.noAccel = v local char = plr.Character if not char then return end applyNoAcceleration(char, v) end)
charTab:CreateSlider("Speed Boost", "Adjust speedhack speed boost", 0, 100, 0, function(v) settings.wspeed = v end)
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
local latest = {} local rSpec = {}
local ins = table.insert
local safe = {["Wardrobe"] = "Wardrobe", ["Toolshed"] = "Toolshed", ["Locker_Large"] = "Locker", ["CircularVent"] = "Vent", ["Dumpster"] = "Dumpster", ["Bed"] = "Bed", ["Double_Bed"] = "Double Bed", ["Wardrobe-FOOLS26"] = "Rush Wardrobe", ["Backdoor_Wardrobe"] = "Wardrobe", ["Rooms_Locker"] = "Locker", ["Rooms_Locker_Fridge"] = "Fridge Locker"}
local misc = {["MouseHole"] = {"Louie"}, ["Toolshed_Small"] = {"Shears Toolshed"}, ["ChestBox"] = {"Chest"}, ["Toolbox"] = {"Toolbox"}, ["TrickOrTreatHouse"] = {"Trick Or Treat", "HouseDoor"}}
local misc2 = {["ChestBoxLocked"] = "Locked Chest", ["Chest_Vine"] = "Vine Chest", ["Toolbox_Locked"] = "Locked Toolbox"}
--SIGMA ONLY 🗿⚠️
local objc = {["KeyObtain"] = {"Key", false, true}, ["ElectricalKeyObtain"] = {"Electrical Key"}, ["LeverForGate"] = {"Gate Lever", "Main"}, ["LiveHintBook"] = {"Hint Book"}, ["LiveBreakerPolePickup"] = {"Breaker Pole"}, ["FuseModel"] = {"Fuse"}, ["MinesGateButton"] = {"Gate Button"}, ["GardenGateButton"] = {"Gate Button"}, ["MinesGenerator"] = {"Generator"}, ["LibraryHintPaper"] = {"Hint Paper"}, ["TimerLever"] = {"Lever", false, true}, ["CringlePresent"] = {"Present Box", "ToolProp"}}
--ITEMS⚠️🫡
local items = {["Lighter"] = "Lighter", ["Flashlight"] = "Flashlight", ["Lockpick"] = "Lockpicks", ["Vitamins"] = "Vitamins", ["Bandage"] = "Bandage", ["Battery"] = "Battery", ["StarVial"] = "Starlight Vial", ["StarBottle"] = "Bottle of Starlight", ["StarJug"] = "Starlight Jug", ["Shakelight"] = "Shake-light", ["Straplight"] = "Strap-light", ["Bulklight"] = "Bulk-light", ["Candle"] = "Candle", ["Crucifix"] = "Crucifix", ["CrucifixWall"] = "Crucifix", ["Glowsticks"] = "Glowstick", ["SkeletonKey"] = "Skeleton Key", ["Candy"] = "Candy", ["ShieldMini"] = "Mini Shield Potion", ["ShieldBig"] = "Big Shield Potion", ["BandagePack"] = "Bandage Pack", ["BatteryPack"] = "Battery Pack", ["Smoothie"] = "Smoothie", ["RiftCandle"] = "Moonlight Candle", ["LaserPointer"] = "Laser Pointer", ["HolyGrenade"] = "Holy Hand Grenade", ["Shears"] = "Shears", ["Cheese"] = "Cheese", ["Bread"] = "Slice of Bread", ["AlarmClock"] = "Alarm Clock", ["RiftSmoothie"] = "Moonlight Float", ["GweenSoda"] = "Gween Soda", ["GlitchCube"] = "Glitch Fragment", ["Scanner"] = "NVCS-3000", ["Bomb"] = "Bomb", ["Knockbomb"] = "Knockbomb", ["Nanner"] = "Banana", ["BigBomb"] = "Big Bomb", ["ShakeBox"] = "Cardboard Box", ["GoldGun"] = "Gold Blaster", ["StopSign"] = "A-90 Sign", ["TipJar"] = "Tip Jar", ["Lantern"] = "Lantern", ["IronKey"] = "Crypt Key", ["KeyIron"] = "Crypt Key", ["IronKeyForCrypt"] = "Crypt Key", ["LotusPetal"] = "Lotus Petal", ["LotusHolder"] = "Lotus Petal", ["Compass"] = "Compass", ["LotusPetalPickup"] = "Lotus Petal", ["LanternLitItem"] = "Lantern", ["Multitool"] = "Multitool", ["RiftJar"] = "Rift Jar", ["AloeVera"] = "Aloe Vera", ["Donut"] = "D'oh nut", ["Lotus"] = "Lotus", ["BoxingGloves"] = "Boxing Gloves", ["StardustPickup"] = "Stardust"}
--Entities😡
local entities = {["Eyes"] = {"Eyes", true, {"👁️Eyes have spawned!", "Don't look at them."}, {"Main"}}, ["BackdoorRush"] = {"Blitz", true, {"Blitz has spawned!", "Hide in locker a little later not to waste time!"}}, ["RushMoving"] = {"Rush", true, {"Rush has spawned!", "Hide in locker quickly!"}}, ["AmbushMoving"] = {"Ambush", true, {"Ambush has spawned!", "Hide in locker quickly!"}}, ["A60"] = {"A-60", true, {"A-60 has spawned!", "Hide in locker and get ready to face A-90!"}}, ["A120"] = {"A-120", true, {"A-120 has spawned!", "Search for nearby locker!"}}, ["BackdoorLookman"] = {"Lookman", true, {"Lookman has spawned.", "Don't look at him."}}, ["FrozenAmbush"] = {"Frozen Ambush", true, {"Frozen Ambush has spawned!", "Hide in nearby locker quickly."}}}
local roomEntities = {["MonumentEntity"] = {"Monument", "Top", {"Monument has spawned🗿", "Keep it in line of sight."}}, ["FigureRig"] = {"Figure", false, false, false, Floor == "Fools26"}, ["LiveEntityBramble"] = {"Bramble"}, ["Grumbo"] = {"Grumble", "GrumbleRig"}}
local function hlRoomSpec(c, r)
  if rSpec[c] or not c then return end
  local n = c.Name local safeName = safe[n]
  if safeName and settings.HideSpotsEsp then
    esp:AddEsp({Obj = c, Name = safeName, Color = Color3.new(0, 1, 0)}) rSpec[c] = {"HideSpotsEsp", r} return
  end
  if settings.EntitiesEsp then
    local eD = roomEntities[n] if eD then local exclude = eD[4] if exclude and table.find(exclude, c.Parent.Name) then return end local h = eD[2] local t = c if h then t = t:FindFirstChild(h) end if t then esp:AddEsp({Obj = t, Name = eD[1], Color = Color3.new(1, 0, 0), Transparent = eD[5]}) rSpec[t] = {"EntitiesEsp", r} end return end
  end
  if settings.ItemsEsp and c:FindFirstChild("PickedUpEvent") then
    local itemName = items[n] if itemName then esp:AddEsp({Obj = c, Name = itemName, Color = "Rainbow"}) rSpec[c] = {"ItemsEsp", r} return end
  end
  if settings.Misc1Esp then
    local miscD = misc[n] if miscD then local h = miscD[2] local t = c if h then t = t:FindFirstChild(h) end if t then esp:AddEsp({Obj = t, Name = miscD[1], Color = Color3.new(1, 0.1, 1)}) rSpec[t] = {"Misc1Esp", r} end return end
  end
  local misc2Name = misc2[n] if misc2Name and settings.Misc2Esp then esp:AddEsp({Obj = c, Name = misc2Name, Color = Color3.fromRGB(130, 0, 130)}) rSpec[c] = {"Misc2Esp", r} return end
  if settings.ObjectivesEsp then
    local obData = objc[n] if obData then local h = obData[2] local t = c if h then t = c:FindFirstChild(h) end if t then esp:AddEsp({Obj = t, Name = obData[1], Color = Color3.fromRGB(0, 200, 255)}) rSpec[t] = {"ObjectivesEsp", r} return end
    end
  end
end
local lastConn = false
local function updRoomEsp()
  if lastConn then lastConn:Disconnect() lastConn = false end
  local rIdx = plr:GetAttribute("CurrentRoom")
  local room = cRooms:FindFirstChild(""..rIdx)
  local cdoor = room:WaitForChild("Door")
  for c, d in pairs(rSpec) do local rR = d[2] if settings[d[1]] and (not rR or rR == room) then continue end esp:RemoveObjectData(c) rSpec[c] = nil end
  for _, c in room:GetDescendants() do hlRoomSpec(c, room) end
  lastConn = room.DescendantAdded:Connect(function(d) if d:FindFirstChild("PickedUpEvent") or entities[d.Name] then hlRoomSpec(d, room) end end)
  local nidx = 1+rIdx
  local nextRoom = cRooms:FindFirstChild(""..nidx)
  local hiding = 0 local tasks = 0
  local obEsp = settings.ObjectivesEsp local moreData = settings.MoreData
  if nextRoom and (obEsp or moreData) then
    for _, c in nextRoom:GetDescendants() do
      if not c then continue end local n = c.Name
      if safe[n] then hiding += 1 elseif objc[n] then tasks += 1 end if not obEsp then continue end local obData = objc[n] if not (obData and obData[3]) then continue end if obData and obData[3] then local h = obData[2] local t = c if h then t = c:FindFirstChild(h) end if not t or rSpec[t] then continue end esp:AddEsp({Obj = t, Name = obData[1], Color = Color3.fromRGB(0, 200, 255)}) rSpec[t] = {"ObjectivesEsp"} end end
  end
  if settings.DoorsEsp then
  cdoor:WaitForChild("Hidden").Transparency = 1
  local sD = {} local sdPadding = ""
  if moreData and nextRoom then
    if hiding > 0 then table.insert(sD, '<font color="#00ff00">'..hiding.."</font>") end
    if tasks > 0 then table.insert(sD, '<font color="#00c8ff">'..tasks.."</font>") end
  end
  if 0 ~= #sD then sdPadding = "\n" end
  if latest[cdoor] then latest[cdoor] = nil esp:UpdateText(cdoor, "Door "..rIdx+doorOffset..sdPadding..table.concat(sD, " ")) esp:UpdateColor(cdoor, Color3.new(1, 1, 0)) else esp:AddEsp({Obj = cdoor, Name = "Door "..rIdx+doorOffset..sdPadding..table.concat(sD, " "), Color = Color3.new(1, 1, 0)}) end
  if not (nextRoom and doorVisible(nidx)) then if #latest == 1 then esp:RemoveEsp(latest[1]) end latest = {[cdoor] = true} return end
  local ndoor = nextRoom:WaitForChild("Door")
  ndoor:WaitForChild("Hidden").Transparency = 1
  if latest[ndoor] then latest[ndoor] = nil esp:UpdateText(ndoor, "Door "..nidx+doorOffset) esp:UpdateColor(ndoor, Color3.fromRGB(175, 175, 0)) else esp:AddEsp({Obj = ndoor, Name = "Door "..nidx+doorOffset, Color = Color3.fromRGB(175, 175, 0)}) end
  for c, _ in pairs(latest) do esp:RemoveEsp(c) end
  latest = {[cdoor] = true, [ndoor] = true}
  end
end updRoomEsp() plr:GetAttributeChangedSignal("CurrentRoom"):Connect(updRoomEsp)
mainTab:CreateToggle("More", "Show more data about next room", false, function(v) settings.MoreData = v updRoomEsp() end)
vsTab:CreateToggle("Doors", "Highlight next door", false, function(v)
  if v then settings.DoorsEsp = true updRoomEsp() return end settings.DoorsEsp = false for c, _ in pairs(latest) do esp:RemoveObjectData(c) end table.clear(latest)
end)
vsTab:CreateToggle("Objectives", "Highlight current objectives", false, function(v) settings.ObjectivesEsp = v updRoomEsp() end)
vsTab:CreateToggle("Items", "Highlight items!", false, function(v) settings.ItemsEsp = v updRoomEsp() end)
local espHostile = {}
local function applyEntityEsp(c)
  if not settings.EntitiesEsp then return end
  local eData = entities[c.Name]
  if not eData then return end
  table.insert(espHostile, c) esp:AddEsp({Obj = c, Name = eData[1], Color = Color3.new(1, 0, 0), Transparent = eData[2]})
end
workspace.ChildAdded:Connect(applyEntityEsp)
vsTab:CreateToggle("Entities", "Highlight hostile entities", false, function(v)
if v then
  settings.EntitiesEsp = true for _, c in pairs(workspace:GetChildren()) do applyEntityEsp(c) end
  return
end
settings.EntitiesEsp = false for _, c in pairs(espHostile) do esp:RemoveObjectData(c) end table.clear(espHostile)
end)
vsTab:CreateToggle("Safe", "Highlight safe (hide) spots", false, function(v) settings.HideSpotsEsp = v updRoomEsp() end)
vsTab:CreateToggle("Misc1", "Highlight main misc objects", false, function(v) settings.Misc1Esp = v updRoomEsp() end)
vsTab:CreateToggle("Misc2", "Highlight secondary misc objects", false, function(v) settings.Misc2Esp = v updRoomEsp() end)
