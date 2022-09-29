
// { S&W Model 19 }

const BCYN = 6;

Class RevoCylinder : Ammo
{
	Default
	{
		Inventory.Amount BCYN;
		Inventory.MaxAmount BCYN;
		Ammo.BackpackAmount 0;
		Ammo.BackpackMaxAmount BCYN;
	}
}

class Revolver : BaseWeapon
{
	bool m_SingleAction;
	vector2 m_Spread;

	Default
	{
		Weapon.Kickback 20;
		Weapon.SlotNumber 2;
		Weapon.AmmoUse 0;
		Weapon.AmmoGive1 0;
		Weapon.AmmoGive2 6;
		Weapon.AmmoType2 "Ammo357";
		Weapon.AmmoType "RevoCylinder";
		Weapon.UpSound("sw/raise");
		Inventory.PickupMessage "[2].357 Revolver";
		Tag "Model 19";
		Obituary "%o was smoked by %k.";
	}

	States
	{
	Spawn:
		PICK A -1;
		Stop;

	Fire:
		TNT1 A 0 A_JumpIf(invoker.m_SingleAction, "Shoot");
	DoubleAction:
		TNT1 A 0 A_StartSound("sw/cock", 3);
		SWDA A 1;
		SWDA B 1;
		SWDA C 1;
	Shoot:
		TNT1 A 0 A_JumpIfInventory("RevoCylinder", 1, 1);
		Goto Empty;

		SWDA E 0 Bright {
			A_AlertMonsters();
			A_TakeInventory("RevoCylinder", 1);
			A_StartSound("sw/fire", 1);
			A_FireBullets(invoker.m_Spread.x, invoker.m_Spread.y, -1, 30, "BulletPuff");
			A_PistolRecoil();
			A_ShotgunSmoke(3, 3);
		}
		TNT1 A 0 { invoker.m_SingleAction = false; }
		Goto PostShot;

	PostShot:
		SWAF A 1 Bright;
		SWAF B 2 Bright;
		SWAF C 2;
		SWAF D 2;
		SWAF E 1;
		SWAF F 1;
		SWAF G 1;
	PostPostShot:
		SWAF I 1;
		TNT1 A 0 A_ReFire("PostPostShot");
		Goto Ready;

	AltFire:
		TNT1 A 0 A_JumpIf(invoker.m_SingleAction, "AltReady");
		SWSA ABCD 2;
		TNT1 A 0 A_StartSound("sw/cock", 10);
		SWSA EFGHIJKLMN 1;
		TNT1 A 0 { invoker.m_SingleAction = true; }
		Goto AltReady;

	AltReady:
		TNT1 A 0 { invoker.m_Spread = (1, 1); }
		SWSA N 4 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;

	Ready:
		TNT1 A 0 { invoker.m_Spread = (4, 3); }
		SWAI A 4 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;

	Empty:
		SWAI A 2 {
			A_StartSound("weapons/empty", 1);
			invoker.m_SingleAction = false;
		}
		Goto Ready;

	Reload:
		TNT1 A 0 A_JumpIfInventory("Ammo357", 1, 1);
		Goto Ready;
		TNT1 A 0 A_JumpIfInventory("RevoCylinder", BCYN, "Ready");
		SWEJ ABCD 1;
		SWEJ E 2;
		TNT1 A 0 A_StartSound("sw/open", CHAN_AUTO);
		SWEJ FG 2;
		SWEJ HI 1;
		SWEJ JK 1;
		TNT1 A 0 A_StartSound("sw/eject", CHAN_AUTO);
		TNT1 A 0 A_TakeInventory("RevoCylinder", BCYN);
		SWEJ LMN 2;
		TNT1 A 0 {
			A_CasingRevolver(0,-28);
			A_CasingRevolver(0,-28);
			A_CasingRevolver(0,-28);
			A_CasingRevolverL(0,-28);
			A_CasingRevolverL(0,-28);
			A_CasingRevolverL(0,-28);
		}
		SWEJ O 2;
		SWEJ P 2;
		SWEJ Q 2;
		SWEJ R 1;
		SWEJ ST 1;
		SWEJ U 2;
	Loading:
		TNT1 A 0 {
	            if (CheckInventory (invoker.AmmoType1, 0) || !CheckInventory (invoker.AmmoType2, 1))
                return ResolveState ("ReloadFinish");
					int ammoAmount = min (FindInventory (invoker.AmmoType1).maxAmount - CountInv (invoker.AmmoType1), CountInv (invoker.AmmoType2));
					if (ammoAmount <= 0)
					return ResolveState ("Ready");

				GiveInventory (invoker.AmmoType1, 1);
				TakeInventory (invoker.AmmoType2, 1);

				return ResolveState ("Load");

				}

	load:
		SWLD ABCD 1;
		TNT1 A 0 A_StartSound("sw/load", CHAN_AUTO);
		SWLD EFG 2;
		SWLD HIJ 1;
		Goto loading;
	ReloadFinish:
	Close:
		SWCL ABCD 2;
		SWCL A 0 A_StartSound("sw/close", CHAN_AUTO);
		SWCL EFGHIJKLMN 2;
		Goto Ready;

	select:
		TNT1 A 0 SetPlayerProperty(0,1,2);
		TNT1 A 1;
		SWAI A 1 Offset(67, 100);
		SWAI A 1 Offset(54, 81);
		SWAI A 1 Offset(32, 69);
		SWAI A 1 Offset(22, 58);
		SWAI A 1 Offset(2, 34);
		SWAF HI 1;
		SWAI A 1 A_Raise(16);
		Goto Ready;
	deselect:
		SWAI A 1 Offset(2, 34);
		SWAI A 1 Offset(22, 58);
		SWAI A 1 Offset(32, 69);
		SWAI A 1 Offset(54, 81);
		SWAI A 1 Offset(67, 100);
		TNT1 A 4;
		SWAI A 1 A_Lower(16);
		Loop;
		}
}

