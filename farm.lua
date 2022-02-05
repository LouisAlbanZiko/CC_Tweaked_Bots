local FUEL = 1
local CROPS = 2
local FREE = 3

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

function farm_round(name_of_crops)
	-- refuel
	turtle.select(FUEL)
	local fuel_detail = turtle.getItemDetail(FUEL, true)
	if turtle.refuel(0) and fuel_detail["count"] < 16 then
		turtle.dropUp()
		turtle.suckUp(32)
	end

	if turtle.getFuelLevel() < 256 then
		turtle.select(FUEL)
		turtle.refuel(8)
	end

	-- get crops
	turtle.select(CROPS)
	local crop_detail = turtle.getItemDetail(CROPS, true)
	if crop_detail == nil then
		for i = FREE, 16, 1 do
			local item_detail = turtle.getItemDetail(i, true)
			if item_detail ~= nil and item_detail["name"] == name_of_crops then
				turtle.select(i)
				turtle.transferTo(CROPS)
			end
		end
	elseif crop_detail["name"] ~= name_of_crops then
		turtle.dropDown()
		for i = FREE, 16, 1 do
			local item_detail = turtle.getItemDetail(i, true)
			if item_detail ~= nil and item_detail["name"] == name_of_crops then
				turtle.select(i)
				turtle.transferTo(CROPS)
			end
		end
	elseif crop_detail["count"] < 64 then
		for i = FREE, 16, 1 do
			local item_detail = turtle.getItemDetail(i, true)
			if item_detail ~= nil and item_detail["name"] == name_of_crops then
				turtle.select(i)
				turtle.transferTo(CROPS)
			end
		end
	end

	-- empty slots
	for i = FREE, 16, 1 do
		turtle.select(i)
		turtle.dropDown()
	end

	-- go through farm
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

	-- go back to start
	for i = 1, 9, 1 do
		turtle.forward()
	end
	turtle.turnRight()
	for i = 1, 9, 1 do
		turtle.forward()
	end
	turtle.turnRight()
end

function farm(name_of_crops, nr_of_rounds, delay)
	if nr_of_rounds == 0 then
		while true do
			farm_round(name_of_crops)
		end
	else
		for i = 1, nr_of_rounds, 1 do
			farm_round(name_of_crops)
		end
	end
end

local item_data_tags = {}
item_data_tags["potatoes"] = "minecraft:potato"
item_data_tags["carrots"] = "minecraft:carrots"
item_data_tags["wheat"] = "minecraft:wheat_seeds"

local name_of_crops = item_data_tags[arg[1]]

local nr_of_rounds = tonumber(arg[2])

local delay = tonumber(arg[3])

if name_of_crops == nil then
	print("Unrecognized crop name.")
	print("Crops are: potatoes, carrots or wheat.")
	print("Usage: farm <crop_name> <nr_of_rounds>(0 for infinite)")
elseif nr_of_rounds == nil then
	print("Nr of rounds not a number.")
	print("Usage: farm <crop_name> <nr_of_rounds>(0 for infinite)")
elseif delay == nil then
	print("Delay ot a number.")
	print("Usage: farm <crop_name> <nr_of_rounds>(0 for infinite)")
else
	farm(name_of_crops, nr_of_rounds, delay)
end