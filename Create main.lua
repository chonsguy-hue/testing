local function safeCall(func, ...)
    local start = tick()
    local success, result = pcall(func, ...)
    local duration = tick() - start
    
    if duration > 0.08 then -- Faster threshold
        warn("Slow function:", debug.info(func, "n") or "anonymous", "took", duration, "seconds")
    end
    
    return success, result
end

-- Cleanup previous execution
if _G.MySkyCleanup then
    pcall(_G.MySkyCleanup)
end

_G.MySkyCleanup = function()
    if _G.MySkyConnections then
        for _, conn in ipairs(_G.MySkyConnections) do
            pcall(function() conn:Disconnect() end)
        end
        _G.MySkyConnections = {}
    end
    
    -- Clean up parts
    for _, part in ipairs(workspace:GetChildren()) do
        if part.Name:find("myskyp") or part.Name:find("Cosmic") then
            pcall(function() part:Destroy() end)
        end
    end
    
    -- Clean up GUI
    local coreGui = game:GetService("CoreGui")
    local existingGui = coreGui:FindFirstChild("SemiInstaSteal")
    if existingGui then
        pcall(function() existingGui:Destroy() end)
    end
end

-- Execute cleanup on script restart
pcall(_G.MySkyCleanup)

-- // ------------------------------------------------ //
-- //                  MAIN SCRIPT                     //
-- // ------------------------------------------------ //

-- Load services in background to prevent freezing
local Services = {}
local servicePromises = {}

-- Function to get services asynchronously
local function getService(serviceName)
    if Services[serviceName] then
        return Services[serviceName]
    end
    
    -- Load service in background
    if not servicePromises[serviceName] then
        servicePromises[serviceName] = task.spawn(function()
            Services[serviceName] = game:GetService(serviceName)
            servicePromises[serviceName] = nil
        end)
    end
    
    -- Wait for service if needed immediately
    while not Services[serviceName] do
        task.wait()
    end
    
    return Services[serviceName]
end

-- Load critical services first without freezing
local Players = getService("Players")
local LocalPlayer = Players.LocalPlayer

-- Connection storage
local connections = {}
_G.MySkyConnections = connections

print("Script loaded successfully for user:", LocalPlayer.Name)

-- Prevent duplicate execution
if _G.MyskypInstaSteal then 
    pcall(_G.MySkyCleanup)
    task.wait(0.1)
end
_G.MyskypInstaSteal = true

-- Configuration constants - Define positions for BOTH bases
local TP_POSITIONS = {
    BASE1 = {
        INFO_POS = CFrame.new(334.76, 55.334, 99.40),  -- Base 1 standing position
        TELEPORT_POS = CFrame.new(-352.98, -7.30, 74.3),    -- Base 1 teleport position
        STAND_HERE_PART = CFrame.new(-334.76, -5.334, 99.40) * CFrame.new(0, 2.6, 0)
    },
    BASE2 = {
        INFO_POS = CFrame.new(334.76, 55.334, 19.17),    -- Base 2 standing position... (7 KB left)
