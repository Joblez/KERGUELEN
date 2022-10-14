class WeatherParticle : Actor
{
	Default
	{
		Mass 8;
		Radius 2;
		Height 4;
		Gravity 1.5;
		// +CANPASS;
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
		Scale 0.6;
		Gravity 2.5;
		RenderStyle "Add";
	}

	States
	{
	Spawn:
		RAIN A 1;
		Loop;
	Death:
		TNT1 A 0 {
			Console.Printf("Died at %i, %i, %i", Pos.x, Pos.y, Pos.z);
		}
		Stop;
	}
}