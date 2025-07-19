local q=getgenv().question or""
local k="AIzaSyAB2mqCTCX_oAlPfPdW1LChUXFkk8YeWG0"
local m="models/gemini-1.5-flash-latest"
local u="https://generativelanguage.googleapis.com/v1beta/"..m..":generateContent?key="..k
local h=game:GetService("HttpService")
local plrs=game:GetService("Players")
local lp=plrs.LocalPlayer
local inv=""
pcall(function()
if lp and lp.Backpack then
for _,i in ipairs(lp.Backpack:GetChildren()) do
inv=inv..i.Name..", "
end
end
end)
local g="Game Name: "..game.Name.." | PlaceId: "..game.PlaceId.." | CreatorId: "..game.CreatorId.." | PlayerName: "..(lp and lp.Name or"").." | PlayerID: "..(lp and lp.UserId or 0).." | Position: "..(lp and lp.Character and lp.Character:FindFirstChild(\"HumanoidRootPart\") and tostring(lp.Character.HumanoidRootPart.Position) or"unknown").." | Inventory: "..inv.." | PlayersInGame: "..#plrs:GetPlayers()
local function a(t)
local r={Url=u,Method="POST",Headers={["Content-Type"]="application/json"},Body=h:JSONEncode({contents={{parts={{text=t}}}}})}
local s=request(r)
if not s or not s.Body then return end
local ok,d=pcall(h.JSONDecode,h,s.Body)
if not ok then return end
if d.error and d.error.message then return end
if d.candidates and d.candidates[1] and d.candidates[1].content and d.candidates[1].content.parts and d.candidates[1].content.parts[1] and d.candidates[1].content.parts[1].text then
print(d.candidates[1].content.parts[1].text)
end
end
if q and #q>0 then
a("Here is detailed info about the Roblox game I am in: "..g..". Based on this exact live data, answer this player question with specific instructions and methods to achieve it in this game: "..q)
end
