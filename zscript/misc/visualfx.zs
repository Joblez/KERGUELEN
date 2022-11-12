class MuzzleSmoke : Actor
{
	Default
	{
		Speed -1;
		RenderStyle "Add";
		Alpha 0.5;
		Radius 0;
		Height 0;
		Scale 0.5;
		+NOGRAVITY
		+NOBLOCKMAP
		+FLOORCLIP
		+FORCEXYBILLBOARD
		+NOINTERACTION
		+DONTSPLASH
		+CLIENTSIDEONLY
	}
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SetTranslucent(0.25);
		SMOK ABCDEFGHIJKLMNOPQ 2 A_FadeOut(0.005);
		Stop;
	}
}

class MuzzleSmoke2 : MuzzleSmoke
{
	Default
	{
		Speed 1;
		Alpha 0.3;
		Radius 0;
		Height 0;
		Scale 0.8;
		+NOGRAVITY
		+NOBLOCKMAP
		+FLOORCLIP
		+FORCEXYBILLBOARD
		+NOINTERACTION
		+DONTSPLASH
		+CLIENTSIDEONLY
	}
}

class ExplosionSmoke : Actor
{
	Default
	{
		RenderStyle "Add";
		Alpha 0.3;
		Radius 2;
		Height 2;
		Scale 0.8;
		Projectile;
		Speed 12;
		Gravity 0.65;
		+CLIENTSIDEONLY
		-NOGRAVITY
	}

	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SetTranslucent(0.25);
		SMOK ABCDEFGHIJKLMNOPQ 2 Bright A_SpawnItem("MuzzleSmoke2");
	Death:
		Stop;
	}
}

class ExplosiveSmokeSpawner : Actor
{
	Default
	{
		Speed 30;
		+NOCLIP
	}
	States
	{
		Spawn:
		TNT1 A 0 NoDelay A_SpawnProjectile("ExplosionSmoke", 32, 0, random(0, 360), 2, random(0, 180));
		Stop;
	}
}

class SmokeSpawner2 : Actor
{
	Default
	{
		Speed 20;
		+NOCLIP
	}

	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnProjectile("MuzzleSmoke2", 0, 0);
		Stop;
	}
}

class SmokeSpawner : Actor
{
	Default
	{
		Speed 20;
		+NOCLIP
	}

	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnProjectile("MuzzleSmoke", 0, 0, random(-180, 180), 0, random(-180, 180));
		Stop;
	}
}

class WallSparks : Actor
{
	Default
	{
		Damage 0;
		Speed 75;
		Alpha 0.4;
		Scale 0.1;
		+THRUACTORS
		+GHOST
		-NOGRAVITY
		+THRUGHOST
		+RANDOMIZE
	}

	States
	{
	Spawn:
		PRBM A 12 Bright;
		Goto Death;
	Death:
		TNT1 A 0;
		Stop;
	XDeath:
		TNT1 A 0;
		Stop;
	}
}

class RocketDebris : Actor
{
	Default
	{
		Damage 0;
		Gravity 0.3;
		BounceFactor 0.2;
		WallBounceFactor 0.2;
		Speed 15;
		Alpha 0.5;
		Scale 0.6;
		RenderStyle "Add";
		BounceType "Grenade";
		+MISSILE
		+RANDOMIZE
		+FORCEXYBILLBOARD
		-NOGRAVITY
		+THRUACTORS
		+GHOST
		+THRUGHOST
	}

	action void A_SpawnDebris()
	{
		A_SpawnProjectile("RocketDebrisII", 0, 0, random(0, 360), 2, random(0, 360));
		A_SpawnProjectile("RocketDebrisII", 0, 0, random(0, 360), 2, random(0, 360));
	}

