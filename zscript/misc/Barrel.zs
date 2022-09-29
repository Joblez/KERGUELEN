Class BarrelExploding : Actor replaces ExplosiveBarrel
{
	Default
	{
		Health 20;
		Radius 10;
		Height 34;
		DamageType "fire";
		DeathSound("Barrel/Hiss");
		Obituary "$OB_BARREL";
		+SOLID;
		+SHOOTABLE;
		+NOBLOOD;
		+ACTIVATEMCROSS;
		+DONTGIB;
		+NOICEDEATH;
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
			if (GetCVar("weapon_particle_toggle") == 1)
			{
				for (int i = 0; i < 6; ++i)
				{
					A_SpawnProjectile("RocketDebris", 0, 0, random(0, 360), 2, random(0, 360));
					A_SpawnProjectile("SmokeSpawner", 0, 0, random(0, 360), 2, random(0, 360));
				}
			}
		}
		BOOM ABCD 1 Bright A_SetTranslucent(0.8, 1);
		BOOM EFGH 1 Bright A_SetTranslucent(0.5, 1);
		BOOM IJKLMNOPQRSTUVWXY 1 Bright A_SetTranslucent(0.3, 1);
		Stop;
	}
}
