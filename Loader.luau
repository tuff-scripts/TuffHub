local GamesList = {[2440500124] = "Doors"}
local url = "https://raw.githubusercontent.com/tuff-scripts/TuffHub/refs/heads/main/"
if not TuffHub then
  getgenv().TuffHub = {
    Ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/tuff-scripts/TuffHub/refs/heads/main/TuffUI"))()
  }
end
if not TuffEsp then getgenv().TuffEsp = loadstring(game:HttpGet("https://raw.githubusercontent.com/tuff-scripts/TuffHub/refs/heads/main/TuffEsp"))() end
local place = game.GameId local CurrentGame = GamesList[place]
if CurrentGame then loadstring(game:HttpGet(url.."Games/"..CurrentGame.."/Main.luau"))() else loadstring(game:HttpGet("https://raw.githubusercontent.com/tuff-scripts/TuffHub/refs/heads/main/Universal.luau"))() end
