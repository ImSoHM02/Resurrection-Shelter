Assets                          =
{
	Asset( "ATLAS", "images/inventoryimages/r_shelter.xml"),
        Asset( "IMAGE", "minimap/r_shelter.tex" ),
        Asset( "ATLAS", "minimap/r_shelter.xml" ),	
}

PrefabFiles                     = {"r_shelter"}

--Variables
STRINGS                         = GLOBAL.STRINGS
Recipe                          = GLOBAL.Recipe
Ingredient                      = GLOBAL.Ingredient
TECH                            = GLOBAL.TECH

--Load Config Data
GLOBAL.ShelterUses              = GetModConfigData("ShelterUses")
GLOBAL.ShelterSanity            = GetModConfigData("ShelterSanity")
GLOBAL.ShelterHunger            = GetModConfigData("ShelterHunger")
GLOBAL.ShelterHealth            = GetModConfigData("ShelterHealth")
GLOBAL.ShelterLight             = (GetModConfigData("ShelterLight")==true)

--Strings
GLOBAL.STRINGS.CHARACTERS.GENERIC.ANNOUNCE_SHELTER      = "Poor bastard!"
GLOBAL.STRINGS.NAMES.R_SHELTER  = "Resurrection Shelter"
STRINGS.RECIPE_DESC.R_SHELTER   = "Insurance for the unknown!"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.R_SHELTER    = "Poor bastard! Haunt the bones to add your flesh!"

local difficultyState           = GetModConfigData("shelterrecipe")

--Add Crafting Recipes to Menu
if difficultyState == 1 then
        AddRecipe2("r_shelter",
        { 
                Ingredient("log", 5),
                Ingredient("pigskin", 4),
                Ingredient("rope", 4),
        },
                TECH.SCIENCE_ZERO,"r_shelter_placer", {"MAGIC"})
        RegisterInventoryItemAtlas("images/inventoryimages/r_shelter.xml", "r_shelter.tex")
end

if difficultyState == 2 then
        AddRecipe2("r_shelter",
        { 
                Ingredient("beardhair", 4),
                Ingredient("nightmarefuel", 2),
                Ingredient("log", 10),
        },
                TECH.SCIENCE_ONE,"r_shelter_placer", {"MAGIC"})
        RegisterInventoryItemAtlas("images/inventoryimages/r_shelter.xml", "r_shelter.tex")
end

if difficultyState == 3 then
        AddRecipe2("r_shelter",        
        { 
                Ingredient("amulet", 1),
                Ingredient("nightmarefuel", 5),
                Ingredient("boards", 10),
        },
                TECH.SCIENCE_TWO, "r_shelter_placer", {"MAGIC"})
        RegisterInventoryItemAtlas("images/inventoryimages/r_shelter.xml", "r_shelter.tex")
end