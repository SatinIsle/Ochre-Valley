/obj/item/holder
	name = "holder"
	desc = "You shouldn't ever see this."
	icon = 'icons/obj/objects.dmi'
	flags_1 = HEAR_1
	slot_flags = SLOT_HEAD | SLOT_BELT_L | SLOT_BELT_R
	var/mob/living/held_mob
	var/matrix/original_transform
	var/original_vis_flags = NONE

/obj/item/holder/Initialize(mapload, mob/held)
	. = ..()
	if(!ismob(held))
		stack_trace("Holder was not passed a mob.")
		return INITIALIZE_HINT_QDEL
	held.forceMove(src)
	START_PROCESSING(SSobj, src)

/*/mob/living/get_status_tab_items() //I'm not sure exactly what this is for, but it seems like a status panel for admins on Chomp maybe? It's a subsystem named 'statpanel'
	. = ..()
	if(. && istype(loc, /obj/item/holder))
		var/location = ""
		var/obj/item/holder/H = loc
		if(ishuman(H.loc))
			var/mob/living/carbon/human/HH = H.loc
			if(HH.l_hand == H)
				location = "[HH]'s left hand"
			else if(HH.r_hand == H)
				location = "[HH]'s right hand"
			else if(HH.r_store == H || HH.l_store == H)
				location = "[HH]'s pocket"
			else if(HH.head == H)
				location = "[HH]'s head"
			else if(HH.shoes == H)
				location = "[HH]'s feet"
			else
				location = "[HH]"
		else if(ismob(H.loc))
			var/mob/living/M = H.loc
			if(M.l_hand == H)
				location = "[M]'s left hand"
			else if(M.r_hand == H)
				location = "[M]'s right hand"
			else
				location = "[M]"
		else if(ismob(H.loc.loc))
			location = "[H.loc.loc]'s [H.loc]"
		else
			location = "[H.loc]"
		if (location != "")
			. += ""
			. += "Location: [location]"*/

/// Loads the mob into the holder and sets several vis_flags
/obj/item/holder/Entered(mob/held, atom/OldLoc)
	if(held_mob)
		held.forceMove(get_turf(src))
		return
	ASSERT(ismob(held))
	. = ..()
	held_mob = held
	original_vis_flags = held.vis_flags
	held.vis_flags = VIS_INHERIT_ID|VIS_INHERIT_LAYER|VIS_INHERIT_PLANE
	vis_contents += held
	name = held.name
	original_transform = held.transform
	held.transform = null
	//held.transform *= 0.7 //Was here prior, but not in the Chomp one? Is it needed for some Roguecode reason?

/// Handles restoring the vis flags and scale of the mob, also makes the holder invisible now that it's empty.
/obj/item/holder/Exited(atom/movable/thing, atom/OldLoc)
	if(thing == held_mob)
		held_mob.transform = original_transform
		held_mob.update_transform()
		held_mob.vis_flags = original_vis_flags
		held_mob = null
		invisibility = INVISIBILITY_ABSTRACT
	..()

/// Dumps the mob if we still hold one, and if we are held by a mob clears us from its inventory.
/obj/item/holder/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(held_mob)
		var/mob/cached_mob = held_mob
		dump_mob()
		cached_mob.reset_perspective() // This case cannot be handled gracefully, make sure the mob view is cleaned up.
	if(ismob(loc))
		var/mob/M = loc
		M.drop_from_inventory(src, loc)
	. = ..()

/// If the mob somehow leaves the holder, clean us up.
/obj/item/holder/process()
	if(held_mob?.loc != src || isturf(loc) || isbelly(loc))
		qdel(src)

/// Releases the mob from inside the holder. Calls forceMove() which calls Exited(). Then does cleanup for the client's eye location.
/obj/item/holder/proc/dump_mob()
	if(!held_mob)
		return
	if (held_mob.loc == src || isnull(held_mob.loc))
		held_mob.forceMove(loc)

