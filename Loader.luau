local GamesList = {[6516141723] = "Doors"}
if not TuffHub then
  getgenv().TuffHub = {
    Ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/tuff-scripts/TuffHub/refs/heads/main/TuffUI"))(),
  }
end
local place = game.PlaceId local CurrentGame = GamesList[place]
if CurrentGame then loadstring(game:HttpGet("https://raw.githubusercontent.com/tuff-scripts/TuffHub/refs/heads/main/Games/"..CurrentGame.."/Main.luau"))() else loadstring(game:HttpGet("https://raw.githubusercontent.com/tuff-scripts/TuffHub/refs/heads/main/Universal.luau"))() end
