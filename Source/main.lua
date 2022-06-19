-- -- -- -- PLAYDATE.STORE UUID -- -- -- -- 
print('app.uuid=f5fc580ddef34127b448d6bb20db88fc')

-- -- -- -- CORELIBS -- -- -- -- 
import 'CoreLibs/graphics'
import 'CoreLibs/object'
import 'CoreLibs/ui'
import 'CoreLibs/crank'

-- -- -- -- LIBRARIES -- -- -- -- 
import 'lib/gfxp'

-- -- -- -- CONSTANTS -- -- -- -- 
import 'options'
local gfx <const> = playdate.graphics
local gfxp <const> = GFXP
local displayWidth = playdate.display.getWidth()
local displayHeight = playdate.display.getHeight()
local listFont = gfx.font.new("assets/fonts/font-pedallica-fun-14")
local listWidth = 105
local listHeight = 70
local rowHeight = 17
local circleRadius = 105
local shapeTypes = {
	'circle',
	'fill',
	'swap front',
	'swap back'
}
local colorTypes = {
	'normal',
	'inverted'
}

-- -- -- -- VARIABLES -- -- -- -- 
local patternIndex = 1
local selectedPattern = menuOptions[patternIndex]
local patternInverted = false
local shapeIndex = 0
local colorIndex = 0
local mixPattern = nil
local listViewDisplay = false
local listViewNeedsDraw = false
local controlsDisplay = true
local controlsColorInverted = false

-- -- -- -- MENU -- -- -- -- 
local pauseMenu = playdate.getSystemMenu()
local showUI, error = pauseMenu:addCheckmarkMenuItem("Show UI", true, function(value)
		if value then
			showControls(true)
		else
			showControls(false)
		end
		
		listViewNeedsDraw = true
		setPattern()
end)
local invertUI, error = pauseMenu:addCheckmarkMenuItem("Invert UI", false, function(value)
		if value then
			invertControlsColor(true)
		else
			invertControlsColor(false)
		end
		
		listViewNeedsDraw = true
		setPattern()
end)

-- -- -- -- SETUP -- -- -- -- 
playdate.display.setRefreshRate(45)
gfx.setStrokeLocation(gfx.kStrokeOutside)
gfx.setLineWidth(2)
gfx.setFont(listFont)

local clickSFX = playdate.sound.synth.new(playdate.sound.kWaveNoise)
clickSFX:setADSR(0, 0.007, 0, 0)
clickSFX:setVolume(0.5)

local selectSFX = playdate.sound.synth.new(playdate.sound.kWaveTriangle)
selectSFX:setADSR(0.004, 0.005, 0, 0)
selectSFX:setVolume(0.8)

