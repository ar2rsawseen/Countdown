--[[
*************************************************************
* This script is developed by Arturs Sosins aka ar2rsawseen, http://appcodingeasy.com
* Feel free to distribute and modify code, but keep reference to its creator
*
* Gideros Countdown class displays (and updates) time left provided by user. 
* Time can be provided in any time units, and they will be recalculated 
* to specified time units. It is possible to specify which units or 
* text will appear in countdown and which text must be hidden 
* if certain unit reaches 0 by using textfields for each time unit.
*
* For more information, examples and online documentation visit: 
* http://appcodingeasy.com/Gideros-Mobile/Countdown-for-Gideros-Mobile
**************************************************************
]]--

local function is_leap_year(year)
	if (math.mod(year,4) == 0) then
		if (math.mod(year,100) == 0)then                
			if (math.mod(year,400) == 0) then                    
				return 2
			end
		else                
			return 2
		end
    end
	return 1
end

--place leading zeros
local function lead_zeros(num)
	local ret = num
	if num < 10 then
		ret = "0"..num
	end
	return ret
end

local function output(span, label, mark, leading)
	if not leading then leading = false end
	if(span.used and label ~= nil) then
		if(span.template ~= "") then
			if(leading) then
				label:setText(span.template:gsub(mark, lead_zeros(span.value)))
			else
				label:setText(span.template:gsub(mark, span.value));
			end
		else
			if(leading)then
				label:setText(lead_zeros(span.value));
			else
				label:setText(span.value);
			end
		end
	end
end

--check if countdown ended
local function is_ended(abr)
	local is_zero = true
	for i in pairs(abr) do
		if(abr[i].used and abr[i].value < 0) then
			return true
		end
		if(abr[i].value > 0) then
			is_zero = false;
		end
	end
	return is_zero
end

--countdown class
Countdown = gideros.class(Sprite)

