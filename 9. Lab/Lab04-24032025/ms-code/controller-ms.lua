-- Motor Schema Controller for ARGoS
-- Implements light-seeking with obstacle avoidance using motor schemas

local vector = require "vector"

-- Parameters
local MAX_SPEED   = 15.0    -- Maximum wheel velocity (rad/s)
local LIGHT_GAIN  = 50.0    -- Gain for attractive light vector
local PROX_GAIN   = 20.0    -- Gain for repulsive obstacle vector
local L           = nil     -- Distance between wheels (m), set in init()

-- Initialization function
function init()
   -- Retrieve wheel axis length
   L = robot.wheels.axis_length
end

-- Main control loop executed each simulation tick
function step()
   -- Read sensor arrays
   local light_readings = robot.light
   local prox_readings  = robot.proximity

   -- 1) Compute attractive vector toward light source
   local v_light = {length = 0.0, angle = 0.0}
   for _, reading in ipairs(light_readings) do
      local intensity = reading.value * LIGHT_GAIN
      local v = { length = intensity, angle = reading.angle }
      v_light = vector.vec2_polar_sum(v_light, v)
   end

   -- 2) Compute repulsive vector away from obstacles
   local v_obs = {length = 0.0, angle = 0.0}
   for _, reading in ipairs(prox_readings) do
      if reading.value and reading.value > 0 then
         local strength = reading.value * PROX_GAIN
         -- Repulsion: push opposite to sensor direction
         local v = { length = strength, angle = reading.angle + math.pi }
         v_obs = vector.vec2_polar_sum(v_obs, v)
      end
   end

   -- 3) Sum behaviours
   local v_total = vector.vec2_polar_sum(v_light, v_obs)

   -- 4) Decompose into translational (v) and angular (omega) components
   local v_trans = v_total.length * math.cos(v_total.angle)
   local v_rot   = v_total.length * math.sin(v_total.angle)

   -- 5) Compute differential wheel speeds
   local vl = v_trans - (L/2.0) * v_rot
   local vr = v_trans + (L/2.0) * v_rot

   -- 6) Clamp wheel speeds to allowable range
   vl = math.max(-MAX_SPEED, math.min(MAX_SPEED, vl))
   vr = math.max(-MAX_SPEED, math.min(MAX_SPEED, vr))

   -- 7) Send commands to wheels
   robot.wheels.set_velocity(vl, vr)
end

-- Reset function (called on experiment reset)
function reset()
   -- No persistent state to reset
end

-- Cleanup (called at end of experiment)
function destroy()
   -- Nothing to clean up
end
