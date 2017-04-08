local cmd = tostring(ngx.var.arg_cmd)
local key = tostring(ngx.var.arg_key)
local val = tostring(ngx.var.arg_val)
local commands = {
    get="get",
    set="set"
}

cmd = commands[cmd]
if not cmd then
	ngx.say("command not found!")
	ngx.exit(400)
end

local redis = require("resty.redis")
local red = redis:new()
red:set_timeout(1000) -- 1 second

local ok,err = red:connect("127.0.0.1",6379)
if not ok then
	ngx.say("failed to connect: ",err)
	return
end
 
if cmd == "get" then
	if not key then 
		ngx.say("plz input key in the url params");
        ngx.exit(400) 
	end
	local res,err = red:get(key)
	if not res then
		ngx.say("failed to get ",key,": ",err)
		return
	end

	ngx.say("get value from redis Suc. key:", key, " vluae:", res)
end

 
if cmd == "set" then
	if not (key and val) then 
        ngx.say("invalid key and value in url params");
		ngx.exit(400) 
	end
	local ok,err = red:set(key,val)

	if not ok then
		ngx.say("failed to set ",key,": ",err)
		return
	end
    ngx.say("Good,set value into redis Suc");

	ngx.say(ok)
end
