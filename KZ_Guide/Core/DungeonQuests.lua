--[[
    KZ Guide - Dungeon Quest Database
    Banco de dados das quests de dungeons do WoW Classic 1.12
    Separado por faccao (Alliance / Horde / Both)

    Usado pelo DungeonBrowser para exibir informacoes de quests
    e pelo futuro pack "Guia Dungeons"
]]--
if not _G then _G = getfenv(0) end
local _G = _G
local GLV = LibStub("KZ_Guide")
if not GLV then return end

GLV.DungeonQuestDB = GLV.DungeonQuestDB or {}
local DQ = GLV.DungeonQuestDB

DQ["rfc"] = {
    { name = "Testing an Enemy's Strength", faction = "Horde", questId = 5723, giver = "Rahauro", location = "Thunder Bluff" },
    { name = "The Power to Destroy...", faction = "Horde", questId = 5726, giver = "Varimathras", location = "Undercity" },
    { name = "Searching for the Lost Satchel", faction = "Horde", questId = 5722, giver = "Rahauro", location = "Thunder Bluff" },
    { name = "Slaying the Beast", faction = "Horde", questId = 5761, giver = "Neeru Fireblade", location = "Orgrimmar" },
    { name = "Hidden Enemies", faction = "Horde", questId = 5727, giver = "Thrall", location = "Orgrimmar" },
}

DQ["wc"] = {
    { name = "Trouble at the Docks", faction = "Both", questId = 959, giver = "Crane Operator Bigglefuzz", location = "Ratchet" },
    { name = "Smart Drinks", faction = "Both", questId = 1491, giver = "Mebok Mizzyrix", location = "Ratchet" },
    { name = "Deviate Hides", faction = "Both", questId = 1486, giver = "Nalpak", location = "Above Wailing Caverns" },
    { name = "Deviate Eradication", faction = "Both", questId = 1487, giver = "Ebru", location = "Above Wailing Caverns" },
    { name = "Serpentbloom", faction = "Horde", questId = 962, giver = "Apothecary Zamah", location = "Thunder Bluff" },
    { name = "Leaders of the Fang", faction = "Horde", questId = 914, giver = "Nara Wildmane", location = "Thunder Bluff" },
}

DQ["dm"] = {
    { name = "The Defias Brotherhood (chain)", faction = "Alliance", questId = 166, giver = "Gryan Stoutmantle", location = "Westfall" },
    { name = "Collecting Memories", faction = "Alliance", questId = 168, giver = "Wilder Thistlenettle", location = "Stormwind" },
    { name = "Oh Brother...", faction = "Alliance", questId = 167, giver = "Wilder Thistlenettle", location = "Stormwind" },
    { name = "Underground Assault", faction = "Alliance", questId = 2040, giver = "Shoni the Shilent", location = "Stormwind" },
    { name = "Red Silk Bandanas", faction = "Alliance", questId = 214, giver = "Scout Riell", location = "Westfall" },
    { name = "The Unsent Letter", faction = "Alliance", questId = 373, giver = "Drop: Edwin VanCleef", location = "Inside Deadmines" },
}

DQ["sfk"] = {
    { name = "Deathstalkers in Shadowfang", faction = "Horde", questId = 1098, giver = "High Executor Hadrec", location = "The Sepulcher" },
    { name = "The Book of Ur", faction = "Horde", questId = 1013, giver = "Keeper Bel'dugur", location = "Undercity" },
    { name = "Arugal Must Die", faction = "Horde", questId = 1014, giver = "Dalar Dawnweaver", location = "The Sepulcher" },
    { name = "The Orb of Soran'ruk", faction = "Horde", questId = 1740, giver = "Doan Karhan", location = "The Barrens" },
    { name = "Devlin's Remains", faction = "Alliance", questId = 1097, giver = "Sven Yorgen", location = "Duskwood" },
}

