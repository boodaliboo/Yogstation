/mob/living/simple_animal/hostile/yeti
	name = "Angry Stick Yeti"
	desc = "It's a horrifyingly enormous yeti, and it seems to resemble something nostalgic"
	icon = 'goon/icons/obj/yeti.dmi'
	icon_state = "yeti"
	icon_living = "yeti"
	icon_dead = "yeti_dead"
	gender = NEUTER
	speak_chance = 0
	maxHealth = 100
	health = 100
	see_in_dark = 3
	speed = 3
	butcher_results = list(/obj/item/stack/sheet/bone = 5)
	response_harm   = "smacks"
	melee_damage_lower = 10
	melee_damage_upper = 15
	attacktext = "slashes, claws"
	attack_sound = 'sound/weapons/punch1.ogg'
	faction = list("skeleton")

	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 5, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 150
	maxbodytemp = 500
	gold_core_spawnable = HOSTILE_SPAWN

/obj/effect/spawner/lootdrop/mob/yeti
	name = "Yeti"
	lootdoubles = 0
	lootcount = 1
	loot = list(/mob/living/simple_animal/hostile/yeti = 1,
			/mob/living/simple_animal/pet/penguin = 1,
			/mob/living/simple_animal/hostile/skeleton/ice = 1,
			/mob/living/simple_animal/hostile/skeleton/eskimo = 1,
			/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/icewing = 1)
