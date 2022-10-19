class WeatherParticle : Actor
{
	Default
	{
		Mass 8;
		Radius 2;
		Height 4;
		Gravity 1.5;
		+NOBLOCKMAP;
		+NOSPRITESHADOW;
		+NOTELEPORT;
		+THRUSPECIES;
		+DONTGIB;
		+FORCEYBILLBOARD;
		+MISSILE;
	}

	States
	{
	Spawn:
		TNT1 A 0;
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	}
}

class RainDrop : WeatherParticle
{
	Default
	{
		VSpeed -20.0;
		XScale 0.4;
		YScale 0.7;
		Gravity 2.5;
		RenderStyle "Add";
	}

	States
	{
	Spawn:
		RAIN A 1;
		Loop;
	Death:
		RAIN A 1;
		TNT1 A 0 {
			if (GetCVar("special_particle_toggle") == 1)
				{
					scale = (0.5,0.5);
					bForceYBillboard = false;
					bForceXYBillboard = true;
					 if (Distance2DSquared(players[consoleplayer].mo) <= 512 * 512)
					 {
					 	for (int i = 0; i < Random(2, 4); ++i)
					 	{
					 		A_SpawnParticle(
					 			0xFFFFFFFF,
					 			SPF_RELVEL,
					 			lifetime: 18,
					 			size: 6,
					 			angle: FRandom(0.0, 360.0),
					 			zoff: 4.0,
					 			velx: FRandom(1.0, 4.0),
					 			velz: FRandom(0.5, 1.0),
					 			accelz: -0.25,
					 			fadestepf: 0,
					 			sizestep: -0.5
					 		);
					 	}
					}		
				}		

		}
		RAIN BCDE 1;
		Stop;
	}
}

class Snowflake : WeatherParticle
{
	Default
	{
		VSpeed -7.0;
		Scale 0.575;
		Gravity 0.1;
		RenderStyle "Add";
		+NOINTERACTION;
	}

	States
	{
	Spawn:
		TNT1 A 0 NoDelay {
			Pitch = -90.0;
			Scale += (FRandom(-0.1, 0.1), FRandom(-0.1, 0.1));
			WeaveIndexXY = Random(0, 63);
		}
	Alive:
		SNOW A 1 A_Weave(2, 0, 0.6, 0);
		TNT1 A 0 {
			if (Pos.z <= FloorZ)
			{
				return ResolveState("Death");
			}
			return ResolveState(null);
		}
		Loop;
	Death:
		SNOW A 1;
		Stop;
	}
}