DQ["bfd"] = {
    { name = "Researching the Corruption", faction = "Alliance", questId = 1275, giver = "Gershala Nightwhisper", location = "Auberdine" },
    { name = "In Search of Thaelrid", faction = "Alliance", questId = 1199, giver = "Dawnwatcher Shaedlass", location = "Darnassus" },
    { name = "Twilight Falls", faction = "Alliance", questId = 1198, giver = "Argent Guard Thaelrid", location = "Inside BFD" },
    { name = "Knowledge in the Deeps", faction = "Alliance", questId = 971, giver = "Gerrig Bonegrip", location = "Ironforge" },
    { name = "Blackfathom Villainy", faction = "Horde", questId = 6921, giver = "Argent Guard Thaelrid", location = "Inside BFD" },
    { name = "The Essence of Aku'Mai", faction = "Both", questId = 6563, giver = "Je'neu Sancrea", location = "Ashenvale" },
    { name = "Baron Aquanis", faction = "Horde", questId = 6922, giver = "Drop: Baron Aquanis", location = "Inside BFD" },
}

DQ["stocks"] = {
    { name = "Crime and Punishment", faction = "Alliance", questId = 377, giver = "Councilman Millstipe", location = "Duskwood" },
    { name = "Quell The Uprising", faction = "Alliance", questId = 387, giver = "Warden Thelwater", location = "Stormwind" },
    { name = "The Color of Blood", faction = "Alliance", questId = 388, giver = "Nikova Raskol", location = "Stormwind" },
    { name = "What Comes Around...", faction = "Alliance", questId = 386, giver = "Guard Berton", location = "Lakeshire" },
}

DQ["gnomer"] = {
    { name = "Gnogaine", faction = "Both", questId = 2904, giver = "Ozzie Togglevolt", location = "Kharanos" },
    { name = "The Only Cure is More Green Glow", faction = "Both", questId = 2922, giver = "Ozzie Togglevolt", location = "Kharanos" },
    { name = "Data Rescue", faction = "Alliance", questId = 2930, giver = "Master Mechanic Castpipe", location = "Ironforge" },
    { name = "Essential Artificials", faction = "Alliance", questId = 2924, giver = "Klockmort Spannerspan", location = "Ironforge" },
    { name = "Save Techbot's Brain!", faction = "Alliance", questId = 2922, giver = "Tinkmaster Overspark", location = "Ironforge" },
    { name = "A Fine Mess", faction = "Both", questId = 2904, giver = "Kernobee", location = "Inside Gnomeregan" },
    { name = "Rig Wars", faction = "Horde", questId = 2841, giver = "Nogg", location = "Orgrimmar" },
}

DQ["rfk"] = {
    { name = "Blueleaf Tubers", faction = "Both", questId = 1221, giver = "Mebok Mizzyrix", location = "Ratchet" },
    { name = "Willix the Importer", faction = "Both", questId = 1144, giver = "Willix the Importer", location = "Inside RFK" },
    { name = "Mortality Wanes", faction = "Horde", questId = 6626, giver = "Heralath Fallowbrook", location = "Inside RFK" },
    { name = "A Vengeful Fate", faction = "Horde", questId = 1142, giver = "Auld Stonespire", location = "Thunder Bluff" },
}

DQ["sm"] = {
    { name = "In the Name of the Light", faction = "Alliance", questId = 1053, giver = "Raleigh the Devout", location = "Southshore" },
    { name = "Mythology of the Titans", faction = "Alliance", questId = 1050, giver = "Librarian Mae Paledust", location = "Ironforge" },
    { name = "Down the Scarlet Path", faction = "Horde", questId = 1048, giver = "Varimathras", location = "Undercity" },
    { name = "Hearts of Zeal", faction = "Horde", questId = 1113, giver = "Master Apothecary Faranell", location = "Undercity" },
    { name = "Test of Lore", faction = "Horde", questId = 1160, giver = "Parqual Fintallas", location = "Undercity" },
    { name = "Compendium of the Fallen", faction = "Both", questId = 1049, giver = "Sage Truthseeker", location = "Thunder Bluff" },
}

DQ["ulda"] = {
    { name = "The Lost Dwarves", faction = "Alliance", questId = 2398, giver = "Prospector Stormpike", location = "Ironforge" },
    { name = "Agmond's Fate", faction = "Alliance", questId = 704, giver = "Prospector Ironband", location = "Loch Modan" },
    { name = "Uldaman Reagent Run", faction = "Both", questId = 17, giver = "Jarkal Mossmeld", location = "Kargath" },
    { name = "Power Stones", faction = "Both", questId = 2418, giver = "Rigglefuzz", location = "Badlands" },
    { name = "The Platinum Discs", faction = "Both", questId = 2280, giver = "The Discs of Norgannon", location = "Inside Uldaman" },
}

