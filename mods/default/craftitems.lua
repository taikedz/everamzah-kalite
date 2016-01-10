-- mods/default/craftitems.lua

minetest.register_craftitem("default:stick", {
	description = "Stick",
	inventory_image = "default_stick.png",
	groups = {stick=1},
	stack_max = 60,
})

minetest.register_craftitem("default:paper", {
	description = "Paper",
	inventory_image = "default_paper.png",
	stack_max = 60,
})

-- Books

local function book_on_use(itemstack, user, pointed_thing)
        local player_name = user:get_player_name()
        local data = minetest.deserialize(itemstack:get_metadata())
        local title, text, owner = "", "", player_name
        if data then
                title, text, owner = data.title, data.text, data.owner
        end
        local formspec
        if owner == player_name then
                formspec = "size[8,8]" .. --default.gui_bg ..
                        "field[0.5,1;7.5,0;title;Title:;" ..
                                minetest.formspec_escape(title) .. "]" ..
                        "textarea[0.5,1.5;7.5,7;text;Contents:;" ..
                                minetest.formspec_escape(text) .. "]" ..
                        "button_exit[2.5,7.5;3,1;save;Save]"
        else
                formspec = "size[8,8]" .. --default.gui_bg ..
                        "label[0.5,0.5;by " .. owner .. "]" ..
                        "label[0.5,0;" .. minetest.formspec_escape(title) .. "]" ..
                        "textarea[0.5,1.5;7.5,7;;" .. minetest.formspec_escape(text) .. ";]"
        end
        minetest.show_formspec(user:get_player_name(), "default:book", formspec)
end

minetest.register_on_player_receive_fields(function(player, form_name, fields)
        if form_name ~= "default:book" or not fields.save or
                        fields.title == "" or fields.text == "" then
                return
        end
        local inv = player:get_inventory()
        local stack = player:get_wielded_item()
        local new_stack, data
        if stack:get_name() ~= "default:book_written" then
                local count = stack:get_count()
                if count == 1 then
                        stack:set_name("default:book_written")
                else
                        stack:set_count(count - 1)
                        new_stack = ItemStack("default:book_written")
                end
        else
                data = minetest.deserialize(stack:get_metadata())
        end
        if not data then data = {} end
        data.title = fields.title
        data.text = fields.text
        data.owner = player:get_player_name()
        local data_str = minetest.serialize(data)
        if new_stack then
                new_stack:set_metadata(data_str)
                if inv:room_for_item("main", new_stack) then
                        inv:add_item("main", new_stack)
                else
                        minetest.add_item(player:getpos(), new_stack)
                end
        else
                stack:set_metadata(data_str)
        end
        player:set_wielded_item(stack)
end)

minetest.register_craftitem("default:book", {
	description = "Book",
	inventory_image = "default_book.png",
	stack_max = 60,
	groups = {book = 1, fuel = 2},
	on_use = book_on_use
})

minetest.register_craftitem("default:book_written", {
	description = "Book with Text",
	inventory_image = "default_book_written.png",
	groups = {book = 1, fuel = 2, not_in_creative_inventory = 1},
	stack_max = 1,
	on_use = book_on_use
})

-- Copying books taken from a PR by sofar.

minetest.register_craft({
	type = "shapeless",
	output = "default:book_written",
	recipe = { "default:book", "default:book_written" }
})

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if itemstack:get_name() ~= "default:book_written" then
		return
	end

	local copy = ItemStack("default:book_written")
	local original
	local index
	for i = 1, player:get_inventory():get_size("craft") do
		if old_craft_grid[i]:get_name() == "default:book_written" then
			original = old_craft_grid[i]
			index = i
		end
	end
	if not original then
		return
	end
	local copymeta = original:get_metadata()
	-- copy of the book held by player's mouse cursor
	itemstack:set_metadata(copymeta)
	-- put the book with metadata back in the craft grid
	craft_inv:set_stack("craft", index, original)
end)

-- Lumps

minetest.register_craftitem("default:coal_lump", {
	description = "Coal Lump",
	inventory_image = "default_coal_lump.png",
	stack_max = 60,
})

minetest.register_craftitem("default:iron_lump", {
	description = "Iron Lump",
	inventory_image = "default_iron_lump.png",
	stack_max = 60,
})

minetest.register_craftitem("default:copper_lump", {
	description = "Copper Lump",
	inventory_image = "default_copper_lump.png",
	stack_max = 60,
})

minetest.register_alias("default:mese_crystal", "default:gold")

minetest.register_craftitem("default:gold_lump", {
	description = "Gold Lump",
	inventory_image = "default_gold_lump.png",
	stack_max = 60,
})

minetest.register_craftitem("default:diamond", {
	description = "Diamond",
	inventory_image = "default_diamond.png",
	stack_max = 60,
})

minetest.register_craftitem("default:clay_lump", {
	description = "Clay Lump",
	inventory_image = "default_clay_lump.png",
	stack_max = 60,
})

minetest.register_craftitem("default:iron_ingot", {
	description = "Iron Ingot",
	inventory_image = "default_iron_ingot.png",
	stack_max = 60,
})
minetest.register_alias("default:steel_ingot", "default:iron_ingot")

minetest.register_craftitem("default:copper_ingot", {
	description = "Copper Ingot",
	inventory_image = "default_copper_ingot.png",
	stack_max = 60,
})

minetest.register_craftitem("default:bronze_ingot", {
	description = "Bronze Ingot",
	inventory_image = "default_bronze_ingot.png",
	stack_max = 60,
})

minetest.register_craftitem("default:gold_ingot", {
	description = "Gold Ingot",
	inventory_image = "default_gold_ingot.png",
	stack_max = 60,
})

minetest.register_craftitem("default:clay_brick", {
	description = "Clay Brick",
	inventory_image = "default_clay_brick.png",
	stack_max = 60,
})

minetest.register_craftitem("default:scorched_stuff", {
	description = "Scorched Stuff",
	inventory_image = "default_scorched_stuff.png",
	stack_max = 60,
})

minetest.register_craftitem("default:obsidian_shard", {
	description = "Obsidian Shard",
	inventory_image = "default_obsidian_shard.png",
	stack_max = 60,
})
