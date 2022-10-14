class WeatherParticle : Actor
{
	Default
	{
		Mass 8;
		Radius 2;
		Height 4;
		Gravity 1.5;
		Speed 0;
		+NOBLOCKMAP;
		+CANPASS;
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
		VSpeed -1.5;
		RenderStyle "Add";
	}

	States
	{
	Spawn:
		RAIN A 1;
		Loop;
	}
}