/obj/item/reagent_containers/dropper
	name = "dropper"
	desc = "A dropper. Holds up to 5 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dropper0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1, 2, 3, 4, 5)
	volume = 5
	reagent_flags = TRANSPARENT

/obj/item/reagent_containers/dropper/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(!target.reagents)
		return

	if(reagents.total_volume > 0)
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='notice'>[target] is full.</span>")
			return

		if(!target.is_injectable(user))
			to_chat(user, "<span class='warning'>You cannot transfer reagents to [target]!</span>")
			return

		var/trans = 0
		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)

		if(ismob(target))
			if(ishuman(target))
				var/mob/living/carbon/human/victim = target

				var/obj/item/safe_thing = victim.is_eyes_covered()

				if(safe_thing)
					if(!safe_thing.reagents)
						safe_thing.create_reagents(100)

					reagents.reaction(safe_thing, TOUCH, fraction)
					trans = reagents.trans_to(safe_thing, amount_per_transfer_from_this, transfered_by = user)

					target.visible_message("<span class='danger'>[user] tries to squirt something into [target]'s eyes, but fails!</span>", \
											"<span class='userdanger'>[user] tries to squirt something into [target]'s eyes, but fails!</span>")

					to_chat(user, "<span class='notice'>You transfer [trans] unit\s of the solution.</span>")
					update_icon()
					return
			else if(isalien(target)) //hiss-hiss has no eyes!
				to_chat(target, "<span class='danger'>[target] does not seem to have any eyes!</span>")
				return

			target.visible_message("<span class='danger'>[user] squirts something into [target]'s eyes!</span>", \
									"<span class='userdanger'>[user] squirts something into [target]'s eyes!</span>")

			reagents.reaction(target, TOUCH, fraction)
			var/mob/M = target
			var/R
			var/viruslist = "" // yogs - adds viruslist variable
			if(reagents)
				for(var/datum/reagent/A in src.reagents.reagent_list)
					R += "[A] ([num2text(A.volume)]),"
// yogs start - checks blood for disease
					if(istype(A, /datum/reagent/blood))
						var/datum/reagent/blood/RR = A
						for(var/datum/disease/D in RR.data["viruses"])
							viruslist += " [D.name]"
							if(istype(D, /datum/disease/advance))
								var/datum/disease/advance/DD = D
								viruslist += " \[ symptoms: "
								for(var/datum/symptom/S in DD.symptoms)
									viruslist += "[S.name] "
								viruslist += "\]"
// yogs end
			log_combat(user, M, "squirted", R)

// yogs start - Adds logs if it is viruslist
			if(viruslist)
				investigate_log("[user.real_name] ([user.ckey]) injected [M.real_name] ([M.ckey]) using a projectile with [viruslist]", INVESTIGATE_VIROLOGY)
				log_game("[user.real_name] ([user.ckey]) injected [M.real_name] ([M.ckey]) with [viruslist]")
// yogs end

		trans = src.reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>You transfer [trans] unit\s of the solution.</span>")
		update_icon()

	else

		if(!target.is_drawable(user, FALSE)) //No drawing from mobs here
			to_chat(user, "<span class='notice'>You cannot directly remove reagents from [target].</span>")
			return

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty!</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user)

		to_chat(user, "<span class='notice'>You fill [src] with [trans] unit\s of the solution.</span>")

		update_icon()

/obj/item/reagent_containers/dropper/update_icon()
	cut_overlays()
	if(reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "dropper")
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)

/obj/item/reagent_containers/dropper/cyborg
	name = "Industrial Dropper"
	desc = "A larger dropper. Transfers 10 units."
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
	volume = 10

/obj/item/reagent_containers/dropper/precision
	name = "pipette"
	desc = "A high precision pippette. Holds 1 unit."
	icon_state = "pipette"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1)
	volume = 1

//Syndicate item. Virus transmitting mini hypospray
/obj/item/reagent_containers/dropper/precision/viral_injector

/obj/item/reagent_containers/dropper/precision/viral_injector/attack(mob/living/M, mob/living/user, def_zone)
	if(M.can_inject(user, TRUE))
		to_chat(user, "<span class='warning'>You stab [M] with the [src].</span>")
		if(reagents.total_volume && M.reagents)
			var/list/injected = list()
			for(var/datum/reagent/R in reagents.reagent_list)
				injected += R.name
				var/datum/reagent/blood/B = R

				if(istype(B) && B.data["viruses"])
					var/virList = list()
					for(var/dis in B.data["viruses"])
						var/datum/disease/D = dis
						var/virusData = D.name
						var/english_symptoms = list()
						var/datum/disease/advance/A = D
						if(A)
							for(var/datum/symptom/S in A.symptoms)
								english_symptoms += S.name
							virusData += " ([english_list(english_symptoms)])"
						virList += virusData
					var/str = english_list(virList)
					add_attack_logs(user, M, "Infected with [str].")

				reagents.reaction(M, REAGENT_INGEST, reagents.total_volume)
				reagents.trans_to(M, 1)

			var/contained = english_list(injected)
			add_attack_logs(user, M, "Injected with [src] containing ([contained])")
