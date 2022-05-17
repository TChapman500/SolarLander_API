--[[
Example Flight Computer Program by TChapman500

For personal use only!  Do not publish!

The API is subject to change during the development
of the Modding Update, so this script may not work
with the current version of the Modding Update.
]]

-- The program that lua looks for.
program = {
	-- These fields are required.
	Name = "Kill Rotation",
	Author = "TChapman500",
	Type = enums.FCPTypes.PilotAssist
}

-- Set to true if you want the program to terminate if the user tries to control the rotation.
local ReleaseImmediately = false

-- The angular velocity on the previous game tick.  Always initialize to zero to ensure proper function.
local PrevAngVel = 0.0

-- This affects how aggressively the rotation is killed.
-- I think lower values = more agressive.
-- Below this may induce oscillations.
local KillRotConst = 1000.0

-- Minimum throttle for the RCS thrusters
local MinThrottle = 0.0

-- Initialization function is called every time the program starts running.
-- This function is not directly called.  See program.Init below.
local function MainInit()
	prevAngVel = 0.0
	
	-- If throttle goes below min, engine shuts off.
	local mins = fc.GetThrusterMinimums()
	MinThrottle = mins.RCS
	
	-- Take control of the rotation of the craft.
	local inputs = { enums.Inputs.Rotation }
	return fc.TakeControl(inputs)	-- Terminate if we can't take control.
end

-- This function is not directly called.  See program.Tick below
-- Unless of course the player is trying to control the rotation
-- and we are not terminating while under player control
local function MainTick()
	-- Get angular velocity and acceleration.
	local angVel = craft.GetAngularVelocity()
	local angAcc = (angVel - prevAngVel) * game.InverseTickStep
	
	-- What we will set the rotation value to.
	local throttle = -angVel * (craft.GetMass() / KillRotConst)
	
	-- Just to make sure we don't go over the max.
	if throttle < -1.0 then throttle = -1.0
	elseif throttle > 1.0 then throttle = 1.0 end
	
	-- Make sure we always apply minimum throttle.
	local absThrottle = math.abs(throttle)
	if absThrottle < MinThrottle then
		if absThrottle > 0.01 then
			absThrottle = MinThrottle
		else	-- We should stop trying to stop the rotation now.
			absThrottle = 0.0
		end
	end
	
	-- Adjust the final throttle value.
	if absThrottle == 0.0 then
		throttle = 0.0
	else	-- Set the new throttle value.
		if throttle < 0.0 then
			throttle = -absThrottle
		else
			throttle = absThrottle
		end
	end
	
	-- Apply the throttle
	fc.SetRotation(throttle)
	
	-- Store angular velocity.
	prevAngVel = angVel
	return true
end

if ReleaseImmediately then	-- When we want the user to be able to terminate the program by trying to take control of the craft.
	program.Update = function()
		-- Terminate the program if the user is trying to take control of the rotation.
		local playerInputs = fc.GetPlayerInputs()
		if math.abs(playerInputs.Rotation) >= 0.25 then
			return false
		end
		return true
	end
	
	-- I don't know if this will work, but it's worth a shot.
	program.Init = MainInit
	program.Tick = MainTick
else	-- When we want to keep the program running even if the user tries to control the rotation of the craft.
	-- Whether we have released control over the craft.
	local released = false
	
	-- Do extra initialization here.
	program.Init = function()
		released = false
		return MainInit()
	end
	
	-- Just retrieve the user inputs
	program.Update = function()
		-- Get the player's control inputs.
		local playerInputs = fc.GetPlayerInputs()
		local rotation = math.abs(playerInputs.Rotation)
		
		-- See if we should take or release control.
		if released then	-- Retake control of the rotation.
			if rotation < 0.25 then
				local inputs = { enums.Inputs.Rotation }
				if fc.TakeControl(inputs) then
					released = false
				else	-- Couldn't take control back.
					return false;
				end
			end
		else	-- Release control of the rotation.
			if rotation >= 0.25 then
				fc.ReleaseControls()
				released = true
			end
		end
		return true
	end
	
	-- Process user inputs before attempting to stop the rotation.
	program.Tick = function()
		-- Return early if the user is trying to control the craft.
		if released then return true end
		
		-- If the user is not controlling the craft's rotation, then stop the rotation.
		return MainTick()
	end
end