/obj/item/holder/throw_at(atom/target, range, speed, thrower)
	if(held_mob)
		var/mob/localref = held_mob
		dump_mob()
		var/thrower_mob_size = 1
		if(ismob(thrower))
			var/mob/M = thrower
			thrower_mob_size = M.mob_size
		var/mob_range = round(range * min(thrower_mob_size / localref.mob_size, 1))
		localref.throw_at(target, mob_range, speed, thrower)

/obj/item/holder/GetID()
	return held_mob?.GetIdCard()

/obj/item/holder/GetAccess()
	var/obj/item/I = GetID()
	return I?.GetAccess() || ..()

/obj/item/holder/container_resist(mob/living/held)
	if(ismob(loc))
		var/mob/M = loc
		M.drop_from_inventory(src) // If it's another item, we can just continue existing, or if it's a turf we'll qdel() in Moved()
		to_chat(M, span_warning("\The [held] wriggles out of your grip!"))
		to_chat(held, span_warning("You wiggle out of [M]'s grip!"))
	else if(istype(loc, /obj/item/clothing/accessory/holster))
		var/obj/item/clothing/accessory/holster/holster = loc
		if(holster.holstered == src)
			holster.clear_holster()
		to_chat(held, span_warning("You extricate yourself from [holster]."))
		forceMove(get_turf(src))
	else if(isitem(loc))
		var/obj/item/I = loc
		to_chat(held, span_warning("You struggle free of [loc]."))
		forceMove(get_turf(src))
		if(istype(I))
			I.on_holder_escape(src)

/obj/item/holder/extrapolator_act(mob/living/user, obj/item/extrapolator/extrapolator, dry_run)
	. = ..()
	EXTRAPOLATOR_ACT_ADD_DISEASES(., held_mob.GetViruses())

//Mob specific holders.
/obj/item/holder/diona
	origin_tech = list(TECH_MAGNET = 3, TECH_BIO = 5)
	slot_flags = SLOT_HEAD | SLOT_OCLOTHING | SLOT_HOLSTER
	item_state = "diona"

/obj/item/holder/drone
	origin_tech = list(TECH_MAGNET = 3, TECH_ENGINEERING = 5)
	item_state = "repairbot"

/obj/item/holder/drone/swarm
	origin_tech = list(TECH_MAGNET = 6, TECH_ENGINEERING = 7, TECH_PRECURSOR = 2, TECH_ARCANE = 1)
	item_state = "constructiondrone"

/obj/item/holder/pai
	origin_tech = list(TECH_DATA = 2)

/obj/item/holder/pai/Initialize(mapload, mob/held)
	. = ..()
	item_state = held.icon_state

/obj/item/holder/mouse
	name = "mouse"
	desc = "It's a small rodent."
	item_state = "mouse_gray"
	slot_flags = SLOT_EARS | SLOT_HEAD | SLOT_ID
	origin_tech = list(TECH_BIO = 2)
	w_class = ITEMSIZE_TINY

/obj/item/holder/mouse/extrapolator_act(mob/living/user, obj/item/extrapolator/extrapolator, dry_run)
	. = ..()
	var/mob/living/simple_mob/animal/passive/mouse/M = held_mob
	EXTRAPOLATOR_ACT_ADD_DISEASES(., M.rat_diseases)

/obj/item/holder/mouse/white
	item_state = "mouse_white"

/obj/item/holder/mouse/gray
	item_state = "mouse_gray"

/obj/item/holder/mouse/brown
	item_state = "mouse_brown"

/obj/item/holder/mouse/black
	item_state = "mouse_black"

/obj/item/holder/mouse/operative
	item_state = "mouse_operative"

/obj/item/holder/mouse/rat
	item_state = "mouse_rat"

/obj/item/holder/possum
	origin_tech = list(TECH_BIO = 2)
	item_state = "possum"

