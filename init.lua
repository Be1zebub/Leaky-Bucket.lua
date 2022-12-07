-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Leaky-Bucket.lua
-- https://en.wikipedia.org/wiki/Leaky_bucket

--[[
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
]]--

local LeakyBucket = {}

function LeakyBucket:GetCapacity()
	return self.capacity
end

function LeakyBucket:GetBandwidth()
	return self.bandwidth
end

function LeakyBucket:GetValue()
	return self.content
end

function LeakyBucket:GetLevel()
	return self.content / self.capacity
end

function LeakyBucket:IsFull()
	return self.content == self.capacity
end

function LeakyBucket:CanFit(size)
	return self.content + size <= self.capacity
end

function LeakyBucket:Add(size, cback)
	if self:CanFit(size) == false then return false end -- overflow leak
	self.content = self.content + size

	self.contents[#self.contents + 1] = {
		size = size,
		cback = cback
	}

	return true
end

function LeakyBucket:__call()
	local incoming = self.contents[1]
	if incoming == nil then return end
	
	local time = os.time()
	if time == self.lastLeak then return end

	local change = (time - self.lastLeak) * self.bandwidth

	self.content = math.max(0, self.content - change)
	incoming.size = incoming.size - change

	if incoming.size <= 0 then
		if incoming.cback then incoming.cback() end
		table.remove(self.contents, 1)
	end

	self.lastLeak = time
end

return setmetatable(LeakyBucket, {
	__call = function(self, capacity, bandwidth)
		return setmetatable({
			capacity 	= capacity,		-- can fit X liters
			bandwidth 	= bandwidth,		-- leak rate per second
			content 	= 0,			-- inner x liters
			contents 	= {},			-- fluids queue
			lastLeak 	= os.time()
		}, self)
	end
})
