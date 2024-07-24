-------------------------------------------------------
--  CONFIGURATION
-------------------------------------------------------

--- General Configuration
gather_method = "gathering"  -- Gathering method, only accept "spearfishing" or "gathering"
consumables_food = "Boiled Egg"        -- Food name(ie. "[Name of food]"), or {"[Name of food 1]", "[Name of food 2]"} or "[Name of food] <hq>"
consumables_potion = "Superior Spiritbond Potion <hq>"      -- Potion name(ie. "[Name of potion]"), or {"[Name of potion 1]", "[Name of potion 2]"} or "[Name of potion] <hq>"
auto_repair = true              -- Configuration for auto gear repair (SELF REPAIR ONLY)
auto_extract = true             -- Configuration for auto materia extraction
auto_reduce = true              -- Configuration for auto aetherial reduction
gear_repair_treshold = 90       -- Gear condition treshold before initiating repair
inventory_threshold_cap = 2     -- Number of free slots before script stopping

--- Spearfishing Configuration
route_visland = "SungiltAethersand"    -- visland route name for spearfishing

--- Logic Variables
reductibles_checked = false
require_repair = false
require_extract = false
require_reduce = false

-------------------------------------------------------
--  SCRIPTS FUNCTIONS
-------------------------------------------------------
--- Printing Messages
local function echo_out(message)
    yield("/echo [Mille LUA] " .. message)
end

--- Trigger wait function
local function wait_action(interval_rate)
    yield("/wait " .. interval_rate)
end

--- Interrupting Cast Functions
local function interrupt_casting()
    if GetCharacterCondition(27) then
        echo_out("Interrupting cast")
        yield("/automove on")
        yield("/automove off")
    end
end

--- Wait untill next itteration functions
local function wait_next_loop()
    if GetCharacterCondition(6) then
        reductibles_checked = false
    end
    while (GetCharacterCondition(6) or GetCharacterCondition(32) or GetCharacterCondition(45) or GetCharacterCondition(27) or not IsPlayerAvailable() or PathfindInProgress()) do
        wait_action(0.2) --yield("/wait " .. interval_rate)
    end
end

--- Start/Resume Spearfishing
local function start_spearfishing(state)
    if state == "start" then
        echo_out("Starting visland route.")
        yield("/visland exec " .. route_visland)
    elseif state == "resume" then
        echo_out("Resuming visland route.")
        yield("/visland resume")
    else
        echo_out("Error visland start state.")
    end
end

--- Stop/Pause Spearfishing
local function stop_spearfishing(state)
    if state == "stop" then
        echo_out("Stopping visland route.")
        yield("/visland stop")
    elseif state == "pause" then
        echo_out("Pausing visland route.")
        yield("/visland pausing")
    else
        echo_out("Error visland stop state.")
    end
end

--- Start/Resume Gathering
local function start_gathering(state)
    if state == "start" then
        echo_out("Starting Gathering.")
        yield("/gbr auto on")
    elseif state == "resume" then
        echo_out("Resuming Gathering.")
        yield("/gbr auto on")
    else
        echo_out("Error gathering start state.")
    end
end

--- Stop/Pause Gathering
local function stop_gathering(state)
    if state == "stop" then
        echo_out("Stopping Gathering.")
        yield("/gbr auto off")
    elseif state == "pause" then
        echo_out("Pausing Gathering.")
        yield("/gbr auto off")
    else
        echo_out("Error gathering stop state.")
    end
end

