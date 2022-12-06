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

	double GetParticleDrawDistance() const
	{
		int setting = GetCVar("splash_particles");
		if (setting == 0) return 0.0;
		return 128 * setting + 128;
	}
}

class WaterRipple : WeatherParticle
{
	Default
	{
		Alpha 0.9;
		RenderStyle "Add";
		+NOINTERACTION;
		+FLATSPRITE;
		+NOGRAVITY;
	}

	States
	{
	Spawn:
		TNT1 A 0 { Angle = FRandom(0.0, 360.0); }
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