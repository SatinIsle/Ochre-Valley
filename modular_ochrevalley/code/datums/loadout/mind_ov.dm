//OV FILE

/datum/mind
	var/show_in_directory
	var/directory_tag
	var/directory_erptag
	var/directory_gendertag
	var/directory_sexualitytag
	var/directory_ad

/mob/living/mind_initialize()
	. = ..()
	if (client?.prefs)
		mind.show_in_directory = client.prefs.show_in_directory
		mind.directory_tag = client.prefs.directory_tag
		mind.directory_erptag = client.prefs.directory_erptag
		mind.directory_ad = client.prefs.directory_ad
		mind.directory_gendertag = client.prefs.directory_gendertag
		mind.directory_sexualitytag = client.prefs.directory_sexualitytag
