-- Repeatable random numbers from integer coordinates and the world seed.

local bxor, band, rshift, lshift, tobit = bit.bxor, bit.band, bit.rshift, bit.lshift, bit.tobit

-- The seed is a 64 bit number given as a string. 31 bits of it are enough
-- here, and they survive the conversion to a Lua number.
local seed = (tonumber(core.get_mapgen_setting("seed")) or 0) % 2147483648
wl_world.seed = seed

-- 32 bit multiplication without leaving the exact range of Lua numbers.
local function mul(a, b)
	local lo = band(a, 0xffff) * b
	local hi = tobit(rshift(a, 16) * b)
	return tobit(lo + lshift(hi, 16) * 1)
end

-- Returns a number in [0, 1) for the integers i, j and salt.
function wl_world.hash(i, j, salt)
	local h = bxor(tobit(seed), mul(tobit(i), 0x27d4eb2d), mul(tobit(j), 0x165667b1),
		mul(tobit(salt), 0x9e3779b1))
	h = mul(bxor(h, rshift(h, 15)), 0x2c1b3c6d)
	h = mul(bxor(h, rshift(h, 12)), 0x297a2d39)
	h = bxor(h, rshift(h, 15))
	return (h % 4294967296) / 4294967296
end

-- Smooth step from 0 to 1 while t runs from 0 to 1.
function wl_world.smooth(t)
	if t <= 0 then return 0 end
	if t >= 1 then return 1 end
	return t * t * (3 - 2 * t)
end
