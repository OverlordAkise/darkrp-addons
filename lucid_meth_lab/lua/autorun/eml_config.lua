-- Stove consumption on heat amount.
EML_Stove_Consumption = 1
-- Stove heat amount.
EML_Stove_Heat = 1
-- Amount of gas in stove and gas canister.
EML_Gas_Amount = 900
-- Can grab with gravity gun?
EML_Stove_GravityGun = true
-- 0 - Can't be exploded/destroyed; 1 - Can be destroyed without explosion; 2 - Explodes after taking amount of damage.
EML_Stove_ExplosionType = 2
-- Stove health if type 1 or 2.
EML_Stove_Health = 400
-- Stove explosion damage if type 2.
EML_Stove_ExplosionDamage = 100

-- Pot default time.
EML_Pot_StartTime = 60
-- Default time, which will be added to pot on collision with Muriatic Acid.
EML_Pot_OnAdd_MuriaticAcid = 10
-- Default time, which will be added to pot on collision with Liquid Sulfur.
EML_Pot_OnAdd_LiquidSulfur = 10
-- Change to false if you won't water/iodine/acid/sulfur disappear on empty.
EML_Pot_DestroyEmpty = true

-- Special Pot default time.
EML_SpecialPot_StartTime = 50
-- Default time, which will be added to pot on collision with Red Phosphorus.
EML_SpecialPot_OnAdd_RedPhosphorus = 10
-- Default time, which will be added to pot on collision with Crystallized Iodine.
EML_SpecialPot_OnAdd_CrystallizedIodine = 10
-- Change to false if you won't Red Phosphorus/Crystallized Iodine disappear on empty.
EML_SpecialPot_DestroyEmpty = true

-- Default Liquid Sulfur amount.
EML_Sulfur_Amount = 2
EML_Sulfur_Color = Color(243, 213, 19, 255)
-- Default Muriatic Acid amount.
EML_MuriaticAcid_Amount = 3
EML_MuriaticAcid_Color = Color(160, 221, 99, 255)
-- Default Liquid Iodine amount.
EML_Iodine_Amount = 2
EML_Iodine_Color = Color(137, 69, 54, 255)
-- Default Water amount.
EML_Water_Amount = 3
EML_Water_Color = Color(133, 202, 219, 255)

-- Meth value modifier. (1500/lbs)
EML_Meth_ValueModifier = 2500
-- Meth addicted person (I don't like NPCs at all).
EML_Meth_UseSalesman = true

-- Type 'methbuyer_setpos <name>' to add NPC on map (at your target position and faces to you).
-- Type 'methbuyer_remove <name>' to remove NPC from map.

-- Salesman phrases if player don't have meth.
EML_Meth_Salesman_NoMeth = "You don't have meth! Get out of here!"

-- Salesman sounds if player don't have meth.
EML_Meth_Salesman_NoMeth_Sound = "vo/npc/male01/gethellout.wav"

-- Salesman phrases if player got meth.
EML_Meth_Salesman_GotMeth = "Wow that rocks!"
	
-- Salesman phrases if player don't have meth.	
EML_Meth_Salesman_GotMeth_Sound = "vo/npc/male01/yeah02.wav"

-- It starts on 0%.
EML_Jar_StartProgress = 0
-- Minimal speed on shaking. (25 is ok)
EML_Jar_MinShake = 25
-- Minimal speed on shaking. (1000 is ok)
EML_Jar_MaxShake = 1000
-- Progress on correct shaking.
EML_Jar_CorrectShake = 6
-- Progress on correct shaking.
EML_Jar_WrongShake = 3
-- 0 - Can't be exploded/destroyed; 1 - Can be destroyed without explosion; 2 - Explodes instantly.
EML_Gas_ExplosionType = 0
