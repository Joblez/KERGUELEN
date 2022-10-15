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
		Death:
			RAIN A 1;
			TNT1 A 0
			{
				scale = (0.5,0.5);
				bForceYBillboard = false;
				bForceXYBillboard = true;
			}
			RAIN BCDE 1;
			Stop;
		Stop;
	}
}