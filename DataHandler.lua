local public = {}
local DataStoreService : DataStoreService = game:GetService("DataStoreService")


function public:GetDataStore(StoreName : string, key : string, attempts : number?, delayTime : number?) : any
	attempts = math.max(attempts, 1) or 5
	delayTime = math.max(delayTime, 0.1) or 1 
	local DataStore : DataStore = DataStoreService:GetDataStore(StoreName)
	local result
	local Valid : boolean = false
	
	for count = 1 , attempts , 1 do 
		
		local success , errorMsg = pcall(function()
			result = DataStore:GetAsync(key)
		end)
		if not success then
			task.wait(delayTime)
			warn("DataStoreError: "..errorMsg)
		elseif success then
			Valid = true
			break
		end
		
	end
	
	
	return result
end


function public:RemoveDataStore(StoreName : string, key : string, attempts : number?, delayTime : number?) : any
	attempts = math.max(attempts, 1) or 5
	delayTime = math.max(delayTime, 0.1) or 1 
	local DataStore : DataStore = DataStoreService:GetDataStore(StoreName)
	local result
	local Valid : boolean = false

	for count = 1 , attempts , 1 do 

		local success , errorMsg = pcall(function()
			result = DataStore:RemoveAsync(key)
		end)
		if not success then
			task.wait(delayTime)
			warn("DataStoreError: "..errorMsg)
		elseif success then
			Valid = true
			break
		end

	end


	return result
end




function public:SetDataStore(StoreName : string, key : string, data : any, attempts : number?, delayTime : number?)
	attempts = math.max(attempts, 1) or 5
	delayTime = math.max(delayTime, 0.1) or 1 
	local DataStore : DataStore = DataStoreService:GetDataStore(StoreName)
	local result = false

	for count = 1 , attempts , 1 do 

		local success , errorMsg = pcall(function()
			DataStore:SetAsync(key,data)
		end)
		if not success then
			task.wait(delayTime)
			warn("DataStoreError: "..errorMsg)
		elseif success then
			result = true
			break
		end

	end


	return result
end





function public:WipeDataStore(StoreName : string)
	local myDataStore = DataStoreService:GetDataStore(StoreName)

	local success, pages = pcall(function()
		return myDataStore:ListKeysAsync()
	end)

	if success then
		while true do
			local keys = pages:GetCurrentPage()
			for _, keyData in ipairs(keys) do
				pcall(function()
					myDataStore:RemoveAsync(keyData.KeyName)
				end)
			end
			if pages.IsLastPage then
				break
			end
			pages:AdvanceAsync()
		end
	end
	
	
end



return public
