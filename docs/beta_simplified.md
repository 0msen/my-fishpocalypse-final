Aesthetic:
- Pixel Retro, fixed camera perspective, 2.5D, characters are pixels, environment is 3D


Environment:
- Fixed environment


Goal:
- No end goal, just survive as N many nights as possible


State/Day system:
- Controls day/night cycle
- Every (10th, 20th, ...) day spawns a buff after the wave ends
- Enables Spawn Enemy System and Spawn Buff System


Gameplay:
- Survive n amount of days; makes fish more frequent
- Day: you fish
- Night: you survive a lot of angry fish


Player system:
- HP
- CP (cast points, mana system for abilities)
- SP (stamina points)
- Inventory slots (based on inventory system)
- Combat system:
- Shooting uses Recharge Cost/shot and CP
- Dodging uses SP


Inventory system:
- Pole slot: your fishing pole
- Main slot: primary weapon
- Secondary slot: secondary weapon
- Two item slots: HP, shield, buffs
- Stores → (FishWeapons[], HealingItem[], FishingPoles[])

Fishing system:
- Refer to Stardew Valley
- Produces → (FishWeapons[], HealingItems[], FishingPoles[])

Fish system:
- Fish that can be caught can be either a weapon or an item
- Some only appear after n days (balancing)

Fish weapon attribute:
- Rarity (multiplier for base stats)
- Spawns only after nth day
- Damage/second
- Projectiles/shot
- Recharge Cost/shot
- delay after shot

Rarity system:
- Affects base stats of all weapons
- Rarity array: [common, uncommon, rare, epic, legendary, "???"]

Enemy pool:
- Normal Fish: melee attack
- Tanky Fish: high damage melee attack
- Shooting Fish: ranged projectile attack

Spawn Enemy system:
- Spawns n amount of fish per night
- Spawn distribution based on fish rarity
- Total population grows by scaling factor over time
- Spawns → (Normal Fish, Tanky Fish, Shooting Fish)

Spawn Item system:
- Spawns all items, weapons, buffs
- Items spawn with randomized velocity + gravity, scattering around drop point (e.g., player)

Item pool:
- FishWeapons array [idk how many]
- HealingItem array [class I, class II, class III, class IV]
- FishingPoles array [normal, reinforced, fish pole variant]
- Buffs array [idk how many]

Buff system:
- Buffs array []
- Buffs improve player stats

Relations:
Player → has → (Inventory System, Fishing System, Combat System, Buff System)
State/Day System → enables → (Spawn Enemy System, Spawn Buff System)
Fishing System → produces → (FishWeapons[], HealingItems[], FishingPoles[])
Inventory System → stores → (FishWeapons[], HealingItems[], FishingPoles[])
Rarity System → modifies → (all FishWeapons stats)
Spawn Enemy System → spawns → (Normal Fish, Tanky Fish, Shooting Fish)
Spawn Item System → spawns → (all items, weapons, buffs)

Ato ni e divide nato ang mga systems ato buhaton
