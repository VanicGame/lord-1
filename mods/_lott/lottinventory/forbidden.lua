-- zfc mod for minetest
-- See README for more information
-- Released by Zeg9 under WTFPL

local SL = lord.require_intllib()

zfc = {}
zfc.users = {}
zfc.crafts = {}
zfc.itemlist = {}

zfc.items_in_group = function(group)
	local items = {}

	for name, item in pairs(minetest.registered_items) do
		-- the node should be in all groups
		local ok = true
		for _, g in ipairs(group:split(',')) do
			if not item.groups[g] then
				ok = false
			end
		end
		if ok then table.insert(items,name) end
	end

	return items
end

local table_copy = function(table)
	local out = {}
	for k,v in pairs(table) do
		out[k] = v
	end
	return out
end

zfc.add_craft = function(input, output, groups)
	if minetest.get_item_group(output, "forbidden") > 0 then
	if not groups then groups = {} end
	local c = {}
	c.width = input.width
	c.type = input.type
	c.items = input.items
	if c.items == nil then return end
	for i, item in pairs(c.items) do
		if item:sub(0,6) == "group:" then
			local groupname = item:sub(7)
			if groups[groupname] ~= nil then
				c.items[i] = groups[groupname]
			else
				for _, gi in ipairs(zfc.items_in_group(groupname)) do
					local g2 = groups
					g2[groupname] = gi
					zfc.add_craft({
						width = c.width,
						type = c.type,
						items = table_copy(c.items)
					}, output, g2) -- it is needed to copy the table, else groups won't work right
				end
				return
			end
		end
	end
	if c.width == 0 then c.width = 3 end
	table.insert(zfc.crafts[output],c)
end
end

zfc.load_crafts = function(name)
	zfc.crafts[name] = {}
	local _recipes = minetest.get_all_craft_recipes(name)
	if _recipes then
		for i, recipe in ipairs(_recipes) do
			if (recipe and recipe.items and recipe.type) then
				zfc.add_craft(recipe, name)
			end
		end
	end
	if zfc.crafts[name] == nil or #zfc.crafts[name] == 0 then
		zfc.crafts[name] = nil
	else
		table.insert(zfc.itemlist,name)
	end
end

zfc.need_load_all = true

zfc.load_all = function()
	print("Loading all crafts, this may take some time...")
	local i = 0
	for name, item in pairs(minetest.registered_items) do
		if (name and name ~= "") then
			zfc.load_crafts(name)
		end
		i = i+1
	end
	table.sort(zfc.itemlist)
	zfc.need_load_all = false
	print("All crafts loaded !")
end

