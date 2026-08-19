local espLib = {
Font = Enum.Font.RobotoCondensed,
Tracers = false,
TracerSize = 0.75,
TracerTransparency = 0,
ShowDistance = true,

FillTransparency = 0.75,
OutlineTransparency = 0,
FadeTime = 0.35,

TextSize = 20,
TextTransparency = 0,
TextStrokeTransparency = 0,

Names = {},

Lines = {},
Highlights = {},
Billboards = {},

Colors = {},
Connections = {},
Enabled = {},
TransparencyEnabled = {},

Rainbow = false, RainbowColor = Color3.new(1, 0, 0)
}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local availableGuiHolder = plr.PlayerGui

local INST = Instance.new local quad = Enum.EasingStyle.Quad
local bottom = UDim2.new(0.5, 0, 1, 0)
local function new(className, parent, properties)
local obj = INST(className) if not properties then obj.Parent = parent return obj end
for p, v in pairs(properties) do obj[p] = v end obj.Parent = parent return obj
end
local function tween(object, properties)
TweenService:Create(object, TweenInfo.new(espLib.FadeTime, quad), properties):Play()
end

function espLib:newHash()
local hash = {} local chars = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789!@#$%^&*()_-=`.,/" local len = #chars
for i = 1, 16 do local idx = math.random(1, len) hash[i] = chars:sub(idx, idx) end return table.concat(hash)
end
function espLib:getGuiFolder() local fold = Instance.new("Folder") fold.Name = espLib:newHash() fold.Parent = availableGuiHolder return fold end

local ui = espLib:getGuiFolder()

local ScreenGui = new("ScreenGui", ui, {ResetOnSpawn = false, IgnoreGuiInset = true})
local HighlightsFolder = INST("Folder") HighlightsFolder.Name = espLib:newHash() HighlightsFolder.Parent = ScreenGui
local BillboardsFolder = INST("Folder") BillboardsFolder.Name = espLib:newHash() BillboardsFolder.Parent = ScreenGui
TracersHolder = new("Frame", ScreenGui, {ZIndex = 0, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Name = espLib:newHash()})

function espLib:RemoveObjectData(object)
local hlTable = espLib.Highlights local lnTable = espLib.Lines local bbTable = espLib.Billboards local connsTable = espLib.Connections
local hl = hlTable[object] if hl then hl:Destroy() hlTable[object] = nil end
local line = lnTable[object] if line then line[1]:Destroy() lnTable[object] = nil end
local bb = bbTable[object] if bb then bb[1]:Destroy() bbTable[object] = nil end
local conn = connsTable[object] if conn then conn:Disconnect() connsTable[object] = nil end
espLib.Colors[object] = nil espLib.Names[object] = nil espLib.Enabled[object] = nil espLib.TransparencyEnabled[object] = nil
end
function espLib:AddEsp(data)
local obj: Model = data.Obj or data.Object if not obj then return end
local enabledTable = espLib.Enabled if enabledTable[obj] then return end
local colorsTable = espLib.Colors local namesTable = espLib.Names
local name = data.Name or "Unknown" namesTable[obj] = name enabledTable[obj] = true
local color = data.Color or Color3.new(1, 1, 1) colorsTable[obj] = color
if data.Transparent then
local hum = obj:FindFirstChild("HighlightHumanoid")
if not hum then
local root = obj.PrimaryPart or obj:FindFirstChildOfClass("Part") if not root then found = false obj.ChildAdded:Connect(function(c) if c:IsA("BasePart") then root = c found = true end end) repeat wait(0) until found end
obj.PrimaryPart = root INST("Humanoid", obj).Name = "HighlightHumanoid"
root.Transparency = 0.9999 root.Material = Enum.Material.Plastic
end
end
local hlTable = espLib.Highlights local lnTable = espLib.Lines local bbTable = espLib.Billboards local connsTable = espLib.Connections
local cConn = connsTable[obj] if cConn then cConn:Disconnect() connsTable[obj] = nil end
local thl = hlTable[obj] if thl then thl:Destroy() hlTable[obj] = nil end
local tln = lnTable[obj] if tln then tln[1]:Destroy() lnTable[obj] = nil end
local tbb = bbTable[obj] if tbb then tbb[1]:Destroy() bbTable[obj] = nil end

local hl = new("Highlight", HighlightsFolder, {FillTransparency = 1, OutlineTransparency = 1, FillColor = color, Adornee = obj, Name = espLib:newHash()})
local bbFrame = new("Frame", BillboardsFolder, {Visible = false, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Name = espLib:newHash()})
local bbText = new("TextLabel", bbFrame, {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), RichText = true, TextSize = espLib.TextSize, TextTransparency = 1, TextColor3 = color, Text = name, TextStrokeTransparency = espLib.TextOutlineTransparency, Font = espLib.Font, Name = espLib:newHash()})

local line = new("Frame", TracersHolder, {Size = UDim2.fromScale(0, 0), BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, Name = espLib:newHash()})
local stroke = new("UIStroke", line, {Transparency = 1, Thickness = espLib.TracerSize, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Name = espLib:newHash()})

