class WeaponFlash : Actor
{
	int m_Duration;
	private int m_TimeAlive;

	Default
	{
		+NOCLIP
		+NOBLOCKMAP
		+NOGRAVITY
		+VULNERABLE
	}

	override void Tick()
	{
		Super.Tick();

		m_TimeAlive++;

		if (m_TimeAlive > m_Duration) A_Die();
	}

	States
	{
	Spawn:
		TNT1 A 1 Light("Flash");
		Loop;
	
	Death:
		TNT1 A 0;
		Stop;
	}
}

class MuzzleSmoke : Actor
{
	Default
	{
		Speed -1;
		RenderStyle "Normal";
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
		SMOK BCDEFGHIJ 2 NoDelay A_FadeOut(0.005);
		Stop;
	}
}

class MuzzleSmoke2 : MuzzleSmoke
{
	Default
	{
		Alpha 0.5;
		Scale 1.0;
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

class EffectTrail : Actor abstract
{
	double m_AirFriction;
	property AirResistance: m_AirFriction;

	private double m_Spacing;
	property Spacing: m_Spacing;

	private double m_DistanceDelta;
	private vector3 m_MaxSpeed;

	mixin ProjectileExt;

	Default
	{
		Projectile;
		Speed 0.0;
		Radius 0.1;
		Height 8;
		Mass 30;

		EffectTrail.Spacing 64.0;
		EffectTrail.AirResistance 1.15;
		+SOLID
		+SHOOTABLE
		+VULNERABLE
		-NOGRAVITY
	}

	abstract void SpawnEffect(vector3 position);

	override void Tick()
	{
		Super.Tick();

		int weaponEffectSetting = CVar.GetCVar("weapon_effects", GetTargetPlayerOrConsolePlayer()).GetInt();

		if (weaponEffectSetting <= Settings.OFF) return;

		double factor = 2.0 - (weaponEffectSetting / Settings.ULTRA);
		double spacing = m_Spacing * factor;

		vector3 delta = LevelLocals.Vec3Diff(Prev, Pos);
		m_DistanceDelta += delta.Length();

		if (m_DistanceDelta >= spacing)
		{
			vector3 spawnPos = Pos;
			if (m_DistanceDelta / spacing < 2.0)
			{
				SpawnEffect(spawnPos);
			}
			else
			{
				for (m_DistanceDelta; m_DistanceDelta >= 0.0; m_DistanceDelta -= spacing)
				{
					SpawnEffect(spawnPos);
					spawnPos -= delta.Unit() * spacing;
					// Console.Printf("Spawned smoke effect.");
				}
			}
			m_DistanceDelta = 0.0;
		}

		Vel.x /= m_AirFriction;
		Vel.y /= m_AirFriction;
		Vel.z /= m_AirFriction;

		if (Vel.Length() <= 0.1)
		{
			A_Die();
		}
	}

	States
	{
	Spawn:
		TNT1 A 1;
		Loop;
	
	Death:
		TNT1 A 0;
		Stop;
	}
}

class SmokeTrail : EffectTrail
{
	Default
	{
		Mass 55;
		Gravity 3.5;
		EffectTrail.Spacing 10.0;
		EffectTrail.AirResistance 1.1;
	}

	override void SpawnEffect(vector3 position)
	{
		Spawn("MuzzleSmoke2", position);
	}
}

class ParticleTrail : EffectTrail
{
	// FSpawnParticleParams doesn't serialize to save games, so all of these need to
	// be stored in fields.
	color m_Color;
	TextureID m_Texture;
	int m_Style;
	int m_Flags;
	int m_Lifetime;
	double m_Size;
	double m_SizeStep;
	vector3 m_Vel;
	vector3 m_Accel;
	double m_StartAlpha;
	double m_FadeStep;
	double m_StartRoll;
	float m_RollVel;
	float m_RollAcc;

	Default
	{
		Mass 35;
		Gravity 3.0;
		BounceFactor 0.7;
		WallBounceFactor 0.7;
		BounceCount 6;

		EffectTrail.Spacing 2.0;
		EffectTrail.AirResistance 1.075;

		+DOOMBOUNCE
	}

	static ParticleTrail Create(vector3 position, FSpawnParticleParams params)
	{
		ParticleTrail trail = ParticleTrail(Spawn("ParticleTrail", position));

		trail.m_Color = params.color1;
		trail.m_Texture = params.texture;
		trail.m_Style = params.style;
		trail.m_Flags = params.flags;
		trail.m_Lifetime = params.lifetime;
		trail.m_Size = params.size;
		trail.m_SizeStep = params.sizestep;
		trail.m_Vel = params.vel;
		trail.m_Accel = params.accel;
		trail.m_StartAlpha = params.startalpha;
		trail.m_FadeStep = params.fadestep;
		trail.m_StartRoll = params.startroll;
		trail.m_RollVel = params.rollvel;
		trail.m_RollAcc = params.rollacc;

		return trail;
	}

	override void SpawnEffect(vector3 position)
	{
		FSpawnParticleParams params;

		params.pos = position;
		params.color1 = m_Color;
		params.texture = m_Texture;
		params.style = m_Style;
		params.flags = m_Flags;
		params.lifetime = m_Lifetime;
		params.size = m_Size;
		params.sizestep = m_SizeStep;
		params.vel = m_Vel;
		params.accel = m_Accel;
		params.startalpha = m_StartAlpha;
		params.fadestep = m_FadeStep;
		params.startroll = m_StartRoll;
		params.rollvel = m_RollVel;
		params.rollacc = m_RollAcc;

		level.SpawnParticle(params);
	}
}

class SparkLightTrail : ParticleTrail
{
	static SparkLightTrail Create(vector3 position, FSpawnParticleParams params)
	{
		SparkLightTrail trail = SparkLightTrail(Spawn("SparkLightTrail", position));

		trail.m_Color = params.color1;
		trail.m_Texture = params.texture;
		trail.m_Style = params.style;
		trail.m_Flags = params.flags;
		trail.m_Lifetime = params.lifetime;
		trail.m_Size = params.size;
		trail.m_SizeStep = params.sizestep;
		trail.m_Vel = params.vel;
		trail.m_Accel = params.accel;
		trail.m_StartAlpha = params.startalpha;
		trail.m_FadeStep = params.fadestep;
		trail.m_StartRoll = params.startroll;
		trail.m_RollVel = params.rollvel;
		trail.m_RollAcc = params.rollacc;

		return trail;
	}

	States
	{
	Spawn:
		TNT1 A 1 Light("Spark");
		Loop;
	
	Death:
		TNT1 A 0;
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
	const MAX_TIME = TICRATE * 20;
	double m_RollOrientation;
	double m_RollSpeed;

	meta double m_StartRoll;
	property StartingRoll: m_StartRoll;

	private int m_TimeAlive;

	private double m_VirtualRoll;
	private bool m_FirstTickPassed;
	private bool m_FirstDeathTickPassed;

	private InterpolatedDouble m_TipOverAngle;

	mixin ProjectileExt;

	Default
	{
		Height 0.75;
		Radius 1;
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

		int weaponCasingSetting = CVar.GetCVar("weapon_casings", GetTargetPlayerOrConsolePlayer()).GetInt();

		if (weaponCasingSetting <= Settings.OFF)
		{
			Destroy();
			return;
		}

		m_TipOverAngle = new("InterpolatedDouble");
		m_TipOverAngle.m_SmoothTime = 3.0 / TICRATE;

		m_RollOrientation = FRandomPick(1.0, -1.0);
		m_RollSpeed = FRandom(2.0, 4.5) * 360.0 / TICRATE;
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

		// Despawn logic before freeze check to ensure consistent performance.
		m_TimeAlive++;

		int weaponCasingSetting = CVar.GetCVar("weapon_casings", GetTargetPlayerOrConsolePlayer()).GetInt();

		int maxTimeAlive = MAX_TIME * (double(weaponCasingSetting) / Settings.ULTRA);

		if (m_TimeAlive > maxTimeAlive)
		{
			Destroy();
			return;
		}

		// Fade out over last 10% of lifetime.
		if (m_TimeAlive > maxTimeAlive * 0.9)
		{
			A_SetRenderStyle(
				Math.Remap(m_TimeAlive,
					maxTimeAlive * 0.9,
					maxTimeAlive,
					1.0,
					0.0),
				STYLE_Translucent);
		}

		if (IsFrozen()) return;

		if (!InStateSequence(CurState, ResolveState("Death")))
		{
			m_VirtualRoll += m_RollSpeed * m_RollOrientation;
			ConvertVirtualRoll();
			return;
		}

		if (!m_FirstDeathTickPassed)
		{
			m_TipOverAngle.ForceSet(m_VirtualRoll);

			// Get nearest multiple of 180.
			m_TipOverAngle.m_Target = round(m_VirtualRoll / 180.0) * 180.0;

			m_FirstDeathTickPassed = true;
		}

		if (!(m_TipOverAngle.GetValue() ~== m_TipOverAngle.m_Target))
		{
			m_TipOverAngle.Update();
			SetVirtualRoll(m_TipOverAngle.GetValue());
			return;
		}

		bRollSprite = false;
		double rollAngle = Math.PosMod(m_VirtualRoll, 360.0);
		frame = rollAngle < 180.0 ? 0 : 4;
	}

	void ConvertVirtualRoll()
	{
		// Frames A-H = numbers 0-7.

		double rollAngle = Math.PosMod(m_VirtualRoll, 360.0);

		// Frames are ordered counterclockwise starting from 0° and go in 45° increments.
		frame = uint(rollAngle / 45);
		// Console.Printf("Roll: %f, Frame %i", m_VirtualRoll, frame);

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
		Scale 0.09;
		BounceSound "weapons/shell4";

		BaseCasing.StartingRoll 110.0;
	}

	States
	{
	Spawn:
		CAS3 A 1;
		Loop;

	Death:
		CAS3 I 1;
		Wait;
	}

}

class RevolverCasing : BaseCasing
{
	Default
	{
		Radius 2;
		Scale 0.10;
		BounceSound "weapons/shell4";

	}

	States
	{
	Spawn:
		CAS5 A 1;
		Loop;

	Death:
		CAS5 I 1;
		Wait;
	}
}

class RifleCasing : BaseCasing
{
	Default
	{
		Speed 8;
		Scale 0.10;
		BounceSound "weapons/shell2";

		BaseCasing.StartingRoll 140.0;
	}

	States
	{
	Spawn:
		CAS4 A 1;
		Wait;

	Death:
		CAS4 I 1;
		Wait;
	}
}

class ShotgunCasing : BaseCasing
{
	Default
	{
		Radius 2;
		Speed 4;
		Scale 0.11;
		BounceSound "weapons/shell3";

		BaseCasing.StartingRoll 130.0;
	}

	States
	{
	Spawn:
		CAS2 A 1;
		Loop;

	Death:
		CAS2 I 1;
		Wait;
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
		RCCA I 1;
		Wait;
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