Class BarrelExploding : Actor replaces ExplosiveBarrel
{
	Default
	{
		+SOLID;
		+SHOOTABLE;
		+NOBLOOD;
		+ACTIVATEMCROSS;
		+DONTGIB;
		+NOICEDEATH;
		Health 20;
		Radius 10;
		Height 34;
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
				A_SpawnProjectile("RocketDebris", 0, 0, random(0, 360), 2, random(0, 360));
				A_SpawnProjectile("SmokeSpawner", 0, 0, random(0, 360), 2, random(0, 360));
				A_SpawnProjectile("RocketDebris", 0, 0, random(0, 360), 2, random(0, 360));
				A_SpawnProjectile("SmokeSpawner", 0, 0, random(0, 360), 2, random(0, 360));
				A_SpawnProjectile("RocketDebris", 0, 0, random(0, 360), 2, random(0, 360));
				A_SpawnProjectile("SmokeSpawner", 0, 0, random(0, 360), 2, random(0, 360));
				A_SpawnProjectile("RocketDebris", 0, 0, random(0, 360), 2, random(0, 360));
				A_SpawnProjectile("SmokeSpawner", 0, 0, random(0, 360), 2, random(0, 360));
				A_SpawnProjectile("RocketDebris", 0, 0, random(0, 360), 2, random(0, 360));
				A_SpawnProjectile("SmokeSpawner", 0, 0, random(0, 360), 2, random(0, 360));
				A_SpawnProjectile("RocketDebris", 0, 0, random(0, 360), 2, random(0, 360));
				A_SpawnProjectile("SmokeSpawner", 0, 0, random(0, 360), 2, random(0, 360));
			}
		}
		BOOM ABCD 1 Bright A_SetTranslucent(0.8, 1);
		BOOM EFGH 1 Bright A_SetTranslucent(0.5, 1);
		BOOM IJKLMNOPQRSTUVWXY 1 Bright A_SetTranslucent(0.3, 1);
		Stop;
	}
}
