game:GetService("RunService").RenderStepped:connect(function()
for i,v in next, game:GetService'Players':GetPlayers() do
if v.Character and v.Character:FindFirstChild'Humanoid' and workspace:FindFirstChild(game:GetService'Players'.LocalPlayer.Name) and    workspace:FindFirstChild(game:GetService'Players'.LocalPlayer.Name):FindFirstChild'Revolver' then
game:GetService'ReplicatedStorage'.RogueEvent:FireServer("ShootingGun", { ["Normal"]= Vector3.new(-0.819869,0,0.572551), ["GunName"]= "Matrix", ["StartHealth"]= 100, ["BarrelEndPosition"]= Vector3.new(-3.53217,96.9706,59.9691), ["Barrel"]= workspace[game:GetService("Players").LocalPlayer.Name].Revolver.BarrelEnd, ["HitPosition"]= Vector3.new(20.9174,96.1692,42.5727), ["HitPart"]= v.Character.Humanoid, ["Gun"]= workspace[game:GetService("Players").LocalPlayer.Name].Revolver, ["Player"]= game:GetService("Players").LocalPlayer.Name, ["Damage"]= .00001 })
end
end
end)