/datum/advclass/mage/prereworkspellblade
	name = "Spellblade"
	tutorial = "You are skilled in both the arcyne and the art of the blade. However, you are a master of neither, and any armor heavier than light hampers your ability to cast."
	outfit = /datum/outfit/job/roguetown/adventurer/prereworkspellblade
	traits_applied = list(TRAIT_MAGEARMOR, TRAIT_ARCYNE_T2)
	subclass_stats = list(
		STATKEY_STR = 2,
		STATKEY_INT = 1,
		STATKEY_CON = 1,
		STATKEY_WIL = 1,
	)
	subclass_spellpoints = 12
	subclass_skills = list(
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/magic/arcane = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/adventurer/prereworkspellblade/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You are skilled in both the arcyne and the art of the blade. However, you are a master of neither, and any armor heavier than light hampers your ability to cast."))
	head = /obj/item/clothing/head/roguetown/bucklehat
	shoes = /obj/item/clothing/shoes/roguetown/boots
	pants = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	gloves = /obj/item/clothing/gloves/roguetown/angle
	belt = /obj/item/storage/belt/rogue/leather
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	backl = /obj/item/storage/backpack/rogue/satchel
	beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/recipe_book/survival = 1)
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/airblade)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/arcynestrike) // freebies! your cousin the spellsinger recently received +4 spellpoints, go get 'em champ
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/enchant_weapon)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/conjure_weapon)
	H.cmode_music = 'sound/music/cmode/adventurer/combat_outlander3.ogg'
	if(H.mind)
		var/weapons = list("Longsword", "Falchion & Wooden Shield", "Messer & Wooden Shield", "Hwando") // Much smaller selection with only three swords. You will probably want to upgrade.
		var/weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapons
		beltr = /obj/item/rogueweapon/scabbard/sword
		armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
		switch(weapon_choice)
			if("Longsword")
				r_hand = /obj/item/rogueweapon/sword/long
			if("Falchion & Wooden Shield")
				backr = /obj/item/rogueweapon/shield/wood
				r_hand = /obj/item/rogueweapon/sword/short/falchion
				H.adjust_skillrank_up_to(/datum/skill/combat/shields, SKILL_LEVEL_APPRENTICE, TRUE)
			if("Messer & Wooden Shield")
				backr = /obj/item/rogueweapon/shield/wood
				r_hand = /obj/item/rogueweapon/sword/short/messer/iron
				H.adjust_skillrank_up_to(/datum/skill/combat/shields, SKILL_LEVEL_APPRENTICE, TRUE)
			if("Hwando")
				r_hand = /obj/item/rogueweapon/sword/sabre/mulyeog // Meant to not have the special foreign scabbards.
				armor = /obj/item/clothing/suit/roguetown/armor/basiceast
	switch(H.patron?.type)
		if(/datum/patron/inhumen/zizo)
			H.cmode_music = 'sound/music/combat_heretic.ogg'