--- Consume Food/Potion
local function consume_item(state, wait_timeout)
    if state == "food" then
        if type(consumables_food) ~= "string" and type(consumables_food) ~= "table" then
            return false
        end
        if GetZoneID() == 1055 then
            return false
        end
        if not HasStatusId(48) then -- if not HasStatus("Well Fed") then
            echo_out("Food Checks.")
            if gather_method == "gathering" then
                stop_gathering("pause")
            elseif gather_method == "spearfishing" then
                stop_spearfishing("pause")
            end 
            interrupt_casting()
            while (GetCharacterCondition(45)) and not IsPlayerAvailable() do
                wait_action(0.2)
                -- yield("/wait " .. interval_rate)
            end
            local timeout_start = os.clock()
            local user_settings = {
                GetSNDProperty("UseItemStructsVersion"),
                GetSNDProperty("StopMacroIfItemNotFound"),
                GetSNDProperty("StopMacroIfCantUseItem")
            }
            SetSNDProperty("UseItemStructsVersion", "true")
            SetSNDProperty("StopMacroIfItemNotFound", "false")
            SetSNDProperty("StopMacroIfCantUseItem", "false")
            repeat
                if type(consumables_food) == "string" then
                    echo_out("Attempt to consume " .. consumables_food)
                    yield("/item " .. consumables_food)
                    wait_action(3) -- yield("/wait " .. math.max(interval_rate, 1))
                elseif type(consumables_food) == "table" then
                    for _, food in ipairs(consumables_food) do
                        echo_out("Attempt to consume food list " .. food)
                        yield("/item " .. food)
                        wait_action(3) -- yield("/wait " .. math.max(interval_rate, 1))
                        if HasStatusId(48) then -- if HasStatus("Well Fed") then
                            break
                        end
                    end
                end
                echo_out("mooder")
                wait_action(1) -- yield("/wait " .. math.max(interval_rate, 1))
            until HasStatusId(48) or os.clock() - timeout_start > wait_timeout -- until HasStatus("Well Fed") or os.clock() - timeout_start > wait_timeout
            SetSNDProperty("UseItemStructsVersion", tostring(user_settings[1]))
            SetSNDProperty("StopMacroIfItemNotFound", tostring(user_settings[2]))
            SetSNDProperty("StopMacroIfCantUseItem", tostring(user_settings[3]))
            if gather_method == "gathering" then
                start_gathering("resume")
            elseif gather_method == "spearfishing" then
                start_spearfishing("resume")
            end 
            return true
        else
            return true
        end
    elseif state == "potion" then
        if type(consumables_potion) ~= "string" and type(consumables_potion) ~= "table" then
            return false
        end
        if GetZoneID() == 1055 then
            return false
        end
        if not HasStatusId(49) then -- if not HasStatus("Medicated") then
            echo_out("Potion Checks.")
            if gather_method == "gathering" then
                stop_gathering("pause")
            elseif gather_method == "spearfishing" then
                stop_spearfishing("pause")
            end 
            interrupt_casting()
            while (GetCharacterCondition(45)) and not IsPlayerAvailable() do
                wait_action(1) -- yield("/wait " .. interval_rate)
            end
            local timeout_start = os.clock()
            local user_settings = {
                GetSNDProperty("UseItemStructsVersion"),
                GetSNDProperty("StopMacroIfItemNotFound"),
                GetSNDProperty("StopMacroIfCantUseItem")
            }
            SetSNDProperty("UseItemStructsVersion", "true")
            SetSNDProperty("StopMacroIfItemNotFound", "false")
            SetSNDProperty("StopMacroIfCantUseItem", "false")
            repeat
                if type(consumables_potion) == "string" then
                    echo_out("Attempt to consume " .. consumables_potion)
                    yield("/item " .. consumables_potion)
                elseif type(consumables_potion) == "table" then
                    for _, pot in ipairs(consumables_potion) do 
                        echo_out("Attempt to consume potion list " .. pot)
                        yield("/item " .. pot)
                        wait_action(3) -- yield("/wait " .. math.max(interval_rate, 1))
                        if HasStatusId(49) then -- if HasStatus("Medicated") then
                            break
                        end
                    end
                end
                wait_action(1) -- yield("/wait " .. math.max(interval_rate, 1))
            until HasStatusId(49) or os.clock() - timeout_start > wait_timeout -- until HasStatus("Medicated") or os.clock() - timeout_start > wait_timeout
            SetSNDProperty("UseItemStructsVersion", tostring(user_settings[1]))
            SetSNDProperty("StopMacroIfItemNotFound", tostring(user_settings[2]))
            SetSNDProperty("StopMacroIfCantUseItem", tostring(user_settings[3]))
            if gather_method == "gathering" then
                start_gathering("resume")
            elseif gather_method == "spearfishing" then
                start_spearfishing("resume")
            end
        end
        return true
    else
        echo_out("Error consumable item state.")
    end
    return false
end

--- Duty Checker
local function check_duty_queue()
    if GetCharacterCondition(59) then
        -- stop_script = true
        echo_out("Detected duty pop, stopping script.")
        if gather_method == "gathering" then
            stop_gathering("stop")
        elseif gather_method == "spearfishing" then
            stop_spearfishing("stop")
        end 
        return true
    end
    return false
end

