
local robootClientPointer : ObjectValue = script.Parent.Pointer.RobootClient
if robootClientPointer.Value == nil then warn("Roboot Error: Client folder was not found in pointer.") return end 
if robootClientPointer.Parent ~= game.ReplicatedStorage then warn("Roboot Error: Client folder needs to be placed in replicated storage!") return end

local public = {}
local private = {}
private.Endpoints = {}
private.Logs = {}


local sockets : Folder = robootClientPointer.Value:FindFirstChild("Sockets")
if sockets == nil then warn("Roboot Error: Sockets were not found inside of client folder!") return end

local STC : RemoteEvent = sockets:FindFirstChild("STC")
local CTSTC : RemoteFunction = sockets:FindFirstChild("CTSTC")

export type ExpectedDataTypes = string
export type Endpoint = {
	Method : "function",
	ExpectedDataTypeList : {string?},
	Player : Player?
	
}

--[[ @ Allows Clients to call an endpoint. Clients cannot send table data, it will be 
	Automatically rejected, server can send anything back to the client 
	This is to protect server from nested annomalies and annoying checks
]]

local function TabEqual(tab : {any}, tab1 : {any})
	if #tab ~= #tab1 then return false end
	for index : number , tabValue : any in tab do 
		if tabValue ~= tab1[index] then 
			return false
		end
		
	end
	
	return true
end

local function isNested(tab : {any})
	for index, value in tab do
		if typeof(value) == "table" then
			return true
		end
	end
	
	return false
end
	



CTSTC.OnServerInvoke = function(player : Player, key : string, ... : any)
	if typeof(key) ~= "string" then warn("Roboot: Caught key from client that is not the correct datatype!") return end
	local endpoint : Endpoint? = private.Endpoints[key]
	if endpoint == nil then warn("Roboot: Client attempted to connect to an endpoint that does not exist!") return end
	if isNested({...}) == true then warn("Roboot: Client attempted to send a table on endpoint."..key.."!") return end
	if endpoint.Player and endpoint.Player ~= player then warn("Roboot: Client attempted to connect to another player's endpoint") return end
	
	local deliveredValues : {string?} = {}
	for index : number , value : any in {...} do 
		table.insert(deliveredValues,typeof(value))
	end
	
	if TabEqual(endpoint.ExpectedDataTypeList,deliveredValues) == false then warn("Roboot: Client attempted to send a incorrect datatypes!")
		return
	end
	
	local result = endpoint.Method(player, ...)
	

	return result
end


function public:InitalizeEndpoint(key : string, player : Player?, method : "function" ,... : ExpectedDataTypes)
	local DoesEndpointExist : boolean = private.Endpoints[key] ~= nil
	if DoesEndpointExist == true then warn("Roboot Error: Endpoint "..key.." already exists!") return end
	if isNested({...}) == true then warn("Roboot Error: Cannot expect table value in endpoint "..key.."!") return end
	
	local endpoint : Endpoint = {
		Player = player,
		Method = method,
		ExpectedDataTypeList = {...}
		
	}
	
	private.Endpoints[key] = endpoint
	
	return {Disconnect = function()
		public:DisconnectEndpoint(key)
	end,}
	
end


function public:DisconnectEndpoint(key : string)
	local endpoint : Endpoint? = private.Endpoints[key]
	if endpoint == nil then warn("Roboot Error: Attempted to disconnect a endpoint that does not exist!") return end
	table.clear(endpoint)
	table.freeze(endpoint)
	private.Endpoints[key] = nil
	
end


function public:callClient(key : string,... : any|Player)
	local players : {Player?} = {}
	local sendTable : {any} = {...}
	
	for index , plr : Player in sendTable do  
		if typeof(plr) == "Instance" and plr:IsA("Player") then
			table.insert(players,plr)
			table.remove(sendTable,index)
		end
	end
	
	if #players == 0 then 
		STC:FireAllClients(key,table.unpack(sendTable))
	else
		for index : number , plr : Player in players do 
			task.spawn(function()
				STC:FireClient(plr,key,table.unpack(sendTable))
			end)
			
		end
	end
	
end
	
	


return public
