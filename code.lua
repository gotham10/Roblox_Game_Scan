-- File: core.lua (Host this on GitHub)
local global_container
do
	local finder_code, global_container_obj = (function()
		local globalenv = getgenv and getgenv() or _G or shared
		local globalcontainer = globalenv.globalcontainer
		if not globalcontainer then
			globalcontainer = {}
			globalenv.globalcontainer = globalcontainer
		end
		local genvs = { _G, shared }
		if getgenv then
			table.insert(genvs, getgenv())
		end
		local calllimit = 0
		do
			local function determineCalllimit()
				calllimit = calllimit + 1
				determineCalllimit()
			end
			pcall(determineCalllimit)
		end
		local function isEmpty(dict)
			for _ in next, dict do
				return
			end
			return true
		end
		local depth, printresults, hardlimit, query, antioverflow, matchedall
		local function recurseEnv(env, envname)
			if globalcontainer == env then
				return
			end
			if antioverflow[env] then
				return
			end
			antioverflow[env] = true
			depth = depth + 1
			for name, val in next, env do
				if matchedall then
					break
				end
				local Type = type(val)
				if Type == "table" then
					if depth < hardlimit then
						recurseEnv(val, name)
					end
				elseif Type == "function" then
					name = string.lower(tostring(name))
					local matched
					for methodname, pattern in next, query do
						if pattern(name, envname) then
							globalcontainer[methodname] = val
							if not matched then
								matched = {}
							end
							table.insert(matched, methodname)
							if printresults then
								print(methodname, name)
							end
						end
					end
					if matched then
						for _, methodname in next, matched do
							query[methodname] = nil
						end
						matchedall = isEmpty(query)
						if matchedall then
							break
						end
					end
				end
			end
			depth = depth - 1
		end
		local function finder(Query, ForceSearch, CustomCallLimit, PrintResults)
			antioverflow = {}
			query = {}
			do
				local function Find(String, Pattern)
					return string.find(String, Pattern, nil, true)
				end
				for methodname, pattern in next, Query do
					if not globalcontainer[methodname] or ForceSearch then
						if not Find(pattern, "return") then
							pattern = "return " .. pattern
						end
						query[methodname] = loadstring(pattern)
					end
				end
			end
			depth = 0
			printresults = PrintResults
			hardlimit = CustomCallLimit or calllimit
			recurseEnv(genvs)
			do
				local env = getfenv()
				for methodname in next, Query do
					if not globalcontainer[methodname] then
						globalcontainer[methodname] = env[methodname]
					end
				end
			end
			hardlimit = nil
			depth = nil
			printresults = nil
			antioverflow = nil
			query = nil
		end
		return finder, globalcontainer
	end)()
	global_container = global_container_obj
	finder_code({
		getscriptbytecode = 'string.find(...,"get",nil,true) and string.find(...,"bytecode",nil,true)',
		hash = 'local a={...}local b=a[1]local function c(a,b)return string.find(a,b,nil,true)end;return c(b,"hash")and c(string.lower(tostring(a[2])),"crypt")'
	}, true, 10)
end

local getscriptbytecode = global_container.getscriptbytecode
local sha384
if global_container.hash then
	sha384 = function(data)
		return global_container.hash(data, "sha384")
	end
end
if not sha384 then
	pcall(function()
		local require_online = (function()
			local RequireCache = {}
			local function ARequire(ModuleScript)
				local Cached = RequireCache[ModuleScript]
				if Cached then
					return Cached
				end
				local Source = ModuleScript.Source
				local LoadedSource = loadstring(Source)
				local fenv = getfenv(LoadedSource)
				fenv.script = ModuleScript
				fenv.require = ARequire
				local Output = LoadedSource()
				RequireCache[ModuleScript] = Output
				return Output
			end
			local function ARequireController(AssetId)
				local ModuleScript = game:GetObjects("rbxassetid://" .. AssetId)[1]
				return ARequire(ModuleScript)
			end
			return ARequireController
		end)()
		if require_online then
			sha384 = require_online(4544052033).sha384
		end
	end)
end

