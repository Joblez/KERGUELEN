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
		int setting = GetCVar("splash_particles");
		if (setting == 0) return 0.0;
		return 128 * setting + 128;
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
		RAIN A 2;
		TNT1 A 0 {
			if (invoker.cursector.GetFloorTerrain(Sector.floor).IsLiquid)
			{
				return ResolveState("WaterDeath");
			}

			int splashParticleSetting = invoker.GetCVar("splash_particles");
			if (splashParticleSetting > 0)
			{
				scale = (0.5,0.5);
				bForceYBillboard = false;
				bForceXYBillboard = true;
				if (Distance3DSquared(players[consoleplayer].mo) <= GetParticleDrawDistance() ** 2)
				{
					if (splashParticleSetting == 6) // Extra detail for Ultra
					{
						for (int i = 0; i < Random(8, 12); ++i)
						{
							A_SpawnParticle(
								0xFFFFFFFF,
								SPF_RELVEL,
								lifetime: 22,
								size: FRandom(1.5, 2.5),
								angle: FRandom(0.0, 360.0),
								zoff: 1.0,
								velx: FRandom(1.5, 4.0),
								velz: FRandom(0.25, 1.5),
								accelz: -0.25,
								fadestepf: 0,
								sizestep: -0.15
							);
						}
					}

					for (int i = 0; i < Random(splashParticleSetting, splashParticleSetting + 2); ++i)
					{
						A_SpawnParticle(
							0xFFFFFFFF,
							SPF_RELVEL,
							lifetime: 22,
							size: FRandom(2.5, 6.0),
							angle: FRandom(0.0, 360.0),
							zoff: 2.0,
							velx: FRandom(0.75, 2.25),
							velz: FRandom(0.5, 2.5),
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
			A_SetTranslucent(max(0.0, invoker.Alpha - 0.9 / 14.0), 1);
			Scale += (0.075, 0.075);
		}
		Stop;
	}
}

class Snowflake : WeatherParticle
{
	Default
	{
		VSpeed -2.5;
		Scale 0.575;
		Gravity 0.05;
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
		SNOW A 1 A_Weave(1, 0, 0.9, 0);
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