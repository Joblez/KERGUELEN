const RMAG = 35;

class RifleMag : Ammo
{
	Default
	{
		Inventory.MaxAmount RMAG;
	}
}

// FN FNC.

class FNC : BaseWeapon replaces Chaingun
{
	bool m_FireSelect; // Fire selector.
	bool m_IsEmpty; // Checks if the gun is empty.

	Default
	{
		Inventory.PickupMessage "(4) 5.56 Assault Rifle";
		Weapon.AmmoUse 0;
		Weapon.AmmoGive1 0;
		Weapon.AmmoGive2 RMAG;
		Weapon.AmmoType1 "RifleMag";
		Weapon.AmmoType2 "Ammo223";
		Weapon.SlotNumber 4;
		Weapon.Kickback 5;
		Weapon.UpSound("fnc/draw");
		DamageType "Normal";
		Tag "FNC";
	}

	States
	{
	Spawn:
		PICK C -1;
		Loop;

	Ready:
		FNCI A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;

	Select:
		TNT1 A 0 SetPlayerProperty(0, 1, 2);
		TNT1 A 1;
		FNRS F 1 A_SetBaseOffset(60, 100);
		#### E 1 A_SetBaseOffset(50, 80);
		#### D 1 A_SetBaseOffset(40, 60);
		#### C 1 A_SetBaseOffset(20, 40);
		#### BA 1 A_SetBaseOffset(2, 30);
		FNCF DE 1;
		FNCI A 0 A_SetBaseOffset(0, WEAPONTOP);
		FNCI A 1 A_Raise(16);
		Goto Ready;

	Deselect:
		FNRS AB 1 A_SetBaseOffset(2, 30);
		#### C 1 A_SetBaseOffset(20, 40);
		#### D 1 A_SetBaseOffset(40, 60);
		#### E 1 A_SetBaseOffset(50, 80);
		#### F 1 A_SetBaseOffset(60, 100);
		FNCI A 0 A_SetBaseOffset(0, WEAPONBOTTOM);
		TNT1 A 4;
		FNCI A 1 A_Lower(16);
		Loop;

	Empty:
		TNT1 A 0 A_StopSound(1);
		TNT1 A 0 A_StartSound("weapons/empty", 10, 0, 0.5);
		FNCF DEF 2;
		Goto Ready;
	ZF:
		TNT1 A 1 A_VRecoil(0.99, 1, 4);
		TNT1 A 1 A_VRecoil(1.0, 1, 4);
		stop;
	Fire:
		TNT1 A 0 A_JumpIfInventory("RifleMag", 1, 1);
		Goto Finalshot;
		TNT1 A 0 A_JumpIf((invoker.m_FireSelect), "Automatic"); //Goes to automatic fire if the selector is on full auto
	Single:
		TNT1 A 0 A_FireBullets(3, 1, -1, 12, "Bullet_Puff");
		TNT1 A 0 A_SetBaseOffset(2, 32);
		FNFL A 1 Bright {
			A_FRecoil(0.8);
			A_CasingRifle(18,-5);
			A_SingleSmoke(5, -3);
			A_TakeInventory("RifleMag", 1);
			A_StartSound("fnc/fire", 1);
			A_AlertMonsters();
			A_GunFlash("ZF",GFF_NOEXTCHANGE);
			let psp = player.FindPSprite(PSP_WEAPON);
			if (psp) psp.frame = random(0, 3);
		}
		FNCF A 1;
		FNCF B 1;
		TNT1 A 0 A_SetBaseOffset(0, 30);
		FNCF C 2 A_WeaponReady(WRF_NOSWITCH);
		FNCF DEF 2 A_WeaponReady(WRF_NOSWITCH);
		Goto Ready;
	Hold:
	Automatic:
		TNT1 A 0 A_JumpIfInventory("RifleMag", 1, 1);
		Goto Finalshot;
		TNT1 A 0 A_FireBullets(5, 2, -1, 12, "Bullet_puff");
		TNT1 A 0 A_SetBaseOffset(2, 32);
		FNFL A 1 Bright {
			A_FRecoil(0.8);
			A_CasingRifle(18, -5);
			A_SingleSmoke(5, -3);
			A_TakeInventory("RifleMag", 1);
			A_AlertMonsters();
			A_StartSound("fnc/loop", 1, CHANF_LOOPING);
			A_GunFlash("ZF", GFF_NOEXTCHANGE);
			let psp = player.FindPSprite(PSP_Weapon);
			if (psp)
			psp.frame = random(0, 3);
			
		}
		FNCF A 1;
		FNCF B 1;
		TNT1 A 0 A_SetBaseOffset(0, 30);
		TNT1 A 0 A_JumpIf(Player.cmd.buttons & BT_ATTACK, "Automatic");
		TNT1 A 0 A_StopSound(1);
		TNT1 A 0 A_StartSound("fnc/loopend", 11);
		FNCF CDEF 2 A_WeaponReady(WRF_NOSWITCH);
		Goto Ready;

	FinalShot:
		TNT1 A 0 A_JumpIf((invoker.m_IsEmpty), "Empty"); //Goes to empty now that the gun has fired its last shot.
		TNT1 A 0 { invoker.m_IsEmpty = true; } // Adds the check.
		TNT1 A 0 A_StopSound(1);
		TNT1 A 0 A_StartSound("fnc/loopend", 11);
		FNCF CDEF 2;
		Goto Ready;

	Reload:
		TNT1 A 0 A_JumpIfInventory("Ammo223", 1, 1);
		Goto Ready;
		TNT1 A 0 { invoker.m_IsEmpty = false; } // Removes the check now that you are reloading.
		TNT1 A 0 A_JumpIfInventory("RifleMag", RMAG, "Ready");
		FNRS ABCDEFG 2;
		FNRS HI 1;
		FNRO AB 1;
		TNT1 A 0 A_StartSound("fnc/magout", 9, 0, 0.5);	
		TNT1 A 0 A_SetBaseOffset(-4, 34);
		FNRO CD 1;
		TNT1 A 0 A_SetBaseOffset(-3, 33);
		FNRO EFGHI 2;
		TNT1 A 0 A_SetBaseOffset(-2, 32);
		FNIN A 2;
		TNT1 A 0 A_SetBaseOffset(-1, 31);
		FNIN BC 1;
		TNT1 A 0 A_SetBaseOffset(0, 30);
		FNIN D 2;
		TNT1 A 0 A_StartSound("fnc/magins", 9, 0, 0.5);
		FNIN EFG 2;
		TNT1 A 0 A_SetBaseOffset(3, 33);
		FNIN HIJ 2;
		TNT1 A 0 A_SetBaseOffset(2, 32);
		FNBT ABC 1;
		TNT1 A 0 A_JumpIfInventory("RifleMag", 1, "Notempty");
		FNBT DE 2;
		TNT1 A 0  A_SetBaseOffset(0, 30);
		FNBT FG 2;
		TNT1 A 0 A_StartSound("fnc/boltback", 9, 0, 0.75);
		TNT1 A 0 A_SetBaseOffset(4, 34);
		FNBT H 1 ;
		FNBT IJKL 2;
		TNT1 A 0 A_StartSound("fnc/boltrel", 9, 0, 0.75);
		FNBT M 2 A_SetBaseOffset(0, 30);
		FNBT NO 2;
		FNBT P 1;
		FNCE ABCDEFGH 2;
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
		Goto Ready;

	NotEmpty:
		FNCE CDEFGH 2 A_SetBaseOffset(0, 30);
		TNT1 A 0 {
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
		Goto Ready;

	AltFire:
		TNT1 A 0 {
			invoker.m_FireSelect = !invoker.m_FireSelect;
		}
		TNT1 A 0 A_SetBaseOffset(1, 31);
		TNT1 A 0 A_Print(invoker.m_FireSelect ? "Full Auto" : "Semi Auto");
	 	TNT1 A 0 A_StartSound("weapons/firemode", CHAN_AUTO, 0, 0.5);
		FNCF DEF 2;
		TNT1 A 0 A_SetBaseOffset(0, 30);
		Goto Ready;
	}
}