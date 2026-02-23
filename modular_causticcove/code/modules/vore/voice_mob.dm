//A very, very simple mob that exists inside other objects to talk and has zero influence on the world.
/mob/living/voice
	name = "unknown person"
	desc = "How are you examining me?"
	see_invisible = SEE_INVISIBLE_LIVING
	//var/obj/item/communicator/comm = null
	var/item_tf = FALSE

	//emote_type = 2 //This lets them emote through containers.  The communicator has a image feed of the person calling them so...

/mob/living/voice/Initialize(mapload)
	grant_language(/datum/language/common)
	selected_default_language = /datum/language/common

	//if(istype(loc, /obj/item/communicator))
	//	comm = loc
	. = ..()

// Proc: transfer_identity()
// Parameters: 1 (speaker - the mob (usually an observer) to copy information from)
// Description: Copies the mob's icons, overlays, TOD, gender, currently loaded character slot, and languages, to src.
/mob/living/voice/proc/transfer_identity(mob/speaker)
	if(ismob(speaker))
		icon = speaker.icon
		icon_state = speaker.icon_state
		overlays = speaker.overlays
		//timeofdeath = speaker.timeofdeath

		alpha = 127 //Maybe we'll have hologram calls later.
		if(speaker.client && speaker.client.prefs)
			var/datum/preferences/p = speaker.client.prefs
			name = p.real_name
			real_name = name
			gender = p.gender

			for(var/language in p.pref_species.languages)
				grant_language(language)
			
			grant_language(p.extra_language)

// Proc: ghostize()
// Parameters: None
// Description: Sets a timeofdeath variable, to fix the free respawn bug.
/mob/living/voice/ghostize()
	timeofdeath = world.time
	. = ..()
