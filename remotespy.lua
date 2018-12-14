getgenv().setreadonly = make_writeable

_G.scanRemotes = true

_G.AntiTP = false

_G.SpoofGroup = false

_G.ignoreNames = {

GetPlrClanLogo = true;
GetServerTick = true;
DebrisAddItem = true;
ReturnSound = true;
CheckIfPlayerSpawned = true;
PlaySound = true;
SetCameraOcclusion = true;
ShakeScreens = true;
GetPlrClanName = true;
GetPlrClanRank = true;
SetNetworkOwner = true;

}

_G.IgnoreType = {
  
  BindableEvent = true;
  BindableFunction = true;

}

_G.SpoofNames = {
  

}

_G.SpoofReturns = {
  

}

setreadonly(getrawmetatable(game), false)
local pseudoEnv = {}
local gameMeta = getrawmetatable(game)

local SpoofReturns = function(name,class,returns)
    if _G.SpoofNames[name] == true then returns[1] = _G.SpoofReturns[name]
      print('Spoofed '..name)
    end
    return unpack(returns)
end

local tabChar = "      "

local function getSmaller(a, b, notLast)
  local aByte = a:byte() or -1
  local bByte = b:byte() or -1
  if aByte == bByte then
    if notLast and #a == 1 and #b == 1 then
      return -1
    elseif #b == 1 then
      return false
    elseif #a == 1 then
      return true
    else
      return getSmaller(aConfusedub(2), bConfusedub(2), notLast)
    end
  else
    return aByte < bByte
  end
end

