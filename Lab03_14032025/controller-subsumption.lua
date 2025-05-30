function init()
    step_count = 0
end

function step()
    step_count = step_count + 1
    local prox_sensors   = robot.proximity
    local light_sensors  = robot.light
    local ground_sensors = robot.motor_ground
    --------DOWN TO TOP OF PYRAMID
    --Level 4: explore env (no priority)
    local left_speed, right_speed = exploreBehavior()
     --Level 3: phototaxis 
    local active, l, r = findLightBehavior(light_sensors)
    if active then left_speed, right_speed = l, r end
    --Level 2: avoid obstacle
    local active, l, r = avoidObstacleBehavior(prox_sensors)
    if active then left_speed, right_speed = l, r end
   --Level 1: stop on black (upper level)
    local active, l, r = stopOnBlackBehavior(ground_sensors)
    if active then left_speed, right_speed = l, r end
    robot.wheels.set_velocity(left_speed, right_speed)
end

function reset()
    robot.wheels.set_velocity(0, 0)
end

function destroy()
end

function exploreBehavior()
    local left  = math.random(3, 6)
    local right = math.random(3, 6)
    return left, right
end

function avoidObstacleBehavior(prox_sensors)
    local THRESHOLD = 0.2
    local left_val, right_val = 0, 0
    local obstacle = false

    for i = 1, #prox_sensors do
        local sensor = prox_sensors[i]
        if sensor.value > THRESHOLD then
            obstacle = true
            local angle = math.deg(sensor.angle)
            if angle < 0 then
                left_val = math.max(left_val, sensor.value)
            else
                right_val = math.max(right_val, sensor.value)
            end
        end
    end

    if obstacle then
        if left_val > right_val then
            return true, 3, 6
        else
            return true, 6, 3
        end
    else
        return false, 0, 0
    end
end

function findLightBehavior(light_sensors)
    local max_light = 0
    local sensor_index = -1

    for i = 1, #light_sensors do
        if light_sensors[i].value > max_light then
            max_light = light_sensors[i].value
            sensor_index = i
        end
    end

    if sensor_index > 0 and max_light > 0.05 then
        local angle = light_sensors[sensor_index].angle
        if angle < -0.26 then
            return true, 10, 5
        elseif angle > -0.26 then
            return true, 5, 10
        else
            return true, 10, 10
        end
    end

    return false, 0, 0
end

function stopOnBlackBehavior(ground_sensors)
    local THRESHOLD = 0.1
    local black_count = 0
    for i = 1, #ground_sensors do
        if ground_sensors[i].value < THRESHOLD then
            black_count = black_count + 1
        end
    end
    if black_count == 4 then
        log("Stop on black at step", step_count)
        return true, 0, 0
    end

    return false, 0, 0
end
