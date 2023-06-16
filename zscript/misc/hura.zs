Class Hura : Actor replaces ExplosiveBarrel
{
	Default
	{
		Health 12;
		Radius 16;
		Height 40;
		Scale 0.75;
		DamageType "normal";
		Bloodcolor "1c412b";
		Obituary "Amerigo hit a hura plant.";
		Species "Plant";
		+SOLID
		+SHOOTABLE
		+STANDSTILL
		+DONTTHRUST
		+ACTIVATEMCROSS
		+NOICEDEATH
	}

	States
	{
	Spawn:
		EFRT A 6;
		Loop;
	Death:
	XDeath:
		TNT1 A 0 A_Startsound("Hura/die", CHAN_AUTO);
		EFEX AB 5 Bright;
		EFEX CD 5 Bright;
		TNT1 A 0 {
			double startAngle = FRandom(-180.0, 180.0);
			int seedCount = Random(6, 9);
			for (int i = 0; i < seedCount; ++i)
			{
				double angle = startAngle + 360.0 * (double(i) / seedCount) + FRandom(-6.0, 6.0);
				A_SpawnProjectile("Huraseed", 20, 0, angle, CMF_AIMDIRECTION, -7.0);
			}
		}
		TNT1 A 0 A_Explode(10, 128);
		TNT1 A 0 A_Startsound("Dryad/Death", CHAN_AUTO);
		TNT1 A 0 A_XScream;
		EFEX EFGHIJ 2 Bright A_NoBlocking;
		EFEX J -1;
		Stop;
	}
}
