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
local listFont = gfx.font.new("font-pedallica-fun-14")
local listWidth = 105
local listHeight = displayHeight
local rowHeight = 17
local circleRadius = 105
local shapeTypes = {
	'circle',
	'filled',
	'swap front',
	'swap back'
}

-- -- -- -- VARIABLES -- -- -- -- 
local patternIndex = 1
local selectedPattern = menuOptions[patternIndex]
local inverted = false
local shapeIndex = 0
local mixPattern = nil
local hideListView = false
local drawingOffset = listWidth
local listViewNeedsDraw = false

-- -- -- -- SETUP -- -- -- -- 
playdate.display.setRefreshRate(20)
gfx.setFont(listFont)

local listView = playdate.ui.gridview.new(0, rowHeight)
local listViewBackground = gfx.image.new(listWidth, listHeight, gfx.kColorBlack)
listView.backgroundImage = listViewBackground
listView:setNumberOfRows(#menuOptions)
listView:setScrollDuration(0)
listView:setSelectedRow(2)

function listView:drawCell(section, row, column, selected, x, y, width, height)	
	if selected then
		gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
		
		if not hideListView then
			gfx.setColor(gfx.kColorWhite)
			gfx.fillRect(x, y, width, rowHeight)
		end

	else
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	end
	
	if not hideListView then
		gfx.drawTextInRect(menuOptions[row], x, y, width, height, nil, "...", kTextAlignment.center)
	end
end

-- -- -- -- UPDATE -- -- -- -- 
function playdate.update()
	if listView:getSelectedRow() ~= patternIndex then
		setPattern()
	end
	
	if listView.needsDisplay or listViewNeedsDraw then
		listView:drawInRect(displayWidth - drawingOffset, 0, listWidth, listHeight)
		listViewNeedsDraw = false
	end
	
	playdate.timer.updateTimers()
end

-- -- -- -- FUNCTIONS -- -- -- -- 
function setPattern()
	patternIndex = listView:getSelectedRow()
	selectedPattern = menuOptions[patternIndex]
	
	if inverted then
		selectedPattern = menuOptions[patternIndex] .. 'i'
	end
	
	setShape()
end

function setShape()
	if hideListView then
		drawingOffset = 0
		ellipseOffset = drawingOffset
	else
		drawingOffset = listWidth 
		ellipseOffset = drawingOffset - (circleRadius/2)
	end
	
	if shapeIndex%#shapeTypes == 0 then
		gfx.clear()
		gfxp.set(selectedPattern)
		gfx.fillCircleAtPoint((displayWidth/2) - ellipseOffset, 120, circleRadius)
	elseif shapeIndex%#shapeTypes == 1 then
		gfx.clear()
		gfxp.set(selectedPattern)
		gfx.fillRect(0, 0, displayWidth - drawingOffset, displayHeight)
	elseif shapeIndex%#shapeTypes == 2 then
		gfxp.set(mixPattern)
		gfx.fillRect(0, 0, displayWidth - drawingOffset, displayHeight)
		gfxp.set(selectedPattern)
		gfx.fillCircleAtPoint((displayWidth/2) - ellipseOffset, 120, circleRadius)
	elseif shapeIndex%#shapeTypes == 3 then
		gfxp.set(selectedPattern)
		gfx.fillRect(0, 0, displayWidth - drawingOffset, displayHeight)
		gfxp.set(mixPattern)
		gfx.fillCircleAtPoint((displayWidth/2) - ellipseOffset, 120, circleRadius)
	end
	
	drawInfoText()
end

function drawInfoText()
	if inverted then
		gfx.setColor(gfx.kColorWhite)
		gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
		
		gfx.fillRect(0, 221, 70, 20)
		
		local w = listFont:getTextWidth(shapeTypes[(shapeIndex + 1)])
		gfx.fillRect(0, -2, w + 12, 20)
		
		gfx.drawText(shapeTypes[(shapeIndex + 1)], 5, 1)
		gfx.drawText("inverted", 5, 223)
	else
		gfx.setColor(gfx.kColorBlack)
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		
		gfx.fillRect(0, 221, 62, 20)
		
		local w = listFont:getTextWidth(shapeTypes[(shapeIndex + 1)])
		gfx.fillRect(0, -2, w + 12, 20)
		
		gfx.drawText(shapeTypes[(shapeIndex + 1)], 5, 1)
		gfx.drawText("normal", 5, 223)
	end
end

-- -- -- -- INPUTS -- -- -- -- 
function playdate.upButtonDown()
	listView:selectPreviousRow(true, true, false)
	setPattern()
end

function playdate.downButtonDown()
	listView:selectNextRow(true, true, false)
	setPattern()
end

function playdate.rightButtonDown()
	hideListView = not hideListView
	listViewNeedsDraw = true
	setPattern()
end

function playdate.AButtonDown()
	inverted = not inverted
	listViewNeedsDraw = true
	setPattern()
end

function playdate.BButtonDown()
	shapeIndex += 1
	shapeIndex = shapeIndex%#shapeTypes
	
	if shapeIndex%#shapeTypes == 2 or shapeIndex%#shapeTypes == 3 then
		mixPattern = selectedPattern
	end
	
	listViewNeedsDraw = true
	setPattern()
end

function playdate.cranked(change, acceleratedChange)
	local t = playdate.getCrankTicks(10)
	
	if t == 1 then
		listView:selectNextRow(true)
		listViewNeedsDraw = true
		setPattern()
	elseif t == -1 then
		listView:selectPreviousRow(true)
		listViewNeedsDraw = true
		setPattern()
	end
end