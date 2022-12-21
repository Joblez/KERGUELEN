class MuzzleSmoke : Actor
{
	Default
	{
		Speed -1;
		RenderStyle "Add";
		Alpha 0.4;
		Radius 0;
		Height 0;
		Scale 0.55;
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
		Alpha 0.5;
		Radius 0;
		Height 0;
		Scale 1.0;
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
		Scale 1.0;
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
		+FORCEXYBILLBOARD;
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
		+FORCEXYBILLBOARD;
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
	double m_RollOrientation;

	meta double m_StartRoll;
	property StartingRoll: m_StartRoll;

	private double m_VirtualRoll;
	private bool m_FirstTickPassed;

	Default
	{
		Height 2;
		Radius 3;
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
		+ROLLSPRITE
		+ROLLCENTER
	}

	override void BeginPlay()
	{
		Super.BeginPlay();

		m_RollOrientation = FRandomPick(1.0, -1.0);
		SetVirtualRoll(m_StartRoll);
	}

	override void Tick()
	{
		Super.Tick();

		// Skip first tick so casings can be seen at their starting roll.
		if (!m_FirstTickPassed)
		{
			m_FirstTickPassed = true;
			ConvertVirtualRoll();
			return;
		}

		if (IsFrozen()) return;

		if (!InStateSequence(CurState, ResolveState("Death")))
		{
			m_VirtualRoll += FRandom(1.0, 3.0) * 360.0 / TICRATE * m_RollOrientation;
			ConvertVirtualRoll();
		}
		else
		{
			bRollSprite = false;
			double rollAngle = Math.PosMod(m_VirtualRoll, 360.0);
			bXFlip = rollAngle < 180.0;
		}
	}

	void ConvertVirtualRoll()
	{
		// Frames A-H = numbers 0-7.

		double rollAngle = Math.PosMod(m_VirtualRoll, 360.0);

		// Frames are ordered counterclockwise starting from 0° and go in 45° increments.
		frame = uint(rollAngle / 45);
		Console.Printf("Roll: %f, Frame %i", m_VirtualRoll, frame);

		// Subtract 22.5 from the remainder to land at the midpoint between angle frames.
		A_SetRoll(Math.PosMod(rollAngle % 45.0, 360.0) - 22.5, SPF_INTERPOLATE);
	}

	void SetVirtualRoll(double newRoll)
	{
		m_VirtualRoll = newRoll + 22.5;
		ConvertVirtualRoll();
	}
}

class PistolCasing : BaseCasing
{
	Default
	{
		Scale 0.14;
		BounceSound "weapons/shell4";

		BaseCasing.StartingRoll 110.0;
	}

	States
	{
	Spawn:
		CAS3 A 1;
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
		Radius 2;
		Scale 0.14;
		BounceSound "weapons/shell4";

	}

	States
	{
	Spawn:
		CAS5 A 1;
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
		Speed 8;
		Scale 0.14;
		BounceSound "weapons/shell2";

		BaseCasing.StartingRoll 140.0;
	}

	States
	{
	Spawn:
		CAS4 A 1;
		Wait;

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
		Height 3;
		Radius 3;
		Speed 4;
		Scale 0.18;
		BounceSound "weapons/shell3";

		BaseCasing.StartingRoll 130.0;
	}

	States
	{
	Spawn:
		CAS2 A 1;
		Loop;

	Death:
		CAS2 I 350;
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
		CAS6 A 1;
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
		RCCA A 1;
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