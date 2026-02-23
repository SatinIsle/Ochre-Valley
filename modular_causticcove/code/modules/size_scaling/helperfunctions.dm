/proc/issmall(A)
	if(A && isliving(A))
		var/mob/living/L = A
		return L.mob_size <= MOB_SMALL
	return 0

//returns the number of size categories between two mob_sizes, rounded. Positive means A is larger than B
/proc/mob_size_difference(var/mob_size_A, var/mob_size_B)
	return round(log(2, mob_size_A/mob_size_B), 1)

/mob/proc/can_wield_item(obj/item/W)
	if(W.w_class >= WEIGHT_CLASS_BULKY && issmall(src))
		return FALSE //M is too small to wield this
	return TRUE

/proc/istiny(A)
	if(A && isliving(A))
		var/mob/living/L = A
		return L.mob_size <= MOB_TINY
	return 0


/proc/ismini(A)
	if(A && isliving(A))
		var/mob/living/L = A
		return L.mob_size <= MOB_MINISCULE
	return 0

//Older helpers - Might not be used now?
/*/mob/living/carbon/human/proc/can_be_picked_up(mob/living/carbon/human/other)
	//TODO consentual before sensual
	if(client)
		if(!client.prefs.pickupable)
			return FALSE
	return TRUE

/mob/living/carbon/human/proc/get_size()
	if(HAS_TRAIT(src, TRAIT_MICRO))
		return 1
	//TODO: Someone is going to put a size between micro and normal, that one will go here with the num 2
	if(HAS_TRAIT(src, TRAIT_MACRO) || HAS_TRAIT(src, TRAIT_BIGGUY))
		var/beeg = 0
		if(HAS_TRAIT(src, TRAIT_MACRO))
			beeg = 6
		if(HAS_TRAIT(src,TRAIT_BIGGUY))
			beeg += 4
		return beeg
	else
		return 3
		

/mob/living/carbon/human/proc/small_enough(mob/living/carbon/human/other)
	var/othersize = other.get_size()
	if(get_size() + 2 <= othersize)
		return TRUE
	return FALSE
*/
