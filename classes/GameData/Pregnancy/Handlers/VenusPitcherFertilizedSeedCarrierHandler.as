package classes.GameData.Pregnancy.Handlers 
{
	import classes.Creature;
	import classes.GameData.Pregnancy.BasePregnancyHandler;
	import classes.PregnancyData;
	import classes.kGAMECLASS;
	import classes.rand;
	
	/**
	 * ...
	 * @author Gedan
	 */
	public class VenusPitcherFertilizedSeedCarrierHandler extends BasePregnancyHandler
	{
		
		public function VenusPitcherFertilizedSeedCarrierHandler() 
		{
			_handlesType = "VenusPitcherFertilizedSeedCarrier";
			_basePregnancyIncubationTime = 1440;
			_basePregnancyChance = 1;
			_alwaysImpregnate = true;
			_ignoreMotherInfertility = true;
			_ignoreInfertility = true;
			_ignoreFatherInfertility = true;
			_allowMultiplePregnancies = false;
			_canImpregnateButt = false;
			_canImpregnateVagina = true;
			_canFertilizeEggs = false;
			_pregnancyQuantityMinimum = 4;
			_pregnancyQuantityMaximum = 9;
			
			this.addStageProgression(600, kGAMECLASS.rumblyInYourTummy);
			this.addStageProgression(240, kGAMECLASS.poppingSoonAlert1);
			this.addStageProgression(60, kGAMECLASS.poppingSoonAlert2);
			
			onDurationEnd = VenusPitcherFertilizedSeedCarrierHandler.FertilizedVenusPitcherOnDurationEnd;
		}

		public static function FertilizedVenusPitcherOnDurationEnd(mother:Creature, pregSlot:int, thisPtr:BasePregnancyHandler):void
		{
			if (!mother.hasStatusEffect("Venus Pitcher Egg Incubation Finished"))
			{
				mother.createStatusEffect("Venus Pitcher Egg Incubation Finished");
			}
			
			kGAMECLASS.eventQueue.push(function():void {
					kGAMECLASS.layFertilizedVenusPitcherEgg();
					VenusPitcherFertilizedSeedCarrierHandler.cleanupPregnancy(kGAMECLASS.pc);
				});
		}
	
		public static function convertPregnancy(father:Creature, mother:Creature, pregSlot:int):void
		{
			var pData:PregnancyData = mother.pregnancyData[pregSlot];
			pData.pregnancyType = "VenusPitcherFertilizedSeedCarrier";
			pData.pregnancyIncubation = 1440;
			
			// Remove the seed residue effect as part of the fertilization process.
			if (mother.hasStatusEffect("Venus Pitcher Seed Residue"))
			{
				mother.removeStatusEffect("Venus Pitcher Seed Residue");
			}
			
			// Remove the existing initial incubation time marker
			if (mother.hasStatusEffect("Venus Pitcher Egg Incubation Finished"))
			{
				mother.removeStatusEffect("Venus Pitcher Egg Incubation Finished");
			}
			
			// Do some outpootis.
			kGAMECLASS.eventBuffer += "\n\nYour womb rumbles audibly as the plant-matter inside you reacts to something, and your [pc.belly] visibly swells.";
			
			if (kGAMECLASS.flags["LAID VENUS PITCHER SEEDS"] != undefined) kGAMECLASS.eventBuffer += " Mmmm, another batch of pods are growing inside you.";
			else kGAMECLASS.eventBuffer += " The stuff the venus pitcher put inside you... it's growing!";
			
			kGAMECLASS.eventBuffer += " A few droplets of pale-green slime leak from your lips";
			
			if (mother.isCrotchGarbed()) kGAMECLASS.eventBuffer += " into your " + mother.lowerUndergarment.longName;
			
			kGAMECLASS.eventBuffer += ".";

			// Change bellyMod
			mother.bellyRatingMod += 2 * pData.pregnancyQuantity;
			pData.pregnancyBellyRatingContribution += 2 * pData.pregnancyQuantity;
		}
		
		public static function cleanupPregnancy(target:Creature):void
		{
			if (target.hasStatusEffect("Venus Pitcher Seed Residue"))
			{
				target.setStatusMinutes("Venus Pitcher Seed Residue", 20160);
			}
			else
			{
				target.createStatusEffect("Venus Pitcher Seed Residue", 0, 0, 0, 0, true, "", "", false, 20160);
			}
			
			var pData:PregnancyData	= target.getPregnancyOfType("VenusPitcherFertilizedSeedCarrier");
			pData.pregnancyQuantity--;
			pData.pregnancyBellyRatingContribution -= 14;
			pData.pregnancyIncubation = 240 + rand(30);
			target.bellyRatingRaw -= 14;
			
			if (pData.pregnancyQuantity == 0)
			{
				if (target.hasStatusEffect("Venus Pitcher Egg Incubation Finished")) target.removeStatusEffect("Venus Pitcher Egg Incubation Finished");
				pData.reset();
			}
		}
		
		/**
		 * Fertilized seeds will make reference to the squirmly tentacle arm things, and the fact
		 * the size is effectively inverted.
		 * 
		 * Some of this text + logic might be pretty dumb, but I'm ill as fuck and I want to DO something.
		 * @param	target
		 * @param	slot
		 * @return
		 */
		override public function pregBellyFragment(target:Creature, slot:int):String
		{
			var pData:PregnancyData = target.pregnancyData[slot];
			var retString:String = "";
			
			// This would have been 9, but it would be impossible to hit it given the cap is 9 eggs, and the first is laid when the ^ status effect is applied
			if (pData.pregnancyQuantity >= 8)
			{
				// Megafull
				retString = "Your belly protrudes unnaturally far forward, the ovoid objects stuffed into your womb by the venus pitchers forming slight bulges in your [pc.skinFurScales]. ";
			}
			else if (pData.pregnancyQuantity >= 7)
			{
				// Full
				retString = "Your belly is painfully distended by your pregnancy, the venus pitcher seed pods stuffing your womb to an uncomfortable degree. ";
			}
			else if (pData.pregnancyQuantity >= 4)
			{
				retString = "Your belly is clearly distended by your pregnancy, the venus pitcher seed pods stuffing your womb to the brim. ";
			}
			else if (pData.pregnancyQuantity >= 3)
			{
				// First one (minimum) is done, trepidation at the rest
				retString = "Your belly is still clearly distended by your pregnancy, the venus pitcher seed pods stuffing your womb throughly. Birthing the pods is an arduous task, but some part of you looks forward to the next time you can experience the process. ";
			}
			else if (pData.pregnancyQuantity == 1)
			{
				// Had fun, just one left....
				retString = "Your belly has shrunken considerably since your initial impregnantion at the tentacle-tips of the venus pitchers, but you can still clearly make out a final pod residing deep within your womb. ";
			}
			
			if (target.hasStatusEffect("Venus Pitcher Egg Incubation Finished"))
			{
				// Eggs incubated and we're prepping to lay a new one
				if (pData.pregnancyIncubation <= 60)
				{
					retString += "Your [pc.vagina] has grown wetter and eager once more, preparing itself for the coming task of birthing another of the venus pitchers seed pods.";
				}
				else if (pData.pregnancyIncubation <= 120)
				{
					retString += "The [pc.skinFurScales] covering your belly occasionally writhes under the motions of the seed pods packed into your womb.";
				}
				else if (pData.pregnancyIncubation <= 600)
				{
					retString += "Hints of slime are once again leaking down your thighs. Your [pc.vagina] must be preparing itself for the upcoming task the Venus Pitchers have burdened your womb with.";
				}
			}
			else
			{
				// Eggs still incubating
				if (pData.pregnancyIncubation <= 60)
				{
					retString += "You'll be laying soon, you're sure of it. Your [pc.vagina] has grown wetter and eager, birth-slime practically dripping out of you.";
				}
				else if (pData.pregnancyIncubation <= 120)
				{
					retString += "The [pc.skinFurScales] covering your belly occasionally writhes under the motions of the objects packed into your womb.";
				}
				else if (pData.pregnancyIncubation <= 600)
				{
					retString += "Hints of slime leak down your thighs, your [pc.vagina] preparing itself for the upcoming task the venus pitchers have burdened your womb with.";
				}
			}
			
			return retString;
		}
	}
}