--initialize
function Countdown:init(config)
	self.timer = Timer.new(1000)
	self.timer:addEventListener(Event.TIMER, function()
		self:update()
	end)
	
	self.conf = {
		--specified timestamp
		time = 0,
		--time
		year = 0,
		month = 0,
		week = 0,
		day = 0,
		hour = 0,
		min = 0,
		sec = 0,
		--labels
		label_year = nil,
		label_month = nil,
		label_week = nil,
		label_day = nil,
		label_hour = nil,
		label_min = nil,
		label_sec = nil,
		--end label
		label_end = nil,
		--settings
		hide_zeros = true,
		leading_zeros = true,
		onend = nil,
		onstep = nil
	}
	
	if config then
		--copying configuration
		for key,value in pairs(config) do
			self.conf[key] = value
		end
	end

	self.offset = false
	self.abr = {
		y = {name = "year", used = false, value = 0, template=""},
		m = {name = "month", used = false, value = 0, template=""},
		w = {name = "week", used = false, value = 0, template=""},
		d = {name = "day", used = false, value = 0, template=""},
		h = {name = "hour", used = false, value = 0, template=""},
		i = {name = "min", used = false, value = 0, template=""},
		s = {name = "sec", used = false, value = 0, template=""}
	}
	self.months = {
		{31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31},
		{31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
	}
	
	for i in pairs(self.abr) do
		if(self.conf["label_"..self.abr[i].name] ~= nil) then
			self:addChild(self.conf["label_"..self.abr[i].name])
			self.abr[i].used = true
			if(self.conf["label_"..self.abr[i].name]:getText():find("{"..i.."}") ~= nil) then
				self.abr[i].template = self.conf["label_"..self.abr[i].name]:getText()
				self.conf["label_"..self.abr[i].name]:setText("")
			end
		end
	end
	if self.conf.label_end ~= nil then
		self.conf.label_end:setVisible(false)
		self:addChild(self.conf.label_end)
	end
	if(self.conf.time > 0) then
		--self.conf.sec = self.conf.time - os.timer()
		self.conf.sec = os.difftime( self.conf.time, os.time() )
	end
	self:normalize()
	self:recalc()
	self:update()
	self:start()
end

--start countdown
function Countdown:start()
	if not self.started then
		self.started = true
		self.timer:start()
	end
end

--stop countdown
function Countdown:stop()
	if self.started then
		self.started = false
		self.timer:stop()
	end
end

--update countdown elements
function Countdown:update()
	self.conf.sec = self.conf.sec - 1
	if(self.conf.sec == -1) then
		self.conf.min = self.conf.min - 1
		self.conf.sec = 59
	end
	if(self.conf.min == -1) then
		self.conf.hour = self.conf.hour - 1
		self.conf.min = 59
	end
	if(self.conf.hour == -1) then
		self.conf.day = self.conf.day - 1
		self.conf.hour = 23
	end
	if(self.conf.day == -1) then
		self.conf.week = self.conf.week - 1
		self.conf.day = 6
	end
	if(self.conf.week == -1) then
		self.conf.month = self.conf.month - 1
		local d = os.date("*t")
		local month = d.month
		local year = d.year
		if(not self.offset) then
			month = month + 1
			if(month > 12) then
				year = year + 1
				month = 1
			end
		end
		local days = self.months[is_leap_year(year)][month]-1;
		self.conf.week = math.floor(days/7);
		self.conf.day = days % 7;
	end
	if(self.conf.month == -1) then
		self.conf.year = self.conf.year - 1;
		self.conf.month = 11;
	end
	self:recalc();
	if(self.conf.onstep) then
		self.conf.onstep(self:getSeconds());
	end
	output(self.abr.y, self.conf.label_year, "{y}");
	output(self.abr.m, self.conf.label_month, "{m}");
	output(self.abr.w, self.conf.label_week, "{w}");
	output(self.abr.d, self.conf.label_day, "{d}");
	output(self.abr.h, self.conf.label_hour, "{h}", self.conf.leading_zeros);
	output(self.abr.i, self.conf.label_min, "{i}", self.conf.leading_zeros);
	output(self.abr.s, self.conf.label_sec, "{s}", self.conf.leading_zeros);
	if(self.conf.hide_zeros) then
		local hide = true;
		if(self.abr.y.used) then
			if(self.abr.y.value <= 0 and hide) then
				self.conf.label_year:setVisible(false)
			else
				hide = false;
			end
		end
		if(self.abr.m.used) then
			if(self.abr.m.value <= 0 and hide) then
				self.conf.label_month:setVisible(false);
			else
				hide = false;
			end
		end
		if(self.abr.w.used) then
			if(self.abr.w.value <= 0 and hide) then
				self.conf.label_week:setVisible(false);
			else
				hide = false;
			end
		end
		if(self.abr.d.used) then
			if(self.abr.d.value <= 0 and hide) then
				self.conf.label_day:setVisible(false);
			else
				hide = false;
			end
		end
		if(self.abr.h.used) then
			if(self.abr.h.value <= 0 and hide) then
				self.conf.label_hour:setVisible(false);
			else
				hide = false;
			end
		end
		if(self.abr.i.used) then
			if(self.abr.i.value <= 0 and hide) then
				self.conf.label_min:setVisible(false);
			else
				hide = false;
			end
		end
		if(self.abr.s.used) then
			if(self.abr.s.value <= 0 and hide) then
				self.conf.label_sec:setVisible(false);
			else
				hide = false;
			end
		end
	end
	if(is_ended(self.abr)) then
		for i in pairs(self.abr) do
			if(self.abr[i].used) then
				self.conf["label_"..self.abr[i].name]:setVisible(false);
			end
		end
		if(self.conf.label_end ~= nil) then
			self.conf.label_end:setVisible(true);
		end
		self:stop()
		if(self.conf.onend) then
			self.conf.onend();
		end
	end
end

--how much seconds left
function Countdown:getSeconds()
	local arr = {}
	for i in pairs(self.abr) do
		arr[i] = {};
		arr[i].value = self.conf[self.abr[i].name]
	end
	
	arr.m.value = arr.m.value + (arr.y.value*12)
	local d = os.date("*t")
	local month = d.month
	local year = d.year
	if(not self.offset) then
		month = month + 1;
		if(month > 12) then
			year = year + 1;
			month = 1;
		end
	end
	
	for i = 1, arr.m.value do
		arr.d.value = arr.d.value + self.months[is_leap_year(year)][month]
		month = month + 1
		if(month > 12) then
			year = year + 1;
			month = 1;
		end
	end
	
	arr.d.value = arr.d.value + (arr.w.value*7)
	arr.h.value = arr.h.value + (arr.d.value*24)
	arr.i.value = arr.i.value + (arr.h.value*60)
	arr.s.value = arr.s.value + (arr.i.value*60)
	return arr.s.value
end

function Countdown:normalize()
	self.conf.min = self.conf.min + math.floor(self.conf.sec/60);
	self.conf.sec = self.conf.sec % 60;
	
	self.conf.hour = self.conf.hour + math.floor(self.conf.min/60);
	self.conf.min = self.conf.min % 60;
	
	self.conf.day = self.conf.day + math.floor(self.conf.hour/24);
	self.conf.hour = self.conf.hour % 24;
	
	self.conf.day = self.conf.day + self.conf.week*7;
	self.conf.week = 0;
	
	local d = os.date("*t")
	local month = d.month
	local year = d.year
	local date = d.day
	local leftover = self.months[is_leap_year(year)][month] - date
	local temp;
	if(self.conf.day > leftover) then
		self.conf.day = self.conf.day - leftover
		repeat
			month = month + 1;
			if(month > 12) then
				year = year + 1
				month = 1
			end
			temp = self.conf.day - self.months[is_leap_year(year)][month]
			if(temp >= 0) then
				self.conf.month = self.conf.month + 1;
				if(self.conf.month > 12) then
					self.conf.year = self.conf.year + 1;
					self.conf.month = 1;
				end
				self.conf.day = temp;
			end
		until(temp > 0)
		
		if(self.conf.day >= date) then
			self.conf.day = self.conf.day - date;
			self.conf.month = self.conf.month + 1;
			self.offset = true;
		else
			self.conf.day = self.conf.day + leftover;
		end
		self.conf.week = self.conf.week + math.floor(self.conf.day/7)
		self.conf.day = self.conf.day % 7
	end
	
	self.conf.year = self.conf.year + math.floor(self.conf.month/12)
	self.conf.month = self.conf.month % 12
end

function Countdown:recalc()
	for i, value in pairs(self.abr) do
		self.abr[i].value = self.conf[self.abr[i].name];
	end
	if(not self.abr.y.used) then
		self.abr.m.value = self.abr.m.value + (self.abr.y.value*12);
		self.abr.y.value = 0;
	end
	if(not self.abr.m.used) then
		local d = os.date("*t")
		local month = d.month
		local year = d.year
		if(not self.offset) then
			month = month + 1;
			if(month > 12) then
				year = year + 1;
				month = 1;
			end
		end

		for i = 1, self.abr.m.value do
			self.abr.d.value = self.abr.d.value + self.months[is_leap_year(year)][month];
			month = month + 1;
			if(month > 12) then
				year = year + 1;
				month = 1;
			end
		end
		self.abr.m.value = 0;
	end

	if(not self.abr.w.used) then
		self.abr.d.value = self.abr.d.value + (self.abr.w.value*7);
		self.abr.w.value = 0;
	else
		self.abr.w.value = self.abr.w.value + math.floor(self.abr.d.value/7);
		self.abr.d.value = self.abr.d.value % 7;
	end
	if(not self.abr.d.used)then
		self.abr.h.value = self.abr.h.value + (self.abr.d.value*24);
		self.abr.d.value = 0;
	end
	if(not self.abr.h.used)then
		self.abr.i.value = self.abr.i.value + (self.abr.h.value*60);
		self.abr.h.value = 0;
	end
	if(not self.abr.i.used) then
		self.abr.s.value = self.abr.s.value + (self.abr.i.value*60);
		self.abr.i.value = 0;
	end
	if(not self.abr.s.used) then
		self.abr.s.value = 0;
	end
end