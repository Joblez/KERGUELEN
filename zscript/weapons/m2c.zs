const RMAG = 35;

class RifleMag : Ammo
{
	Default
	{
		Inventory.MaxAmount RMAG;
	}
}

// Armalite AR10

class M2C : BaseWeapon replaces Chaingun
{

	Default
	{
		Inventory.PickupMessage "(4)7.62 Armalite Rifle";
		Weapon.AmmoUse 0;
		Weapon.AmmoGive1 0;
		Weapon.AmmoGive2 RMAG;
		Weapon.SlotNumber 4;
		Weapon.Kickback 5;
		Weapon.BobRangeX 5.0;
		Weapon.BobRangeY 2.0;
		Weapon.AmmoType1 "RifleMag";
		Weapon.AmmoType2 "Ammo762";
		Weapon.UpSound("AR10/draw");

		BaseWeapon.MoveSwayUpRange 1.0;
		BaseWeapon.MoveSwayWeight 3.75;
		BaseWeapon.MoveSwayResponse 18.0;
		BaseWeapon.HUDExtensionType "M2CHUD";

		DamageType "Normal";
		Tag "AR-10";
	}

	States
	{
	Spawn:
		PICK C -1;
		Loop;

	Ready:
		AR1I A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;

	Select:
		TNT1 A 0 {
			SetPlayerProperty(0, 1, 2);
		}
		TNT1 A 1;
		AR1I A 1 A_SetBaseOffset(-60, 100);
		#### A 1 A_SetBaseOffset(-50, 80);
		#### A 1 A_SetBaseOffset(-40, 60);
		#### A 1 A_SetBaseOffset(-20, 40);
		#### A 1 A_SetBaseOffset(-2, 30);
		AR1I A 1 A_SetBaseOffset(0, WEAPONTOP);
		AR1I A 1 A_Raise(16);
		Goto Ready;

	Deselect:
		AR1I A 1 A_SetBaseOffset(2, 30);
		#### A 1 A_SetBaseOffset(20, 40);
		#### A 1 A_SetBaseOffset(40, 60);
		#### A 1 A_SetBaseOffset(50, 80);
		#### A 1 A_SetBaseOffset(60, 100);
		AR1I A 1 A_SetBaseOffset(0, WEAPONBOTTOM);
		TNT1 A 4;
		AR1I A 1 A_Lower(16);
		Loop;

	Empty:
		TNT1 A 0 A_StopSound(1);
		TNT1 A 0 A_StartSound("weapons/empty", CHAN_AUTO, 0, 0.5);
		ARFR DEF 2;
		Goto Reload;
	ZF:
		TNT1 A 1 A_VRecoil(10, 2, 5);
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

	Single:
		TNT1 A 0 A_JumpIfInventory("RifleMag", 1, 1);
		Goto Finalshot;

		TNT1 A 0 A_FireBulletsEx((1.0, 1.0), 5120.0, Random(15, 20), 1);
		TNT1 A 0 A_SetBaseOffset(2, 32);
		ARFL A 1 Bright {
			A_FRecoil(2.0);
			A_SpawnCasing();
			A_SpawnSmoke();
			A_SpawnFlash(5, -3);
			A_TakeInventory("RifleMag", 1);
			A_AlertMonsters();
			A_StartSound("AR10/fire", CHAN_WEAPON);
			A_GunFlash("ZF", GFF_NOEXTCHANGE);
			let psp = player.FindPSprite(PSP_Weapon);
			if (psp)
			psp.frame = random(0, 3);

		}
		ARFR A 1;
		ARFR B 1;
		TNT1 A 0 A_SetBaseOffset(0, 30);
		TNT1 A 0 A_JumpIf(Player.cmd.buttons & BT_ATTACK, "Automatic");
		ARFR CDEFF 1 A_WeaponReady(WRF_NOSWITCH);
		Goto Ready;
		
	Automatic:
		TNT1 A 0 A_JumpIfInventory("RifleMag", 1, 1);
		Goto Finalshot;

		TNT1 A 0 A_FireBulletsEx((5.0, 1.0), 5120.0, Random(15, 20), 1);
		TNT1 A 0 A_SetBaseOffset(2, 32);
		ARFL A 1 Bright {
			A_FRecoil(1.2);
			A_SpawnCasing();
			A_SpawnSmoke();
			A_SpawnFlash(5, -3);
			A_TakeInventory("RifleMag", 1);
			A_AlertMonsters();
			//A_StartSound("AR10/fire", CHAN_WEAPON);
			A_StartSound("AR10/loop", CHAN_WEAPON, CHANF_LOOPING);
			A_GunFlash("ZF", GFF_NOEXTCHANGE);
			let psp = player.FindPSprite(PSP_Weapon);
			if (psp)
			psp.frame = random(0, 3);

		}
		ARFR A 1;
		ARFR B 1;
		TNT1 A 0 A_SetBaseOffset(0, 30);
		TNT1 A 0 A_JumpIf(Player.cmd.buttons & BT_ATTACK, "Automatic");
		TNT1 A 0 A_StopSound(1);
		TNT1 A 0 A_StartSound("AR10/loopend", 11);
		ARFR CDEFF 2 A_WeaponReady(WRF_NOSWITCH);
		Goto Ready;

	FinalShot:
		TNT1 A 0 A_StopSound(1);
		TNT1 A 0 A_StartSound("AR10/loopend", 11);
		ARFR DEF 2;
		Goto Ready;

	Reload:
		TNT1 A 0 A_JumpIfInventory(invoker.ammotype2, 1, 1);
		Goto Ready;
		TNT1 A 0 A_JumpIfInventory("RifleMag", RMAG, "Ready");
		TNT1 A 0 { invoker.GetHUDExtension().SendEventToSM('ReloadStarted'); }
		ARMO ABCDEFG 2;
		ARMO HI 1;
		TNT1 A 0 A_StartSound("AR10/magout", 9, 0, 0.5);		
		ARMO JKL 1;
		TNT1 A 0 A_SetBaseOffset(-4, 34);
		ARMI AB 3;
		TNT1 A 0 A_SetBaseOffset(-3, 33);
		ARMI CDEFG 2;
		TNT1 A 0 A_StartSound("AR10/magins", 9, 0, 0.5);
		ARMI HIJK 2;
		ARMI L 2;
		ARMI M 4;
		TNT1 A 0 A_StartSound("AR10/magtap", 9, 0, 0.5);
		TNT1 A 0 A_SetBaseOffset(3, 33);
		ARMI NOPQRS 2;
		TNT1 A 0 A_JumpIfInventory("RifleMag", 1, "Notempty");
		TNT1 A 0  A_SetBaseOffset(0, 30);
		ARMB ABC 2;
		TNT1 A 0 A_SetBaseOffset(4, 34);
		TNT1 A 0 A_StartSound("AR10/boltback", 9, 0, 0.75);		
		ARMB D 1;
		ARMB EFG 2;
		TNT1 A 0 A_StartSound("AR10/boltrel", 9, 0, 0.75);		
		ARMB H 1;
		ARMB IJK 2;
		ARME ABC 1;
		ARME DEFGH 2;
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
		TNT1 A 0 { invoker.GetHUDExtension().SendEventToSM('ReloadFinished'); }
		Goto Ready;

	NotEmpty:
		ARME ABC 2;
		ARME DEFGH 1 A_SetBaseOffset(0, 30);
		ARME H 1 {
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
	}

	override int GetAmmo() const
	{
		return Ammo1.Amount;
	}

	override int GetReserveAmmo() const
	{
		return Ammo2.Amount;
	}

	private action void A_SpawnSmoke()
	{
		if (CVar.GetCVar("weapon_effects", invoker.owner.player).GetInt() <= Settings.OFF) return;

		Actor effect = invoker.SpawnEffect(
			"MuzzleSmoke",
			(8.5, 5.0, 32.0),
			FRandom(-14.0, 14.0),
			FRandom(-9.0, 9.0),
			FRandom(4.0, 8.0),
			true);

		effect.A_FadeOut(FRandom(0.0, 0.075));
		effect.Scale.x += 0.2;
		effect.Scale.y = effect.Scale.x;
	}

	private action void A_SpawnCasing()
	{
		if (CVar.GetCVar("weapon_casings", invoker.owner.player).GetInt() <= Settings.OFF) return;

		invoker.SpawnEffect(
			"RifleCasing",
			(Math.Remap(Pitch, -120.0, 120.0, 30.0, 20.0),
			Math.Remap(abs(Pitch), 0.0, 90.0, 18.0, 20.0),
			26.0),
			-90.0 + FRandom(-5.0, 5.0),
			FRandom(40.0, 65.0),
			FRandom(3.0, 5.5),
			true);
	}
}