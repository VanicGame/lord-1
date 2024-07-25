
--- @class base_classes.Form.Mixin.Personal: base_classes.Form.Mixin
local Personal = {
	--- @static late
	--- @protected
	--- @type table<string,base_classes.Form.Base>
	opened_for = {},
}

--- @public
--- @static late
--- @param player Player
function Personal:get_opened_for(player)
	return self.opened_for[player:get_player_name()]
end

--- @protected
--- @param player    Player
--- @param form_name string
--- @param fields    table
function Personal:handler(player, form_name, fields)
	if form_name ~= self.NAME then
		return
	end

	local form = self:get_opened_for(player)
	if not form then return end

	self.event:trigger(self.event.Type.on_handle, form, player, fields)
	form:handle(fields)

	if fields.quit then
		form:close()
	end
end

--- @protected
--- @param player Player
function Personal:player_leave(player, _)
	local form = self:get_opened_for(player);
	if form then
		form:close()
	end
end


--- @static
--- @param class base_classes.Form.Base
function Personal.mix_to(class)
	table.overwrite(class, Personal)

	--- @param self   base_classes.Form.Mixin.Personal
	--- @param player Player
	--- @param _      Position
	class.on_instance(function(self, player, _)
		self.player_name = player:get_player_name()
	end)
	--- @param self base_classes.Form.Mixin.Personal
	--- @param _    Player
	--- @param _    Position
	class.on_open(function(self, _, _)
		self.opened_for[self.player_name] = self;
	end)
	--- @param self base_classes.Form.Mixin.Personal
	class.on_register(function(self)
		minetest.register_on_leaveplayer(function(player, _)
			self:player_leave(player)
		end)
	end)
end


return Personal