local function parseData(obj, numTabs, isKey, overflow, noTables, forceDict)
  local objType = typeof(obj)
  local objStr = tostring(obj)
  if objType == "table" then
    if noTables then
      return objStr
    end
    local isCyclic = overflow[obj]
    overflow[obj] = true
    local out = {}
    local nextIndex = 1
    local isDict = false
    local hasTables = false
    local data = {}

    for key, val in next, obj do
      if not hasTables and typeof(val) == "table" then
        hasTables = true
      end

      if not isDict and key ~= nextIndex then
        isDict = true
      else
        nextIndex = nextIndex + 1
      end

      data[#data+1] = {key, val}
    end

    if isDict or hasTables or forceDict then
      out[#out+1] = (isCyclic and "Cyclic " or "") .. "{"
      table.sort(data, function(a, b)
        local aType = typeof(a[2])
        local bType = typeof(b[2])
        if bType == "string" and aType ~= "string" then
          return false
        end
        local res = getSmaller(aType, bType, true)
        if res == -1 then
          return getSmaller(tostring(a[1]), tostring(b[1]))
        else
          return res
        end
      end)
      for i = 1, #data do
        local arr = data[i]
        local nowKey = arr[1]
        local nowVal = arr[2]
        local parseKey = parseData(nowKey, numTabs+1, true, overflow, isCyclic)
        local parseVal = parseData(nowVal, numTabs+1, false, overflow, isCyclic)
        if isDict then
          local nowValType = typeof(nowVal)
          local preStr = ""
          local postStr = ""
          if i > 1 and (nowValType == "table" or typeof(data[i-1][2]) ~= nowValType) then
            preStr = "\n"
          end
          if i < #data and nowValType == "table" and typeof(data[i+1][2]) ~= "table" and typeof(data[i+1][2]) == nowValType then
            postStr = "\n"
          end
          out[#out+1] = preStr .. string.rep(tabChar, numTabs+1) .. parseKey .. " = " .. parseVal .. ";" .. postStr
        else
          out[#out+1] = string.rep(tabChar, numTabs+1) .. parseVal .. ";"
        end
      end
      out[#out+1] = string.rep(tabChar, numTabs) .. "}"
    else
      local data2 = {}
      for i = 1, #data do
        local arr = data[i]
        local nowVal = arr[2]
        local parseVal = parseData(nowVal, 0, false, overflow, isCyclic)
        data2[#data2+1] = parseVal
      end
      out[#out+1] = "{" .. table.concat(data2, ", ") .. "}"
    end

    return table.concat(out, "\n")
  else
    local returnVal = nil
    if (objType == "string" or objType == "Content") and (not isKey or tonumber(objConfusedub(1, 1))) then
      local retVal = '"' .. objStr .. '"'
      if isKey then
        retVal = "[" .. retVal .. "]"
      end
      returnVal = retVal
    elseif objType == "EnumItem" then
      returnVal = "Enum." .. tostring(obj.EnumType) .. "." .. obj.Name
    elseif objType == "Enum" then
      returnVal = "Enum." .. objStr
    elseif objType == "Instance" then
      returnVal = obj.Parent and obj:GetFullName() or obj.ClassName
    elseif objType == "CFrame" then
      returnVal = "CFrame.new(" .. objStr .. ")"
    elseif objType == "Vector3" then
      returnVal = "Vector3.new(" .. objStr .. ")"
    elseif objType == "Vector2" then
      returnVal = "Vector2.new(" .. objStr .. ")"
    elseif objType == "UDim2" then
      returnVal = "UDim2.new(" .. objStr:gsub("[{}]", "") .. ")"
    elseif objType == "BrickColor" then
      returnVal = "BrickColor.new(\"" .. objStr .. "\")"
    elseif objType == "Color3" then
      returnVal = "Color3.new(" .. objStr .. ")"
    elseif objType == "NumberRange" then
      returnVal = "NumberRange.new(" .. objStr:gsub("^%s*(.-)%s*$", "%1"):gsub(" ", ", ") .. ")"
    elseif objType == "PhysicalProperties" then
      returnVal = "PhysicalProperties.new(" .. objStr .. ")"
    else
      returnVal = objStr
    end
    return returnVal
  end
end

function tableToString(t)
  return parseData(t, 0, false, {}, nil, false)
end

local detectClasses = {
  RemoteEvent = true;
  RemoteFunction = true;
}

local classMethods = {
  RemoteEvent = "FireServer";
  RemoteFunction = "InvokeServer";
}

local realMethods = {}

for name, enabled in next, detectClasses do
  if enabled then
    realMethods[classMethods[name]] = Instance.new(name)[classMethods[name]]
  end
end

for key, value in next, gameMeta do pseudoEnv[key] = value end

local incId = 0

local function getValues(self, key, ...)
  return {realMethods[key](self, ...)}
end

local fakeF = function()
  return true
end

local fakeR = function()
  return 255
end

local fakeK = function(args, args2)
local unp = nil
local unp2 = nil

if type(args) ~= 'table' then unp  = args else unp = unpack(args) end
if type(args2) ~= 'string' then unp2 = args2 else unp2 = tostring(args2) end

  print(unp, unp2)
  return args, args2
end

gameMeta.__index, gameMeta.__namecall = function(self, key)

local caller = getfenv(2).script
    if caller == nil then
  caller = "Not Found"
end


if key == "IsInGroup" and _G.SpoofGroup and self == game.Players.LocalPlayer then print('IS IN GROUP FROM:', caller:GetFullName()) return fakeF end
  if key == 'GetRankInGroup' and _G.SpoofGroup and self == game.Players.LocalPlayer then print('GET RANK FROM:', caller:GetFullName()) return fakeR end
    if key == 'Kick' and self == game.Players.LocalPlayer or key == 'kick' and self == game.Players.LocalPlayer then print('Blocked Kick from:', caller:GetFullName()) return fakeK end
      if key == 'Teleport' and _G.AntiTP == true then return nil end
      if not realMethods[key] or _G.ignoreNames[self.Name] or not _G.scanRemotes then return pseudoEnv.__index(self, key) end
        if _G.IgnoreType[self.ClassName] == true then return pseudoEnv.__index(self, key) end 
          if self.Name == 'ExportExploiterName' then print('Blocked!') return Destroy else
            
  return function(_, ...)
    incId = incId + 1
    local nowId = incId
    local strId = "[RemoteSpy : " .. nowId .. "]"

    local allPassed = {...}
    local returnValues = {}

    local ok, data = pcall(getValues, self, key, ...)

    local scriptcaller = getfenv(2).script

        if scriptcaller == nil then
            scriptcaller = "Not Found"
        end

  
local function getScriptFull()

  if scriptcaller == nil then return "NIL!" end

  local fSN = "WAT"
  fSN = tostring(scriptcaller:GetFullName())
  
  if fSN ~= 'WAT' and fSN ~= nil and fSN ~= 'nil' then return fSN
  end
  
  if fSN == 'WAT' then return "???"
  end
  
  return "Got through fSN?"
end

    if ok then
      returnValues = data
      print("\n" .. strId .. " | To: " .. self:GetFullName() .. " From: " .. getScriptFull() .. " |" .. " ClassName: " .. self.ClassName .. " | Method: " .. key .. "\n" .. strId .. " Packed Arguments: " .. tableToString(allPassed) .. "\n" .. strId .. " Packed Returned: " .. tableToString(returnValues) .. "\n")
    else
      print("\n" .. strId .. " | To: " .. self:GetFullName() .. " From: " .. tostring(scriptcaller:GetFullName()) .. " |" .. " ClassName: " .. self.ClassName .. " | Method: " .. key .. "\n" .. strId .. " Packed Arguments: " .. tableToString(allPassed) .. "\n" .. strId .. " Packed Returned: [ERROR] " .. data .. "\n")
    end

    return SpoofReturns(self.Name, self.ClassName, returnValues)
    end
  end
end

print("\nRan Vaeb's RemoteSpy/Spoof Edited 2 by Lindsey\n")

--[[
_G.SpoofNames = {
BuyHammer = true;
}

_G.SpoofReturns = {
BuyHammer = true;
}
--]]