local listView = playdate.ui.gridview.new(0, rowHeight)
local listViewBackground = gfx.image.new(listWidth, listHeight, gfx.kColorBlack)
listView.backgroundImage = listViewBackground
listView:setNumberOfRows(#menuOptions)
listView:setScrollDuration(0)
listView:setSelectedRow(2)

function listView:drawCell(section, row, column, selected, x, y, width, height)	
	if selected then
		if listViewDisplay and controlsColorInverted then
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			gfx.setColor(gfx.kColorBlack)
		elseif listViewDisplay then
			gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
			gfx.setColor(gfx.kColorWhite)
		end
	else
		if controlsColorInverted then
			gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
			gfx.setColor(gfx.kColorWhite)
		else
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			gfx.setColor(gfx.kColorBlack)
		end
	end
		
	gfx.fillRect(x, y, width, rowHeight)
	
	if listViewDisplay then
		local text = menuOptions[row]
		if patternInverted then
			text = menuOptions[row] .. 'i'
		end
			
		gfx.drawTextInRect(text, x, y, width, height, nil, "...", kTextAlignment.center)
	end
end

-- -- -- -- UPDATE -- -- -- -- 
function playdate.update()
	if listView:getSelectedRow() ~= patternIndex or listViewNeedsDraw then
		setPattern()
	end
	
	if listView.needsDisplay or listViewNeedsDraw then
		if listViewDisplay then
			drawListBackground()
			listView:drawInRect(0, displayHeight - listHeight, listWidth, listHeight)
			listViewNeedsDraw = false
		end
	end
	
	playdate.timer.updateTimers()
end

-- -- -- -- FUNCTIONS -- -- -- -- 
function setPattern()
	patternIndex = listView:getSelectedRow()
	selectedPattern = menuOptions[patternIndex]
	
	if patternInverted then
		selectedPattern = menuOptions[patternIndex] .. 'i'
	end
	
	setShape()
end

function setShape()	
	if shapeIndex%#shapeTypes == 0 then
		gfx.clear()
		gfxp.set(selectedPattern)
		gfx.fillCircleAtPoint((displayWidth/2), 120, circleRadius)
	elseif shapeIndex%#shapeTypes == 1 then
		gfx.clear()
		gfxp.set(selectedPattern)
		gfx.fillRect(0, 0, displayWidth, displayHeight)
	elseif shapeIndex%#shapeTypes == 2 then
		gfxp.set(mixPattern)
		gfx.fillRect(0, 0, displayWidth, displayHeight)
		gfxp.set(selectedPattern)
		gfx.fillCircleAtPoint((displayWidth/2), 120, circleRadius)
	elseif shapeIndex%#shapeTypes == 3 then
		gfxp.set(selectedPattern)
		gfx.fillRect(0, 0, displayWidth, displayHeight)
		gfxp.set(mixPattern)
		gfx.fillCircleAtPoint((displayWidth/2), 120, circleRadius)
	end
	
	if controlsDisplay then
		drawInfoText()
	end
end

function drawInfoText()
	if controlsColorInverted then
		gfx.setColor(gfx.kColorWhite)
		gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
	else
		gfx.setColor(gfx.kColorBlack)
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	end
	
	-- UI boxes fill
	local shapeTextWidth = listFont:getTextWidth(shapeTypes[(shapeIndex + 1)])
	local colorTextWidth = listFont:getTextWidth(colorTypes[(colorIndex + 1)])
	gfx.fillRect(displayWidth - shapeTextWidth - 27, 0, shapeTextWidth + 30, 22)
	gfx.fillRect(displayWidth - colorTextWidth - 27, 218, colorTextWidth + 31, 22)
		
	-- UI text
	gfx.drawText(shapeTypes[(shapeIndex + 1)], displayWidth - shapeTextWidth - 3, 3)
	gfx.drawText("Ⓑ", displayWidth - shapeTextWidth - 25, 2)
	gfx.drawText(colorTypes[(colorIndex + 1)], displayWidth - colorTextWidth - 3, 222)
	gfx.drawText("Ⓐ", displayWidth - colorTextWidth - 25, 220)
	
	if controlsColorInverted then
		gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
	else
		gfx.setImageDrawMode(gfx.kDrawModeNXOR)
	end
	
	-- UI D-Pad
	if not listViewDisplay then
		gfx.fillRect(0, 218, 22, 22)
		gfx.drawText("⬅️", 1, 219)
	end
	
	-- UI boxes outlines
	if controlsColorInverted then
		gfx.setColor(gfx.kColorBlack)
	else
		gfx.setColor(gfx.kColorWhite)
	end
	gfx.drawRect(displayWidth - shapeTextWidth - 27, 0, shapeTextWidth + 30, 22)
	gfx.drawRect(displayWidth - colorTextWidth - 27, 218, colorTextWidth + 31, 22)
	gfx.drawRect(0, 218, 22, 22)
end

function drawListBackground()
	if controlsColorInverted then
		gfx.setColor(gfx.kColorBlack)
	else
		gfx.setColor(gfx.kColorWhite)
	end
	
	gfx.drawRect(0, displayHeight - listHeight, listWidth, listHeight)
end

function showControls(flag)
	controlsDisplay = flag
end

function invertControlsColor(flag)
	controlsColorInverted = flag
end

function playListSFX(pitch)
	clickSFX:playNote(pitch)
end

function playClickSFX()
	clickSFX:playNote(420)
end

function playColorSFX()
	selectSFX:playNote(320)
end

function playStyleSFX()
	selectSFX:playNote(390)
end

-- -- -- -- INPUTS -- -- -- -- 
function playdate.upButtonDown()
	listView:selectPreviousRow(true, true, false)
	playListSFX(1700)
	setPattern()
end

function playdate.downButtonDown()
	listView:selectNextRow(true, true, false)
	playListSFX(1100)
	setPattern()
end

function playdate.leftButtonDown()
	listViewDisplay = not listViewDisplay
	listViewNeedsDraw = true
	
	playClickSFX()
	setPattern()
end

function playdate.AButtonDown()
	colorIndex += 1
	colorIndex = colorIndex%#colorTypes
	
	patternInverted = not patternInverted -- don't need this
	listViewNeedsDraw = true
	
	playColorSFX()
	setPattern()
end

function playdate.BButtonDown()
	shapeIndex += 1
	shapeIndex = shapeIndex%#shapeTypes
	
	if shapeIndex%#shapeTypes == 2 or shapeIndex%#shapeTypes == 3 then
		mixPattern = selectedPattern
	end
	
	listViewNeedsDraw = true
	
	playStyleSFX()
	setPattern()
end

function playdate.cranked(change, acceleratedChange)
	local t = playdate.getCrankTicks(9)
	
	if t == 1 then
		listView:selectNextRow(true)
		listViewNeedsDraw = true
		
		playListSFX(1700)
		setPattern()
	elseif t == -1 then
		listView:selectPreviousRow(true)
		listViewNeedsDraw = true
		
		playListSFX(1100)
		setPattern()
	end
end

