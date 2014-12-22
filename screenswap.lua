scriptId = 'com.anotherlizwong.first.screenswap'
scriptTitle = "Screen Swapper"
scriptDetailsUrl = "https://github.com/anotherlizwong/MyoScripts"

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
		if pose == "fingersSpread" then
			onFingersSpread()
			elseif popupOpen() then
				if (pose == "waveOut") then
					onWaveOut()
			elseif (pose == "waveIn") then
				onWaveIn()
				elseif (pose == "fist") then
					onFist()
				end
	--Extend unlock and notify user
	myo.unlock("hold")
	myo.notifyUserAction()
	elseif pose == "rest" and not popupOpen() then
		myo.debug("Dismiss alt button")
		myo.keyboard("left_alt","up")
	end
	elseif edge =="off" then
		myo.unlock("timed")
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
