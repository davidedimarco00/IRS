function init()
    step_count=0
end

function step()
    step_count = step_count + 1
    prox_sensors   = robot.proximity
    light_sensors  = robot.light
    ground_sensors = robot.motor_ground
    positioning_sensors = robot.positioning 

    --the first thing is explore
    left_speed, right_speed = exploreBehavior()

    --obstacle avoiding
    a_left, a_right = avoidObstacleBehavior(prox_sensors)
    if a_left ~= nil and a_right ~= nil then
        left_speed  = a_left
        right_speed = a_right
    end

    --find light
    l_left, l_right = findLightBehavior(light_sensors)
    if l_left ~= nil and l_right ~= nil then
        left_speed  = l_left
        right_speed = l_right
    end

    --when i am in black zone
    s_left, s_right = stopOnBlackBehavior(ground_sensors)
    if s_left ~= nil and s_right ~= nil then
        left_speed  = s_left
        right_speed = s_right
    end
    robot.wheels.set_velocity(left_speed, right_speed)
end
 
 
 function reset()
    robot.wheels.set_velocity(0, 0)
 end
 
 
 function destroy()
    
 end
 

 function exploreBehavior()
    left  = math.random(3, 6)
    right = math.random(3, 6)
    return left, right
 end
 

 function avoidObstacleBehavior(prox_sensors)
    THRESHOLD = 0.2
    obstacle_detected = false
    left_val  = 0
    right_val = 0
    for i = 1, #prox_sensors do
       ps = prox_sensors[i]
       if ps.value > THRESHOLD then
          obstacle_detected = true
          angle_deg = math.deg(ps.angle)
          if angle_deg < 0 then
             left_val = math.max(left_val, ps.value)
          else
             right_val = math.max(right_val, ps.value)
          end
       end
    end
 
    if obstacle_detected then
       if left_val > right_val then
          return 3, 6
       else
          return 6, 3
       end
    else
       return nil, nil
    end
 end
 
 function findLightBehavior(light_sensors)
    max_light = 0
    sensor_index = -1
    for i = 1, #light_sensors do
       sensor = light_sensors[i]
       if sensor.value > max_light then
          max_light = sensor.value
          sensor_index = i
       end
    end
 
    if sensor_index > 0 and max_light > 0.05 then
       angle = math.deg(light_sensors[sensor_index].angle)
       
       if angle < -15 then
          return 10, 5
       elseif angle > 15 then
          return 5, 10
       else
          return 10, 10
       end
    else
       return nil, nil
    end
 end
 
 function stopOnBlackBehavior(ground_sensors)
    THRESHOLD = 0.1
    black_count = 0
    for i = 1, #ground_sensors do
       if ground_sensors[i].value < THRESHOLD then
          black_count = black_count + 1
       end
    end
    if black_count == 4 then
        log("Step",step_count)
       return 0, 0
    else
       return nil, nil
    end
 end
 