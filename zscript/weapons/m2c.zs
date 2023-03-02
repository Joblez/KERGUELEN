const RMAG = 35;

class RifleMag : Ammo
{
	Default
	{
		Inventory.MaxAmount RMAG;
	}
}

// M2 Carbine

class M2C : BaseWeapon replaces Chaingun
{
	bool m_FireSelect; // Fire selector.

	Default
	{
		Inventory.PickupMessage "(4) .30 Carbine Automatic";
		Weapon.AmmoUse 0;
		Weapon.AmmoGive1 0;
		Weapon.AmmoGive2 RMAG;
		Weapon.SlotNumber 4;
		Weapon.Kickback 5;
		Weapon.BobRangeX 5.0;
		Weapon.BobRangeY 2.0;
		Weapon.AmmoType1 "RifleMag";
		Weapon.AmmoType2 "Ammo30";
		Weapon.UpSound("M2C/draw");

		BaseWeapon.MoveSwayUpRange 1.0;
		BaseWeapon.MoveSwayWeight 3.75;
		BaseWeapon.MoveSwayResponse 18.0;
		BaseWeapon.HUDExtensionType "M2CHUD";

		DamageType "Normal";
		Tag "M2 Carbine";
	}

	States
	{
	Spawn:
		PICK C -1;
		Loop;

	Ready:
		M2CI A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;

	Select:
		TNT1 A 0 {
			SetPlayerProperty(0, 1, 2);
		}
		TNT1 A 1;
		M2ST F 1 A_SetBaseOffset(-60, 100);
		#### E 1 A_SetBaseOffset(-50, 80);
		#### D 1 A_SetBaseOffset(-40, 60);
		#### C 1 A_SetBaseOffset(-20, 40);
		#### BA 1 A_SetBaseOffset(-2, 30);
		M2CF DE 1;
		M2CI A 1 A_SetBaseOffset(0, WEAPONTOP);
		M2CI A 1 A_Raise(16);
		Goto Ready;

	Deselect:
		M2ST A 1 A_SetBaseOffset(2, 30);
		#### B 1 A_SetBaseOffset(20, 40);
		#### B 1 A_SetBaseOffset(40, 60);
		#### B 1 A_SetBaseOffset(50, 80);
		#### C 1 A_SetBaseOffset(60, 100);
		M2CI A 1 A_SetBaseOffset(0, WEAPONBOTTOM);
		TNT1 A 4;
		M2CI A 1 A_Lower(16);
		Loop;

	Empty:
		TNT1 A 0 A_StopSound(1);
		TNT1 A 0 A_StartSound("weapons/empty", CHAN_AUTO, 0, 0.5);
		M2CF DEF 2;
		Goto Ready;
	ZF:
		TNT1 A 1 A_VRecoil(7, 1, 4);
		stop;
	Fire:
		TNT1 A 0 {
			if (CheckInventory("RifleMag", 1))
			{
				return ResolveState(null);
			}
			else
			{
				return ResolveState("Empty");
			}
		}
		TNT1 A 0 A_JumpIf((invoker.m_FireSelect), "Automatic"); //Goes to automatic fire if the selector is on full auto
	Single:
		TNT1 A 0 A_FireBullets(3, 1, -1, 10, "Bullet_Puff");
		TNT1 A 0 A_SetBaseOffset(2, 32);
		M2FL A 1 Bright {
			A_FRecoil(0.8);
			A_SpawnCasing();
			A_SingleSmoke(5, -3);
			A_TakeInventory("RifleMag", 1);
			A_StartSound("M2C/fire", CHAN_AUTO, 0, 0.9);
			A_AlertMonsters();
			A_GunFlash("ZF",GFF_NOEXTCHANGE);
			A_SpawnFlash(6, -1);
			let psp = player.FindPSprite(PSP_WEAPON);
			if (psp) psp.frame = random(0, 3);
		}
		M2CF A 1;
		M2CF B 1;
		TNT1 A 0 A_SetBaseOffset(0, WEAPONTOP);
		M2CF C 2 A_WeaponReady(WRF_NOSWITCH);
		M2CF DEF 2 A_WeaponReady(WRF_NOSWITCH);
		Goto Ready;
	Hold:
	Automatic:
		TNT1 A 0 A_JumpIfInventory("RifleMag", 1, 1);
		Goto Finalshot;
		TNT1 A 0 A_FireBullets(5, 2, -1, 10, "Bullet_puff");
		TNT1 A 0 A_SetBaseOffset(2, 32);
		M2FL A 1 Bright {
			A_FRecoil(0.8);
			A_SpawnCasing();
			A_SingleSmoke(5, -3);
			A_SpawnFlash(5, -3);
			A_TakeInventory("RifleMag", 1);
			A_AlertMonsters();
			A_StartSound("M2C/loop", CHAN_WEAPON, CHANF_LOOPING);
			A_GunFlash("ZF", GFF_NOEXTCHANGE);
			let psp = player.FindPSprite(PSP_Weapon);
			if (psp)
			psp.frame = random(0, 3);

		}
		M2CF A 1;
		M2CF B 1;
		TNT1 A 0 A_SetBaseOffset(0, 30);
		TNT1 A 0 A_JumpIf(Player.cmd.buttons & BT_ATTACK, "Automatic");
		TNT1 A 0 A_StopSound(1);
		TNT1 A 0 A_StartSound("M2C/loopend", 11);
		M2CF CDEF 2 A_WeaponReady(WRF_NOSWITCH);
		Goto Ready;

	FinalShot:
		TNT1 A 0 A_StopSound(1);
		TNT1 A 0 A_StartSound("M2C/loopend", 11);
		M2CF CDEF 2;
		Goto Ready;

	Reload:
		TNT1 A 0 A_JumpIfInventory(invoker.ammotype2, 1, 1);
		Goto Ready;
		TNT1 A 0 A_JumpIfInventory("RifleMag", RMAG, "Ready");
		TNT1 A 0 { invoker.GetHUDExtension().SendEventToSM('ReloadStarted'); }
		M2ST ABCDEFG 2;
		M2ST H 1;
		MOUT AB 1;
		TNT1 A 0 A_StartSound("M2C/magout", 9, 0, 0.5);
		TNT1 A 0 A_SetBaseOffset(-4, 34);
		MOUT CDE 2;
		TNT1 A 0 A_SetBaseOffset(-3, 33);
		MOUT FG 3;
		TNT1 A 0 A_SetBaseOffset(-2, 32);
		MINS A 2;
		TNT1 A 0 A_SetBaseOffset(-1, 31);
		MINS BCD 1;
		TNT1 A 0 A_SetBaseOffset(0, 30);
		MINS EF 2;
		TNT1 A 0 A_StartSound("M2C/magins", 9, 0, 0.5);
		MINS G 2;
		TNT1 A 0 A_SetBaseOffset(3, 33);
		MINS HIJK 2;
		TNT1 A 0 A_SetBaseOffset(2, 32);
		M2BT ABCD 1;
		M2BT E 2;
		TNT1 A 0 A_JumpIfInventory("RifleMag", 1, "Notempty");
		TNT1 A 0  A_SetBaseOffset(0, 30);
		M2BT FG 2;
		TNT1 A 0 A_SetBaseOffset(4, 34);
		M2BT HIJ 1;
		TNT1 A 0 A_StartSound("M2C/boltback", 9, 0, 0.75);
		M2BT KL 2;
		M2BT M 2 A_SetBaseOffset(0, 30);
		M2BT NO 2;
		TNT1 A 0 A_StartSound("M2C/boltrel", 9, 0, 0.75);
		M2BT PQRSTU 1;
		M2ED ABCDEFG 2;
		M2ED G 1;
	Loading:
		TNT1 A 0 {
			if (CheckInventory(invoker.AmmoType1, 0) || !CheckInventory(invoker.AmmoType2, 1))
			{
				return ResolveState ("Ready");
			}

			int ammoAmount = min(
				FindInventory(invoker.AmmoType1).maxAmount - CountInv(invoker.AmmoType1),
				CountInv(invoker.AmmoType2));

			if (ammoAmount <= 0) return ResolveState ("Ready");

			GiveInventory (invoker.AmmoType1, ammoAmount);
			TakeInventory (invoker.AmmoType2, ammoAmount);

			return ResolveState ("ReloadFinish");
		}
	ReloadFinish:
		M2ED G 1;
		TNT1 A 0 { invoker.GetHUDExtension().SendEventToSM('ReloadFinished'); }
		Goto Ready;

	NotEmpty:
		M2ED BCDEF 2 A_SetBaseOffset(0, 30);
		M2ED G 1 {
			if (CheckInventory(invoker.AmmoType1, 0) || !CheckInventory(invoker.AmmoType2, 1))
			{
				return ResolveState ("Ready");
			}

			int ammoAmount = min(
				FindInventory(invoker.AmmoType1).maxAmount - CountInv(invoker.AmmoType1),
				CountInv(invoker.AmmoType2));

			if (ammoAmount <= 0) return ResolveState ("Ready");

			GiveInventory(invoker.AmmoType1, ammoAmount);
			TakeInventory(invoker.AmmoType2, ammoAmount);

			return ResolveState("ReloadFinish");
		}
		Goto ReloadFinish;

	AltFire:
		TNT1 A 0 {
			invoker.m_FireSelect = !invoker.m_FireSelect;
		}
		TNT1 A 0 A_SetBaseOffset(1, 31);
		TNT1 A 0 A_Print(invoker.m_FireSelect ? "Full Auto" : "Semi Auto");
	 	TNT1 A 0 A_StartSound("weapons/firemode", CHAN_AUTO, 0, 0.5);
		M2CF DEF 2;
		TNT1 A 0 A_SetBaseOffset(0, 30);
		Goto Ready;
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

		A_SpawnEffect(
			"RifleCasing",
			(Math.Remap(Pitch, -90.0, 90.0, 34.0, 20.0),
			Math.Remap(abs(Pitch), 0.0, 90.0, 19.0, 23.0),
			31.0),
			-90.0 + FRandom(-5.0, 5.0),
			FRandom(40.0, 65.0),
			FRandom(3.0, 5.5),
			true);
	}
}