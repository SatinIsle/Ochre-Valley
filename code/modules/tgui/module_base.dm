/*
TGUI MODULES

This allows for datum-based TGUIs that can be hooked into objects.
This is useful for things such as the power monitor, which needs to exist on a physical console in the world, but also as a virtual device the AI can use

Code is pretty much ripped verbatim from nano modules, but with un-needed stuff removed
*/
/datum/tgui_module
	var/name
	var/datum/host
	var/list/using_access

	var/tgui_id

/datum/tgui_module/New(var/host)
	src.host = host

/datum/tgui_module/Destroy(force)
	host = null
	. = ..()

/datum/tgui_module/ui_host()
	return host ? host.ui_host() : src

/datum/tgui_module/ui_assets(mob/user)
	var/list/data = list()
	return data

/datum/tgui_module/ui_close(mob/user)
	if(host)
		host.ui_close(user)

/datum/tgui_module/proc/can_still_topic(mob/user, datum/ui_state/state)
	return (ui_status(user, state) == UI_INTERACTIVE)

/datum/tgui_module/ui_act(action, params, datum/tgui/ui)
	if(..())
		return TRUE

// Just a nice little default interact in case the subtypes don't need any special behavior here
/datum/tgui_module/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, tgui_id, name)
		ui.open()

/datum/tgui_module/proc/relaymove(mob/user, direction)
	return FALSE

/datum/tgui_module/proc/close_ui()
	SStgui.close_uis(src)
