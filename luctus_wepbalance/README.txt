# Luctus Weaponbalance

This addon lets you balance weapons ingame.  

Simply hold the weapon you want to change and type !balance in the chat.  
You can edit any values on a weapon that are either: text, number or vectors.

This was tested with:
 - M9k
 - TFA
 - CW2
 - FA:S 2

This won't change the lua files but instead change the weapon table after loading all the weapons.  
Every player will get the updated weapon stats after it has been saved in the balance window.  
Weapons that are already spawned are not affected by changing stats, you have to spawn a new weapon for it to have the adjusted attributes.

I tested the networking load with all m9k weapons, changing the damage, rpm, clipsize and starting ammunition on every gun in the pack. It was working flawlessly.
