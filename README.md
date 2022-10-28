# Leaky-Bucket.lua
A Lua implementation of Leaky bucket algorithm https://en.wikipedia.org/wiki/Leaky_bucket

## Example

```lua
local LeakyBucket = require("leaky-bucket")(1000, 50) -- 1 liter capacity, 50 milliliters per second bandwidth

function webserver:onRequestReceive(request, response)
	LeakyBucket:Add(request.headers.length, function() -- fluid size = request length
		response.headers.code = 200
		response.body = "pong!"
		response()
	end)
end

while true do
	LeakyBucket()
	webserver.listen()
end
```

## TODO

gmod net.Incoming ratelimiter based on this lib


#### Join to our developers community [incredible-gmod.ru](https://discord.incredible-gmod.ru)
[![thumb](https://i.imgur.com/LYGqTnx.png)](https://discord.incredible-gmod.ru)
