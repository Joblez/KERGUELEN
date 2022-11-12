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
		+DONTSPLASH;
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

	double GetParticleDrawDistance()
	{
		return 128 * GetCVar("weather_particles");
	}
}

class RainDrop : WeatherParticle
{
	Default
	{
		VSpeed -32.0;
		Height 3;
		XScale 0.4;
		YScale 0.7;
		RenderStyle "Add";
		-NOGRAVITY;
	}

	States
	{
	Spawn:
		RAIN A 1;
		Loop;
	Death:
		RAIN A 1;
		TNT1 A 0 {
			if (invoker.cursector.GetFloorTerrain(Sector.floor).IsLiquid)
			{
				return ResolveState("WaterDeath");
			}

			int weatherParticleSetting = invoker.GetCVar("weather_particles");
			if (weatherParticleSetting > 0)
			{
				scale = (0.5,0.5);
				bForceYBillboard = false;
				bForceXYBillboard = true;
				if (Distance2DSquared(players[consoleplayer].mo) <= GetParticleDrawDistance() ** 2)
				{
					for (int i = 0; i < Random(weatherParticleSetting, weatherParticleSetting + 2); ++i)
					{
						A_SpawnParticle(
							0xFFFFFFFF,
							SPF_RELVEL,
							lifetime: 22,
							size: FRandom(2.5, 7.5),
							angle: FRandom(0.0, 360.0),
							zoff: 2.0,
							velx: FRandom(1.0, 4.0),
							velz: FRandom(0.5, 1.5),
							accelz: -0.25,
							fadestepf: 0,
							sizestep: -0.5
						);
					}
				}
			}

			return ResolveState(null);
		}
		RAIN BCDE 1;
		Stop;

	WaterDeath:
		TNT1 A 0 {
			invoker.bFlatSprite = true;
			Angle = FRandom(0.0, 360.0);
			Scale = (1.0, 1.0);
			Alpha = 0.9;
		}
		RAIN FFGGHHIIJJKKLL 1 Bright {
			A_SetTranslucent(max(0.0, invoker.Alpha - 0.075), 1);
			Scale += (0.075, 0.075);
		}
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