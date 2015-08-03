local signature = ngx.req.get_headers()["X-Hub-Signature"]
local key = "yourkey"
if signature == nil then
    return ngx.exit(404)
end
ngx.req.read_body()
local t = {}
for k, v in string.gmatch(signature, "(%w+)=(%w+)") do
    t[k] = v
end
local str = require "resty.string"
local digest = ngx.hmac_sha1(key, ngx.req.get_body_data())
if not str.to_hex(digest) == t["sha1"] then
    return ngx.exit(404)
end
os.execute("bash /usr/servers/conf/build.sh");
ngx.say("OK")
ngx.exit(200)