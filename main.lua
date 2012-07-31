
--you need to create text field 
--where to output specific units
local seconds = TextField.new(nil, "")
seconds:setPosition(20, 120)

--you can provide some text with time unit
--which will be hidden when unit reaches zero
local minutes = TextField.new(nil, "somet text here {i} and there")
minutes:setPosition(20, 100)

--you can use font with your countdown
local tahoma = TTFont.new("tahoma.ttf", 15)
local hours = TextField.new(tahoma, "{h} hours left")
hours:setPosition(20, 80)

--you can also use TextWrap class
local days = TextWrap.new("{d} days left", 320, "center")
days:setPosition(0, 60)

--you don't need to use all possible time units
--if you don't use one, it will be 
--automatically recalculated to lower ones
--local weeks = TextField.new(nil, "{w} weeks left")
--weeks:setPosition(20, 40)

--add other possible time units are months and years
local months = TextField.new(nil, "{m} months left")
months:setPosition(20, 20)

local years = TextField.new(nil, "{y} years left")
years:setPosition(20, 0)


--textfield, or sprite or anything 
--that is hidden and can be made visible using
--setVisible(true) method when countdown ends
local ended = TextField.new(nil, "Countdown Ended")
ended:setPosition(20, 120)


--create coutndown
local cd = Countdown.new({

	--time to specific timestamp
	--time = 1639324800
	
	--or provide time left
	year = 1,
	month = 0,
	week = 0,
	day = 0,
	hour = 0,
	min = 0,
	sec = 10,
	
	--textfields where to output countdown
	label_sec = seconds,
	label_min = minutes,
	label_hour = hours,
	label_day = days,
	--label_week = weeks,
	label_month = months,
	label_year = years,
	
	--TextField to show when countdown ended
	label_end = ended,
	--hide ended units
	hide_zeros = true,
	--use leading zeros for hours, minutes and seconds
	leading_zeros = true,
	--callback function on countdown end
	onend = function() print("Ended") end,
	--callback function on each coutndown step
	--provides seconds left till end of countdown
	onstep = function(seconds) print(seconds) end
})

cd:setPosition(0,10)
stage:addChild(cd)