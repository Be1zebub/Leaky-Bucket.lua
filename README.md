# Leaky-Bucket.lua
A Lua implementation of Leaky bucket algorithm https://en.wikipedia.org/wiki/Leaky_bucket

## Example

```lua
local LeakyBucket = require("leaky-bucket")(1000, 50) -- 1 liter capacity, 50 milliliters per second bandwidth

function webserver:onRequestReceive(request, response)
  LeakyBucket:Add(request.headers.length, function()
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
