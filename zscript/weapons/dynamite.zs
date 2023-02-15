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
		DYNI ABCD 3 BRIGHT A_WeaponReady();
		Loop;

	Fire:
		DYNH AB 1 BRIGHT;
		DYNH CDE 1 BRIGHT;
		TNT1 A 0 A_StartSound("dynamite/fuse", 9);
		DYNH FHJLMN 1 BRIGHT;
		TNT1 A 0 A_StartSound("dynamite/close", 10);
		DYNH OP 1 BRIGHT;
	Hold:
		DYNH S 1 BRIGHT {
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
		DYNS E 2 A_StartSound("dynamite/light", 10);
		DYNS FGHI 2;
		TNT1 A 0 A_Refire("Fire");
		Goto Ready;

	SelfDetonate:
		TNT1 A 0 {
			if (Health <= 0) return ResolveState("DIE"); // Ugly, but...

			return ResolveState(null);
		}
		DYNH SSSSSSSS 1 A_SetBaseOffset(0, invoker.m_PSpritePosition.GetBaseY() + 10);
		Goto NewStick;
	DIE:
		DYNH SSSSSSSS 1 A_SetBaseOffset(0, invoker.m_PSpritePosition.GetBaseY() + 10);
		DYNS B 2 A_Lower(1);
		Wait;

	Select:
		TNT1 A 0 { invoker.AmmoUse1 = invoker.GetReserveAmmo() > 0 ? 0 : 1; }
		DYNS A 2 A_SetBaseOffset(1, 85);
		DYNS B 2 A_SetBaseOffset(1, 60);
		TNT1 A 0 A_StartSound("dynamite/open", 10);
		DYNS CDE 2 A_SetBaseOffset(1, 50);
		TNT1 A 0 A_StartSound("dynamite/light", 10);
		DYNS FGH 2 A_SetBaseOffset(1, 30);
		DYNS I 2 A_SetBaseOffset(0, WEAPONTOP);
		TNT1 A 0 A_Raise(16);
		Wait;

	Deselect:
		DYNS FEDCB 2;
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

	Default
	{
		Radius 8;
		Height 8;
		Speed 20;
		Damage 0;
		ExplosionDamage 320;
		ExplosionRadius 360;
		Gravity 0.9;
		Scale 0.5;
		DeathSound "";
		Seesound "dynamite/fuseloop";
		Obituary "$OB_GRENADE"; // "%o caught %k's grenade."
		DamageType "Explosive";
		Projectile;

		DynamiteStick.ThrustForce 360;

		//+DOOMBOUNCE;
		-NOGRAVITY;
		+NOEXTREMEDEATH;
		+NODAMAGETHRUST;
		+RANDOMIZE;
		+FORCEXYBILLBOARD;
		+DEHEXPLOSION;
	}

	States
	{
	Spawn:
		DYNP ABCDEFGH 2 BRIGHT;
		Loop;
	Death:
		TNT1 A 1 {
			A_StopSound(7);
			A_NoGravity();
			A_SetScale(1,1);
			A_SetTranslucent(0.2);
			A_StartSound("dynamite/explode", CHAN_AUTO, attenuation: 0.4);

			if (CVar.GetCVar('weapon_particle_toggle', target.player).GetBool())
			{
				for (int i = 0; i < 9; ++i)
				{
					A_SpawnProjectile("RocketDebris", 0.0, 0.0, FRandom(0.0, 360.0), 2, FRandom(0.0, 360.0));
					A_SpawnProjectile("ExplosionSmoke", 0.0, 0.0, FRandom(0.0, 360.0), 2, FRandom(0.0, 360.0));
					A_SpawnProjectile("RocketDebris", 0.0, 0.0, FRandom(0.0, 360.0), 2, FRandom(0.0, 360.0));
					A_SpawnProjectile("ExplosionSmoke", 0.0, 0.0, FRandom(0.0, 360.0), 2, FRandom(0.0, 360.0));
				}
			}

			ActorUtil.Explode3D(self, int(ExplosionDamage * FRandom(1.0, 1.15)), m_ThrustForce, ExplosionRadius);
			A_AlertMonsters(4096.0);

		}
		BOOM TRP 1 Bright Radius_Quake(100,8,0,15,0);
		BOOM M 1 Bright {
			Radius_Quake(100,8,0,15,0);

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
		BOOM KJIHGFEDCBAPQR 1 Bright Radius_Quake(100,8,0,15,0);
		Stop;
	Grenade:
		DYPP ABC 10 A_Die;
		Wait;
	Detonate:
		Stop;
	}
}