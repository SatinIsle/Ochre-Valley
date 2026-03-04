//PORTED AND ADAPTED FROM ROGUESTAR: https://github.com/TS-Rogue-Star/Rogue-Star/pull/1261

SUBSYSTEM_DEF(inventory_return)
	name = "Inventory Return"
	flags = SS_NO_FIRE

	var/list/master_inv = list()		//Master list for checking against
	var/list/sorted_inv = list()		//A list of lists indexed by mobs real_name
	var/list/blacklisted_types = list(	//A list of types we're not allowed to store
		/obj/item/organ,
		/obj/item/reagent_containers
	)

/datum/controller/subsystem/inventory_return/proc/catalogue_object(var/obj/item/I,var/mob/living/L)
	if(!I)
		return FALSE
	if(I in master_inv)	//This object has already been registered so let's not even think about it!
		return TRUE
	if(!L)
		if(isliving(I.loc))
			L = I.loc
	if(!check_viability(I,L))
		return FALSE
	master_inv |= I
	if(!sorted_inv[L.real_name])
		sorted_inv[L.real_name] = list(I)
	else
		sorted_inv[L.real_name] |= I

	RegisterSignal(I, COMSIG_PARENT_QDELETING, PROC_REF(unregister_item), TRUE)

	return TRUE

/datum/controller/subsystem/inventory_return/proc/preserve_object(var/obj/item/I)
	if(!catalogue_object(I))
		return FALSE
	if(isliving(I.loc))
		var/mob/living/L = I.loc
		L.dropItemToGround(I,force = TRUE)	//Unequip it just to be sure
	mob_check(I)	//Check to make sure there's no mobs hidden inside of it, we're about to send it to nullspace, so we want to make extra super sure
	I.moveToNullspace()
	I.digest_stage = null	//Reset its digest damage back to normal
	return TRUE

/datum/controller/subsystem/inventory_return/proc/digest_inventory_preserve(var/mob/living/L)
	if(!L)
		return
	catalogue_full_inventory(L)
	preserve_full_inventory(L)

/datum/controller/subsystem/inventory_return/proc/catalogue_full_inventory(var/mob/living/L)
	if(!L)
		return
	var/list/our_inventory = L.get_equipped_items(TRUE)

	for(var/obj/item/I in our_inventory)
		catalogue_object(I)
	for(var/obj/item/I in L.held_items)
		catalogue_object(I)

/datum/controller/subsystem/inventory_return/proc/preserve_full_inventory(var/mob/living/L)
	if(!L)
		return
	for(var/obj/item/I in sorted_inv[L.real_name])
		preserve_object(I)

/datum/controller/subsystem/inventory_return/proc/mob_check(var/atom/movable/AM,var/atom/droploc)
	if(!AM)
		return

	if(!droploc)
		droploc = find_belly_or_turf(AM)

	for(var/thing in AM.contents)
		if(isliving(thing))
			var/mob/living/L = thing
			L.forceMove(droploc)
			continue
		if(istype(thing,/obj/item/micro))	//Micro holders always hold mobs! If we find one we don't even need to think about it
			var/obj/item/micro/M = thing
			M.forceMove(droploc)
			continue
		mob_check(thing,droploc)	//We need to recursive check allllll the way down, since you can hide a person in a bottle, in a shirt, in a bag, etc etc etc

/datum/controller/subsystem/inventory_return/proc/dispense(var/mob/living/L, var/turf/dispense_loc, var/atom/source)
	if(!L || !dispense_loc)
		return FALSE
	if(!isliving(L))
		return FALSE
	var/to_dispense = L.real_name
	var/list/ourlist = sorted_inv[to_dispense]
	if(ourlist?.len <= 0)
		return FALSE
	if(!isturf(dispense_loc))
		dispense_loc = get_turf(dispense_loc)
	var/msg = "\The [L] retrieves "
	for(var/obj/item/I in ourlist)
		if(I.loc)
			if(!isbelly(I.loc))	//If we're tracking it and it's not in a belly then someone may be using it or looking at it, so if it isn't in nullspace or in a belly we will assume someone wanted to hold on to it.
				continue
		I.forceMove(dispense_loc)
		master_inv -= I
		sorted_inv[to_dispense] -= I
		UnregisterSignal(I,COMSIG_PARENT_QDELETING)
		if(ourlist.len > 0)
			msg += "[I.name], "
		else
			if(source)
				msg += "and [I.name] from \the [source]."
			else
				msg += "and [I.name]."

	dispense_loc.visible_message(span_notice(msg),runechat_message = "clunk")
	sorted_inv -= to_dispense
	return TRUE

/datum/controller/subsystem/inventory_return/proc/check_viability(var/obj/item/candidate,var/mob/living/L)
	if(!candidate)
		return FALSE
	if(is_type_in_list(candidate.type, blacklisted_types))
		return FALSE
	if(!isitem(candidate))
		return FALSE
	if(!isliving(L))	//If it's not on a mob then we don't have a good way of knowing who it belongs to, and so can't really determine who to return it to
		return FALSE
	if(!L.last_login_key)
		return FALSE
	return TRUE

/datum/controller/subsystem/inventory_return/proc/unregister_item()
	var/obj/item/I = args[1]	//args got from signal

	if(!I)
		return

	UnregisterSignal(I,COMSIG_PARENT_QDELETING)

	master_inv -= I

	for(var/thing in sorted_inv)
		if(!islist(sorted_inv[thing]))
			continue
		sorted_inv[thing] -= I

/datum/controller/subsystem/inventory_return/proc/beltcheck(var/mob/living/L,var/preserve = FALSE)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.beltr)
			if(preserve)
				preserve_object(H.beltr)
			else
				catalogue_object(H.beltr)
		if(H.beltl)
			if(preserve)
				preserve_object(H.beltl)
			else
				catalogue_object(H.beltl)

/////////////

/proc/find_belly_or_turf(var/atom/movable/AM)
	if(!AM)
		return FALSE
	if(isturf(AM.loc) || isbelly(AM.loc))
		return AM.loc

	return find_belly_or_turf(AM.loc)

/////////////

/mob
	var/last_login_key

/mob/Login()
	. = ..()
	last_login_key = key	//Because it is possible to become other mobs and things which clears your key, ckey, and client. Want to be sure there is something to indicate that this mob was definitively a player at some point.

/obj/belly/Entered(atom/movable/thing, atom/OldLoc)	//Makes it so that even if you drop stuff in a belly you can recover it. So you can throw your clothes off or whatever.
	if(!isliving(OldLoc))
		return
	var/mob/living/L = OldLoc
	if(L == owner)	//Don't count things you ate yourself silly
		return
	SSinventory_return.catalogue_object(thing,L)
	..()
