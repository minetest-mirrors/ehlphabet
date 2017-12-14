local characters = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0","!","#","$","%","&","(",")","*","+",",","-",".","/",":",";","<","=",">","?","@"}


for _, name in ipairs(characters) do --do this for all characters in the list
   local byte = string.byte(name)
     if byte < 10 then file = "00"..byte end
     if byte > 10 and byte < 100 then file = "0"..byte end         
     if byte > 100 then file = tostring(byte) end 
   local desc = "The \'"..name.."\' Character"

   minetest.register_node("ehlphabet:"..byte, {
      description = "Ehlphabet Block \'"..name.."\'",
      tiles = {"ehlphabet_"..file..".png"},
      groups = {cracky=3,not_in_creative_inventory=1,not_in_crafting_guide=1}
   })
  minetest.register_craft ({ type="shapeless", output = "ehlphabet:block", recipe = {"ehlphabet:"..byte} })
end

minetest.register_node("ehlphabet:machine", {
   description = "Letter Machine",
   tiles = {"ehlphabet_machine.png"},
   paramtype = "light",
   groups = {cracky=2},
   
   can_dig = function(pos, player)                                                    -- "Can you dig it?" -Cyrus
     local meta = minetest.env:get_meta(pos)
     local inv = meta:get_inventory()
     if not inv:is_empty("input") or not inv:is_empty("output") then
       if player then
         minetest.chat_send_player(player:get_player_name(), "You cannot dig the Letter Machine with blocks inside")
       end                                                                            -- end if player
       return false
     end                                                                              -- end if not empty
     return true
   end,                                                                               -- end can_dig function
   
   after_place_node = function(pos, placer)
      local meta = minetest.env:get_meta(pos)
   end,

   on_construct = function(pos)
      local meta = minetest.env:get_meta(pos)
      meta:set_string("formspec", "invsize[8,6;]"..
         "field[3.8,.5;1,1;lettername;Letter;]"..
         "list[current_name;input;2.5,0.2;1,1;]"..
         "list[current_name;output;4.5,0.2;1,1;]"..
         "list[current_player;main;0,2;8,4;]"..
         "button[2.54,-0.25;3,4;name;Blank -> Letter]")
         local inv = meta:get_inventory()
      inv:set_size("input", 1)
      inv:set_size("output", 1)
   end,

   on_receive_fields = function(pos, formname, fields, sender)
      local meta = minetest.env:get_meta(pos)
      local inv = meta:get_inventory()
      local inputstack = inv:get_stack("input", 1)
      if fields.lettername ~= nil and inputstack:get_name()=="ehlphabet:block" then
         for _,v in pairs(characters) do
            if v == fields.lettername then
               local give = {}
               give[1] = inv:add_item("output","ehlphabet:"..string.byte(fields.lettername))
               inputstack:take_item()
               inv:set_stack("input",1,inputstack)
               break
            end
         end
         
      end   
   end
})

minetest.register_node("ehlphabet:block", {
  description = "Ehlphabet Block (blank)",
  tiles = {"ehlphabet_000.png"},
  groups = {cracky=3},
})

--RECIPE: blank blocks
minetest.register_craft({ output = "ehlphabet:block 8",
  recipe = {
    {'default:paper', 'default:paper', 'default:paper'},
    {'default:paper', '', 'default:paper'},
    {'default:paper', 'default:paper', 'default:paper'},
  }
})

--RECIPE: build the machine!
minetest.register_craft({ output = "ehlphabet:machine",
  recipe = {
    {'default:stick', '', 'default:stick'},
    {'default:coal_lump', 'ehlphabet:block', 'default:coal_lump'},
    {'default:paper', '', 'default:paper'},
  }
})

--RECIPE: craft unused blocks back into paper
minetest.register_craft ({ output = "default:paper",
  recipe = {"ehlphabet:block"},
  type = "shapeless"
})
