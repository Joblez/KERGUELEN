
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

class Revolver : BaseWeapon replaces Supershotgun
{
	bool m_SingleAction; //Checks if you're firing in Single action.
	vector2 m_Spread; //Weapon Spread.
	bool m_IsLoading; //checks if you are reloading.

	Default
	{
		Weapon.Kickback 20;
		Weapon.SlotNumber 2;
		Weapon.AmmoUse 0;
		Weapon.AmmoGive1 0;
		Weapon.AmmoGive2 BCYN;
		Weapon.AmmoType1 "RevoCylinder";
		Weapon.AmmoType2 "Ammo357";
		Weapon.UpSound("sw/raise");

		BaseWeapon.HUDExtensionType "RevolverHUD";

		Inventory.PickupMessage "[2].357 Magnum Revolver";

		Tag "Model 19";
	}

	States
	{
	Spawn:
		PICK A -1;
		Stop;

	ZF:
		TNT1 A 1 A_VRecoil(0.9,1,4);
		TNT1 A 1 A_VRecoil(0.95,1,4);
		TNT1 A 1 A_VRecoil(1.0,1,4);
		stop;
	Fire:
		TNT1 A 0 A_JumpIf((invoker.m_IsLoading), "ReloadEnd"); // If reloading.
		TNT1 A 0 A_JumpIf(invoker.m_SingleAction, "Shoot");
	DoubleAction:
		TNT1 A 0 {
			A_StartSound("sw/cock2", 9);
			invoker.GetHUDExtension().SendEventToSM('CylinderRotated');
		}
		SWDA A 1;
		SWDA B 1;
		SWDA C 1;
	Shoot:
		TNT1 A 0 A_JumpIfInventory("RevoCylinder", 1, 1);
		Goto Empty;

		SWDA E 0 Bright {
			A_AlertMonsters();
			A_TakeInventory("RevoCylinder", 1);
			invoker.GetHUDExtension().SendEventToSM('RoundFired');
			A_StartSound("sw/fire", CHAN_AUTO);
			A_GunFlash("ZF", GFF_NOEXTCHANGE);
			A_FireBullets(invoker.m_Spread.x, invoker.m_Spread.y, -1, 35, "BulletPuff");
			A_FRecoil(1);
			A_ShotgunSmoke(7, -1);
		}
		TNT1 A 0 { invoker.m_SingleAction = false; }
		Goto PostShot;

	PostShot:
		SWAF A 1 Bright;
		SWAF B 2 Bright;
		SWAF C 1;
		SWAF D 2;
		SWAF E 1;
		SWAF F 2;
		SWAF G 1;
	PostPostShot:
		SWAF I 1;
		TNT1 A 0 A_ReFire("PostPostShot");
		Goto Ready;

	AltFire:
		TNT1 A 0 A_JumpIf((invoker.m_IsLoading), "ReloadEnd"); // If reloading.
		TNT1 A 0 A_JumpIf(invoker.m_SingleAction, "AltReady");
		SWSA ABCD 1;
		TNT1 A 0 A_StartSound("sw/cock", 10,0,0.5);
		SWSA E 1;
		SWSA F 1 { invoker.GetHUDExtension().SendEventToSM('CylinderRotated'); }
		SWSA GHIJKLMN 1;
		TNT1 A 0 { invoker.m_SingleAction = true; }
		Goto AltReady;

	AltReady:
		TNT1 A 0 { invoker.m_Spread = (1, 1); }
		SWSA N 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;

	Ready:
		TNT1 A 0 { invoker.m_Spread = (3, 3); }
		SWAI A 1 A_WeaponReady(WRF_ALLOWRELOAD);
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
		SWEJ ABC 1;
		SWEJ DE 2;
		TNT1 A 0 A_StartSound("sw/open", CHAN_AUTO,0,0.5);
		SWEJ FG 1;
		SWEJ HI 1;
		SWEJ JKL 1;
		SWEJ M 3;
		TNT1 A 0 {
			invoker.m_IsLoading = true;
			A_DropCasings();
			A_TakeInventory("RevoCylinder", BCYN);
			invoker.GetHUDExtension().SendEventToSM('CylinderEmptied');
			A_StartSound("sw/eject", CHAN_AUTO, 0, 0.5);
		}
		SWEJ N 1;
		SWEJ O 3;
		SWEJ PQ 1;
		SWEJ R 1;
		SWEJ ST 1;
		SWEJ UV 2;
	Load:
		SWLD ABC 1 A_WeaponReady(WRF_NOSWITCH);
		SWLD DE 1 A_WeaponReady(WRF_NOSWITCH);
		TNT1 A 0 {
			A_StartSound("sw/load", CHAN_AUTO,0,0.5);
			int ammoAmount = min(
				FindInventory(invoker.AmmoType1).maxAmount - CountInv(invoker.AmmoType1),
				CountInv(invoker.AmmoType2));

			if (ammoAmount <= 0) return ResolveState("Ready");

			GiveInventory(invoker.AmmoType1, 1);
			TakeInventory(invoker.AmmoType2, 1);

			invoker.GetHUDExtension().SendEventToSM('RoundInserted');
			return ResolveState(null);
		}
		SWLD FG 2 A_WeaponReady(WRF_NOSWITCH);
		SWLD HIJ 1 A_WeaponReady(WRF_NOSWITCH);
		TNT1 A 0 {
			if (CheckInventory(invoker.AmmoType1, BCYN) || !CheckInventory(invoker.AmmoType2, 1))
			{
				return ResolveState ("ReloadEnd");
			}

			return ResolveState("Load");
		}
	ReloadEnd:
	Close:
		SWCL AB 1;
		SWCL C 1 {
			invoker.GetHUDExtension().SendEventToSM('CylinderClosed');
		}
		SWCL DE 1;
		SWCL A 0 A_StartSound("sw/close", CHAN_AUTO, 0, 0.5);
		SWCL FGH 3;
		SWCL IJKLMN 2;
		TNT1 A 0 {
			invoker.GetHUDExtension().SendEventToSM('SmoothTimeReset');
			invoker.m_SingleAction = false;
			invoker.m_IsLoading = false;
		}
		Goto Ready;

	Select:
		TNT1 A 0 {
			SetPlayerProperty(0, 1, 2);
			invoker.m_SingleAction = false;
		}
		TNT1 A 1;
		SWCL J 1 A_SetBaseOffset(-65, 81);
		SWCL J 1 A_SetBaseOffset(-35, 55);
		SWCL J 1 A_SetBaseOffset(-28, 39);
		SWCL J 1 A_SetBaseOffset(-12, 38);
		SWCL K 1 A_SetBaseOffset(3, 34);
		SWCL K 1 A_SetBaseOffset(3, 34);
		SWCL LMN 1;
		SWAF A 0 A_SetBaseOffset(0, WEAPONTOP);
		SWAI A 1 A_Raise(16);
		Goto Ready;

	Deselect:
		SWCL M 1 A_SetBaseOffset(3, 34);
		SWCL K 1 A_SetBaseOffset(-12, 38);
		SWCL J 1 A_SetBaseOffset(-28, 39);
		SWCL J 1 A_SetBaseOffset(-35, 55);
		SWCL J 1 A_SetBaseOffset(-65, 81);
		TNT1 A 0 A_SetBaseOffset(0, WEAPONBOTTOM);
		TNT1 A 4;
		SWAI A 1 A_Lower(16);
		Wait;
	}

	override void Travelled()
	{
		if (m_SingleAction) owner.Player.SetPSprite(PSP_WEAPON, ResolveState("AltReady"));
	}

	override int GetAmmo() const
	{
		return Ammo1.Amount;
	}

	override int GetReserveAmmo() const
	{
		return Ammo2.Amount;
	}

	private action void A_DropCasings()
	{
		if (GetCVar("casing_toggle") == 1)
		{
			// Yuck.
			RevolverHUD hud = RevolverHUD(invoker.GetHUDExtension());

			for (int i = 0; i < BCYN - hud.m_EmptyRounds; ++i)
			{
				vector2 coords = MathVec2.PolarToCartesian((3.0, (360.0 - double(i) * 60.0)));
				A_SpawnEffect(
					"RevolverCasing",
					(coords.x, coords.y + 8.0, -2.0),
					210.0,
					FRandom(-62.0, -63.0),
					FRandom(2.0, 2.5),
					true);
			}
		}
	}
}