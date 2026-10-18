local public = {}
local private = {}

local sockets = script.Parent.Sockets
local stc = sockets.STC
local ctstc = sockets.CTSTC

function public:CallEndpoint(key : string, ... : any?)
	return ctstc:InvokeServer(key,...)
end

function public:listen(key : string, method : "function")
	local event = stc.OnClientEvent:Connect(function(lkey,...)
		if key == lkey then
			method(...)
		end
	end)
	
	return {Disconnect = function()
		event:Disconnect()
	end,}
	
end



return public
