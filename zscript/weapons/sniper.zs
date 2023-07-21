const SMAG = 10;

class SniperAmmo: Ammo
{
	Default
	{
		Inventory.MaxAmount SMAG;
		Ammo.BackpackAmount 0;
		Ammo.BackpackMaxAmount SMAG;
	}
}

class Ishapore : baseweapon replaces Plasmarifle {
	bool m_Chambered; //checks if you are aiming down the Scope.
	bool m_Shouldered; //checks if you are aiming down the Scope.
	bool m_IsLoading; //checks if you are reloading.

	Default
	{
		Weapon.Kickback 20;
		Weapon.SlotNumber 6;
		Weapon.AmmoUse 0;
		Weapon.AmmoGive1 0;
		Weapon.AmmoGive2 10;
		Weapon.BobRangeX 6.0;
		Weapon.BobRangeY 2.0;
		Weapon.AmmoType1 "SniperAmmo";
		Weapon.AmmoType2 "Ammo54r";
		Weapon.UpSound("sniper/raise");

		BaseWeapon.HUDExtensionType "IshaporeHUD";
		BaseWeapon.LookSwayXRange 56.0;
		BaseWeapon.LookSwayStrengthX 28.0;
		BaseWeapon.LookSwayResponse 4.0;
		BaseWeapon.LookSwayRigidity 7.0;

		BaseWeapon.MoveSwayUpRange 0.5;
		BaseWeapon.MoveSwayDownRange 18.0;
		BaseWeapon.MoveSwayWeight 14.0;
		BaseWeapon.MoveSwayResponse 12.0;

		Inventory.PickupMessage "[6]7.62 Infantry Rifle";

		Tag "SVT-40";
	}

