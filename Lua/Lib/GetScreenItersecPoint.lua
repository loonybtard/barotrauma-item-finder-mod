

---@param From Vector2
---@param To Vector2
---@return number
local function GetDistance(From, To)
    return math.sqrt( math.pow(From.X - To.X, 2) + math.pow(From.Y - To.Y, 2) );
end

---@param Line1Start Vector2
---@param Line2End Vector2
---@param Line2Start Vector2
---@param Line2End Vector2
---@return Vector2|nil
local function CalcLinesItersecPoint(Line1Start, Line1End, Line2Start, Line2End)
	local a1 = Line2End.Y - Line2Start.Y;
	local b1 = Line2Start.X - Line2End.X;
	local c1 = -Line2Start.X * Line2End.Y + Line2Start.Y * Line2End.X;

	local a2 = Line1End.Y - Line1Start.Y;
	local b2 = Line1Start.X - Line1End.X;
	local c2 = -Line1Start.X * Line1End.Y + Line1Start.Y * Line1End.X;	

	return Vector2(
		(b1 * c2 - b2 * c1) / (a1 * b2 - a2 * b1), -- X
		(a2 * c1 - a1 * c2) / (a1 * b2 - a2 * b1)  -- Y
	);
end

---@param LineStart Vector2
---@param LineEnd Vector2
---@return Vector2|nil
local function GetScreenItersecPoint(LineStart, LineEnd)
	local ScreenSize = GUI.ReferenceResolution;
	local Point1, Point2 = nil;
	if LineEnd.X < 0 then
		Point1 = CalcLinesItersecPoint(
			Vector2(0, 0), Vector2(0, ScreenSize.Y),
			LineStart, LineEnd
		);
	end

	if LineEnd.X > ScreenSize.X then
		Point1 = CalcLinesItersecPoint(
			Vector2(ScreenSize.X, 0), Vector2(ScreenSize.X, ScreenSize.Y),
			LineStart, LineEnd
		);
	end

	if LineEnd.Y < 0 then
		Point2 = CalcLinesItersecPoint(
			Vector2(0, 0), Vector2(ScreenSize.X, 0),
			LineStart, LineEnd
		);
	end

	if LineEnd.Y > ScreenSize.Y then
		Point2 = CalcLinesItersecPoint(
			Vector2(0, ScreenSize.Y), Vector2(ScreenSize.X, ScreenSize.Y),
			LineStart, LineEnd
		);
	end


	if Point1 == nil and Point2 == nil then
		return nil;
	end

	if Point1 == nil then
		return Point2;
	end

	if Point2 == nil then
		return Point1;
	end

	if GetDistance(Point1, LineStart) < GetDistance(Point2, LineStart) then
		return Point1;
	else
		return Point2;
	end
end


return GetScreenItersecPoint;