zfc.formspec = function(pn)
	if zfc.need_load_all then zfc.load_all() end
	local page = zfc.users[pn].page
	local alt = zfc.users[pn].alt
	local current_item = zfc.users[pn].current_item
	local formspec = "size[8,7.5]"
		.. "listcolors[#606060AA;#888;#14F318;#30434C;#FFF]"
		.. "button_exit[6,7;2,0.5;;"..SL("Exit").."]"
	if zfc.users[pn].history.index > 1 then
		formspec = formspec .. "image_button[0,1;1,1;zcg_previous.png;zfc_previous;;false;false;zcg_previous_press.png]"
	else
		formspec = formspec .. "image[0,1;1,1;zcg_previous_inactive.png]"
	end
	if zfc.users[pn].history.index < #zfc.users[pn].history.list then
		formspec = formspec .. "image_button[1,1;1,1;zcg_next.png;zfc_next;;false;false;zcg_next_press.png]"
	else
		formspec = formspec .. "image[1,1;1,1;zcg_next_inactive.png]"
	end
	-- Show craft recipe
	if current_item ~= "" then
		if zfc.crafts[current_item] then
			if alt > #zfc.crafts[current_item] then
				alt = #zfc.crafts[current_item]
			end
			if alt > 1 then
				formspec = formspec .. "button[7,0;1,1;zfc_alt:"..(alt-1)..";^]"
			end
			if alt < #zfc.crafts[current_item] then
				formspec = formspec .. "button[7,2;1,1;zfc_alt:"..(alt+1)..";v]"
			end
			local c = zfc.crafts[current_item][alt]
			if c then
				local x = 3
				local y = 0
				for i, item in pairs(c.items) do
					formspec = formspec ..
						"item_image_button[" ..
							((i - 1) % c.width + x) .. "," .. (math.floor((i - 1) / c.width + y)) .. ";" ..
							"1,1;" ..
							item .. ";" ..
							"zfc:" .. item .. ";" ..
						"]"
				end
				if c.type == "normal" or c.type == "cooking" then
					formspec = formspec .. "image[6,2;1,1;zcg_method_"..c.type..".png]"
				else -- we don't have an image for other types of crafting
					formspec = formspec .. "label[0,2;Method: "..c.type.."]"
				end
				formspec = formspec .. "image[6,1;1,1;zcg_craft_arrow.png]"
				formspec = formspec .. "item_image_button[7,1;1,1;"..zfc.users[pn].current_item..";;]"
			end
		end
	end

	-- Node list
	local npp = 8*3 -- nodes per page
	local i = 0 -- for positionning buttons
	local s = 0 -- for skipping pages
	for _, name in ipairs(zfc.itemlist) do
		if s < page*npp then s = s+1 else
			if i >= npp then break end
			formspec = formspec ..
				"item_image_button["..(i%8)..","..(math.floor(i/8)+3.5)..";1,1;"..name..";zfc:"..name..";]"
			i = i+1
		end
	end
	if page > 0 then
		formspec = formspec .. "button[0,7;1,.5;zfc_page:"..(page-1)..";<<]"
	end
	if i >= npp then
		formspec = formspec .. "button[1,7;1,.5;zfc_page:"..(page+1)..";>>]"
	end
	-- The Y is approximatively the good one to have it centered vertically...
	formspec = formspec .. "label[2,6.85;"..SL("Page").." "..(page+1).."/"..(math.floor(#zfc.itemlist/npp+1)).."]"
	formspec = formspec .. "label[0,0;"..SL("Book of Forbidden Crafts").."]"
	formspec = formspec .. "background[5,5;1,1;craft_formbg.png;true]"

	return formspec
end

minetest.register_on_player_receive_fields(function(player,formname,fields)
	local pn = player:get_player_name();
	if zfc.users[pn] == nil then zfc.users[pn] = {current_item = "", alt = 1, page = 0, history={index=0,list={}}} end
	if fields.zfc then
		inventory_plus.set_inventory_formspec(player, zfc.formspec(pn))
		return
	elseif fields.zfc_previous then
		if zfc.users[pn].history.index > 1 then
			zfc.users[pn].history.index = zfc.users[pn].history.index - 1
			zfc.users[pn].current_item = zfc.users[pn].history.list[zfc.users[pn].history.index]
			inventory_plus.set_inventory_formspec(player,zfc.formspec(pn))
		end
	elseif fields.zfc_next then
		if zfc.users[pn].history.index < #zfc.users[pn].history.list then
			zfc.users[pn].history.index = zfc.users[pn].history.index + 1
			zfc.users[pn].current_item = zfc.users[pn].history.list[zfc.users[pn].history.index]
			inventory_plus.set_inventory_formspec(player,zfc.formspec(pn))
		end
	end
	for k, v in pairs(fields) do
		if (k:sub(0,4)=="zfc:") then
			local ni = k:sub(5)
			if zfc.crafts[ni] then
				zfc.users[pn].current_item = ni
				table.insert(zfc.users[pn].history.list, ni)
				zfc.users[pn].history.index = #zfc.users[pn].history.list
				inventory_plus.set_inventory_formspec(player,zfc.formspec(pn))
			end
		elseif (k:sub(0,9)=="zfc_page:") then
			zfc.users[pn].page = tonumber(k:sub(10))
			inventory_plus.set_inventory_formspec(player,zfc.formspec(pn))
		elseif (k:sub(0,8)=="zfc_alt:") then
			zfc.users[pn].alt = tonumber(k:sub(9))
			inventory_plus.set_inventory_formspec(player,zfc.formspec(pn))
		end
	end
end)

minetest.register_tool("lottinventory:forbidden_crafts_book",{
    description = SL("Book of Forbidden Crafts"),
    inventory_image = "lottinventory_forbidden_book.png",
    wield_image = "",
    wield_scale = {x=1,y=1,z=1},
    stack_max = 1,
    tool_capabilities = {
        full_punch_interval = 1.0,
        max_drop_level=0,
        groupcaps={
            fleshy={times={[2]=0.80, [3]=0.40}, uses=20, maxlevel=1},
            snappy={times={[2]=0.80, [3]=0.40}, uses=20, maxlevel=1},
            choppy={times={[3]=0.90}, uses=20, maxlevel=0}
        }
    },
    groups = {armor_crafts=1, book=1, paper=1},
    on_use = function(itemstack, player, pointed_thing)
		local pn = player:get_player_name();
		if zfc.users[pn] == nil then zfc.users[pn] = {current_item = "", alt = 1, page = 0, history={index=0,list={}}} end
		inventory_plus.set_inventory_formspec(player, zfc.formspec(pn))
    end,
})
