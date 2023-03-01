class Dynamite : BaseWeapon replaces Rocketlauncher
{
	bool m_IsThrowing; //checks if the player is holding down the button to throw.
	double m_Throw; //multiplier for how far the dynamite is thrown.
	
	private bool m_Died; //check for when the dynamite explodes in the player's hands.

	property BaseThrowFactor: m_Throw;

	Default
	{
		Weapon.Kickback 100;
		Weapon.SlotNumber 5;
		Weapon.AmmoUse 0;
		Weapon.AmmoGive 1;
		Weapon.AmmoType "DynamiteAmmo";
		Weapon.UpSound("dynamite/equip");

		Dynamite.BaseThrowFactor 1.0;

		BaseWeapon.LookSwayResponse 0.0;
		BaseWeapon.MoveSwayWeight 1.0;
		BaseWeapon.MoveSwayResponse 26.0;

		Inventory.PickupMessage "[5] Dynamite Stick";
		Tag "Dynamite";
		+WEAPON.EXPLOSIVE;
		-WEAPON.AMMO_OPTIONAL;
	}

	States
	{
	Spawn:
		PICK D -1;
		Stop;

	Ready:
		TNT1 A 0 A_AttachLightDef('lighter', 'Lighter');
	ReadyLoop:
		DYNI ABCD 3 A_WeaponReady();
		Loop;

	Fire:
		DYNH ABCDE 1;
		TNT1 A 0 A_StartSound("dynamite/fuse", 9);
		DYNH FHJL 1;
		TNT1 A 0 A_RemoveLight('lighter');
		DYNH MN 1;
		TNT1 A 0 A_StartSound("dynamite/close", 10);
		DYNH OP 1;
	Hold:
		DYNH S 1 {
			if (invoker.m_Throw >= 5)
			{
				Actor stick = A_FireProjectile("DynamiteStick", 0, 1, 0, 12 ,0, 0);
				invoker.m_Throw = 0.0;
				if (stick)
				{
					stick.Vel = Vec3Util.Zero();
					stick.SetState(stick.ResolveState("Death"));
				}
				return ResolveState("SelfDetonate");
			}
			return ResolveState(null);
		}
		TNT1 A 0 {
			invoker.m_IsThrowing = true;
			invoker.m_Throw += 1.0 / TICRATE;
		}
		TNT1 A 0 A_Refire();
	Release:
		TNT1 A 0 A_StartSound("hatchet/swing", 9);
		TNT1 A 0 A_TakeInventory(invoker.AmmoType1, 1);
		DYNT ABC 1;
		TNT1 A 0 {
			Actor stick = A_FireProjectile("DynamiteStick", 0, 1, 0, 12, 0, 0);
			stick.Vel *= min(invoker.m_Throw, 2.5);
		}
		DYNT DE 2;
		DYNT FGHIJK 1;
		TNT1 A 0 {
			invoker.AmmoUse1 = invoker.GetReserveAmmo() > 0 ? 0 : 1;
			A_CheckReload();
		}
	NewStick:
		TNT1 A 0 {
			invoker.m_IsThrowing = false;
			invoker.m_Throw = invoker.default.m_Throw;
			A_SetBaseOffset(0, WEAPONTOP);
		}
		DYNS A 2 A_StartSound("dynamite/open", 10);
		DYNS BCD 2;
		TNT1 A 0 A_AttachLightDef('lighter', 'Lighter');
		DYNS E 2 Light("Flash") A_StartSound("dynamite/light", 10);
		DYNS FGHI 2 Light("Flash");
		TNT1 A 0 A_Refire("Fire");
		Goto Ready;

	SelfDetonate:
		TNT1 A 0 {
			if (Health <= 0) return ResolveState("DIE"); // Ugly, but...
			A_RemoveLight('lighter');

			return ResolveState(null);
		}
		DYNH SSSSSSSS 1 A_SetBaseOffset(0, invoker.m_PSpritePosition.GetBaseY() + 10);
		Goto NewStick;
	DIE:
		TNT1 A 0 A_RemoveLight('lighter');
		DYNH SSSSSSSS 1 A_SetBaseOffset(0, invoker.m_PSpritePosition.GetBaseY() + 10);
		DYNS B 2 A_Lower(1);
		Wait;

	Select:
		TNT1 A 0 { invoker.AmmoUse1 = invoker.GetReserveAmmo() > 0 ? 0 : 1; }
		DYNS A 2 A_SetBaseOffset(1, 85);
		DYNS B 2 A_SetBaseOffset(1, 60);
		TNT1 A 0 A_StartSound("dynamite/open", 10);
		DYNS CD 2 A_SetBaseOffset(1, 50);
		TNT1 A 0 A_AttachLightDef('lighter', 'Lighter');
		TNT1 A 0 A_StartSound("dynamite/light", 10);
		DYNS E 2 A_SetBaseOffset(1, 50);
		DYNS FGH 2 A_SetBaseOffset(1, 30);
		DYNS I 2 A_SetBaseOffset(0, WEAPONTOP);
		TNT1 A 0 A_Raise(16);
		Wait;

	Deselect:
		DYNS FED 2;
		TNT1 A 0 A_RemoveLight('lighter');
		DYNS CB 2;
		TNT1 A 0 A_StartSound("dynamite/close", 10);
		DYNS A 2;
		TNT1 A 0 A_SetBaseOffset(0, WEAPONBOTTOM);
		TNT1 A 0 A_Lower(16);
		Wait;
	}

	override int GetReserveAmmo() const
	{
		return Ammo1.Amount;
	}
}