/obj/item/holder/possum/poppy
	origin_tech = list(TECH_BIO = 2, TECH_ENGINEERING = 4)
	item_state = "poppy"

/obj/item/holder/cat
	origin_tech = list(TECH_BIO = 2)
	item_state = "cat"

/obj/item/holder/cat/runtime

/obj/item/holder/fennec
	origin_tech = list(TECH_BIO = 2)

/obj/item/holder/cat/runtime

	origin_tech = list(TECH_BIO = 2, TECH_DATA = 4)

/obj/item/holder/cat/cak
	origin_tech = list(TECH_BIO = 2)
	item_state = "cak"

/obj/item/holder/cat/bluespace
	origin_tech = list(TECH_BIO = 2, TECH_BLUESPACE = 6)
	item_state = "bscat"

/obj/item/holder/cat/spacecat
	origin_tech = list(TECH_BIO = 2, TECH_MATERIAL = 4)
	item_state = "spacecat"

/obj/item/holder/cat/original
	origin_tech = list(TECH_BIO = 2, TECH_BLUESPACE = 4)
	item_state = "original"

/obj/item/holder/cat/breadcat
	origin_tech = list(TECH_BIO = 2)
	item_state = "breadcat"

/obj/item/holder/corgi
	origin_tech = list(TECH_BIO = 2)
	item_state = "corgi"

/obj/item/holder/lisa
	origin_tech = list(TECH_BIO = 2)
	item_state = "lisa"

/obj/item/holder/old_corgi
	origin_tech = list(TECH_BIO = 2)
	item_state = "old_corgi"

/obj/item/holder/void_puppy
	origin_tech = list(TECH_BIO = 2, TECH_BLUESPACE = 3)
	item_state = "void_puppy"

/obj/item/holder/narsian
	origin_tech = list(TECH_BIO = 2, TECH_ILLEGAL = 3)
	item_state = "narsian"

/obj/item/holder/bullterrier
	origin_tech = list(TECH_BIO = 2)
	item_state = "bullterrier"

/obj/item/holder/fox
	origin_tech = list(TECH_BIO = 2)
	item_state = "fox"

/obj/item/holder/pug
	origin_tech = list(TECH_BIO = 2)
	item_state = "pug"

/obj/item/holder/sloth
	origin_tech = list(TECH_BIO = 2)
	item_state = "sloth"

/obj/item/holder/borer
	origin_tech = list(TECH_BIO = 6)
	item_state = "brainslug"

/obj/item/holder/leech
	color = "#003366"
	origin_tech = list(TECH_BIO = 5, TECH_PHORON = 2)

/obj/item/holder/cat/fluff/tabiranth
	name = "Spirit"
	desc = "A small, inquisitive feline, who constantly seems to investigate his surroundings."
	gender = MALE
	icon_state = "kitten"
	w_class = ITEMSIZE_SMALL

/obj/item/holder/cat/kitten
	icon_state = "kitten"
	w_class = ITEMSIZE_SMALL

/obj/item/holder/cat/fluff/bones
	name = "Bones"
	desc = "It's Bones! Meow."
	gender = MALE
	icon_state = "cat3"

/obj/item/holder/bird
	name = "bird"
	desc = "It's a bird!"
	icon_state = null
	item_icons = null
	w_class = ITEMSIZE_SMALL

/obj/item/holder/bird/Initialize(mapload)
	. = ..()
	held_mob?.lay_down()

/obj/item/holder/fish
	attack_verb = list("fished", "disrespected", "smacked", "smackereled")
	hitsound = 'sound/effects/slime_squish.ogg'
	slot_flags = SLOT_HOLSTER
	origin_tech = list(TECH_BIO = 3)

/obj/item/holder/fish/afterattack(var/atom/target, var/mob/living/user, proximity)
	if(!target)
		return
	if(!proximity)
		return
	if(isliving(target))
		var/mob/living/L = target
		if(prob(10))
			L.Stun(2)

