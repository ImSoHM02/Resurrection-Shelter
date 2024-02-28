description = 
[[
Another island masterpiece!

-V1.0-
Cleaned and updated code. Made the ressurector also act like a Siesta Lean To.

Recipe, Uses, Health, Sanity, and Hunger all configurable.
]]
name                        = "Resurrection Shelter"
author                      = "Im So HM02 (Original by Afro1967)"
version                     = "1.0"
forumthread                 = ""
icon                        = "modicon.tex"
icon_atlas                  = "modicon.xml"
api_version                 = 10
all_clients_require_mod     = true
dst_compatible              = true
client_only_mod             = false

--Locals

local Options 				= {{description = "Yes", data = true}, {description = "No", data = false}}

local Difficulty 			= {{description = "Easy", data = 1}, {description = "Normal", data = 2}, {description = "Hard", data = 3}}

local Gains 				= {{description = "x1", data = 1}, {description = "x2", data = 2}, {description = "x3", data = 3}}

local Uses					= {{description = "5", data = 5}, {description = "10", data = 10}, {description = "20", data = 20}, {description = "Infinite", data = 1000000}}

local Empty 				= {{description = "", data = 0}}

local function Title(title) --Allows use of an empty label as a header
return {name=title, options=Empty, default=0,}
end

local SEPARATOR 			= Title("")

--Config options

configuration_options =
{
	Title("Settings"),
	{
		name	= "shelterrecipe",
		label	= "Recipe Difficulty",
		options = Difficulty,
		default = 2,
	},

	{
		name 	= "ShelterUses", 
		label 	= "Shelter Uses",
		options = Uses,
		default = 5,
	},

	{
		name 	= "ShelterHealth",
		label	= "Health Gain",
		options = Gains,
		default = 2
	},

	{
		name 	= "ShelterSanity",
		label 	= "Sanity Gain",
		options = Gains,
		default = 2,
	},

	{
		name	= "ShelterHunger",
		label	= "Hunger Loss",
		options = Gains,
		default = 1,
	},

	{
		name = "ShelterLight", 
		label = "Enable Night Light?",
		hover = "Here you can choose to enable or disable the night light",
		options = Options,
		default = true,
	},
}

