const STUBE = 8;

class Sh12Tube : Ammo
{
	Default
	{
		Inventory.MaxAmount STUBE;
	}
}

//Ithaca M37

class Ithaca : BaseWeapon replaces Shotgun
{
	bool m_Chambered; //checks if the gun is chambered.
	bool m_IsLoading; //checks if you are reloading.

	Default
	{
		Weapon.AmmoUse 0;
		Weapon.AmmoGive1 0;
		Weapon.AmmoGive2 8;
		Weapon.SlotNumber 3;
		Weapon.AmmoType2 "Ammo12";
		Weapon.AmmoType1 "Sh12Tube";
		Weapon.Kickback 50;
		Weapon.UpSound("shotgun/draw");

		BaseWeapon.MaxLookSwayTranslationX 48.0;
		BaseWeapon.LookSwayStrengthX 15.0;
		BaseWeapon.LookSwayResponse 5.0;
		BaseWeapon.LookSwayRigidity 9.0;

		Inventory.PickupMessage "(3)12 Gauge Hunting Shotgun";

		DamageType "Shotgun";
		Tag "Ithaca";
	}

	States
	{
	Spawn:
		PICK B -1;
		Stop;

	Ready:
		TNT1 A 0 A_JumpIfInventory("Sh12Tube", 1, 1);
		ITAI A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;

	ZF:
		TNT1 A 1 A_VRecoil(0.9,1,4);
		TNT1 A 1 A_VRecoil(0.95,1,4);
		TNT1 A 1 A_VRecoil(1.0,1,4);
		Stop;

	Fire:
		TNT1 A 0 A_JumpIf((!invoker.m_Chambered && invoker.m_IsLoading), "ReloadEnd"); // If empty.
		TNT1 A 0 A_JumpIf((invoker.m_Chambered && invoker.m_IsLoading), "ReloadEnd"); // If loaded.
		TNT1 A 0 A_JumpIfInventory("Sh12Tube", 1, 1);
		Goto Empty;

		ITAF A 2 Bright {
			invoker.m_Chambered = false;

			let iterator = BlockThingsIterator.Create(self, 256.0);

			while (iterator.Next())
			{
				Actor mo = iterator.thing;

				if (mo == self || !mo.bSolid || !mo.bShootable) continue;

				vector3 origin = (self.Pos.xy, self.Player.viewz);
				vector3 position = (mo.Pos.xy, mo.Pos.z + mo.Height / 2.0);
				vector3 toTarget = position - origin;
				double distance = toTarget.Length();

				if (distance > 290.0) continue;

				double dotProduct = min(0.925, toTarget.Unit() dot Vec3Util.FromAngles(self.angle, self.pitch));
				Console.Printf("Dot: %f", dotProduct);

				if (dotProduct >= 0.8)
				{
					FLineTraceData t;

					LineTrace(
						AngleTo(mo),
						distance + 1.0,
						ActorUtil.PitchTo(self, mo),
						offsetz: self.Height / 2.0,
						data: t);

					if (t.HitActor)
					{
						double force = Math.Remap(dotProduct, 0.8, 0.925, 50.0, 260.0);
						force *= 1.0 - Math.Remap(distance, 32.0, 290.0, 0.0, 0.85);
						Console.Printf("Force: %f", force);
						ActorUtil.Thrust3D(mo, toTarget.Unit(), force, true);
					}
				}
			}

			A_FireBullets(7, 7, 12, 4, "Bullet_Puff");
			A_FRecoil(2);
			A_AlertMonsters();
			A_ShotgunSmoke(4, -4);
			A_ShotgunSmoke(4, -4);
			A_TakeInventory("Sh12Tube", 1);
			A_StartSound("shotgun/fire", CHAN_WEAPON);
			A_GunFlash("ZF", GFF_NOEXTCHANGE);
			A_SetBaseOffset(4, 34);
		}
		ITAF B 1 Bright A_SetBaseOffset(2, 32);
		ITAF CDEF 1;
		ITAF GHI 2;
		TNT1 A 0 A_SetBaseOffset(0, 30);
		TNT1 A 0 {
			if (CountInv("Sh12Tube") == 0) {
				return ResolveState("Ready");
			}
			else {
				return ResolveState("Pump");
			}
		}
	Pump:
		TNT1 A 0 A_StartSound("shotgun/pumpback", 9,0,0.9);
		ITAP ABC 1;
		ITAP DE 2;
		TNT1 A 0 A_StartSound("shotgun/pumpfor", 9,0,0.9);
		TNT1 A 0 A_SpawnCasing();
		ITAP FG 2;
		TNT1 A 0 { invoker.m_Chambered = true; }
		ITAP HIJ 2 A_WeaponReady();
		Goto Ready;

	Empty:
		TNT1 A 0 A_StartSound("weapons/empty", 10,0,0.5);
		ITAF FGH 2;
		Goto Ready;

	Charge:
		TNT1 A 0 { invoker.m_IsLoading = false; }
		TNT1 A 0 A_StartSound("shotgun/pumpback", 9,0,0.9);
		ITAP ABC 1;
		ITAP DE 2;
		TNT1 A 0 A_SpawnCasing();
		TNT1 A 0 A_StartSound("shotgun/pumpfor", 9,0,0.9);
		ITAP FG 2;
		TNT1 A 0 { invoker.m_Chambered = true; }
		ITAP HIJ 2 A_WeaponReady();
		Goto Ready;

	Select:
		TNT1 A 0 SetPlayerProperty(0, 1, 2);
		TNT1 A 1;
		ITRS F 1 A_SetBaseOffset(70, 100);
		ITRS E 1 A_SetBaseOffset(60, 80);
		ITRS D 1 A_SetBaseOffset(40, 60);
		ITRS C 1 A_SetBaseOffset(20, 40);
		ITRS B 1 A_SetBaseOffset(10, 30);
		ITRS A 1 A_SetBaseOffset(2, 30);
		ITAI A 0 A_SetBaseOffset(0, WEAPONTOP);
		ITAF FGH 2;
		ITAI A 1 A_Raise(16);
		Goto Ready;

	Deselect:
		ITAI A 2 A_SetBaseOffset(2, 34);
		ITAI A 1 A_SetBaseOffset(22, 58);
		ITAI A 1 A_SetBaseOffset(32, 69);
		ITAI A 1 A_SetBaseOffset(54, 81);
		ITAI A 1 A_SetBaseOffset(67, 100);
		ITAI A 0 A_SetBaseOffset(0, WEAPONBOTTOM);
		TNT1 A 4;
		ITAI A 1 A_Lower(16);
		Loop;

	Reload:
		TNT1 A 0 A_JumpIfInventory("Sh12Tube", STUBE, "Ready");
		TNT1 A 0 A_JumpIfInventory("Ammo12", 1, 1);
		Goto Ready;

	ReloadStart:
		ITRS ABCDE 1 A_WeaponReady(WRF_NOFIRE | WRF_NOBOB);
		ITRS FGH 2 A_WeaponReady(WRF_NOFIRE | WRF_NOBOB);
		TNT1 A 0 { invoker.m_IsLoading = true; }
	ReloadRepeat:
		TNT1 A 0 A_JumpIfInventory("Sh12Tube", STUBE, "ReloadEnd");
		TNT1 A 0 A_JumpIfInventory("Ammo12", 1, "ProperReload");
		Goto ReloadEnd;

	ProperReload:
		TNT1 A 0 A_SetBaseOffset(0, 30);
		ITRL ABCD 1 A_WeaponReady(WRF_NOSWITCH | WRF_NOBOB);
		TNT1 A 0 A_StartSound("shotgun/load", 10,0,0.5);
		ITRL EF 2 A_WeaponReady(WRF_NOSWITCH | WRF_NOBOB);
		ITRL G 1 A_WeaponReady(WRF_NOSWITCH | WRF_NOBOB);
		ITRL HI 1;
		TNT1 A 0 A_SetBaseOffset(4, 34);
		ITRL JKL 2 A_WeaponReady(WRF_NOSWITCH | WRF_NOBOB);
		TNT1 A 0 A_SetBaseOffset(3, 33);
		ITRL M 2 A_WeaponReady(WRF_NOSWITCH | WRF_NOBOB);
		TNT1 A 0 A_SetBaseOffset(2, 32);
		TNT1 A 0 {
			if (CheckInventory(invoker.AmmoType1, 0) || !CheckInventory(invoker.AmmoType2, 1))
			{
				return ResolveState("ReloadEnd");
			}

			int ammoAmount = min(
				FindInventory(invoker.AmmoType1).maxAmount - CountInv(invoker.AmmoType1),
				CountInv(invoker.AmmoType2));

			if (ammoAmount <= 0) return ResolveState("Ready");

			GiveInventory(invoker.AmmoType1, 1);
			TakeInventory(invoker.AmmoType2, 1);

			return ResolveState("ReloadRepeat");
		}
	ReloadEnd:
		TNT1 A 0 { invoker.m_IsLoading = false; }
		TNT1 A 0 A_SetBaseOffset(2, 32);
		ITRE ABCDE 2 A_WeaponReady(WRF_NOSWITCH | WRF_NOBOB);
		TNT1 A 0 A_SetBaseOffset(1, 31);
		ITRE FGHI 1 A_WeaponReady(WRF_NOSWITCH | WRF_NOBOB);
		TNT1 A 0 A_SetBaseOffset(0, 30);
		TNT1 A 0 A_JumpIf((invoker.m_Chambered), "Ready");
		Goto Charge;
	}

	private action void A_SpawnCasing()
	{
		if (GetCVar("casing_toggle") == 1)
		{
			A_SpawnEffect(
				"ShotgunCasing",
				(21.0, 19.0, 42.0),
				0.0 + FRandom(7.0, 0),
				FRandom(-6.0, -6.75),
				FRandom(6.0, 6.5),
				true);
		}
	}
}