/obj/item/holder/attackby(obj/item/W as obj, mob/user as mob)
	//CHOMPADDITION: MicroHandCrush
	if(W == src && user.a_intent == I_HURT)
		for(var/mob/living/M in src.contents)
			if(user.size_multiplier > M.size_multiplier)
				var/dam = (user.size_multiplier - M.size_multiplier)*(rand(2,5))
				to_chat(user, span_danger("You roughly squeeze [M]!"))
				to_chat(M, span_danger("You are roughly squeezed by [user]!"))
				log_and_message_admins("[key_name(M)] has been harmsqueezed by [key_name(user)]")
				M.apply_damage(dam)
	//CHOMPADDITION: MicroHandCrush END
	for(var/mob/M in src.contents)
		M.attackby(W,user)

//Mob procs and vars for scooping up
/mob/living/var/holder_type

/mob/living/MouseDrop(var/atom/over_object)
	var/mob/living/carbon/human/H = over_object
	if(holder_type && issmall(src) && istype(H) && !H.lying && Adjacent(H) && (src.a_intent == I_HELP && H.a_intent == I_HELP)) //VOREStation Edit
		if(!issmall(H) || !ishuman(src))
			get_scooped(H, (usr == src))
		return
	return ..()

/mob/living/proc/get_scooped(var/mob/living/carbon/grabber, var/self_grab)

	if(!holder_type || buckled || pinned.len)
		return

	// Dodge pickup if enabled by personal space bubble.
	if(!self_grab && (touch_reaction_flags & SPECIES_TRAIT_PICKUP_DODGE))
		grabber.visible_message(span_notice("[src] deftly evades [grabber]'s attempt to pick them up!"))
		to_chat(grabber, span_notice("[src] evaded your pickup attempt!"))
		return

	if(self_grab)
		if(src.incapacitated()) return
	else
		if(grabber.incapacitated()) return

	//YW edit - size diff check
	var/sizediff = grabber.size_multiplier - size_multiplier
	if(sizediff < -0.5)
		if(self_grab)
			to_chat(src, span_warning("You are too big to fit in \the [grabber]\'s hands!"))
		else
			to_chat(grabber, span_warning("\The [src] is too big to fit in your hands!"))
		return
	//end YW edit

	var/obj/item/holder/H = new holder_type(get_turf(src), src)
	H.sync(src)
	grabber.put_in_hands(H)

	if(self_grab)
		to_chat(grabber, span_notice("\The [src] clambers onto you!"))
		to_chat(src, span_notice("You climb up onto \the [grabber]!"))
		grabber.equip_to_slot_if_possible(H, slot_back, 0, 1)
	else
		to_chat(grabber, span_notice("You scoop up \the [src]!"))
		to_chat(src, span_notice("\The [grabber] scoops you up!"))

	add_attack_logs(grabber, H.held_mob, "Scooped up", FALSE) // Not important enough to notify admins, but still helpful.
	return H

/obj/item/holder/proc/sync(var/mob/living/M)
	dir = 2
	overlays.Cut()
	if(M.item_state)
		item_state = M.item_state
	color = M.color
	name = M.name
	desc = M.desc
	overlays |= M.overlays

