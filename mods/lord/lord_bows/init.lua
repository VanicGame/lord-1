-- lord bows

dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/entities_projectiles.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/mechanics_throwing.lua")


local function register_bow(name, def)
	local wield_scale = {x = 2, y = 2, z = 0.75}

	minetest.register_tool(name, {
	range = 1,
		description = def.desc,
		wield_scale = wield_scale,
		inventory_image = def.inventory_image..".png",
		wield_image = def.inventory_image..".png",
		tool_capabilities = def.tool_capabilities,
		groups = def.groups,
	})

	minetest.register_tool(name.."_2", {
		description = def.desc,
		range = 0,
		wield_scale = wield_scale,
		inventory_image = def.inventory_image.."_2.png",
		wield_image = def.inventory_image.."_2.png",
		tool_capabilities = def.tool_capabilities,
		groups = def.groups,
	})

	minetest.register_tool(name.."_3", {
		description = def.desc,
		range = 0,
		wield_scale = wield_scale,
		inventory_image = def.inventory_image.."_3.png",
		wield_image = def.inventory_image.."_3.png",
		tool_capabilities = def.tool_capabilities,
		groups = def.groups,
		})

	minetest.register_tool(name.."_4", {
		description = def.desc,
		range = 0,
		wield_scale = wield_scale,
		inventory_image = def.inventory_image.."_4.png",
		wield_image = def.inventory_image.."_4.png",
		tool_capabilities = def.tool_capabilities,
		groups = def.groups,
	})
end

register_bow("lord_bows:bow_wooden", {
	desc = "Wooden bow",
	inventory_image = "items_tools_bow_wooden", -- указывается без .png
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level = 0,
		groupcaps = {
			crumbly = {
			times={[1]=3.00, [2]=1.60, [3]=0.60},
			uses=10,
			maxlevel=1
		},
		},
		damage_groups = {fleshy=2},
	},
	groups = {wooden = 1, bow = 1},
})

minetest.register_craftitem("lord_bows:arrow", {
	description = "Arrow",
	inventory_image = "items_tools_arrow.png",
	groups = {projectiles = 1, arrow = 1},
	stack_max = 99
})
