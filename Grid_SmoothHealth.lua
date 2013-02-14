-- Port of oUF Smooth Update by Xuerian for Grid
-- http://www.wowinterface.com/downloads/info11503-oUFSmoothUpdate.html

if not Grid or not Grid.GetModule then
	return
end

local GridFrame = Grid:GetModule("GridFrame")

if not GridFrame then
	return
end

local smoothing = {}
local function Smooth(self, value)
	local _, max = self:GetMinMaxValues()
	if value == self:GetValue() or (self._max and self._max ~= max) then
		smoothing[self] = nil
		self:SetValue_(value)
	else
		smoothing[self] = value
	end
	self._max = max
end

local function SmoothBar(bar)
	if not bar.SetValue_ then
		bar.SetValue_ = bar.SetValue;
		bar.SetValue = Smooth;
	end
end

local function ResetBar(bar)
	if bar.SetValue_ then
		bar.SetValue = bar.SetValue_;
		bar.SetValue_ = nil;
	end
end

local f, min, max = CreateFrame('Frame'), math.min, math.max
f:SetScript('OnUpdate', function()
	local limit = 30/GetFramerate()
	for bar, value in pairs(smoothing) do
		local cur = bar:GetValue()
		local new = cur + min((value-cur)/3, max(value-cur, limit))
		if new ~= new then
			-- Mad hax to prevent QNAN.
			new = value
		end
		bar:SetValue_(new)
		if (cur == value or abs(new - value) < 2) then
			bar:SetValue_(value)
			smoothing[bar] = nil	
		end
	end
end)

local function InitializeFrame(self, frame)
	SmoothBar(frame.Bar)
end

hooksecurefunc(GridFrame, "InitializeFrame", InitializeFrame)
