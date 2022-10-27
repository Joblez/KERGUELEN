
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
	bool m_IsLoading;

	Default
	{
		Weapon.Kickback 20;
		Weapon.SlotNumber 2;
		Weapon.AmmoUse 0;
		Weapon.AmmoGive1 0;
		Weapon.AmmoGive2 6;
		Weapon.AmmoType1 "RevoCylinder";
		Weapon.AmmoType2 "Ammo357";
		Weapon.UpSound("sw/raise");
		Inventory.PickupMessage "[2].357 Revolver";
		Tag "Model 15";
	}

	override void Travelled()
	{
		if (m_SingleAction) owner.Player.SetPSprite(PSP_WEAPON, ResolveState("AltReady"));
	}

	States
	{
	Spawn:
		PICK A -1;
		Stop;

	ZF:
		TNT1 A 1 A_VRecoil(0.95,1,4);
		TNT1 A 1 A_VRecoil(1.0,1,4);
		stop;
	Fire:
		TNT1 A 0 A_JumpIf((invoker.m_IsLoading), "ReloadEnd"); // If reloading.
		TNT1 A 0 A_JumpIf(invoker.m_SingleAction, "Shoot");
	DoubleAction:
		TNT1 A 0 A_StartSound("sw/cock2", 9);
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
			A_GunFlash("ZF",GFF_NOEXTCHANGE);
			A_FireBullets(invoker.m_Spread.x, invoker.m_Spread.y, -1, 20, "BulletPuff");
			A_FRecoil(1);
			A_ShotgunSmoke(3, 3);
		}
		TNT1 A 0 { invoker.m_SingleAction = false; }
		Goto PostShot;

	PostShot:
		SWAF A 1 Bright;
		SWAF B 2 Bright;
		SWAF C 1;
		SWAF D 1;
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
		TNT1 A 0 A_StartSound("sw/cock", 10,0,0.5);
		SWSA EFGHIJKLMN 1;
		TNT1 A 0 { invoker.m_SingleAction = true; }
		Goto AltReady;

	AltReady:
		TNT1 A 0 { invoker.m_Spread = (1, 1); }
		SWSA N 4 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;

	Ready:
		TNT1 A 0 { invoker.m_Spread = (3, 3); }
		SWAI A 4 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;

	Empty:
		SWAI A 2 {
			A_StartSound("weapons/empty", CHAN_AUTO,0,0.5);
			invoker.m_SingleAction = false;
		}
		Goto Ready;

	Reload:
		TNT1 A 0 {
			if (CheckInventory(invoker.AmmoType1, BCYN) || !CheckInventory(invoker.AmmoType2, 1))
			{
				// Wish I could just conditional operator this...
				if (invoker.m_SingleAction)
				{
					return ResolveState("AltReady");
				}
				else
				{
					return ResolveState("Ready");
				}
			}
			return ResolveState(null);
		}
		SWEJ ABCD 1;
		SWEJ E 2;
		TNT1 A 0 A_StartSound("sw/open", CHAN_AUTO,0,0.5);
		SWEJ FG 2;
		SWEJ HI 1;
		SWEJ JKL 1;
		TNT1 A 0 A_StartSound("sw/eject", CHAN_AUTO,0,0.5);
		TNT1 A 0 A_TakeInventory("RevoCylinder", BCYN);
		SWEJ M 2;
		TNT1 A 0 { invoker.m_IsLoading = true; }
		TNT1 A 0 {
			A_CasingRevolver(random(-4,4), random(-30,-34));
			A_CasingRevolver(random(-4,4), random(-30,-34));
			A_CasingRevolver(random(-4,4), random(-30,-34));
			A_CasingRevolver(random(-4,4), random(-30,-34));
			A_CasingRevolver(random(-4,4), random(-30,-34));
			A_CasingRevolver(random(-4,4), random(-30,-34));
		}
		SWEJ NO 2;
		SWEJ P 1;
		SWEJ Q 2;
		SWEJ R 1;
		SWEJ ST 1;
		SWEJ U 2;
	Loading:
		TNT1 A 0 {
			if (CheckInventory(invoker.AmmoType1, 0) || !CheckInventory(invoker.AmmoType2, 1))
			{
				return ResolveState ("ReloadEnd");
			}

			int ammoAmount = min(
				FindInventory(invoker.AmmoType1).maxAmount - CountInv(invoker.AmmoType1),
				CountInv(invoker.AmmoType2));

			if (ammoAmount <= 0) return ResolveState("Ready");

			GiveInventory(invoker.AmmoType1, 1);
			TakeInventory(invoker.AmmoType2, 1);

			return ResolveState("Load");
		}
	Load:
		SWLD ABCD 1 A_WeaponReady(WRF_NOSWITCH);
		TNT1 A 0 A_StartSound("sw/load", CHAN_AUTO,0,0.5);
		SWLD EF 2 A_WeaponReady(WRF_NOSWITCH);
		SWLD GHIJ 1 A_WeaponReady(WRF_NOSWITCH);
		Goto Loading;

	ReloadEnd:
	Close:
		SWCL ABCD 2;
		SWCL A 0 A_StartSound("sw/close", CHAN_AUTO,0,0.5);
		TNT1 A 0 { invoker.m_IsLoading = false; }
		SWCL EFGHIJKLMN 2;
		TNT1 A 0 { invoker.m_SingleAction = false; }
		Goto Ready;

	Select:
		TNT1 A 0 SetPlayerProperty(0, 1, 2);
		TNT1 A 0 { invoker.m_SingleAction = false; }
		TNT1 A 1;
		SWCL J 1 A_SetBaseOffset(-65, 81);
		SWCL J 1 A_SetBaseOffset(-35, 55);
		SWCL J 1 A_SetBaseOffset(-28, 39);
		SWCL J 1 A_SetBaseOffset(-12, 38);
		SWCL K 1 A_SetBaseOffset(3, 34);
		SWCL K 1 A_SetBaseOffset(3, 34);
		SWCL LMN 1;
		SWAF A 0 { invoker.m_PSpritePosition.SetBaseY(WEAPONTOP); }
		SWAI A 1 A_Raise(16);
		Goto Ready;

	Deselect:
		SWCL M 1 A_SetBaseOffset(3, 34);
		SWCL K 1 A_SetBaseOffset(-12, 38);
		SWCL J 1 A_SetBaseOffset(-28, 39);
		SWCL J 1 A_SetBaseOffset(-35, 55);
		SWCL J 1 A_SetBaseOffset(-65, 81);
		SWAF A 0 { invoker.m_PSpritePosition.SetBaseY(WEAPONBOTTOM); }
		TNT1 A 4;
		SWAI A 1 A_Lower(16);
		Loop;
	}
}