DQ["rfd"] = {
    { name = "Bring the End", faction = "Both", questId = 3636, giver = "Andrew Brownell", location = "Undercity" },
    { name = "Extinguishing the Idol", faction = "Both", questId = 3525, giver = "Belnistrasz", location = "Inside RFD" },
    { name = "A Host of Evil", faction = "Alliance", questId = 6521, giver = "Myriam Moonsinger", location = "Outside RFD" },
}

DQ["zf"] = {
    { name = "Scarab Shells", faction = "Both", questId = 2865, giver = "Tran'rek", location = "Tanaris" },
    { name = "Troll Temper", faction = "Both", questId = 3042, giver = "Trenton Lighthammer", location = "Tanaris" },
    { name = "Tiara of the Deep", faction = "Both", questId = 2846, giver = "Tabetha", location = "Dustwallow Marsh" },
    { name = "Nekrum's Medallion", faction = "Horde", questId = 2991, giver = "Thadius Grimshade", location = "Blasted Lands" },
    { name = "The Prophecy of Mosh'aru", faction = "Both", questId = 3527, giver = "Yeh'kinya", location = "Tanaris" },
    { name = "Divino-matic Rod", faction = "Both", questId = 2768, giver = "Chief Engineer Bilgewhizzle", location = "Tanaris" },
}

DQ["mara"] = {
    { name = "Legends of Maraudon", faction = "Both", questId = 7044, giver = "Cavindra", location = "Outside Maraudon" },
    { name = "Vyletongue Corruption", faction = "Both", questId = 7041, giver = "Talendria", location = "Outside Maraudon" },
    { name = "Twisted Evils", faction = "Both", questId = 7028, giver = "Willow", location = "Outside Maraudon" },
    { name = "The Pariah's Instructions", faction = "Both", questId = 7067, giver = "Centaur Pariah", location = "Desolace" },
}

DQ["st"] = {
    { name = "Into The Temple of Atal'Hakkar", faction = "Alliance", questId = 1446, giver = "Brohann Caskbelly", location = "Stormwind" },
    { name = "The Temple of Atal'Hakkar", faction = "Horde", questId = 1445, giver = "Fel'Zerul", location = "Stonard" },
    { name = "Secret of the Circle", faction = "Both", questId = 3447, giver = "Discovered in temple", location = "Inside ST" },
    { name = "Jammal'an the Prophet", faction = "Both", questId = 1446, giver = "Atal'ai Exile", location = "Hinterlands" },
    { name = "The God Hakkar", faction = "Both", questId = 3528, giver = "Yeh'kinya", location = "Tanaris" },
}

DQ["brd"] = {
    { name = "Dark Iron Legacy", faction = "Both", questId = 3802, giver = "Franclorn Forgewright (ghost)", location = "Blackrock Mountain" },
    { name = "Ribbly Screwspigot", faction = "Both", questId = 4136, giver = "Yuka Screwspigot", location = "Burning Steppes" },
    { name = "The Heart of the Mountain", faction = "Both", questId = 4123, giver = "Maxwort Uberglint", location = "Burning Steppes" },
    { name = "Hurley Blackbreath", faction = "Both", questId = 4126, giver = "Ragnar Thunderbrew", location = "Kharanos" },
    { name = "A Taste of Flame", faction = "Both", questId = 4024, giver = "Cyrus Therepedes", location = "Burning Steppes" },
    { name = "Incendius!", faction = "Both", questId = 4262, giver = "Jalinda Sprig", location = "Morgan's Vigil" },
    { name = "Commander Gor'shak", faction = "Horde", questId = 4241, giver = "Thrall", location = "Orgrimmar" },
    { name = "The Royal Rescue", faction = "Alliance", questId = 4341, giver = "King Magni Bronzebeard", location = "Ironforge" },
    { name = "Marshal Windsor", faction = "Alliance", questId = 4241, giver = "Marshal Maxwell", location = "Morgan's Vigil" },
}

