local public = {}
local dataStoreHandler = require(script.Parent.DataStoreHandler)



local function tableCheck(tab : {},value : string)
	for i , v in tab do 
		if v == "table" then 
			return true
		end
	end
	return false
end

function public:Create(EntityName : string, ExpectedValues : {[string] : string})
	local data : any , valid : boolean = dataStoreHandler:GetDataStore("Entity",EntityName,5,1)
	
	if tableCheck(ExpectedValues,"table") == true then warn("Roboot Error: Attempted to expect a table to an entity") return end
	if data ~= nil and valid == true then
		local result = dataStoreHandler:SetDataStore("Entity",EntityName,ExpectedValues,5,1)
		if result == true then
			warn("Roboot: Entity, "..EntityName..   ", set successfully!")
		elseif result == false then
			warn("Roboot Error: Failed to set "..EntityName.."!")
			
		end
		
	end
end


function public:Delete(EntityName : string)
	local data : any , valid : boolean = dataStoreHandler:GetDataStore("Entity",EntityName,5,1)

	if data ~= nil and valid == true then
		local result = dataStoreHandler:RemoveDataStore("Entity",EntityName,5,1)
		if result == true then
			dataStoreHandler:WipeDataStore(EntityName)
			warn("Roboot: Entity Deletion successful")
		else
			warn("Roboot Error: Something unexpected happend during entity deletion")
		end
		
	end
	
end

function public:Remove(EntityName : string, EntryId : string)
	local result : boolean = dataStoreHandler:RemoveDataStore(EntityName,EntryId,5,1)
	if result == true then
		warn("Roboot: Entry was successfully removed")
	elseif result == false then
		warn("Roboot Error: Entry removal was unsuccessful")
	end
end

local function ExpectationCheck(value : any, dataType : string)
	local result : boolean = typeof(value) == dataType and typeof(value) ~= "table"
	return result
end

local function tabmx(tab)
	local c = 0
	for i , v in tab do 
		c += 1
	end
	return c
end

local function ExpectationEntryCheck(dataSet : {[string] : any},validationSet : {[string] : string})
	local result : boolean = true
	if tabmx(dataSet) ~= tabmx(validationSet) then return false end
	
	for index : string , validation : string in validationSet do 
		local data = dataSet[index]
		if data == nil then 
			result = false 
			break
		elseif ExpectationCheck(data,validation) == false then 
			result = false
			break
		end
		
	end
	
	return result
end


function public:Post(EntityName : string, EntryId : string, data : {[string] : any})
	local entry, valid = dataStoreHandler:GetDataStore(EntityName,EntryId,5,1)
	local entity, valid2 = dataStoreHandler:GetDataStore("Entity",EntityName,5,1)
	
	if entity == nil then warn("Roboot Error: Entity requested could not be found!") return end
	if entry ~= nil then warn("Roboot Error: An entry with the id ".. EntryId.." already exists!") return end
	if valid == false then warn("Roboot Error: Failed to check entry!") return end
	if ExpectationEntryCheck(data,entity) == false then warn("Roboot Error: Entry does not match expected datatypes!") return end
	
	dataStoreHandler:SetDataStore(EntityName,EntryId,data,5,1)

end

function public:Put(EntityName : string, EntryId : string, colunmId : string, data : any)
	local entry, valid = dataStoreHandler:GetDataStore(EntityName,EntryId,5,1)
	local entity, valid2 = dataStoreHandler:GetDataStore("Entity",EntityName,5,1)

	if entity == nil then warn("Roboot Error: Entity requested could not be found!") return end
	if entry == nil then warn("Roboot Error: An entry with the id ".. EntryId.." does not exist!") return end
	if valid == false then warn("Roboot Error: Failed to check entry!") return end
	
	local dataType = entity[colunmId]
	if dataType == nil then warn("Roboot Error: Colunm does not exist in this entity!") return end
	if ExpectationCheck(data,dataType) == false then warn("Roboot Error: Failed to put, data given does not match the correct datatype!")
	
	entry[colunmId] = data 
	
	local result = dataStoreHandler:SetDataStore(EntityName,EntryId,entry,5,1)
	if result == false then
		warn("Roboot Error: failed to change data in entry")
	elseif result == true then
		warn("Roboot: Successfully updated entry")
	end
	end
	
end


function public:Update(EntityName : string, colunmId : string,dataType : string)
	local entity , valid = dataStoreHandler:GetDataStore("Entity",EntityName,5,1)
	
	if entity == nil then warn("Roboot Error: Entity could not be found!") return end
	if entity[colunmId] ~= nil then warn("Roboot Error: Colunm already exists!") return end
	
	entity[colunmId] = dataType
	
	local result : boolean = dataStoreHandler:SetDataStore("Entity",EntityName,entity,5,1)
	if result == false then 
		warn("Roboot Error: Unable to update entity at this time.")
	elseif result == true then
		warn("Roboot Error: Entity updated colunm successfully!")
	end
end

function public:Retire(EntityName : string, colunmId : string)
	-- DATA IS NOT LOST FROM RETIRING, IT JUST PREVENTS POSTING UNTIL YOU UPDATE AGAIN
		local entity , valid = dataStoreHandler:GetDataStore("Entity",EntityName,5,1)

		if entity == nil then warn("Roboot Error: Entity could not be found!") return end
			if entity[colunmId] == nil then warn("Roboot Error: Colunm does not exist!") return end

			entity[colunmId] = nil

		local result : boolean = dataStoreHandler:SetDataStore("Entity",EntityName,entity,5,1)
		if result == false then 
			warn("Roboot Error: Unable to retire entity at this time.")
		elseif result == true then
			warn("Roboot Error: Entity retired colunm successfully!")
		end
	
	
end






return public