	States
	{
	Spawn:
		PRBM A 4 Bright NoDelay A_SetTranslucent(0.8, 1);
		TNT1 A 0 A_SpawnDebris;
		PRBM A 4 Bright A_SetTranslucent(0.7, 1);
		TNT1 A 0 A_SpawnDebris;
		PRBM A 4 Bright A_SetTranslucent(0.6, 1);
		TNT1 A 0 A_SpawnDebris;
		PRBM A 4 Bright A_SetTranslucent(0.4, 1);
		TNT1 A 0 A_SpawnDebris;
		PRBM A 4 Bright A_SetTranslucent(0.1, 1);
		Goto Death;

	Death:
		TNT1 A 0;
		Stop;
	XDeath:
		TNT1 A 0;
		Stop;
	}
}

class RocketDebrisII : RocketDebris
{
	Default
	{
		Damage 0;
		Gravity 0.3;
		BounceFactor 0.2;
		WallBounceFactor 0.2;
		RenderStyle "Add";
		Speed 10;
		Alpha 0.5;
		Scale 0.3;
	}

	States
	{
	Spawn:
		PRBM A 4 Bright NoDelay A_SetTranslucent(0.8, 1);
		PRBM A 4 Bright A_SetTranslucent(0.7, 1);
		PRBM A 4 Bright A_SetTranslucent(0.6, 1);
		PRBM A 4 Bright A_SetTranslucent(0.4, 1);
		PRBM A 4 Bright A_SetTranslucent(0.1, 1);
		Goto Death;
	Death:
		TNT1 A 0;
		Stop;
	XDeath:
		TNT1 A 0;
		Stop;
	}
}

class Bullet_Puff : Actor replaces BulletPuff
{
	Default
	{
		Radius 1;
		Height 1;
		Scale 0.7;
		Alpha 0.7;
		Speed 0;
		RenderStyle "Add";
		Decal "BulletChip";
		+NOBLOCKMAP;
		+NOGRAVITY;
		+RANDOMIZE;
		+FLOORCLIP;
		+PUFFONACTORS;
		+NOEXTREMEDEATH;
	}

	States
	{
	Xdeath:
		TNT1 A 0 A_SetRenderStyle(200,STYLE_None);
		TNT1 A 0 A_StartSound("weapons/hitflesh", 11,0,0.5);
		NBL2 ABCD 1;
		Stop;

	Crash:
		TNT1 A 0 A_Jump(128, "Crash2", "Crash3");
		TNT1 A 0 A_StartSound("weapons/ricochet", 11,0,0.5);
		FX57 A 1 Bright;
		FX57 BC 1 Bright;
		FX57 D 1 Bright;
		FX57 E 1 Bright A_SetTranslucent(.5, 1);
		Stop;
	Crash2:
		TNT1 A 0 A_StartSound("weapons/ricochet", 11,0,0.5);
		FX57 J 1 Bright;
		FX57 KL 1 Bright;
		FX57 M 1 Bright;
		FX57 N 1 Bright A_SetTranslucent(.5, 1);
		Stop;
	Crash3:
		TNT1 A 0 A_StartSound("weapons/ricochet", 11,0,0.5);
		FX57 F 1 Bright;
		FX57 GH 1 Bright;
		FX57 I 1 Bright;
		Stop;
	}
}

class Melee_Puff: Bullet_Puff
{
	Default
	{
	-PUFFONACTORS;
	}
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SetScale(0.2);
		TNT1 A 1 A_SetTranslucent(0.25);
		Stop;

	Crash:
		TNT1 A 0 A_SetScale(0.5);
		FX57 A 1 Bright A_StartSound("hatchet/hitwall", CHAN_AUTO);
		FX57 BC 1 Bright A_SetTranslucent(.8, 1);
		FX57 DE 1 Bright A_SetTranslucent(.6, 1);
		FX57 FG 1 Bright A_SetTranslucent(.4, 1);
		FX57 HIJ 1 Bright A_SetTranslucent(.2, 1);
		Stop;
	Melee:
		FX57 A 0 Bright A_StartSound("hatchet/hit", CHAN_AUTO);
		TNT1 A 0 A_SetScale(0.5);
		Stop;
	}
}

