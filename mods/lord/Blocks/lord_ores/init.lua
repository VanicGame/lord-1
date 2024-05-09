local S = minetest.get_translator("lord_ores")

local mod_path    = minetest.get_modpath(minetest.get_current_modname())
dofile(mod_path .. "/rock_ores.lua")

minetest.register_node("lord_ores:magma", {
	description       = S("Magma"),
	groups            = { rock = 1, cracky = 2, },
	paramtype         = "light",
	light_source      = 4,
	sounds            = default.node_sound_stone_defaults(),
	tiles             = {
		{
			name      = "lord_ores_magma.png",
			animation = {
				type     = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length   = 1.5
			}
		}
	},
})
