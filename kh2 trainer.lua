PROCESS_NAME = "KINGDOM HEARTS II FINAL MIX.exe"

scanned = false
musicString = "62 67 6D 2F 6D 75 73 69 63 25 30 33 64 2E 77 69 6E 33 32 2E 73 63 64 00"
gummi1String = "76 61 67 73 74 72 65 61 6D 2F 47 4D 31 5F 41 73 74 65 72 6F 69 64 2E 77 69 6E 33 32 2E 73 63 64 00"
gummi2String = "76 61 67 73 74 72 65 61 6D 2F 47 4D 32 5F 48 69 67 68 77 61 79 2E 77 69 6E 33 32 2E 73 63 64 00"
gummi3String = "76 61 67 73 74 72 65 61 6D 2F 47 4D 33 5F 43 6C 6F 75 64 2E 77 69 6E 33 32 2E 73 63 64 00"
gummi4String = "76 61 67 73 74 72 65 61 6D 2F 47 4D 34 5F 46 6C 6F 61 74 69 6E 67 2E 77 69 6E 33 32 2E 73 63 64 00"
gummi5String = "76 61 67 73 74 72 65 61 6D 2F 47 4D 35 5F 53 65 6E 6B 61 6E 2E 77 69 6E 33 32 2E 73 63 64 00"
reportString = "76 61 67 73 74 72 65 61 6D 2F 45 6E 64 5F 50 69 61 6E 6F 2E 77 69 6E 33 32 2E 73 63 64 00"
titleString = "76 61 67 73 74 72 65 61 6D 2F 54 69 74 6C 65 2E 77 69 6E 33 32 2E 73 63 64 00"
bgmDefault = stringToByteTable("bgm")
bgmClassic = stringToByteTable("bg2")
bgmRemastered = stringToByteTable("bg3")
vagstreamDefault = stringToByteTable("vagstream")
vagstreamClassic = stringToByteTable("vagstrea2")
vagstreamRemastered = stringToByteTable("vagstrea3")

function writeDefaultMusic()
	writeBytes(musicAddress,bgmDefault)
	writeBytes(gummi1Address,vagstreamDefault)
	writeBytes(gummi2Address,vagstreamDefault)
	writeBytes(gummi3Address,vagstreamDefault)
	writeBytes(gummi4Address,vagstreamDefault)
	writeBytes(gummi5Address,vagstreamDefault)
	writeBytes(reportAddress,vagstreamDefault)
	writeBytes(titleAddress,vagstreamDefault)
end

function writeClassicMusic()
	writeBytes(musicAddress,bgmClassic)
	writeBytes(gummi1Address,vagstreamClassic)
	writeBytes(gummi2Address,vagstreamClassic)
	writeBytes(gummi3Address,vagstreamClassic)
	writeBytes(gummi4Address,vagstreamClassic)
	writeBytes(gummi5Address,vagstreamClassic)
	writeBytes(reportAddress,vagstreamClassic)
	writeBytes(titleAddress,vagstreamClassic)
end

function writeRemasteredMusic()
	writeBytes(musicAddress,bgmRemastered)
	writeBytes(gummi1Address,vagstreamRemastered)
	writeBytes(gummi2Address,vagstreamRemastered)
	writeBytes(gummi3Address,vagstreamRemastered)
	writeBytes(gummi4Address,vagstreamRemastered)
	writeBytes(gummi5Address,vagstreamRemastered)
	writeBytes(reportAddress,vagstreamRemastered)
	writeBytes(titleAddress,vagstreamRemastered)
end

function scanMusic()
	m = createMemScan()
	m.setOnlyOneResult(true)
	musicAddress = scanAOB(musicString, 0, 0xffffffffffffffff, m)
	gummi1Address = scanAOB(gummi1String, musicAddress, 0xffffffffffffffff, m)
	gummi2Address = scanAOB(gummi2String, gummi1, 0xffffffffffffffff, m)
	gummi3Address = scanAOB(gummi3String, gummi2, 0xffffffffffffffff, m)
	gummi4Address = scanAOB(gummi4String, gummi3, 0xffffffffffffffff, m)
	gummi5Address = scanAOB(gummi5String, gummi4, 0xffffffffffffffff, m)
	reportAddress = scanAOB(reportString, gummi5, 0xffffffffffffffff, m)
	titleAddress = scanAOB(titleString, reportAddress, 0xffffffffffffffff, m)
	m.destroy()
	scanned = true
