local question = getgenv().question or ""
local k = "AIzaSyAB2mqCTCX_oAlPfPdW1LChUXFkk8YeWG0"
local model = "models/gemini-1.5-flash-latest"
local u = "https://generativelanguage.googleapis.com/v1beta/" .. model .. ":generateContent?key=" .. k
local h = game:GetService("HttpService")

local function ask(q)
    local req = {
        Url = u,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = h:JSONEncode({
            contents = {
                {
                    parts = {
                        {
                            text = q
                        }
                    }
                }
            }
        })
    }
    local res = request(req)
    if not res or not res.Body then
        warn("Invalid response from API")
        return
    end
    local ok, decoded = pcall(h.JSONDecode, h, res.Body)
    if not ok then
        warn("Failed to decode API response.")
        return
    end
    if decoded.error and decoded.error.message then
        warn("API Error: " .. decoded.error.message)
        return
    end
    if decoded.candidates and decoded.candidates[1] and decoded.candidates[1].content and decoded.candidates[1].content.parts and decoded.candidates[1].content.parts[1] and decoded.candidates[1].content.parts[1].text then
        print(decoded.candidates[1].content.parts[1].text)
    else
        warn("No text found in API response.")
    end
end

if question and #question > 0 then
    ask(question)
else
    warn("No question provided.")
end
