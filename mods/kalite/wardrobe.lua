kalite.wardrobe = {}

local skin_db = {}

local load = function ()
	local fh, err = io.open(minetest.get_worldpath() .. "/skins.txt", "r")
	if err then
		skin_db = {{"dusty", "Dusty"}, {"sam", "Sam"}}
		minetest.log("action", "No skins.txt found!  Loading default skins.")
		return
	end
	while true do
		local line = fh:read()
		if line == nil then
			break
		end
		local paramlist = string.split(line, ":")
		local w = {
			paramlist[1],
			paramlist[2]
		}
		table.insert(skin_db, w)
	end
	fh:close()
	minetest.log("action", table.getn(skin_db) .. " skins loaded.")
end

load() -- Why put this in a function?


-- Functions
local function get_skin(player)
	local skin = player:get_properties().textures[1]
	return skin
end

local function show_formspec(name, skin, spos)
	minetest.show_formspec(name, "skinform",
		"size[8,8.5]" ..
		default.gui_bg_img ..
		default.gui_slots ..
		"list[detached:skin_" .. name .. ";main;0,1.5;1,1]" ..
		"image[0.75,0.1;4,4;kalite_skin_" .. skin .. ".png]" ..
		"list[nodemeta:" .. spos .. ";main;4,0.5;4,3]" ..
		"list[current_player;main;0,4.25;8,1;]" ..
		"list[current_player;main;0,5.5;8,3;8]" ..
		default.get_hotbar_bg(0, 4.25)
	)
end

-- Nodes
minetest.register_node("kalite:wardrobe", {
	description = "Wardrobe",
	paramtype2 = "facedir",
	tiles = {
		"kalite_wardrobe_topbottom.png",
		"kalite_wardrobe_topbottom.png",
		"kalite_wardrobe_sides.png",
		"kalite_wardrobe_sides.png",
		"kalite_wardrobe_sides.png",
		"kalite_wardrobe_front.png",
	},
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy = default.dig.wood, flammable = 5},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Wardrobe")
		local inv = meta:get_inventory()
		inv:set_size("main", 4 * 3)
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local name = clicker:get_player_name()
		local spos = pos.x .. "," .. pos.y .. "," .. pos.z
		kalite.wardrobe[name] = spos
		local skin
		local current_skin = get_skin(clicker)

		for _, v in pairs(skin_db) do
			if current_skin == "character_" .. v[1] .. ".png" then
				skin = v[1]
			elseif not skin then
				skin = "dusty"
			end
		end

		show_formspec(name, skin, spos)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if minetest.get_item_group(stack:get_name(), "skin") == 1 then
			return 1
		else
			return 0
		end
	end
})

minetest.register_craft({
	output = "kalite:wardrobe",
	recipe = {
		{"group:wood", "group:stick", "group:wood"},
                {"group:wood", "group:wool", "group:wood"},
                {"group:wood", "group:wool", "group:wood"},
	}
})

-- Craftitems
for _, v in pairs(skin_db) do
	minetest.register_craftitem("kalite:skin_" .. v[1], {
		description = v[2],
		inventory_image = "kalite_skin_" .. v[1] .. ".png",
		groups = {skin = 1},
		stack_max = 1
	})
end

-- Callbacks?
minetest.register_on_newplayer(function(player)
	local name = player:get_player_name()
	minetest.after(0.1, function ()
		local inv = minetest.get_inventory{type = "player", name = name}
		inv:set_stack("skin", 1, {name = "kalite:skin_dusty"})

		local detached = minetest.get_inventory{type = "detached", name = "skin_" .. name}
		detached:set_stack("main", 1, {name = "kalite:skin_dusty"})
	end)
end)


minetest.register_on_joinplayer(function(player, _)
	local skin_inv = player:get_inventory()
	skin_inv:set_size("skin", 1)

	-- FIXME Old players missing the skin inventory do not receive their skin

	for _, v in pairs(skin_db) do
		if skin_inv:contains_item("skin", {name = "kalite:skin_" .. v[1]}) then
			player:set_properties({textures = {"character_" .. v[1] .. ".png"}})
		end
	end

	local skin = minetest.create_detached_inventory("skin_" .. player:get_player_name(), {
		allow_put = function(inv, listname, index, stack, player)
			if minetest.get_item_group(stack:get_name(), "skin") == 1 then
				return 1
			else
				return 0
			end
		end,
		allow_take = function(inv, listname, index, stack, player)
			return 0
		end,
		on_put = function(inv, listname, index, stack, player)
			local name = player:get_player_name()

			for _, v in pairs(skin_db) do
				if stack:get_name() == "kalite:skin_" .. v[1] then
					player:set_properties({textures = {"character_" .. v[1] .. ".png"}})
					skin_inv:set_stack("skin", 1, {name = "kalite:skin_" .. v[1]})
					return show_formspec(name, v[1], kalite.wardrobe[player:get_player_name()])
				end
			end
		end
	},
	player:get_player_name())
	skin:set_size("main", 1)

	for _, v in pairs(skin_db) do
		if skin_inv:contains_item("skin", {name = "kalite:skin_" .. v[1]}) then
			skin:set_stack("main", 1, {name = "kalite:skin_" .. v[1]})
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	kalite.wardrobe[player:get_player_name()] = nil
end)