end

function scanAOB(string, startAddress, endAddress, scanner)
	scanner.firstScan(soExactValue, vtByteArray, nil, string, nil, startAddress, endAddress, "*X*C*W", nil, nil , true, nil, nil, nil)
	scanner.waitTillDone()
	return scanner.getOnlyResult()
end

function lines_from(file)
	local lines = {}
	for line in io.lines(file) do
		lines[#lines + 1] = line
	end
	return lines
end

function loadHotkeys()
	lines = lines_from(TrainerOrigin .. "kh2config.txt")
	defaultHotkey = lines[2]:upper():gsub('%s+', '')
	classicHotkey = lines[4]:upper():gsub('%s+', '')
	remasteredHotkey = lines[6]:upper():gsub('%s+', '')
	UDF1.CELabel2.setCaption("Press " .. defaultHotkey .. " to change to the Custom Soundtrack")
	UDF1.CELabel3.setCaption("Press " .. classicHotkey .. " to change to the Classic Soundtrack")
	UDF1.CELabel4.setCaption("Press " .. remasteredHotkey .. " to change to the Remastered Soundtrack")
end

function loadSettings()
	settings=getSettings('KH2SoundtrackSwitcher')
	if #settings.Value['lastSelection'] == 0 then
		settings.Value['lastSelection'] = "Remastered"	
	end
	if #settings.Value['attachementSound'] == 0 then
		settings.Value['attachementSound'] = true	
	end
	lastSelection = settings.Value['lastSelection']
	attachementSound = settings.Value['attachementSound']
	UDF1.CELabel7.setCaption(lastSelection)
	UDF1.CECheckbox1.setState(attachementSound)
end

function attach(timer)
	if getProcessIDFromProcessName(PROCESS_NAME) ~= nil then
		timer.destroy()
		openProcess(PROCESS_NAME)
		scanMusic()
		if lastSelection == "Custom" then
			writeDefaultMusic()
		elseif lastSelection == "Classic" then
			writeClassicMusic()
		elseif lastSelection == "Remastered" then
			writeRemasteredMusic()
		end
		UDF1.CELabel1.setCaption("Attached")
		if attachementSound == "1" then
			sound = createMemoryStream()
			sound.loadFromFile(getCheatEngineDir() .. "sound.wav")
			playSound(sound)
		end
	end
end

function switch(timer)
	if scanned == true then
		if isKeyPressed(defaultHotkey) == true then
			writeDefaultMusic()
            UDF1.CELabel7.setCaption("Custom")
		elseif isKeyPressed(classicHotkey) == true then
			writeClassicMusic()
            UDF1.CELabel7.setCaption("Classic")
		elseif isKeyPressed(remasteredHotkey) == true then
			writeRemasteredMusic()
            UDF1.CELabel7.setCaption("Remastered")
		end
	end
end

function close(sender)
	settings.Value['lastSelection'] = UDF1.CELabel7.getCaption()
	settings.Value['attachementSound'] = UDF1.CECheckbox1.getState()
	MainForm.Close()
end

loadSettings()
loadHotkeys()
UDF1.setOnClose(close)
UDF1.Show()
timer = createTimer(MainForm)
timer.Interval = 100
timer.OnTimer = attach
keyTimer = createTimer(MainForm)
keyTimer.Interval = 100
keyTimer.OnTimer = switch
closeTimer = createTimer(MainForm)
closeTimer.Interval = 100
closeTimer.OnTimer = function(closeTimer)
	if scanned == true and getProcessIDFromProcessName(PROCESS_NAME) == nil then
		UDF1.Close()
	end
end
