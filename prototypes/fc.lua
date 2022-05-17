--[[
Flight Computer function prototypes by TChapman500.

For Use as REFERENCE ONLY!

Do not attempt to use these in your scripts or they will break!
--]]

fc = {}

fc.TakeControl = function(inputs)
	return true	-- If control is given to the program.
	return false	-- If control is not given to the program.
end

fc.ReleaseControl = function(inputs) end
fc.ReleaseControls = function() end

fc.GetThrusterMinimums = function()
	local minimums = {
		Main = 0.2,	-- Example values, real value may be lower or higher
		Retro = 0.2,
		RCS = 0.25
	}
	return minimums
end

fc.SetRotation = function(throttle) end
fc.SetXTranslation = function(throttle) end
fc.SetYTranslation = function(throttle) end
fc.SetMain = function(throttle) end	-- Sets both main and retro engines

fc.GetPlayerInputs = function()
	local inputs = {
		Main = 0.0,	-- Example values, real values may be lower or higher
		Retro = 0.0,
		Rotation = 0.0,
		XTranslation = 0.0,
		YTranslation = 0.0
	}
end

fc.Stage = function()
	return enums.StageResults.Success	-- If Successfully staged
	return enums.StageResults.Forbidden	-- Not allowed to stage at this time.
	return enums.StageResults.NoStages	-- Nothing to stage.
end

-- Any ports we cannot control will be excluded
fc.GetDockingPorts = function()
	local portsList = {}	-- Each entry is a separate docking port
	return portsList
end
