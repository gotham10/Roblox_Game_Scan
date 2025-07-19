return function(question)
    local k = "AIzaSyAB2mqCTCX_oAlPfPdW1LChUXFkk8YeWG0"
    local model = "models/gemini-2.5-flash"
    local u = "https://generativelanguage.googleapis.com/v1beta/" .. model .. ":generateContent?key=" .. k
    local h = game:GetService("HttpService")

    local function ask(q)
        local req = {
            Url = u,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = h:JSONEncode({
                contents = {
                    { parts = { { text = q } } }
                }
            })
        }

        local res = request(req)
        if not res or not res.Body then
            warn("Invalid response from API")
            return
        end

        local ok, decoded = pcall(h.JSONDecode, h, res.Body)
        if not ok or not decoded.candidates or not decoded.candidates[1] then
            warn("Failed to decode or no candidates")
            return
        end

        local parts = decoded.candidates[1].content.parts
        if parts and parts[1] and parts[1].text then
            print(parts[1].text)
        else
            warn("No content.parts.text in response")
        end
    end

    if question and #question > 0 then
        ask(question)
    else
        warn("No question provided.")
    end
end
