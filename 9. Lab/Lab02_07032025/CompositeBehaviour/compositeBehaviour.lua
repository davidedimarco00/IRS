
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
    
    for i = 1, #light_sensors do
        if light_sensors[i].value > max_light then
            max_light = light_sensors[i].value
            sensor_index = i
            light_detected = true
            if max_light > 0.4 then
                log("arrived")
            end
        end
    end

    if light_detected then
        log("Light Detected: ",light_sensors[sensor_index].value )
        local angle = math.deg(light_sensors[sensor_index].angle)
        
        -- Smooth movement towards light
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

    --obstacle avoidance
    local obstacle_detected = false
    local avoidance_turn = 0

    for i = 1, #prox_sensors do
        if prox_sensors[i].value > 0.2 then  
            obstacle_detected = true
            avoidance_turn = prox_sensors[i].angle  
            log("Ostacolo rilevato: valore=", prox_sensors[i].value, " angolo=", avoidance_turn)
            break
        end
    end

    if obstacle_detected then
        if avoidance_turn > 0 then  
            left_speed = 10
            right_speed = -5
        else 
            left_speed = -5
            right_speed = 10
        end
    elseif not light_detected then
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
