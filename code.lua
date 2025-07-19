local question = ""

local k = "AIzaSyAB2mqCTCX_oAlPfPdW1LChUXFkk8YeWG0"
local model = "models/gemini-2.5-flash"
local u = "https://generativelanguage.googleapis.com/v1beta/" .. model .. ":generateContent?key=" .. k
local h = game:GetService("HttpService")

local function ask(q)
    local p = {
        contents = {
            {
                parts = {
                    {
                        text = q
                    }
                }
            }
        }
    }

    local r = {
        Url = u,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = h:JSONEncode(p)
    }

    local d = request(r)
    local j = h:JSONDecode(d.Body)

    if j and j.candidates and j.candidates[1] then
        local parts = j.candidates[1].content.parts
        if parts and parts[1] and parts[1].text then
            print(parts[1].text)
        end
    end
end

if question and #question > 0 then
    ask(question)
else
    warn("No question provided.")
end