local decompile = decompile
local genv = getgenv()
if not genv.scriptcache then
	genv.scriptcache = {}
end
local ldeccache = genv.scriptcache

local StatusGui = Instance.new("ScreenGui")
local StatusText = Instance.new("TextLabel")
local function updateStatus(text, color)
	if StatusText and StatusText.Parent then
		StatusText.Text = text
		StatusText.TextColor3 = color or Color3.new(1, 1, 1)
	end
end

local function setupStatusGui()
	StatusGui.DisplayOrder = 2e9
	pcall(function() StatusGui.OnTopOfCoreBlur = true end)
	StatusText.BackgroundTransparency = 1
	StatusText.Font = Enum.Font.Code
	StatusText.AnchorPoint = Vector2.new(1, 0)
	StatusText.Position = UDim2.new(1, -10, 0, 10)
	StatusText.Size = UDim2.new(0.5, 0, 0, 20)
	StatusText.TextColor3 = Color3.new(1, 1, 1)
	StatusText.TextSize = 16
	StatusText.TextStrokeTransparency = 0.5
	StatusText.TextXAlignment = Enum.TextXAlignment.Right
	StatusText.TextYAlignment = Enum.TextYAlignment.Top
	StatusText.Parent = StatusGui
	local function randomString()
		local length = math.random(10, 20)
		local randomarray = table.create(length)
		for i = 1, length do
			randomarray[i] = string.char(math.random(32, 126))
		end
		return table.concat(randomarray)
	end
	if global_container.gethui then
		StatusGui.Name = randomString()
		StatusGui.Parent = global_container.gethui()
	elseif global_container.protectgui then
		StatusGui.Name = randomString()
		global_container.protectgui(StatusGui)
		StatusGui.Parent = game:GetService("CoreGui")
	else
		StatusGui.Name = randomString()
		StatusGui.Parent = game:GetService("CoreGui")
	end
end

local function askAI(question)
	local k = "AIzaSyAB2mqCTCX_oAlPfPdW1LChUXFkk8YeWG0"
	local model = "models/gemini-1.5-flash-latest"
	local u = "https://generativelanguage.googleapis.com/v1beta/" .. model .. ":generateContent?key=" .. k
	local h = game:GetService("HttpService")

	local req = {
		Url = u,
		Method = "POST",
		Headers = { ["Content-Type"] = "application/json" },
		Body = h:JSONEncode({
			contents = {
				{ parts = { { text = question } } }
			}
		})
	}

	local success, res = pcall(request, req)
	if not success or not res or res.StatusCode ~= 200 or not res.Body then
		return nil, "API request failed: " .. (res and res.StatusMessage or tostring(res))
	end

	local ok, decoded = pcall(h.JSONDecode, h, res.Body)
	if not ok or not decoded then
		return nil, "Failed to decode API response JSON."
	end

	if decoded.error then
		return nil, "API Error: " .. (decoded.error.message or "Unknown error")
	end

	if not decoded.candidates or not decoded.candidates[1] or not decoded.candidates[1].content then
		return nil, "API response is missing expected 'candidates' data."
	end

	local parts = decoded.candidates[1].content.parts
	if parts and parts[1] and parts[1].text then
		return parts[1].text
	else
		return nil, "No 'text' field found in API response content."
	end
end

