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
		VSpeed -15.0;
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
			scale = (0.5,0.5);
			bForceYBillboard = false;
			bForceXYBillboard = true;
			// if (Distance2DSquared(players[consoleplayer].mo) <= 512 * 512)
			// {
			// 	for (int i = 0; i < Random(2, 4); ++i)
			// 	{
			// 		A_SpawnParticle(
			// 			0xFFFFFFFF,
			// 			SPF_RELVEL,
			// 			lifetime: 18,
			// 			size: 6,
			// 			angle: FRandom(0.0, 360.0),
			// 			zoff: 4.0,
			// 			velx: FRandom(1.0, 4.0),
			// 			velz: FRandom(0.5, 1.0),
			// 			accelz: -0.25,
			// 			fadestepf: 0,
			// 			sizestep: -0.5
			// 		);
			// 	}
			// }
		}
		RAIN BCDE 1;
		Stop;
	}
}