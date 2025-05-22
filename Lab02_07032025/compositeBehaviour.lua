function init()
    sensor_index = 0
    robot.wheels.set_velocity(5, 5)
    step_count = 0 
    reaches    = 0  
    reached    = false 
    target = { x = 1, y = 1 }
    threshold = 0.3
    coll_threshold = 0.2
end

function step()
    step_count = step_count + 1
    --sensors
    local prox_sensors  = robot.proximity
    local light_sensors = robot.light
    --implementation variables
    local max_light = 0
    local light_detected = false
    local sensor_index = 0
    local left_speed, right_speed = 5, 5
    --obs avoidance
    local obstacle_detected = false
    local left_distance  = 0
    local right_distance = 0
    for i = 1, #prox_sensors do
        if prox_sensors[i].value > coll_threshold then
            obstacle_detected = true
            if prox_sensors[i].angle > 0 then
                right_distance = prox_sensors[i].value
            else
                left_distance = prox_sensors[i].value
            end
        end
    end
    if obstacle_detected then
        log("Obstacle Detected! Avoiding...")
        if left_distance > right_distance then
            left_speed, right_speed = 3, 6
        else
            left_speed, right_speed = 6, 3
        end
    end
    --light detection
    for i = 1, #light_sensors do
        if light_sensors[i].value > max_light then
            max_light    = light_sensors[i].value
            sensor_index = i
            light_detected = true
        end
    end
    if light_detected then
        log("Light Detected:", light_sensors[sensor_index].value)
        local angle = light_sensors[sensor_index].angle 
        if angle < -0.26 then 
            left_speed, right_speed = 10, 5
        elseif angle > 0.26 then 
            left_speed, right_speed = 5, 10
        else
            left_speed, right_speed = 10, 10
        end
    end
     --move randomly if no light detected
    if not light_detected and not obstacle_detected then
        left_speed  = math.random(3, 7)
        right_speed = math.random(3, 7)
    end
    --apply speed
    robot.wheels.set_velocity(left_speed, right_speed)




     -- 4) TESTING: calcola distanza e conta raggiungimenti
    local pos = robot.positioning.position  -- {x, y, z}
    local dx  = pos.x - target.x
    local dy  = pos.y - target.y
    local dist = math.sqrt(dx*dx + dy*dy)

    if dist <= threshold then
        if not reached then
            reaches = reaches + 1
            reached = true
            log(" Raggiunto target in passi:", step_count)
        end
    else
        reached = false
    end

    
end

function reset()
    -- reinizializza contatori per nuove run
    step_count = 0
    reaches    = 0
    reached    = false
    robot.wheels.set_velocity(5, 5)
end

function destroy()
    -- a simulazione terminata, stampa i risultati
    local pos = robot.positioning.position
    local dx  = pos.x - target.x
    local dy  = pos.y - target.y
    local dist = math.sqrt(dx*dx + dy*dy)

    log("  • Passi totali eseguiti:", step_count)
    log("  • Numero di raggiungimenti:", reaches)
    log("  • Distanza finale dal target:", dist)
end