--- Dismounting Function
local function character_dismount(wait_timeout)
    if GetCharacterCondition(4) then
        echo_out("Attempting to dismount.")
        if GetCharacterCondition(77) then
            local random_j = 0
            ::DISMOUNT_START::
            CheckNavmeshReady()
            local land_x
            local land_y
            local land_z
            local i = 0
            while not land_x or not land_y or not land_z do
                land_x =
                    QueryMeshPointOnFloorX(
                    GetPlayerRawXPos() + math.random(0, random_j),
                    GetPlayerRawYPos() + math.random(0, random_j),
                    GetPlayerRawZPos() + math.random(0, random_j),
                    false,
                    i
                )
                land_y =
                    QueryMeshPointOnFloorY(
                    GetPlayerRawXPos() + math.random(0, random_j),
                    GetPlayerRawYPos() + math.random(0, random_j),
                    GetPlayerRawZPos() + math.random(0, random_j),
                    false,
                    i
                )
                land_z =
                    QueryMeshPointOnFloorZ(
                    GetPlayerRawXPos() + math.random(0, random_j),
                    GetPlayerRawYPos() + math.random(0, random_j),
                    GetPlayerRawZPos() + math.random(0, random_j),
                    false,
                    i
                )
                i = i + 1
            end
            NodeMoveFly("land," .. land_x .. "," .. land_y .. "," .. land_z)

            local timeout_start = os.clock()
            repeat
                wait_action(0.2) -- yield("/wait " .. interval_rate)
                if os.clock() - timeout_start > wait_timeout then
                    echo_out("Failed to navigate to dismountable terrain.")
                    echo_out("Trying another place to dismount...")
                    random_j = random_j + 1
                    goto DISMOUNT_START
                end
            until not PathIsRunning()

            yield('/gaction "Mount Roulette"')

            timeout_start = os.clock()
            repeat
                wait_action(0.2) -- yield("/wait " .. interval_rate)
                if os.clock() - timeout_start > wait_timeout then
                    echo_out("Failed to dismount.")
                    echo_out("Trying another place to dismount...")
                    random_j = random_j + 1
                    goto DISMOUNT_START
                end
            until not GetCharacterCondition(77)
        end
        if GetCharacterCondition(4) then
            yield('/gaction "Mount Roulette"')
            repeat
                wait_action(0.2) -- yield("/wait " .. interval_rate)
            until not GetCharacterCondition(4)
        end
    end
end

--- Check if gear need repair
local function check_gear()
    if auto_repair then
        repair_threshold = tonumber(gear_repair_treshold) or 99
        if NeedsRepair(tonumber(repair_threshold)) then
            require_repair = true
            return true
        end
    end 
    return false
end

--- Check if need materia extraction
local function check_materia()
    if auto_extract then
        require_extract = CanExtractMateria()
        return require_extract
    end
    return false
end

--- Check if got reducibles
local function check_reducibles(wait_timeout)
    if not reductibles_checked and not require_reduce then
        while not IsAddonVisible("PurifyItemSelector") and not IsAddonReady("PurifyItemSelector") do
            yield('/gaction "Aetherial Reduction"')
            local timeout_start = os.clock()
            repeat
                wait_action(0.2) -- yield("/wait " .. interval_rate)
            until IsNodeVisible("PurifyItemSelector", 1, 6) or IsNodeVisible("PurifyItemSelector", 1, 7) or os.clock() - timeout_start > wait_timeout
        end
        wait_action(0.2) -- yield("/wait " .. interval_rate)
        require_reduce = IsNodeVisible("PurifyItemSelector", 1, 6)
        while IsAddonVisible("PurifyItemSelector") do
            yield('/gaction "Aetherial Reduction"')
            repeat
                wait_action(0.2) -- yield("/wait " .. interval_rate)
            until IsPlayerAvailable()
        end
        reductibles_checked = true
    end
    return require_reduce
end

--- Stop Flying movement
local function stop_movement_flying()
    PathStop()
    while PathIsRunning() do
        wait_action(0.2) -- yield("/wait " .. interval_rate)
    end  
end

