local math_min, math_max, math_floor, math_ceil, math_sqrt, math_tan, math_rad
    = math.min, math.max, math.floor, math.ceil, math.sqrt, math.tan, math.rad


local MIN_CONE_FOOT_DIAMETER = 3

--- @param diameter number
--- @return number[][]
local function fill_with_zeroes(diameter)
	local map = {}
	for i = 1, diameter do
		map[i] = {}
		for j = 1, diameter do  map[i][j] = 0  end
	end

	return map
end

--- Generate mountain as cone
--- @param top_pos Position
--- @param config  table
--- @return table, number, number "height map, map size, center_coordinate"
mountgen.cone = function(top_pos, config)
	local H = top_pos.y - config.Y0                        -- height of truncated cone
	local W = 2 * (config.TOP_RADIUS + math_ceil(          -- width (diameter) of cone foot
		H * math_tan( math_rad(90 - config.ANGLE) )
	))

	local diameter = math_max(W, MIN_CONE_FOOT_DIAMETER)
	local radius   = diameter / 2
	local height   = math_ceil( radius * math_tan( math_rad(config.ANGLE) ) )  -- height of full cone (not truncated)

	local height_map_size   = math_min(W, 2 * config.MAX_RADIUS)
	local height_map_radius = math_floor(height_map_size / 2)
	local height_map        = fill_with_zeroes(height_map_size)

	local l0 = math_sqrt(radius^2 + radius^2)

	for z = 0, height_map_size - 1 do
		for x = 0, height_map_size - 1 do
			local px = x - height_map_radius
			local pz = z - height_map_radius

			local l  = math_sqrt(px^2 + pz^2)
			if l <= height_map_radius then
				local h  = height * (1 - 2 * l / l0)
				mountgen.set_value(height_map, z, x, math_min(h, H))
			end
		end
	end

	return height_map, height_map_size, height_map_radius
end
