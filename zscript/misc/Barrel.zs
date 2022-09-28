Class BarrelExploding : Actor replaces Explosivebarrel
	{
	Default
	{
		Health 20;
		Radius 10;
		Height 34;
		+SOLID;
		+SHOOTABLE;
		+NOBLOOD;
		+ACTIVATEMCROSS;
		+DONTGIB;
		+NOICEDEATH;
		DamageType "fire";
		Deathsound("Barrel/Hiss");
		Obituary "$OB_BARREL";	
		}
	States
	{
	
  Spawn:
    BAR1 AB 6;
    Loop;
  Death:
    BEXP A 5 Bright;
    BEXP B 5 Bright A_Scream;
    BEXP C 5 Bright;
    BEXP D 5 Bright A_Explode();
		TNT1 A 0 { 
           if (GetCvar("weapon_particle_toggle") == 1)
            {		
				A_SpawnProjectile ("Rocketdebris", 0, 0, random (0, 360), 2, random (0, 360));				
				A_SpawnProjectile ("SmokeSpawner", 0, 0, random (0, 360), 2, random (0, 360));	
				A_SpawnProjectile ("Rocketdebris", 0, 0, random (0, 360), 2, random (0, 360));				
				A_SpawnProjectile ("SmokeSpawner", 0, 0, random (0, 360), 2, random (0, 360));	
				A_SpawnProjectile ("Rocketdebris", 0, 0, random (0, 360), 2, random (0, 360));				
				A_SpawnProjectile ("SmokeSpawner", 0, 0, random (0, 360), 2, random (0, 360));	
				A_SpawnProjectile ("Rocketdebris", 0, 0, random (0, 360), 2, random (0, 360));				
				A_SpawnProjectile ("SmokeSpawner", 0, 0, random (0, 360), 2, random (0, 360));					
				A_SpawnProjectile ("Rocketdebris", 0, 0, random (0, 360), 2, random (0, 360));				
				A_SpawnProjectile ("SmokeSpawner", 0, 0, random (0, 360), 2, random (0, 360));	
				A_SpawnProjectile ("Rocketdebris", 0, 0, random (0, 360), 2, random (0, 360));				
				A_SpawnProjectile ("SmokeSpawner", 0, 0, random (0, 360), 2, random (0, 360));					
				}	
			}	
		BOOM ABCD 1 BRIGHT A_SetTranslucent(0.8,1);
		BOOM EFGH 1 BRIGHT A_SetTranslucent(0.5,1);
		BOOM IJKLMNOPQRSTUVWXY 1 BRIGHT A_SetTranslucent(0.3,1);	
	Stop;
	}		
	
		
}	