hlTable[obj] = hl lnTable[obj] = {line, stroke} bbTable[obj] = {bbFrame, bbText}

local transparencyTable = espLib.TransparencyEnabled transparencyTable[obj] = false
tween(bbText, {TextTransparency = espLib.TextTransparency, TextStrokeTransparency = espLib.TextStrokeTransparency}) tween(line, {BackgroundTransparency = 0}) tween(stroke, {Transparency = 0})
local tw = TweenService:Create(hl, TweenInfo.new(espLib.FadeTime, quad), {FillTransparency = espLib.FillTransparency, OutlineTransparency = espLib.OutlineTransparency}) tw:Play() tw.Completed:Once(function() if transparencyTable[obj] == nil then return end transparencyTable[obj] = true end)
local function render()
if not (obj and obj.Parent) then espLib:removeEsp(obj) return end
local pos = obj:GetPivot().Position
local sPoint, onScreen = Camera:WorldToViewportPoint(pos)
line.Visible = onScreen bbFrame.Visible = onScreen
local cachedHL = hlTable[obj]
if onScreen then
bbFrame.Position = UDim2.fromOffset(sPoint.X, sPoint.Y)
if enabledTable[obj] and not cachedHL then cachedHL = new("Highlight", HighlightsFolder, {FillTransparency = 1, OutlineTransparency = 1, FillColor = color, Adornee = obj, Name = espLib:newHash()}) hlTable[obj] = cachedHL end
elseif cachedHL then cachedHL:Destroy() hlTable[obj] = nil end
local currColor = espLib.Rainbow and espLib.RainbowColor or colorsTable[obj] or Color3.new(1, 1, 1)
if not (cachedHL and onScreen and plr.Character) then return end
local Dist = plr:DistanceFromCharacter(pos)
if espLib.ShowDistance then bbText.Text = namesTable[obj].."\n["..math.round(Dist).."]" else bbText.Text = namesTable[obj] end
bbText.TextColor3 = currColor stroke.Color = currColor
cachedHL.FillColor = currColor cachedHL.OutlineColor = currColor
local tracersEnabled = espLib.Tracers
if tracersEnabled then
  local screenSize = Camera.ViewportSize
  local origin = Vector2.new(screenSize.X/2, screenSize.Y)
  local destination = Vector2.new(sPoint.X, sPoint.Y)
  local mid = 0.5 * (origin+destination) local rotation = math.deg(math.atan2(destination.Y-origin.Y, destination.X-origin.X))
  local length = (origin-destination).Magnitude
  line.Position = UDim2.fromOffset(mid.X, mid.Y)
  line.Size = UDim2.new(0, length, 0, 0) line.Rotation = rotation
  stroke.Color = currColor stroke.Thickness = espLib.TracerSize
  line.Visible = true
else line.Visible = false end
if not (transparencyTable[obj] and enabledTable[obj]) then return end
bbText.TextTransparency = espLib.TextTransparency bbText.TextStrokeTransparency = espLib.TextStrokeTransparency
cachedHL.FillTransparency = espLib.FillTransparency cachedHL.OutlineTransparency = espLib.OutlineTransparency
if tracersEnabled then stroke.Transparency = espLib.TracerTransparency end
end
connsTable[obj] = RunService.RenderStepped:Connect(render)
end
function espLib:RemoveEsp(obj)
local enabledTable = espLib.Enabled if not enabledTable[obj] then return end enabledTable[obj] = false
local hlTable = espLib.Highlights local lnTable = espLib.Lines local bbTable = espLib.Billboards
local fadeTime = espLib.FadeTime
task.delay(0.05+fadeTime, function()
if not obj.Parent then if not enabledTable[obj] then espLib:RemoveObjectData(obj) return end end
if enabledTable[obj] then local reHL = hlTable[obj] if not reHL then return end tween(reHL, {FillTransparency = espLib.FillTransparency, OutlineTransparency = espLib.OutlineTransparency}) return end
espLib:RemoveObjectData(obj)
end)
local bb = bbTable[obj] if bb then tween(bb[2], {TextTransparency = 1}) end
local hl = hlTable[obj] if hl then tween(hl, {FillTransparency = 1, OutlineTransparency = 1}) end
local line = lnTable[obj] if line then tween(line[1], {BackgroundTransparency = 1}) tween(line[2], {Transparency = 1}) end
end
function espLib:UpdateText(obj, text) local texts = espLib.Names if not texts[obj] then return end texts[obj] = text end
function espLib:UpdateColo(obj, color) local colors = espLib.Colors if not colors[obj] then return end colors[obj] = color end
workspace.DescendantRemoving:Connect(function(d) if not espLib.Lines[d] then return end espLib:RemoveObjectData(d) end)

local hue = 0 rStep = 0
RunService.RenderStepped:Connect(function(d)
rStep += d if 0.016666 > rStep then return end
rStep = 0 hue = (hue+0.0025)%1 espLib.RainbowColor = Color3.fromHSV(hue, 0.8, 1)
end)

return espLib