//Everything below this was the OLD 'holder' when it was just the Micro stuff here.
/*
/obj/item/holder/Initialize(mapload, mob/held)
	. = ..()
	held.forceMove(src)
	START_PROCESSING(SSobj, src)

/obj/item/holder/examine(mob/user)
	. = list()
	for(var/mob/living/M in contents)
		. += M.examine(user)

/obj/item/holder/dropped(mob/user, silent)
	if (held_mob?.loc != src || isturf(loc))
		var/held = held_mob
		dump_mob()
		held_mob = held
	. = ..()

/obj/item/holder/proc/dump_mob()
	if(!held_mob)
		return
	if (held_mob.loc == src || isnull(held_mob.loc))
		held_mob.set_resting(FALSE,FALSE)
		held_mob.transform = original_transform
		held_mob.update_transform()
		held_mob.forceMove(get_turf(src))
		held_mob = null
		process()

/obj/item/holder/process()
	if(held_mob?.loc != src || isturf(loc))
		qdel(src)
	
/obj/item/holder/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(held_mob)
		dump_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.forceMove(get_turf(src))
	return ..()

/obj/item/holder/container_resist(mob/living/held)
	if(ismob(loc))
		var/mob/M = loc
		var/wrestling_diff = 0
		var/resist_chance = 55
		var/combat_modifier = 0.45 // -30 and -25 from being in combat mode diff and aggro grab, apply those immidietly
		if(held_mob.mind)
			wrestling_diff += (held_mob.get_skill_level(/datum/skill/combat/wrestling)) //NPCs don't use this
		if(M.mind)
			wrestling_diff -= (M.get_skill_level(/datum/skill/combat/wrestling))
		resist_chance += max((wrestling_diff * 10), -20)
		resist_chance *= combat_modifier
		resist_chance = clamp(resist_chance, 5, 95)
		if(!prob(resist_chance))
			to_chat(M, span_warning("[held] uselessly wiggles against my grip!"))
			to_chat(held, span_warning("You struggle against [M]'s grip!"))
		else
			dump_mob()
			to_chat(M, span_warning("\The [held] wriggles out of your grip!"))
			to_chat(held, span_warning("You wiggle out of [M]'s grip!"))
	else if(isitem(loc))
		to_chat(held, span_warning("You struggle free of [loc]."))
		dump_mob()
	
	process()

/obj/item/holder/Entered(mob/held, atom/OldLoc)
	. = ..()
	if(ismob(held))
		held_mob = held
		original_vis_flags = held.vis_flags
		held.vis_flags = VIS_INHERIT_ID|VIS_INHERIT_LAYER|VIS_INHERIT_PLANE
		vis_contents += held
		name = held.name
		original_transform = held.transform
		held.transform = null
		held.transform *= 0.7

/obj/item/holder/Exited(mob/held, atom/newLoc)
	var/mob/living/current_held = held_mob

	//I cannot do anything about spatials getting removed because that would be touching azure code in inappropriate places, so here is the shitcode we are doing

	//First we save the spatials that are about to be removed
	var/list/nested_locs = get_nested_locs(src)
	var/list/preremovespatials = list()
	for(var/channel in important_recursive_contents)
		for(var/atom/movable/location as anything in nested_locs)
			preremovespatials[location] = list()
			switch(channel)
				if(RECURSIVE_CONTENTS_CLIENT_MOBS, RECURSIVE_CONTENTS_HEARING_SENSITIVE)
					preremovespatials[location] += channel

	//We do the holder removal thing as per usual
	if(held == current_held) //<-- not sure what is the purpose of this single line and the indent that it makes but Lira probably knows??? Not touching it.
		current_held.set_resting(FALSE,FALSE)
		current_held.transform = original_transform
		current_held.update_transform()
		current_held.vis_flags = original_vis_flags
		vis_contents -= current_held
		original_transform = null
		original_vis_flags = NONE
		held_mob = null
	. = ..()
	
	//Then we reapply it
	for(var/reapplylocation in preremovespatials)
		for(var/channeltoreapply in reapplylocation)
			SSspatial_grid.add_grid_awareness(reapplylocation,channeltoreapply)


/obj/item/holder/MouseDrop(mob/living/M)
	..()
	if(isliving(usr))
		var/mob/living/livingusr = usr
		if(!Adjacent(usr))
			return
		/*if(M.voremode) <-- commented out until is fixed!
			if(Adjacent(M))
				livingusr.vore_attack(livingusr, held_mob, M)
			else
				to_chat(livingusr,span_notice(M + " is too far!"))*/
		else
			for(var/mob/living/carbon/human/O in contents)
				O.show_inv(livingusr)
*/
