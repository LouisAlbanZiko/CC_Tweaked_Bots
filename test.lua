local FUEL = 1
local SEEDS = 2
local FREE = 3

function plant()
    turtle.select(SEEDS)
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


while true do
    for i = 1, 16, 1 do
        turtle.select(i)
        turtle.dropDown()
    end
    
    local fuel_set = false
    local seeds_set = false
    turtle.select(FREE)
    while turtle.suckDown() do
        item_data = turtle.getItemDetail(FREE, true)
        if turtle.refuel(0) and not fuel_set then
            turtle.transferTo(FUEL)
            fuel_set = true
        elseif item_data ~= nil and item_data["tags"]["forge:seeds"] and not seeds_set then
            turtle.transferTo(SEEDS)
            seeds_set = true
        else
            turtle.dropUp()
        end
    end
    
    while turtle.suckUp() do
        turtle.dropDown()
    end
    
    if turtle.getFuelLevel() < 200 then
        turtle.select(FUEL)
        turtle.refuel(10)
    end

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
    
    for i = 1, 9, 1 do
        turtle.forward()
    end
    turtle.turnRight()
    for i = 1, 9, 1 do
        turtle.forward()
    end
    turtle.turnRight()
end
