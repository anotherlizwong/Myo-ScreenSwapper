scriptId = 'com.anotherlizwong.first.screenswap'

locked = true
unlockedSince = 0
appTitle = ""

function onForegroundWindowChange(app, title)
	myo.debug("onForegroundWindowChange: " .. app .. ", " .. title)
	appTitle = title
	return true
end

function activeAppName()
	return appTitle
end

function popupOpen()
	local titleMatch = string.match(appTitle, "Task Switching") ~= nil or string.match(appTitle, "TaskSwitching") ~= nil
	myo.debug("Task Switching: "  .. tostring(titleMatch))
	return titleMatch;
end

function onPoseEdge(pose, edge)
	myo.debug("onPoseEdge: " .. pose)
	pose = conditionallySwapWave(pose)
	if (edge == "on") then
		if (pose == "thumbToPinky") then
			toggleLock()
		elseif (not locked and pose == "fingersSpread") then
			onFingersSpread()
		elseif (not locked and popupOpen()) then
			if (pose == "waveOut") then
				onWaveOut()
			elseif (pose == "waveIn") then
				onWaveIn()
			elseif (pose == "fist") then
				onFist()
			end
		elseif (not locked and pose == "rest" and not popupOpen()) then
			myo.debug("Dismiss alt button")
			myo.keyboard("left_alt","up")
		end
	end
end

function toggleLock()
	locked = not locked
	myo.vibrate("short")
	if (not locked) then
		-- Vibrate twice on unlock
		unlockedSince = myo.getTimeMilliseconds()
		myo.debug("Unlocked")
		myo.vibrate("short")
	else
		myo.debug("Locked")
	end
end

function onWaveOut()
	myo.debug("Next")
	myo.keyboard("tab", "press")
end

function onWaveIn()
	myo.debug("Previous")
	myo.keyboard("left_arrow", "press")
end

function onFist()
	myo.debug("Select")
	myo.keyboard("return", "press")
	myo.keyboard("left_alt", "press")
end

function onFingersSpread()
	myo.debug("Toggle popup")
	myo.keyboard("left_alt", "down", "left_alt")
	myo.keyboard("tab", "press")
end

function conditionallySwapWave(pose)
	if myo.getArm() == "left" then
		if pose == "waveIn" then
			pose = "waveOut"
		elseif pose == "waveOut" then
			pose = "waveIn"
		end
	end
	return pose
end


-- All timeouts in milliseconds.
-- Time since last activity before we lock
UNLOCKED_TIMEOUT = 22000

function onPeriodic()
    local now = myo.getTimeMilliseconds()
    -- Lock after inactivity
    if not locked then
        -- If we've been unlocked longer than the timeout period, lock.
        -- Activity will update unlockedSince, see extendUnlock() above.
        local timeSince = myo.getTimeMilliseconds() - unlockedSince
        if timeSince > UNLOCKED_TIMEOUT then
            locked = true
			myo.vibrate("short")
            myo.debug("lock due to inactivity:  "..timeSince)
        end
    end
end