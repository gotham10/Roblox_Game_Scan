return function(question)
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
			},
            generationConfig = {
                temperature = 0.4,
                topK = 32,
                topP = 1,
                maxOutputTokens = 8192,
            },
            safetySettings = {
                { category = "HARM_CATEGORY_HARASSMENT", threshold = "BLOCK_NONE" },
                { category = "HARM_CATEGORY_HATE_SPEECH", threshold = "BLOCK_NONE" },
                { category = "HARM_CATEGORY_SEXUALLY_EXPLICIT", threshold = "BLOCK_NONE" },
                { category = "HARM_CATEGORY_DANGEROUS_CONTENT", threshold = "BLOCK_NONE" },
            }
		})
	}

	local success, res = pcall(request, req)
	if not success or not res or res.StatusCode ~= 200 or not res.Body then
		return "API request failed: " .. (res and res.StatusMessage or tostring(res))
	end

	local ok, decoded = pcall(h.JSONDecode, h, res.Body)
	if not ok or not decoded then
		return "Failed to decode API response JSON."
	end

	if decoded.error then
		return "API Error: " .. (decoded.error.message or "Unknown error")
	end

	if not decoded.candidates or not decoded.candidates[1] or not decoded.candidates[1].content then
		if decoded.promptFeedback and decoded.promptFeedback.blockReason then
			return "API Error: Prompt was blocked. Reason: " .. decoded.promptFeedback.blockReason
		end
		return "API response is missing expected 'candidates' data."
	end

	local parts = decoded.candidates[1].content.parts
	if parts and parts[1] and parts[1].text then
		return parts[1].text
	else
		return "No 'text' field found in API response content."
	end
end
