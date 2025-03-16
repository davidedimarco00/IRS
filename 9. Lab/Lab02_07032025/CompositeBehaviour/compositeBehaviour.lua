function init()
    robot.wheels.set_velocity(5, 5)
    sensor_index = 0
    last_vision = 0
end

function step()
    local prox_sensors = robot.proximity
    local light_sensors = robot.light
    local max_light = 0
    local light_detected = false
    local sensor_index = 0
    local left_speed, right_speed = 5, 5
    
    -- Rilevamento della luce
    for i = 1, #light_sensors do
        if light_sensors[i].value > max_light then
            max_light = light_sensors[i].value
            sensor_index = i
            light_detected = true
        end
    end

    if light_detected then
        log("Light Detected: ", light_sensors[sensor_index].value)
        local angle = math.deg(light_sensors[sensor_index].angle)

        -- Se la luce è dritta davanti, acceleriamo
        if angle < -15 then
            left_speed, right_speed = 10, 5
        elseif angle > 15 then
            left_speed, right_speed = 5, 10
        else
            left_speed, right_speed = 10, 10
        end
    else
        log("Light NOT Detected")
    end

    
    local obstacle_detected = false
    local left_distance = 0
    local right_distance = 0

    for i = 1, #prox_sensors do
        if prox_sensors[i].value > 0.2 then  
            obstacle_detected = true
            if prox_sensors[i].angle > 0.2 then
                right_distance = prox_sensors[i].value
            else
                left_distance = prox_sensors[i].value
            end
        end
    end

    if obstacle_detected then
        log("Obstacle Detected! Avoiding...")
        -- Se c'è più spazio a sinistra, segue il bordo sulla destra
        if left_distance > right_distance then  
            left_speed = 3
            right_speed = 6
        else  
            left_speed = 6
            right_speed = 3
        end
    end

    -- Se non ha rilevato né luce né ostacoli, si muove casualmente
    if not light_detected and not obstacle_detected then
        left_speed = math.random(3, 7)
        right_speed = math.random(3, 7)
    end

    robot.wheels.set_velocity(left_speed, right_speed)
end

function reset()
    robot.wheels.set_velocity(5, 5)
end

function destroy()
end
