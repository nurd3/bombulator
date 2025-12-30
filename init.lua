bombulator = {}

local path = core.get_modpath "bombulator"
local S = core.get_translator "bombulator"

bombulator.get_modpath = path
bombulator.get_translator = S

dofile (path .. "/functions.lua")
dofile (path .. "/register.lua")
dofile (path .. "/bombulation.lua")
dofile (path .. "/cheating.lua")

deploader.load_depends()

local http = core.request_http_api()

if http then
	local http_anti_spam = 1.0
	local http_last_request = 0.0
	local function show_ad(package, player)
		local playername = player:get_player_name()

		local package_link = "https://content.luanti.org/packages"
			.. "/" .. package.author
			.. "/" .. package.name
		local texture_name = package.name .. "_thumbnail.png"
		local ad_text = core.formspec_escape(package.title) .. " by " .. core.formspec_escape(package.author)

		local formspec =
			"formspec_version[4]"
			.. "size[8,4]"
			.. "position[0.5,0.5]"
			.. "background[0,1;8,4;" .. texture_name .. ";true]"
			.. "label[0,0.5;BROUGHT TO YOU BY " .. ad_text .. "]"
			.. "button_url[0,3;8,1;title" 
				.. ";GET " .. ad_text .. " NOW!!!"
				.. ";" .. package_link
			.. "]"
			.. "button_exit[]"
		http.fetch({url = package.thumbnail}, function(res)
			core.dynamic_add_media({
				filename = texture_name,
				filedata = res.data,
				to_player = playername
			}, function()
				core.show_formspec(playername, "bombulator:ad", formspec)
			end)
			
		end)
	end

	bombulator.register_bombulation("bombulator:ads", {
		interval = 10.0,
		per_player = function(player)
			local currtime = os.time()
			if http_last_request + http_anti_spam > currtime then return end
			http_last_request = currtime
			http.fetch({
				url = "https://content.luanti.org/api/packages/"
					-- sorting/order
					.. "?sort=last_release&order=asc"
					-- limit
					.. "&limit=10"
					-- tags to hide
					.. "&hide=nonfree"
					-- licenses
					.. "&license=GPL-2.0-only&license=GPL-3.0-only&license=GPL-2.0-or-later&license=GPL-3.0-or-later"
					-- format
					.. "&fmt=short"
			}, function(res)
				if not res.succeeded then return end
				local result = core.parse_json(res.data)
				table.shuffle(result)
				show_ad(result[1], player)
			end)
		end
	})
else
	bombulator.utils.announce_fmt("Did you know: If you add bombulator to secure.http_mods in your minetest.conf file, you can get extra prankster features!")
end