class BaseCasing : Actor
{
	Default
	{
		Height 4;
		Radius 2;
		Speed 8;
		Gravity 0.8;
		BounceFactor 0.5;
		WallBounceFactor 0.5;
		Bouncetype "Doom";
		+MISSILE
		+DROPOFF
		+NOBLOCKMAP
		+MOVEWITHSECTOR
		+THRUACTORS
		+FORCEXYBILLBOARD
		+ACTIVATEIMPACT
	}
}

class PistolCasing : BaseCasing
{
	Default
	{
		Scale 0.14;
		BounceSound "weapons/shell4";
	}

	States
	{
	Spawn:
		CAS3 A 2;
		CAS3 B 2;
		CAS3 C 2;
		CAS3 D 2;
		CAS3 E 2;
		CAS3 F 2;
		CAS3 G 2;
		CAS3 H 2;
		Loop;

	Death:
		CAS3 I 350;
		CAS3 I 3 A_SetTranslucent(0.8, 0);
		CAS3 I 3 A_SetTranslucent(0.6, 0);
		CAS3 I 3 A_SetTranslucent(0.4, 0);
		CAS3 I 3 A_SetTranslucent(0.2, 0);
		Stop;
	}

}

class RevolverCasing : BaseCasing
{
	Default
	{
		Height 5;
		Scale 0.14;
		BounceSound "weapons/shell4";
	}

	States
	{
	Spawn:
		CAS5 A 2;
		CAS5 B 2;
		CAS5 C 2;
		CAS5 D 2;
		CAS5 E 2;
		CAS5 F 2;
		CAS5 G 2;
		CAS5 H 2;
		CAS5 I 2;
		Loop;

	Death:
		CAS5 I 350;
		CAS5 I 3 A_SetTranslucent(0.8, 0);
		CAS5 I 3 A_SetTranslucent(0.6, 0);
		CAS5 I 3 A_SetTranslucent(0.4, 0);
		CAS5 I 3 A_SetTranslucent(0.2, 0);
		Stop;
	}
}

class RifleCasing : BaseCasing
{
	Default
	{
		Height 8;
		Radius 6;
		Speed 8;
		Scale 0.14;
		BounceSound "weapons/shell2";
	}

	States
	{
	Spawn:
		CAS4 A 2;
		CAS4 B 2;
		CAS4 C 2;
		CAS4 D 2;
		CAS4 E 2;
		CAS4 F 2;
		CAS4 G 2;
		CAS4 H 2;
		Loop;
	Death:
		CAS4 I 350;
		CAS4 I 3 A_SetTranslucent(0.8, 0);
		CAS4 I 3 A_SetTranslucent(0.6, 0);
		CAS4 I 3 A_SetTranslucent(0.4, 0);
		CAS4 I 3 A_SetTranslucent(0.2, 0);
		CAS4 I 3 A_SetTranslucent(0.0, 0);
		Stop;
	}
}

class ShotgunCasing : BaseCasing
{
	Default
	{
		Height 6;
		Radius 4;
		Speed 4;
		Scale 0.18;
		BounceSound "weapons/shell3";
	}

	States
	{
	Spawn:
		CAS2 A 2;
		CAS2 B 2;
		CAS2 C 2;
		CAS2 D 2;
		CAS2 E 2;
		CAS2 F 2;
		CAS2 G 2;
		CAS2 H 2;
		Loop;

	Death:
		CAS2 I 350 ;
		CAS2 I 3 A_SetTranslucent(0.8, 0);
		CAS2 I 3 A_SetTranslucent(0.6, 0);
		CAS2 I 3 A_SetTranslucent(0.4, 0);
		CAS2 I 3 A_SetTranslucent(0.2, 0);
		CAS2 I 3 A_SetTranslucent(0.0, 0);
		Stop;
	}

}

class GrenadeCasing : BaseCasing
{
	Default
	{
		Height 8;
		Radius 6;
		Speed 4;
		Scale 0.5;
		BounceSound "weapons/shell3";
	}

