--[[

original code author: Ilya Kolbin (iskolbin@gmail.com)
original code: github.com/iskolbin/lhsx

---------
MIT License
Copyright (c) 2018 Ilya Kolbin
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
---------

--]]


local min, max, abs = math.min, math.max, math.abs

function _rgb2hsv( r, g, b )
	local M, m = max( r, g, b ), min( r, g, b )
	local C = M - m
	local K = 1.0/(6.0 * C)
	local h = 0.0
	if C ~= 0.0 then
		if M == r then     h = ((g - b) * K) % 1.0
		elseif M == g then h = (b - r) * K + 1.0/3.0
		else               h = (r - g) * K + 2.0/3.0
		end
	end
	return h, M == 0.0 and 0.0 or C / M, M
end

-- wrapper for preparing arguments
function rgb2hsv( r, g, b )
	-- if passed Color or table in r
	if g == nil then
		if type(r) == "table" then
			g = r[2] or 0
			b = r[3] or 0
			r = r[1] or 0
		else
			g = r.g
			b = r.b
			r = r.r
		end
	end
	
	r = r / 255
	g = g / 255
	b = b / 255

	local h, s, v = _rgb2hsv(r, g, b);

	return h * 360, s, v
end

return rgb2hsv