class DynamiteStick : Actor
{
	meta double m_ThrustForce;
	property ThrustForce : m_ThrustForce;

	meta int m_SmokeTrails;
	property SmokeTrails : m_SmokeTrails;

	meta int m_SparkTrails;
	property SparkTrails : m_SparkTrails;

	private PointLight m_ExplosionFadeLight;

	private array<Actor> m_SpawnedEffects;

	Default
	{
		Radius 4;
		Height 4;
		Speed 20;
		Damage 0;
		ExplosionDamage 320;
		ExplosionRadius 360;
		Gravity 0.9;
		Scale 0.5;
		Alpha 1.0;
		RenderStyle "Normal";
		DeathSound "";
		Seesound "dynamite/fuseloop";
		Obituary "$OB_GRENADE"; // "%o caught %k's grenade."
		DamageType "Explosive";
		Projectile;

		DynamiteStick.ThrustForce 360;
		DynamiteStick.SmokeTrails 16;
		DynamiteStick.SparkTrails 40;

		//+DOOMBOUNCE;
		-NOGRAVITY;
		+BRIGHT;
		+NOEXTREMEDEATH;
		+NODAMAGETHRUST;
		+RANDOMIZE;
		+FORCEXYBILLBOARD;
		+DEHEXPLOSION;
	}

