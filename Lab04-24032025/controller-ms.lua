local vector = require "vector"

--parametri
local L = 0.0
local MAX_SPEED = 15.0
local AVOID_THRESHOLD = 0.2
local LIGHT_THRESHOLD = 0.05
local LIGHT_INTENSITY_SCALE = 2.0
local K_OMEGA = 10.0
local step_count = 0
local step_interval = 15

function init()
    L = robot.wheels.axis_length
end


-- Potential fields attractive
function lightAttraction()
    local result = { length = 0.0, angle = 0.0 }
    for i = 1, #robot.light do
        local sensor = robot.light[i]
        local contribution = {
            length = sensor.value * LIGHT_INTENSITY_SCALE,
            angle = sensor.angle
        }
        result = vector.vec2_polar_sum(result, contribution)
    end
    return result
end


-- function to reduce speed
function reduce_speed(v)
    local sign = v >= 0 and 1 or -1
    local abs_v = math.abs(v)
    if abs_v <= MAX_SPEED then
        return v
    else
        -- Riduzione tramite radice quadrata (puoi usare anche log o divisione)
        local reduced = math.sqrt(abs_v)
        return reduced * sign
    end
end

-- potential field repulsive
function avoidObstacles()
    local result = { length = 0.0, angle = 0.0 }
    for i = 1, #robot.proximity do
        local sensor = robot.proximity[i]
        log(i," ",sensor.value)
        if sensor.value > 0.015 then 
            step_interval = 2
            local strength = (AVOID_THRESHOLD - sensor.value)
            log(i,"  strength " , math.abs(strength))
            if math.abs(strength) > 0 then
                local repulsion = {
                    length = math.abs(strength) / AVOID_THRESHOLD,
                    angle = sensor.angle + math.pi
                }
                result = vector.vec2_polar_sum(result, repulsion)
            end
        else
            step_interval = 15
        end
        
    end
    return result
end


function step()

    step_count = step_count + 1 -- step count

    if step_count % step_interval == 0 then
        local light_vec = lightAttraction()
        local avoid_vec = avoidObstacles()
        local combined = vector.vec2_polar_sum(light_vec, avoid_vec)
        if light_vec.length < LIGHT_THRESHOLD then
            robot.wheels.set_velocity(0, 0)
            return
        end

        local v = combined.length
        local omega = combined.angle * K_OMEGA

        local vl = v - (L / 2.0) * omega
        local vr = v + (L / 2.0) * omega

        vl = reduce_speed(vl)
        vr = reduce_speed(vr)
        print("reduced: " , math.abs(vl), " ", math.abs(vr))


        robot.wheels.set_velocity(vl, vr)
    else
        robot.wheels.set_velocity(5,5)

    end
        
end

function reset()
end

function destroy()
end
