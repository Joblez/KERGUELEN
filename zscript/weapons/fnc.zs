const RMAG = 30;

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
	Default
	{
		Inventory.PickupMessage "(4)";

		Weapon.AmmoUse 0;
		Weapon.AmmoGive1 0;
		Weapon.AmmoGive2 30;
		Weapon.AmmoType1 "RifleMag";
		Weapon.AmmoType2 "Ammo223";
		Weapon.SlotNumber 4;

		DamageType "Normal";
		Tag "FNC";
	}

	bool m_FireSelect; //Fire selector
	bool m_isempty; //Checks if the gun is empty
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
		FNCI A 1 A_SetBaseOffset(67, 100);
		FNCI A 1 A_SetBaseOffset(54, 81);
		FNCI A 1 A_SetBaseOffset(32, 69);
		FNCI A 1 A_SetBaseOffset(22, 58);
		FNCI A 1 A_SetBaseOffset(2, 34);
		FNCF CDE 1;
		FNCI A 0 { invoker.m_PSpritePosition.SetBaseY(WEAPONTOP); }
		FNCI A 1 A_Raise(16);
		Goto Ready;

	Deselect:
		FNCI A 1 A_SetBaseOffset(2, 34);
		FNCI A 1 A_SetBaseOffset(22, 58);
		FNCI A 1 A_SetBaseOffset(32, 69);
		FNCI A 1 A_SetBaseOffset(54, 81);
		FNCI A 1 A_SetBaseOffset(67, 100);
		FNCI A 0 { invoker.m_PSpritePosition.SetBaseY(WEAPONBOTTOM); }
		TNT1 A 4;
		FNCI A 1 A_Lower(16);
		Loop;

	Empty:
		TNT1 A 0 A_StopSound(1);
		TNT1 A 0 A_StartSound("weapons/empty", 10);
		FNCF DEF 2;
		Goto Ready;

	Fire:
		TNT1 A 0 A_JumpIfInventory("RifleMag", 1, 1);
		Goto Finalshot;
		TNT1 A 0 A_JumpIf((invoker.m_FireSelect == 1), "Automatic"); //Goes to automatic fire if the selector is on full auto
	Single:
		TNT1 A 0 A_FireBullets(3, 1, -1, 10, "BulletPuff");
		FNFL A 1 Bright {
			A_RifleRecoil();
			A_CasingRifle(16 ,-3);
			A_SingleSmoke(5, -3);
			A_TakeInventory("RifleMag", 1);
			A_StartSound("fnc/fire", 1);
			A_AlertMonsters();

			let psp = player.FindPSprite(PSP_WEAPON);
			if (psp) psp.frame = random(0, 3);
		}
		FNCF A 1;
		FNCF B 1;
		FNCF C 2 A_WeaponReady(WRF_NOSWITCH);
		FNCF DEF 2 A_WeaponReady(WRF_NOSWITCH);
		Goto Ready;
	Hold:
	Automatic:
		TNT1 A 0 A_JumpIfInventory("RifleMag", 1, 1);
		Goto Finalshot;
		TNT1 A 0 A_FireBullets(5, 2, -1, 10, "Bulletpuff");
		FNFL A 1 Bright {
			A_RifleRecoil();
			A_CasingRifle(16,-3);
			A_SingleSmoke(5,-3);
			A_TakeInventory("RifleMag",1);
			A_AlertMonsters();
			A_StartSound("fnc/loop",1,CHANF_LOOPING);

			let psp = player.FindPSprite(PSP_Weapon);
			if (psp)
			psp.frame = random(0,3);
		}
		FNCF A 1;
		FNCF B 1;
		TNT1 A 0 A_ReFire;
		TNT1 A 0 A_StopSound(1);
		TNT1 A 0 A_StartSound("fnc/loopend", 11);
		FNCF CDEF 2 A_WeaponReady(WRF_NOSWITCH);
		Goto Ready;

	FinalShot:
		TNT1 A 0 A_JumpIf((invoker.m_isempty == 1), "Empty"); //Goes to empty now that the gun has fired it's last shot
		TNT1 A 0 { invoker.m_isempty = invoker.m_isempty + 1; } //adds the check
		TNT1 A 0 A_StopSound(1);
		TNT1 A 0 A_StartSound("fnc/loopend", 11);
		FNCF CDEF 2;
		Goto Ready;

	Reload:
		TNT1 A 0 A_JumpIfInventory("Ammo223", 1, 1);
		Goto Ready;
		TNT1 A 0 { invoker.m_isempty = invoker.m_isempty - 1; }	//removes the check now that you are reloading
		TNT1 A 0 A_JumpIfInventory("RifleMag", RMAG, "Ready");
		FNRS ABCDEFG 2;
		FNRS HI 1 ;
		FNRO AB 1 ;
		TNT1 A 0 A_StartSound("fnc/magout", 9);
		FNRO CD 1;
		TNT1 A 0 A_StartSound("Weapon/cloth2", 10);
		FNRO EFGHI 2;
		FNIN A 2 ;
		FNIN BC 1;
		FNIN D 2;
		TNT1 A 0 A_StartSound("fnc/magins", 9);
		FNIN EFG 2;
		FNIN HIJ 2;
		FNBT ABC 1;
		TNT1 A 0 A_JumpIfInventory("RifleMag", 1, "Notempty");
		FNBT DE 2;
		FNBT FG 2;
		TNT1 A 0 A_StartSound("fnc/boltback", 9);
		FNBT H 1;
		FNBT IJKL 2;
		TNT1 A 0 A_StartSound("fnc/boltrel", 9);
		FNBT M 2;
		FNBT NO 2;
		FNBT P 1;
		FNCE ABCDEFGH 2;
	Loading:
		TNT1 A 0 {
			if (CheckInventory(invoker.AmmoType1, 0) || !CheckInventory(invoker.AmmoType2, 1)) {
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
		FNCE CDEFGH 2;
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
		TNT1 A 0 A_JumpIf((invoker.m_FireSelect == 1), "SemiAuto");
		TNT1 A 0 A_Print("Full Auto");
		TNT1 A 0 { invoker.m_FireSelect = invoker.m_FireSelect + 1; }
		TNT1 A 0 A_StartSound("weapons/firemode", 1);
		FNCF DEF 2;
		Goto Ready;

	SemiAuto:
		TNT1 A 0 A_Print("Semi Auto");
		TNT1 A 0 { invoker.m_FireSelect = invoker.m_FireSelect - 1; }
		TNT1 A 0 A_StartSound("weapons/firemode", 1);
		FNCF DEF 2;
		Goto Ready;
	}
}