	States
	{

	Spawn:
		PICK E -1;
		Stop;

	ZF:
		TNT1 A 1 A_VRecoil(40, 1, 4);
		Stop;

	ZFScoped:
		TNT1 A 1 A_VRecoil(120, 1, 4);
		Stop;

	Ready:
		SVTI A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;

	Empty:
		TNT1 A 0 A_StartSound("weapons/empty", 10, 0, 0.5);
		TNT1 A 0 A_SetBaseOffset(2, 32);
		SVTF FF 2;
		TNT1 A 0 A_SetBaseOffset(0, 30);
		Goto Reload;

	Fire:
		TNT1 A 0 A_JumpIf((invoker.m_IsLoading), "ReloadEnd"); // If empty.
		TNT1 A 0 A_JumpIf((invoker.m_Shouldered), "ShoulderedFire");
		TNT1 A 0 A_JumpIfInventory("SniperAmmo", 1, 1);
		Goto Empty;
		TNT1 A 0;
		SVTF A 1 Bright {
			FLineTraceData t;

			double attackAngle = FRandom(-2.0, 2.0);
			double attackPitch = FRandom(-2.0, 2.0);

			LineTrace(Angle + ViewAngle + attackAngle, 16384.0, Pitch + ViewPitch + attackPitch, offsetz: self.Player.viewz - self.Pos.z, data: t);

			int damage = 120;

			if (t.Distance > 8192.0) damage *= 1.0 - ((t.Distance - 8192.0) / 8192.0);

			A_FireBulletsEx((attackAngle, attackPitch), 16384.0, damage, 1, FBF_EXPLICITANGLE);

			if (t.HitActor)
			{
				ActorUtil.Thrust3D(t.HitActor, Vec3Util.FromAngles(Angle + ViewAngle + attackAngle, Pitch + ViewPitch + attackPitch), 220.0, true);
			}

			A_FRecoil(2);
			A_SpawnSmokeTrail(t, (10.0, 5.0, 36.0), 4.5, spread: 1.35);

			A_SpawnFlash(5, -3, 2);
			A_TakeInventory("SniperAmmo", 1);
			A_StartSound("sniper/fire", CHAN_AUTO);
			A_AlertMonsters();
			A_GunFlash("ZF", GFF_NOEXTCHANGE);
			A_SetBaseOffset(8, 36);
			invoker.m_Chambered = false;
			A_SpawnCasingAlt();
		}
		SVTF A 1;
		TNT1 A 0 { invoker.m_Chambered = true; }
		SVTF B 1 A_SetBaseOffset(4, 33);
		SVTF CDE 2 A_SetBaseOffset(0, 30);
		SVTF FG 2 A_Weaponready(WRF_NOSWITCH);
		goto ready;

	Reload:
		TNT1 A 0 A_JumpIf(invoker.GetAmmo() == SMAG || invoker.GetReserveAmmo() == 0, "Ready");
		SVRS ABCDE 1;
		SVRS FGHI 2;
		TNT1 A 0 A_StartSound("sniper/boltback", 9);
		TNT1 A 0 {
			invoker.m_IsLoading = true;
			invoker.m_Chambered = false;
		}
		SVRS J 1;
		SVRS KL 2;
		SVRS MN 2;
	ReloadRepeat:
		TNT1 A 0 A_JumpIfInventory("SniperAmmo", SMAG, "ReloadEnd");
		TNT1 A 0 A_JumpIfInventory("Ammo54r", 1, "ProperReload");
		Goto ReloadEnd;

	ProperReload:
		SVRL ABCDEF 1 A_WeaponReady(WRF_NOSWITCH | WRF_NOSECONDARY);
		TNT1 A 0 {
			A_StartSound("sniper/load", 10);
			A_SetBaseOffset(-1, 33);

			GiveInventory(invoker.AmmoType1, 1);
			TakeInventory(invoker.AmmoType2, 1);
		}
		SVRL GH 2 A_WeaponReady(WRF_NOSWITCH | WRF_NOSECONDARY);
		TNT1 A 0 A_SetBaseOffset(-1, 32);
		SVRL IJ 2 A_WeaponReady(WRF_NOSWITCH | WRF_NOSECONDARY);
		TNT1 A 0 A_SetBaseOffset(-1, 31);
		SVRL K 2 A_WeaponReady(WRF_NOSWITCH | WRF_NOSECONDARY);
		TNT1 A 0 {
			if (CheckInventory(invoker.AmmoType1, 0) || !CheckInventory(invoker.AmmoType2, 1))
			{
				return ResolveState("ReloadEnd");
			}

			int ammoAmount = min(
				FindInventory(invoker.AmmoType1).maxAmount - CountInv(invoker.AmmoType1),
				CountInv(invoker.AmmoType2));

			if (ammoAmount <= 0) return ResolveState("Ready");

			return ResolveState("ReloadRepeat");
		}	
	ReloadEnd:
		TNT1 A 0 { invoker.m_IsLoading = false; }
		SVRE ABC 2;
		TNT1 A 0 {
			A_StartSound("sniper/boltfor", 9);
		}
		TNT1 A 0 {invoker.m_Chambered = true;}
		TNT1 A 0 A_SetBaseOffset(-2, 32);
		SVRE DEFGH 2;
		TNT1 A 0 A_SetBaseOffset(-1, 31);
		SVRE IJK 2;
		TNT1 A 0 A_SetBaseOffset(0, 30);
		SVRE LMN 2 A_Weaponready();
		Goto Ready;

	AltFire:
		TNT1 A 0 {
			if (invoker.m_Shouldered)
			{
				return ResolveState("Deshoulder");
			}
			else{

				return ResolveState("Shoulder");
			}
	}
	wait;

	Shoulder:
		TNT1 A 0 A_SetCrosshair(58);
		SADS A 1 { KergPlayer(self).SetZoomFactor(1.0); }
		SADS A 1 { KergPlayer(self).SetZoomFactor(1.33); }
		SADS B 1 { KergPlayer(self).SetZoomFactor(1.67); }
		SADS B 1 { KergPlayer(self).SetZoomFactor(2.0); }
		SADS C 1 { KergPlayer(self).SetZoomFactor(2.33); }
		SADS C 1 { KergPlayer(self).SetZoomFactor(2.67); }
		SADS D 1 { KergPlayer(self).SetZoomFactor(3.0); }
		SADS D 1 { KergPlayer(self).SetZoomFactor(3.33); }
		SADS E 1 { KergPlayer(self).SetZoomFactor(3.67); }
		SADS FG 1 { KergPlayer(self).SetZoomFactor(4.0); }
		TNT1 A 0 A_ZoomFactor(4.0);
		TNT1 A 0 { invoker.m_Shouldered = true; }
		Goto AltReady;

	Deshoulder:
		SADS E 1 { KergPlayer(self).SetZoomFactor(4.0); }
		SADS E 1 { KergPlayer(self).SetZoomFactor(3.67); }
		SADS D 1 { KergPlayer(self).SetZoomFactor(3.33); }
		SADS D 1 { KergPlayer(self).SetZoomFactor(3.0); }
		SADS C 1 { KergPlayer(self).SetZoomFactor(2.67); }
		SADS C 1 { KergPlayer(self).SetZoomFactor(2.33); }
		SADS B 1 { KergPlayer(self).SetZoomFactor(1.67); }
		SADS B 1 { KergPlayer(self).SetZoomFactor(2.0); }
		SADS A 1 { KergPlayer(self).SetZoomFactor(1.33); }
		SADS A 1 { KergPlayer(self).SetZoomFactor(1.0); }
		TNT1 A 0 A_ZoomFactor(1.0);
		TNT1 A 0 A_SetCrosshair(0);
		TNT1 A 0 { invoker.m_Shouldered = false; }
		goto ready;


	DeshoulderToReload:
		SADS E 1 { KergPlayer(self).SetZoomFactor(4.0); }
		SADS E 1 { KergPlayer(self).SetZoomFactor(3.67); }
		SADS D 1 { KergPlayer(self).SetZoomFactor(3.33); }
		SADS D 1 { KergPlayer(self).SetZoomFactor(3.0); }
		SADS C 1 { KergPlayer(self).SetZoomFactor(2.67); }
		SADS C 1 { KergPlayer(self).SetZoomFactor(2.33); }
		SADS B 1 { KergPlayer(self).SetZoomFactor(1.67); }
		SADS B 1 { KergPlayer(self).SetZoomFactor(2.0); }
		SADS A 1 { KergPlayer(self).SetZoomFactor(1.33); }
		SADS A 1 { KergPlayer(self).SetZoomFactor(1.0); }
		TNT1 A 0 A_ZoomFactor(1.0);
		TNT1 A 0 A_SetCrosshair(0);
		TNT1 A 0 { invoker.m_Shouldered = false; }
		Goto Reload;

	AltReady:
		SADI A 1 A_WeaponReady();
		Loop;

	EmptyScoped:
		TNT1 A 0 A_StartSound("weapons/empty", 10, 0, 0.5);
		SADS EF 2;
		Goto DeshoulderToReload;

	ShoulderedFire:
		TNT1 A 0 A_JumpIfInventory("SniperAmmo", 1, 1);
		Goto EmptyScoped;
		SADF A 2 Bright {
			FLineTraceData t;
			LineTrace(Angle + ViewAngle, 16384.0, Pitch + ViewPitch, offsetz: self.Player.viewz - self.Pos.z, data: t);

			int damage = 150;

			if (t.Distance > 8192.0) damage *= 1.0 - ((t.Distance - 8192.0) / 8192.0);

			A_FireBulletsEx((0.0, 0.0), 16384.0, damage, 1);

			if (t.HitActor)
			{
				ActorUtil.Thrust3D(t.HitActor, Vec3Util.FromAngles(Angle + ViewAngle, Pitch + ViewPitch), 220.0, true);
			}

			A_SpawnSmokeTrail(t, (0.0, 18.0, 32.0), 4.5, spread: 1.35);

			A_GunFlash("ZFScoped");
			A_StartSound("sniper/fire", 1);
			A_AlertMonsters();
			A_FRecoil(2.5);
			A_SpawnFlash(0, 0, 2);
			A_TakeInventory("SniperAmmo", 1);
			A_SpawnCasing();
		}
		SADF BCD 2;
		SADF E 2 A_WEAPONREADY(WRF_NOSWITCH);
		Goto AltReady;

	Select:
		// Workaround for IDFA/IDKFA UI bug.
		TNT1 A 0 { if (CheckInventory(invoker.AmmoType1, SMAG)) invoker.m_Chambered = true; }
		TNT1 A 4 A_SetBaseOffset(-65, 81);
		SVTI A 1 A_SetBaseOffset(-65, 81);
		SVTI A 1 A_SetBaseOffset(-35, 55);
		SVTI A 1 A_SetBaseOffset(-28, 39);
		SVTI A 1 A_SetBaseOffset(-12, 37);
		SVTI A 1 A_SetBaseOffset(1, 34);
		SVTI AAA 1 A_SetBaseOffset(0, 30);
		TNT1 A 0 A_SetBaseOffset(0, WEAPONTOP);
		TNT1 A 0 A_Raise(16);
		Goto Ready;

	Deselect:
		TNT1 A 0 {
			KergPlayer(self).SetZoomFactor(1.0);
			A_ZoomFactor(1.0);
			invoker.m_Shouldered = false;
			A_SetCrosshair(0);
		}
		SVTI A 1 A_SetBaseOffset(1, 34);
		SVTI A 1 A_SetBaseOffset(-12, 38);
		SVTI A 1 A_SetBaseOffset(-28, 39);
		SVTI A 1 A_SetBaseOffset(-35, 55);
		SVTI A 1 A_SetBaseOffset(-65, 81);
		SVTI A 1 A_SetBaseOffset(-65, 81);
		TNT1 A 0 A_SetBaseOffset(0, WEAPONBOTTOM);
		TNT1 A 4;
		SVTI A 1 A_Lower(16);
		Wait;
	}

	override int GetAmmo() const
	{
		return Ammo1.Amount;
	}

	override int GetReserveAmmo() const
	{
		return Ammo2.Amount;
	}

	private action void A_SpawnCasing()
	{
		if (CVar.GetCVar("weapon_casings", invoker.owner.player).GetInt() <= Settings.OFF) return;

		RifleCasing effect = RifleCasing(
			invoker.SpawnEffect(
				"RifleCasing",
				(-8.0, 17.0, 33.0),
				-90.0 + FRandom(-5.0, 1.0),
				FRandom(70.0, 75.0),
				FRandom(5.35, 5.45),
				true));
		
		effect.SetVirtualRoll(130.0);
	}

	private action void A_SpawnCasingAlt()
	{
		if (CVar.GetCVar("weapon_casings", invoker.owner.player).GetInt() <= Settings.OFF) return;

		RifleCasing effect = RifleCasing(
			invoker.SpawnEffect(
				"RifleCasing",
				(12.0, 12.0, 16.0),
				-90.0 + FRandom(-5.0, 5.0),
				FRandom(85.0, 90.0),
				FRandom(5.0, 5.5),
				true));
		
		effect.SetVirtualRoll(175.0);
	}
}