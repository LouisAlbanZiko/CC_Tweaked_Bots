-- settings
local MIN_FUEL = 8
local MIN_FUEL_LEVEL = 256
local MIN_CROPS = 64
local SLEEP_TIME_SEC = 60 * 52

-- inventory slots
local FUEL = 1
local CROPS = 2
local FREE = 3

function isFuel(slot)
	local currentSlot = turtle.getSelectedSlot()
	turtle.select(slot)
	local is_fuel = turtle.refuel(0)
	turtle.select(currentSlot)
	return is_fuel
end

function sort_inventory(crop_name)
	-- empty inventory
	print("Emptying inventory...")
	for i = 1, 16, 1 do
		turtle.select(i)
		turtle.dropDown()
	end

	-- get crops and fuel
	print(string.format("Looking for %s and fuel in the chest...", crop_name))
	local fuel_count = 0
	local fuel_name = ""
	local crop_count = 0

	turtle.select(FREE)
	local fuel_detail = turtle.getItemDetail(FUEL, true)
	local crop_detail = turtle.getItemDetail(CROPS, true)

	while turtle.suckDown() and (((fuel_detail == nil) or (fuel_detail ~= nil and fuel_detail["count"] < MIN_FUEL)) or ((crop_detail == nil) or (crop_detail ~= nil and crop_detail["name"] ~= crop_name and crop_detail["count"] ~= crop_detail["maxCount"]))) do
		local item_detail = turtle.getItemDetail(FREE, true)
		if item_detail["name"] == crop_name and crop_count ~= MIN_CROPS then
			print(string.format("Found %d %s as crops.", item_detail["count"], item_detail["name"]))
			turtle.transferTo(CROPS)
			crop_detail = turtle.getItemDetail(CROPS, true)
			crop_count = crop_detail["count"]
		elseif turtle.refuel(0) and fuel_count < MIN_FUEL and (fuel_name == item_detail["name"] or fuel_name == "") then
			print(string.format("Found %d %s as fuel.", item_detail["count"], item_detail["name"]))
			turtle.transferTo(FUEL)
			fuel_detail = turtle.getItemDetail(FUEL, true)
			fuel_count = fuel_detail["count"]
			fuel_name = fuel_detail["name"]
		end
		turtle.dropUp()
	end

	-- move from top chest to bottom
	while turtle.suckUp() do
		turtle.dropDown()
	end

	-- empty unused slots
	for i = FREE, 16, 1 do
		turtle.select(i)
		turtle.dropDown()
	end
end

function refuel()
	print("Checking fuel...")
	local fuel_level = turtle.getFuelLevel()
	if fuel_level < 256 then
		print(string.format("Not enough fuel. %d; Refueling...", fuel_level))
		turtle.select(FUEL)
		turtle.refuel(8)
		fuel_level = turtle.getFuelLevel()
		if fuel_level < 256 then
			print(string.format("Refueling failed, not enough fuel. %d", fuel_level))
			return false
		else
			print(string.format("Refuel successfull. %d", fuel_level))
			return true
		end
	else
		print(string.format("Fuel level is ok. %d >= %d", fuel_level, MIN_FUEL_LEVEL))
		return true
	end
end

function plant()
	turtle.select(CROPS)
	turtle.placeDown()
	turtle.select(FUEL)
end

function check_crops()
	has_block, crop_data = turtle.inspectDown()
	if has_block then
		age = crop_data["state"]["age"]
		if age == 7 then
			turtle.digDown()
			plant()
		end
	else
		turtle.digDown()
		plant()
	end
end

function farm_round()
	-- go through farm
	print("Farming...")
	turtle.select(CROPS)
	turtle.forward()
	check_crops()
	for i = 1, 9, 1 do
		for i = 1, 8, 1 do
			turtle.forward()
			check_crops()
		end
		if i % 2 == 1 then
			turtle.turnRight()
			turtle.forward()
			turtle.turnRight()
			if i ~= 9 then
				check_crops()
			end
		else
			turtle.turnLeft()
			turtle.forward()
			turtle.turnLeft()
			if i ~= 9 then
				check_crops()
			end
		end
	end
	print("Going back to chest...")
	-- go back to start
	for i = 1, 9, 1 do
		turtle.forward()
	end
	turtle.turnRight()
	for i = 1, 9, 1 do
		turtle.forward()
	end
	turtle.turnRight()
	print("Done")
end

function farm(crop_name, nr_of_rounds)
	if nr_of_rounds == 0 then
		print("Starting farming for infinite rounds.")
		while true do
			sort_inventory(crop_name)
			if not refuel() then
				print("Stopping execution!")
				return
			end
			farm_round()
			print(string.format("Waiting for %d seconds...", SLEEP_TIME_SEC))
			os.sleep(SLEEP_TIME_SEC)
			print("Done.")
		end
		print("Exiting.")
	else
		print(string.format("Starting farming for %d rounds.", nr_of_rounds))
		for i = 1, nr_of_rounds, 1 do
			sort_inventory(crop_name)
			if not refuel() then
				print("Stopping execution!")
				return
			end
			farm_round()
			if i ~= nr_of_rounds then
				print(string.format("Waiting for %d seconds...", SLEEP_TIME_SEC))
				os.sleep(SLEEP_TIME_SEC)
				print("Done.")
			end
		end
		print("Exiting.")
	end
end

local item_data_tags = {}
item_data_tags["potatoes"] = "minecraft:potato"
item_data_tags["carrots"] = "minecraft:carrot"
item_data_tags["wheat"] = "minecraft:wheat_seeds"

local crop_name = item_data_tags[arg[1]]

local nr_of_rounds = tonumber(arg[2])

if crop_name == nil then
	print("Unrecognized crop name.")
	print("Crops are: potatoes, carrots or wheat.")
	print("Usage: farm <crop_name> <nr_of_rounds>(0 for infinite)")
elseif nr_of_rounds == nil then
	print("Nr of rounds not a number.")
	print("Usage: farm <crop_name> <nr_of_rounds>(0 for infinite)")
else
	farm(crop_name, nr_of_rounds)
end