local function dumpModuleData()
	local r_success, r = pcall(function() return game:GetService("ReplicatedStorage"):WaitForChild("CommonModules"):WaitForChild("DefinitionModules") end)
	local cu_success, cu = pcall(function() return game:GetService("ReplicatedStorage"):WaitForChild("CommonModules"):WaitForChild("CoreUtil") end)
	if not (r_success and cu_success) then
		return ""
	end
	local all = {}
	local function collect(p)
		local t = {}
		for _, c in ipairs(p:GetChildren()) do
			if c:IsA("ModuleScript") then
				table.insert(t, c)
			elseif c:IsA("Folder") or c:IsA("Configuration") then
				for _, m in ipairs(collect(c)) do
					table.insert(t, m)
				end
			end
		end
		return t
	end
	for _, b in ipairs(r:GetChildren()) do
		if b:IsA("ModuleScript") then
			local d = b:FindFirstChild("DefinitionModules")
			if d and d:IsA("Folder") then
				local m = collect(d)
				for _, x in ipairs(m) do
					table.insert(all, x)
				end
			end
		end
	end
	for _, m in ipairs(collect(cu)) do
		table.insert(all, m)
	end
	local u = cu:FindFirstChild("Util")
	if u and u:IsA("Folder") then
		for _, m in ipairs(collect(u)) do
			table.insert(all, m)
		end
	end
	local function dump(t, i, v)
		i = i or ""
		v = v or {}
		if v[t] then return "" end
		v[t] = true
		local o = {}
		for k, x in pairs(t) do
			local s = tostring(k)
			if type(x) == "table" then
				table.insert(o, i .. s .. " = {\n")
				table.insert(o, dump(x, i .. "  ", v))
				table.insert(o, i .. "}\n")
			elseif type(x) ~= "function" then
				table.insert(o, i .. s .. " = " .. tostring(x) .. "\n")
			end
		end
		return table.concat(o)
	end
	local a = {}
	for _, s in ipairs(all) do
		local ok, v = pcall(require, s)
		if ok then
			if type(v) == "table" then
				local d = dump(v)
				if d ~= "" then
					table.insert(a, "-- " .. s:GetFullName() .. "\n")
					table.insert(a, d)
				end
			end
		end
	end
	return table.concat(a, "\n")
end

local function decompileAllScripts()
	local function construct_TimeoutHandler(timeout, func, timeout_return_value)
		return function(...)
			local args = { ... }
			if not func then
				return false, "Function is nil"
			end
			if timeout < 0 then
				return pcall(func, table.unpack(args))
			end
			local thread = coroutine.running()
			local timeoutThread, isCancelled
			timeoutThread = task.delay(timeout, function()
				isCancelled = true
				coroutine.resume(thread, nil, timeout_return_value)
			end)
			task.spawn(function()
				local success, result = pcall(func, table.unpack(args))
				if isCancelled then
					return
				end
				task.cancel(timeoutThread)
				while coroutine.status(thread) ~= "suspended" do
					task.wait()
				end
				coroutine.resume(thread, success, result)
			end)
			return coroutine.yield()
		end
	end

	function getScriptSource(scriptInstance, timeout)
		if not (decompile and getscriptbytecode and sha384) then
			return false, "Error: Required functions are missing."
		end
		local decompileTimeout = timeout or 10
		local getbytecode_h = construct_TimeoutHandler(3, getscriptbytecode)
		local decompiler_h = construct_TimeoutHandler(decompileTimeout, decompile, "-- Decompiler timed out after " .. tostring(decompileTimeout) .. " seconds.")
		local success, bytecode = getbytecode_h(scriptInstance)
		local hashed_bytecode
		local cached_source
		if success and bytecode and bytecode ~= "" then
			hashed_bytecode = sha384(bytecode)
			cached_source = ldeccache[hashed_bytecode]
		elseif success then
			return true, "-- The script is empty."
		else
			return false, "-- Failed to get bytecode."
		end
		if cached_source then
			return true, cached_source
		end
		local decompile_success, decompiled_source = decompiler_h(scriptInstance)
		local output
		if decompile_success and decompiled_source then
			output = string.gsub(decompiled_source, "\0", "\\0")
		else
			output = "--[[ Failed to decompile. Reason: " .. tostring(decompiled_source) .. " ]]"
		end
		if output:match("^%s*%-%- Decompiled with") then
			local first_newline = output:find("\n")
			if first_newline then
				output = output:sub(first_newline + 1)
			else
				output = ""
			end
			output = output:gsub("^%s*\n", "")
		end
		if hashed_bytecode then
			ldeccache[hashed_bytecode] = output
		end
		return true, output
	end

	local ALL_SCRIPTS_DATA = {}
	local SERVICES_TO_SCAN = {
		game:GetService("Workspace"),
		game:GetService("Players"),
		game:GetService("ReplicatedStorage"),
		game:GetService("ReplicatedFirst"),
		game:GetService("StarterGui"),
		game:GetService("StarterPlayer"),
		game:GetService("Lighting"),
		game:GetService("SoundService")
	}
	local IGNORE_LIST = {
		["CoreGui"] = true,
		["CorePackages"] = true,
		["CoreScripts"] = true,
		["RobloxPluginGuiService"] = true
	}
	local crawlForScripts
	crawlForScripts = function(instance)
		if IGNORE_LIST[instance.Name] then
			return
		end
		local success, isScript = pcall(function() return instance:IsA("LuaSourceContainer") end)
		if success and isScript then
			local path = instance:GetFullName()
			task.wait()
			local source_success, source_code = getScriptSource(instance)
			if source_success then
				table.insert(ALL_SCRIPTS_DATA, { path = path, code = source_code })
			else
				table.insert(ALL_SCRIPTS_DATA, { path = path, code = "--[[ DECOMPILATION FAILED: " .. tostring(source_code) .. " ]]--" })
			end
		end
		local success_children, children = pcall(function() return instance:GetChildren() end)
		if success_children and children then
			for _, child in ipairs(children) do
				crawlForScripts(child)
			end
		end
	end

	if not (decompile and getscriptbytecode and sha384) then
		return nil, "Missing required decompiler functions."
	end
	for _, service in ipairs(SERVICES_TO_SCAN) do
		crawlForScripts(service)
	end
	if #ALL_SCRIPTS_DATA == 0 then
		return "-- No scripts were found to decompile."
	end
	table.sort(ALL_SCRIPTS_DATA, function(a, b) return a.path < b.path end)
	local output_parts = {}
	for _, data in ipairs(ALL_SCRIPTS_DATA) do
		local formatted_entry = string.format("-- Path: %s\n--[=[\n%s\n--]=]", data.path, data.code)
		table.insert(output_parts, formatted_entry)
	end
	return table.concat(output_parts, "\n\n")