	States
	{
	Spawn:
		DYNP ABCDEFGH 2 Light("Stick");
		Loop;
	Death:
		TNT1 A 1 {
			A_NoGravity();
			A_StopSound(7);
			A_SetScale(2.0, 2.0);
			A_AlertMonsters(4096.0);
			A_SetRenderStyle(1.0, STYLE_Add);
			A_StartSound("dynamite/explode", CHAN_AUTO, attenuation: 0.4);

			array<Actor> hitActors;
			ActorUtil.Explode3D(self, int(ExplosionDamage * FRandom(1.0, 1.1)), m_ThrustForce, ExplosionRadius, hitActors: hitActors);

			int weaponEffectSetting = CVar.GetCVar('weapon_effects', target.player).GetInt();

			if (weaponEffectSetting <= Settings.OFF) return;

			array<Actor> spawnedEffects;

			FSpawnParticleParams params;
			params.color1 = 0xFFFFFFFF;
			params.texture = TexMan.CheckForTexture("PRBMA0");
			params.style = STYLE_Add;
			params.flags = SPF_ROLL | SPF_FULLBRIGHT;
			params.startroll = 180.0;
			params.sizestep = -1.0;
			// params.fadestep = -1;

			int smokeTrailCount = round(MathI.Lerp(0, m_SmokeTrails, double(weaponEffectSetting) / Settings.ULTRA));

			// Smoke trails.
			for (int i = 0; i < smokeTrailCount; ++i)
			{
				Actor effect = null;

				// Distribute evenly across hemispheres.
				double pitch = 0.0;
				if (i % 2 == 0)
				{
					pitch = FRandom(-180.0, -20.0);
				}
				else
				{
					pitch = FRandom(20.0, 180.0);
				}

				effect = Spawn("SmokeTrail", Pos + Vec3Util.FromAngles(FRandom(0.0, 360.0), pitch, FRandom(2.0, 4.0)));
				if (effect)
				{
					spawnedEffects.Push(effect);
					effect.A_ChangeLinkFlags(0);
					effect.target = target;
				}
			}

			int sparkTrailCount = round(MathI.Lerp(0, m_SparkTrails, double(weaponEffectSetting) / Settings.ULTRA));

			// Spark trails.
			for (int i = 0; i < sparkTrailCount; ++i)
			{
				params.size = FRandom(4.0, 8.0);
				params.startalpha = FRandom(0.15, 0.6);
				params.lifetime = int(round(params.size));

				// Distribute evenly across hemispheres.
				double pitch = 0.0;
				if (i % 2 == 0)
				{
					pitch = FRandom(-180.0, -20.0);
					params.startalpha = FRandom(0.15, 0.3);
				}
				else
				{
					pitch = FRandom(20.0, 180.0);
					params.startalpha = FRandom(0.2, 0.6);
				}

				SparkLightTrail trail = SparkLightTrail.Create(Pos + Vec3Util.FromAngles(FRandom(0.0, 360.0), pitch, FRandom(5.0, 12.0)), params);
				trail.m_AirFriction += FRandom(0.0, 0.3);
				trail.Mass += FRandom(0.0, 25.0);
				trail.Gravity += FRandom(0.0, 2.5);
				trail.bouncefactor = FRandom(0.3, 0.8);
				trail.wallbouncefactor = trail.bouncefactor;
				
				if (trail)
				{
					spawnedEffects.Push(trail);
					trail.A_ChangeLinkFlags(0);
					trail.target = target;
				}
			}

			ActorUtil.Explode3D(self, 0, m_ThrustForce, ExplosionRadius, THRTARGET_Origin, hitActors);

			foreach (effect : spawnedEffects)
			{
				if (effect)
				{
					effect.A_ChangeLinkFlags(1);
					effect.bSolid = false;
					effect.bShootable = false;
				}
			}
			spawnedEffects.Clear();
		}
		BOOM T 1 {
			m_ExplosionFadeLight = PointLight(Spawn("PointLight", Pos));
			m_ExplosionFadeLight.bNoGravity = true;
			m_ExplosionFadeLight.args[PointLight.LIGHT_RED] = int(255 * 0.5);
			m_ExplosionFadeLight.args[PointLight.LIGHT_GREEN] = int(255 * 0.25);
			m_ExplosionFadeLight.args[PointLight.LIGHT_BLUE] = int(255 * 0.0);
			m_ExplosionFadeLight.args[PointLight.LIGHT_INTENSITY] += int(256.0 / 2.0);
			Radius_Quake(100, 8, 0, 15, 0);
		}
		BOOM R 1 {
			m_ExplosionFadeLight.args[PointLight.LIGHT_INTENSITY] += int(256.0 / 2.0);
			Radius_Quake(100, 8, 0, 15, 0);
		}
		BOOM P 1 Radius_Quake(100, 8, 0, 15, 0);
		BOOM M 1 {
			Radius_Quake(100, 8, 0, 15, 0);

			// Thrust nashgore gibs.
			array<Actor> gibs;
			Actor a;

			let iterator = ThinkerIterator.Create("NashGoreGibs");
			while ((a = Actor(iterator.Next()))) gibs.Push(a);

			iterator = ThinkerIterator.Create("NashGoreRealGibs");
			while ((a = Actor(iterator.Next()))) gibs.Push(a);

			iterator = ThinkerIterator.Create("NashGoreBlood");
			while ((a = Actor(iterator.Next()))) gibs.Push(a);

			foreach (mo : gibs)
			{
				// Avoid division by zero and negative radius.
				double radius = ExplosionRadius > 0.0 ? ExplosionRadius : double.Epsilon;

				vector3 toTarget = LevelLocals.Vec3Diff(Pos, mo.Pos);
				double distance = toTarget.Length();

				if (distance > radius) continue;

				FLineTraceData traceData;
				LineTrace(AngleTo(mo), radius, PitchTo(mo), data: traceData);
	
				if (traceData.HitType == TRACE_HitWall
					|| traceData.HitType == TRACE_HitCeiling
					|| traceData.HitType == TRACE_HitFloor
					|| (traceData.HitType == TRACE_HitActor && traceData.HitActor && traceData.HitActor != mo))
				{
					continue;
				}

				double attenuatedForce = (radius - distance) / radius * (m_ThrustForce * 0.6);

				ActorUtil.Thrust3D(mo, toTarget, attenuatedForce);
			}
		}
		BOOM KJIHGFE 1 Radius_Quake(100, 8, 0, 15, 0);
		BOOM DCBAPQ 1 {
			m_ExplosionFadeLight.args[PointLight.LIGHT_INTENSITY] -= 256.0 / 7.0;
			Radius_Quake(100, 8, 0, 15, 0);
		}
		BOOM R 1 { m_ExplosionFadeLight.Destroy(); }
		Stop;
	Grenade:
		DYPP ABC 10 A_Die;
		Wait;
	Detonate:
		Stop;
	}
}