--- Attempt to repair gear
local function repair_gear()
    if require_repair then
        echo_out("Repairing Gear.")
        stop_movement_flying()
        character_dismount()
        echo_out("Attempting to repair.")
        while not IsAddonVisible("Repair") and not IsAddonReady("Repair") do
            character_dismount()
            yield('/gaction "Repair"')
            repeat
                wait_action(0.2) -- yield("/wait " .. interval_rate)
            until IsPlayerAvailable()
        end
        wait_action(0.1) -- yield("/wait 0.1")
        yield("/pcall Repair true 0")
        repeat
            wait_action(0.2) -- yield("/wait " .. interval_rate)
        until IsAddonVisible("SelectYesno") and IsAddonReady("SelectYesno")
        yield("/pcall SelectYesno true 0")
        repeat
            wait_action(0.2) -- yield("/wait " .. interval_rate)
        until not IsAddonVisible("SelectYesno")
        while GetCharacterCondition(39) do
            wait_action(0.2) -- yield("/wait " .. interval_rate)
        end
        while IsAddonVisible("Repair") do
            yield('/gaction "Repair"')
            repeat
                wait_action(0.2) -- yield("/wait " .. interval_rate)
            until IsPlayerAvailable()
        end
        if NeedsRepair() then
            echo_out("Self Repair failed!")
            echo_out("Please place the appropriate Dark Matter in your inventory,")
            echo_out("Or find a NPC mender.")
            return false
        else
            echo_out("Repairs complete!")
            require_repair = false
        end
    end
end

--- Attempt to extract materia
local function extract_materia()
    if require_extract and GetInventoryFreeSlotCount() +1 > inventory_threshold_cap then
        echo_out("Extracting Materia.")
        stop_movement_flying()
        character_dismount()
        while GetCharacterCondition(27) do
            wait_action(0.2) -- yield("/wait " .. interval_rate)
        end
        wait_action(1) -- yield("/wait 3")
        echo_out("Attempting to extract materia...")
        while not IsAddonVisible("Materialize") and not IsAddonReady("Materialize") do
            yield('/gaction "Materia Extraction"')
            repeat
                wait_action(0.2) -- yield("/wait " .. interval_rate)
            until IsPlayerAvailable()
        end
        while CanExtractMateria() and GetInventoryFreeSlotCount() + 1 > inventory_threshold_cap do
            character_dismount()
            wait_action(0.1) -- yield("/wait 0.1")
            yield("/pcall Materialize true 2 0")
            repeat
                wait_action(1) -- yield("/wait 1")
            until not GetCharacterCondition(39)
        end
        while IsAddonVisible("Materialize") do
            yield('/gaction "Materia Extraction"')
            repeat
                wait_action(0.2) -- yield("/wait " .. interval_rate)
            until IsPlayerAvailable()
        end
        if CanExtractMateria() then
            echo_out("Failed to fully extract all materia!")
            echo_out("Please check your if you have spare inventory slots,")
            echo_out("Or manually extract any materia.")
            return false
        else
            echo_out("Materia extraction complete!")
            require_extract = false
        end
    end
end

--- Attempt to reduce reducibles
local function reduce_item(wait_timeout)
    if require_reduce or check_reducibles(10) then
        echo_out("Aetherial Reducting.")
        stop_movement_flying()
        character_dismount()
        echo_out("Attempting to perform aetherial reduction...")
        repeat --Show reduction window
            yield('/gaction "Aetherial Reduction"')
            local timeout_start = os.clock()
            repeat
                --yield("/wait " .. interval_rate)
                
            until IsNodeVisible("PurifyItemSelector", 1, 6) or IsNodeVisible("PurifyItemSelector", 1, 7) or
                os.clock() - timeout_start > wait_timeout
        until IsAddonVisible("PurifyItemSelector") and IsAddonReady("PurifyItemSelector")
        wait_action(0.2) -- yield("/wait " .. interval_rate)
        while not IsNodeVisible("PurifyItemSelector", 1, 7) and IsNodeVisible("PurifyItemSelector", 1, 6) and
            GetInventoryFreeSlotCount() > inventory_threshold_cap do -- reduce all
            character_dismount()
            yield("/pcall PurifyItemSelector true 12 0")
            repeat
                wait_action(0.2) -- yield("/wait " .. interval_rate)
            until not GetCharacterCondition(39)

            if (stop_main) then
                yield('/gaction "Aetherial Reduction"')
                return
            end
        end
        while IsAddonVisible("PurifyItemSelector") do --Hide reduction window
            yield('/gaction "Aetherial Reduction"')
            repeat
                wait_action(0.2) -- yield("/wait " .. interval_rate)
            until IsPlayerAvailable()
        end
        echo_out("Aetherial reduction complete!")
        require_reduce = false
        reductibles_checked = true
    end