	States
	{
	Spawn:
		CAS6 A 2;
		CAS6 B 2;
		CAS6 C 2;
		CAS6 D 2;
		CAS6 E 2;
		CAS6 F 2;
		CAS6 G 2;
		CAS6 H 2;
		Loop;

	Death:
		CAS6 I 350;
		CAS6 I 3 A_SetTranslucent(0.8, 0);
		CAS6 I 3 A_SetTranslucent(0.6, 0);
		CAS6 I 3 A_SetTranslucent(0.4, 0);
		CAS6 I 3 A_SetTranslucent(0.2, 0);
		Stop;
	}
}

class RocketCasing : BaseCasing
{
	Default
	{
		Height 6;
		Radius 12;
		Speed 6;
		BounceSound "weapons/shell5";
	}

	States
	{
	Spawn:
		RCCA A 2;
		Loop;
	Death:
		RCCA A 350;
		RCCA A 3 A_SetTranslucent(0.8, 0);
		RCCA A 3 A_SetTranslucent(0.6, 0);
		RCCA A 3 A_SetTranslucent(0.4, 0);
		RCCA A 3 A_SetTranslucent(0.2, 0);
		Stop;
	}
}

class BaseSpawner: Actor
{
	double x;
	double y;
	double angle;

	Default
	{
		Projectile;
		Speed 35;
		+NOCLIP;
		+DONTSPLASH;
		+NOTIMEFREEZE;
		-ACTIVATEIMPACT;
	}
}

class PistolSpawnerR : BaseSpawner
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnProjectile("PistolCasing", 0, random(-1, 1), random(80, 90), 0);
		Stop;
	}
}

class PistolSpawnerL : BaseSpawner
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnProjectile("PistolCasing", 0, random(-1, 1), random(-80, -90), 0);
		Stop;
	}
}

class RevolverSpawnerR : BaseSpawner
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnProjectile("RevolverCasing", 0, random(-1, 1), random(80, 90), 0);
		Stop;
	}
}

class RevolverSpawnerL : BaseSpawner
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnProjectile("RevolverCasing", 0, random(-1, 1), random(-80, -90), 0);
		Stop;
	}
}

class ShellSpawnerR : BaseSpawner
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnProjectile("ShotgunCasing", 0, random(-1, 1), random(80, 90), 0);
		Stop;
	}
}

class ShellSpawnerL : BaseSpawner
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnProjectile("ShotgunCasing", 0, random(-1, 1), random(-80, -90), 0);
		Stop;
	}
}

class RifleSpawnerR : BaseSpawner
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnProjectile("RifleCasing", 0, random(-1, 1), random(80, 90), 0);
		Stop;
	}
}

class RifleSpawnerL : BaseSpawner
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnProjectile("RifleCasing", 0, random(-1, 1), random(-80, -90), 0);
		Stop;
	}
}

class GrenadeSpawnerR : Basespawner
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnProjectile("GrenadeCasing", 0, random(-1, 1), random(80, 90), 0);
		Stop;
	}
}

class GrenadeSpawnerL : Basespawner
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnProjectile("GrenadeCasing", 0, random(-1, 1), random(-80, -90), 0);
		Stop;
	}
}

class RocketSpawnerR : Basespawner
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnProjectile("RocketCasing", 0, random(-1, 1), random(80, 90), 0);
		Stop;
	}
}

class Rocket_Trail : Actor
{
	Default
	{
		Height 1;
		Radius 1;
		Mass 0;
		RenderStyle "Add";
		Scale 0.1;
		+MISSILE;
		+NOBLOCKMAP;
		+NOGRAVITY;
		+DONTSPLASH;
		+FORCEXYBILLBOARD;
		+CLIENTSIDEONLY;
		+THRUACTORS;
		+GHOST;
		+THRUGHOST;
	}

	States
	{
	Spawn:
		SPRK A 7 Bright;
		SPRK AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 Bright A_FadeOut(0.02);
		Stop;
	}
}

class Rocket_Trail2 : Rocket_Trail
{
	Default
	{
		Radius 1;
		Height 1;
		Alpha 1.0;
		RenderStyle "Add";
		Scale 0.1;
		Speed 4;
		Gravity 0.2;
		+BOUNCEONCEILINGS;
		+BOUNCEONWALLS;
		-SKYEXPLODE;
		-NOGRAVITY;
	}
}