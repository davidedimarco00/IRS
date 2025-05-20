-- Random walk with collision avoidance
function init()
    robot.wheels.set_velocity(5, 5)
end

function step()
    local prox = robot.proximity
    local left_speed, right_speed = 5, 5
    
    local obstacle_detected = false
    local avoidance_turn = 0
    for i = 1, #prox do
        if prox[i].value > 0.4 then  
            obstacle_detected = true
            avoidance_turn = prox[i].angle  
            log("Ostacle: value=", prox[i].value, " angle", avoidance_turn)
            break
        end
    end
    if obstacle_detected then
        if avoidance_turn > 0 then  
            left_speed = 5
            right_speed = 0
        else 
            left_speed = 0
            right_speed = 5
        end
    else
        if math.random() < 0.1 then
            left_speed = math.random(3, 7)
            right_speed = math.random(3, 7)
        end
    end
    robot.wheels.set_velocity(left_speed, right_speed)
end

function reset()
    robot.wheels.set_velocity(5, 5)
end

function destroy()
end