DQ["lbrs"] = {
    { name = "Warlord's Command", faction = "Horde", questId = 4903, giver = "Warchief Rend Blackhand", location = "Inside LBRS" },
    { name = "Bijou's Belongings", faction = "Both", questId = 5001, giver = "Bijou", location = "Inside LBRS" },
    { name = "Maxwell's Mission", faction = "Alliance", questId = 4264, giver = "Marshal Maxwell", location = "Morgan's Vigil" },
    { name = "Seal of Ascension", faction = "Both", questId = 4743, giver = "Vaelan", location = "Inside LBRS" },
}

DQ["dmn"] = {
    { name = "Pusillin and the Elder Azj'Tordin", faction = "Both", questId = 7441, giver = "Azj'Tordin", location = "Inside DM East" },
    { name = "Lethtendris's Web", faction = "Both", questId = 7488, giver = "Latronicus Moonspear", location = "Feathermoon Stronghold" },
    { name = "The Madness Within", faction = "Both", questId = 7461, giver = "Shen'dralar Ancient", location = "Inside DM North" },
    { name = "A Broken Trap", faction = "Both", questId = 1193, giver = "Broken Trap", location = "Inside DM North" },
    { name = "Elven Legends", faction = "Alliance", questId = 7482, giver = "Scholar Runethorn", location = "Feathermoon Stronghold" },
    { name = "Libram quests", faction = "Both", questId = 7484, giver = "Various NPCs", location = "Inside DM" },
}

DQ["scholo"] = {
    { name = "Doctor Theolen Krastinov, the Butcher", faction = "Both", questId = 5382, giver = "Eva Sarkhoff", location = "Caer Darrow" },
    { name = "Kirtonos the Herald", faction = "Both", questId = 5384, giver = "Eva Sarkhoff", location = "Caer Darrow" },
    { name = "The Lich, Ras Frostwhisper", faction = "Both", questId = 5466, giver = "Magistrate Marduke", location = "Caer Darrow" },
    { name = "Barov Family Fortune", faction = "Alliance", questId = 5341, giver = "Weldon Barov", location = "Chillwind Camp" },
    { name = "Barov Family Fortune", faction = "Horde", questId = 5343, giver = "Alexi Barov", location = "The Bulwark" },
    { name = "Plagued Hatchlings", faction = "Both", questId = 5529, giver = "Betina Bigglezink", location = "Light's Hope Chapel" },
    { name = "Dawn's Gambit", faction = "Both", questId = 4771, giver = "Betina Bigglezink", location = "Light's Hope Chapel" },
}

DQ["strat"] = {
    { name = "The Restless Souls", faction = "Both", questId = 5282, giver = "Egan", location = "Plaguelands" },
    { name = "Of Love and Family", faction = "Both", questId = 5848, giver = "Tirion Fordring", location = "Western Plaguelands" },
    { name = "Aurius' Reckoning", faction = "Both", questId = 5125, giver = "Aurius", location = "Inside Stratholme" },
    { name = "The Medallion of Faith", faction = "Both", questId = 5122, giver = "Aurius", location = "Inside Stratholme" },
    { name = "Houses of the Holy", faction = "Both", questId = 5463, giver = "Leonid Barthalomew", location = "Light's Hope Chapel" },
    { name = "The Archivist", faction = "Both", questId = 5251, giver = "Duke Nicholas Zverenhoff", location = "Light's Hope Chapel" },
}

DQ["ubrs"] = {
    { name = "Seal of Ascension", faction = "Both", questId = 4743, giver = "Vaelan", location = "Inside LBRS" },
    { name = "General Drakkisath's Demise", faction = "Alliance", questId = 5102, giver = "Marshal Maxwell", location = "Morgan's Vigil" },
    { name = "For the Horde!", faction = "Horde", questId = 4974, giver = "Thrall", location = "Orgrimmar" },
    { name = "Drakefire Amulet (Onyxia Attunement)", faction = "Both", questId = 6502, giver = "Haleh", location = "Winterspring" },
}

function GLV:GetDungeonQuests(dungeonId)
    if not dungeonId then return {} end
    return DQ[dungeonId] or {}
end

function GLV:GetDungeonQuestsForFaction(dungeonId, playerFaction)
    local allQuests = self:GetDungeonQuests(dungeonId)
    if not allQuests or table.getn(allQuests) == 0 then return {} end

    local result = {}
    for _, quest in ipairs(allQuests) do
        if quest.faction == "Both" or quest.faction == playerFaction then
            table.insert(result, quest)
        end
    end
    return result
end