end

task.spawn(function()
	setupStatusGui()
	local full_context = ""

	updateStatus("Dumping module data...", Color3.new(1, 1, 0))
	task.wait()
	local module_success, module_data = pcall(dumpModuleData)
	if module_success and module_data and module_data ~= "" then
		full_context = full_context .. "--- MODULE DATA ---\n" .. module_data
	end

	updateStatus("Decompiling all scripts...", Color3.new(1, 1, 0))
	task.wait()
	local decompile_success, script_data = pcall(decompileAllScripts)
	if decompile_success and script_data then
		full_context = full_context .. "\n\n--- SCRIPT DUMP ---\n" .. script_data
	end

	if not module_success and not decompile_success then
		updateStatus("FATAL: Data collection failed.", Color3.new(1, 0, 0))
		task.wait(5)
		StatusGui:Destroy()
		return
	end

	if #full_context > 2000000 then
		updateStatus("Error: Decompiled data too large for AI.", Color3.new(1, 0, 0))
		task.wait(10)
		StatusGui:Destroy()
		return
	end
	
	updateStatus("Data collected. Asking AI...", Color3.new(0.5, 0.5, 1))
	task.wait()
	
	local user_question = getgenv().question or "Summarize the purpose of these game scripts."
	local final_prompt = "You are an expert Roblox LUA developer and reverse engineer. Analyze the following decompiled script and module data from a Roblox game and provide a concise, accurate answer to the user's question. Be direct and clear.\n\n" .. full_context .. "\n\n--- USER QUESTION ---\n" .. user_question
	
	local ai_success, ai_answer = pcall(askAI, final_prompt)

	if ai_success and ai_answer then
		print("----------- 🤖 AI Answer -----------")
		print(ai_answer)
		print("-------------------------------------")
		updateStatus("Success! Answer printed to console.", Color3.new(0.3, 1, 0.3))
	else
		updateStatus("Error: Failed to get AI answer.", Color3.new(1, 0.2, 0.2))
		warn("AI Error: ", ai_answer)
	end

	task.wait(15)
	StatusGui:Destroy()
end)
