local S = 0.01         --spontaneous stop prob.
local W = 0.1          --spontaneous walking prob.
local alpha = 0.1      --positive feedback
local beta = 0.05      --negative feedback
local PSmax = 0.99     --max for stop probability
local PWmin = 0.005    --min of probability
local MAXRANGE = 30.0  --max distance
local STATE = { WALK = 0, STOP = 1 }
local current_state = STATE.WALK
function init()
   robot.range_and_bearing.set_data(1, 0)  -- inizialmente cammina
   robot.leds.set_all_colors("green")
end
function step()
   local N = CountStoppedNeighbors()
   local Ps = math.min(PSmax, S + alpha * N) --Ps depends on number of neighbors
   local Pw = math.max(PWmin, W - beta * N) --Pw depends on number of neighbors
   local t = robot.random.uniform()
   if current_state == STATE.WALK then
      robot.range_and_bearing.set_data(1, 0)
      robot.leds.set_all_colors("green")
      robot.wheels.set_velocity(5, 5)
      if t <= Ps then
         current_state = STATE.STOP
      end
   elseif current_state == STATE.STOP then
      robot.range_and_bearing.set_data(1, 1)
      robot.leds.set_all_colors("red")
      robot.wheels.set_velocity(0, 0)
      if t <= Pw then
         current_state = STATE.WALK
      end
   end
end
function CountStoppedNeighbors()
   local count = 0
   for i = 1, #robot.range_and_bearing do
      if robot.range_and_bearing[i].range < MAXRANGE and
         robot.range_and_bearing[i].data[1] == 1 then
         count = count + 1
      end
   end
   return count
end

function reset()
   current_state = STATE.WALK
   robot.range_and_bearing.set_data(1, 0)
   robot.leds.set_all_colors("green")
end

function destroy()
end