end

--- AIO Check Repair Extract & Reducibles
local function check_repair_extract_reduce()
    return check_gear() or check_materia() or check_reducibles(10)
end

--- Food and Potion Status Checks
local function food_potion_check()
    if check_duty_queue() then
        return false
    end
    if not GetCharacterCondition(6) then
        consume_item("food",10)
    end
    if check_duty_queue() then
        return false
    end
    if not GetCharacterCondition(6) then
        consume_item("potion",10)
    end
    return true
end

--- Spearfishing function
local function main_spearfishing()
    local spear_init = true
    local stop_script = false
    while not stop_script do
        if food_potion_check() then
            if spear_init then
                spear_init = false
                start_spearfishing("start")
            end
            if (check_repair_extract_reduce()) then
                stop_spearfishing("pause")
                interrupt_casting()
                while GetCharacterCondition(45) and not IsPlayerAvailable() do -- while busy
                    wait_action(0.2)
                    -- yield("/wait " .. interval_rate)
                end
                if auto_repair then
                    echo_out("Gear Checks")
                    repair_gear()
                end
                if auto_extract then
                    echo_out("Materia Checks")
                    extract_materia()
                end
                if auto_reduce then
                    echo_out("Reduce Checks")
                    reduce_item(10)
                end
                stop_script = check_duty_queue()
                echo_out("Finished Checks.")
                start_spearfishing("resume")
            end
        else
            stop_script = true
        end
        if GetInventoryFreeSlotCount() <= inventory_threshold_cap then
            echo_out("Inventory free slot threshold reached. Disabling script")
            stop_spearfishing("stop")
            stop_script = true
            return false
        end
        wait_next_loop()
    end
end

--- Gathering function
local function main_gathering()
    local gather_init = true
    local stop_script = false
    while not stop_script do
        if food_potion_check() then
            if gather_init then
                gather_init = false
                start_gathering("start")
            end
            if (check_repair_extract_reduce()) then
                stop_gathering("pause")
                interrupt_casting()
                while GetCharacterCondition(45) and not IsPlayerAvailable() do
                    wait_action(0.2)
                    -- yield("/wait " .. interval_rate)
                end
                if auto_repair then
                    echo_out("Gear Checks")
                    repair_gear()
                end
                if auto_extract then
                    echo_out("Materia Checks")
                    extract_materia()
                end
                if auto_reduce then
                    echo_out("Reduce Checks")
                    reduce_item(10)
                end
                stop_script = check_duty_queue()
                echo_out("Finished Checks.")
                start_gathering("resume")
            end
        else
            stop_script = true
        end
        if GetInventoryFreeSlotCount() <= inventory_threshold_cap then
            echo_out("Inventory free slot threshold reached. Disabling script")
            stop_gathering("stop")
            stop_script = true
            return false
        end
        wait_next_loop()
    end
end

--- Checking Dependency
local function dependency_check()
    local depedencies_status = true
    if not HasPlugin("vnavmesh") then
        echo_out("Please Install vnavmesh")
        depedencies_status = false
    end
    if not HasPlugin("GatherbuddyReborn") then
        echo_out("Please Install Gather Buddy Reborn")
        depedencies_status = false
    end

    if not HasPlugin("visland") then
        echo_out("Please Install V(ery) Island")
        depedencies_status = false
    end

    --Optional dependencies
    if do_extract == true or do_repair == true or do_reduce == true then
        if not HasPlugin("YesAlready") then
            echo_out("Please Install YesAlready")
            depedencies_status = false
        elseif do_extract == true then
            echo_out(
                "Materia extraction detected. Please make sure YesAlready setting -> Bothers -> MaterializeDialog option is enabled."
            )
        end
    end

    if (consumables_food == true or consumables_potion == true) then
        echo_out("Please specify a food/drink name instead of 'true'")
        depedencies_status = false
    end

    return depedencies_status
end

--- Base function
local function main()
    echo_out("Starting Script")
    local depedencies_pass = dependency_check()
    echo_out("Checking Dependencies ")
    if depedencies_pass then
        if gather_method == "spearfishing" then
            main_spearfishing()
        elseif gather_method == "gathering" then
            main_gathering()
        else
            echo_out("wrong gather_method, please check on your configured gather_method on the script.")
        end
    end
    return
end

main()