const CMAG = 8;

Class ColtMag : Ammo
{
	Default
	{
		Inventory.Amount CMAG;
		Inventory.MaxAmount CMAG;
		Ammo.BackpackAmount 0;
		Ammo.BackpackMaxAmount CMAG;
	}
}

class Colt : BaseWeapon replaces Pistol
{
	bool m_Empty;

	Default
	{
		Weapon.Kickback 10;
		Weapon.AmmoUse 0;
		Weapon.AmmoGive1 0;
		Weapon.AmmoGive2 CMAG;
		Weapon.AmmoType1 "ColtMag";
		Weapon.AmmoType2 "Ammo45";
		Weapon.UpSound("sw/raise");

		BaseWeapon.HUDExtensionType "ColtHUD";

		Inventory.PickupMessage "[2] .45 Handgun";

		Tag "M1911";
	}

	States
	{
		Spawn:
			PIST A -1;
			Stop;

		ZF:
			TNT1 A 1 A_VRecoil(5, 1, 4);
			Stop;
		
		Select:
			TNT1 A 0 { invoker.m_Empty = !CheckInventory(invoker.AmmoType1, 1); }
			TNT1 A 0 A_BranchOnEmpty("EmptySelect", "ChamberedSelect");
			Stop;

		ChamberedSelect:
			M19R A 1 A_SetBaseOffset(65, 81);
			M19R A 1 A_SetBaseOffset(35, 55);
			M19R A 1 A_SetBaseOffset(28, 39);
			M19R A 1 A_SetBaseOffset(12, 38);
			M19R A 1 A_SetBaseOffset(3, 34);
			M19I A 1 A_SetBaseOffset(0, WEAPONTOP);
			M19I A 3;
			Goto Ready;
		
		EmptySelect:
			M1FE I 1 A_SetBaseOffset(65, 81);
			M1FE I 1 A_SetBaseOffset(35, 55);
			M1FE I 1 A_SetBaseOffset(28, 39);
			M1FE I 1 A_SetBaseOffset(12, 38);
			M1FE I 1 A_SetBaseOffset(3, 34);
			M1FE I 1 A_SetBaseOffset(3, 34);
			M1FE I 1 A_SetBaseOffset(0, WEAPONTOP);
			M1FE I 3;
			Goto AltReady;

		Ready:
			TNT1 A 0 { invoker.m_Empty = false; }
			M19I A 1 A_WeaponReady(WRF_ALLOWRELOAD);
			Loop;
		
		Fire:
			TNT1 A 0 {
				if (CheckInventory("ColtMag", 1))
				{
					return ResolveState(null);
				}
				else
				{
					return ResolveState("Empty");
				}
			}
			
			TNT1 A 0 A_JumpIfInventory("ColtMag", 2, 1);
			Goto FinalShot;
			
			M19F A 1 BRIGHT {
				A_AlertMonsters();
				A_TakeInventory("ColtMag", 1);
				A_StartSound("colt/fire", CHAN_AUTO);
				A_GunFlash("ZF", GFF_NOEXTCHANGE);
				A_FireBulletsEx((1.5, 1.0), 4096.0, Random(14, 18), 1);
				A_FRecoil(1);
				A_SpawnFlash(6, -1);
				A_SpawnEffect(
					"MuzzleSmoke",
					(10.5, 3.0, 20.0),
					FRandom(-3.0, 3.0),
					FRandom(-1.5, 1.5),
					4.0,
					true);
			}
			M19F B 1 A_SpawnCasing();
			M19F CDE 1;
			M19F FGH 2 A_WeaponReady(WRF_NOBOB);
			Goto Ready;
		
		FinalShot:
			M19F A 1 BRIGHT {
				invoker.m_Empty = true;
				A_AlertMonsters();
				A_TakeInventory("ColtMag", 1);
				A_StartSound("colt/fire", CHAN_WEAPON);
				A_GunFlash("ZF", GFF_NOEXTCHANGE);
				A_FireBulletsEx((1.5, 1.0), 4096.0, Random(14, 18), 1);
				A_FRecoil(3.0);
				A_SpawnFlash(6, -1);
				A_SpawnSmoke();
			}
			M1FE B 1 A_SpawnCasing();
			M1FE CEFGHI 1;
			Goto AltReady;

		AltReady:
			TNT1 A 0 A_JumpIf(CheckInventory("ColtMag", 1), "Ready"); // In case players use inventory cheats
			M1FE I 1 A_WeaponReady(WRF_ALLOWRELOAD);
			Loop;
		
		Empty:
			M1FE I 1 {
				invoker.m_Empty = true;
				A_StartSound("weapons/empty", CHAN_AUTO, 0, 0.5);
			}
			M1FE GH 1;
			Goto Reload;
		
		Reload:
			TNT1 A 0 {
				if (CheckInventory(invoker.AmmoType1, CMAG)) return ResolveState("Ready");

				if (!CheckInventory(invoker.AmmoType2, 1))
				{
					return A_BranchOnEmpty("AltReady", "Ready");
				}

				return ResolveState(null);
			}
			TNT1 A 0 A_BranchOnEmpty("EmptyReload", "ChamberedReload");
			Stop;

		ChamberedReload:
			M19R ABCD 1;
			M19R EF 1;
			TNT1 A 0 A_StartSound("colt/magout", CHAN_AUTO);
			M19R GHIJ 1;
			M19R KLM 2;
			M19R NO 2;
			M19R PQR 2;
			M19R STU 1;
			TNT1 A 0 A_StartSound("colt/magins", CHAN_AUTO);
			M19R VW 3;
			M19R XYZ 2;
			M199 A 2;
			M199 BCD 1;
			M199 EFG 2;
			Goto Loading;
		
		EmptyReload:
			M1RE ABCD 1;
			M1RE EF 1;
			TNT1 A 0 A_StartSound("colt/magout", CHAN_AUTO);
			M1RE GHIJ 1;
			M1RE KLM 2;
			M1RE NOPQR 2;
			TNT1 A 0 A_StartSound("colt/magins", CHAN_AUTO);
			M1RE STU 1;
			M1RE VW 2;
			M1RE XYZ 2;
			M1RR ABCDEF 1;
			TNT1 A 0 A_StartSound("colt/sliderel", CHAN_AUTO);
			M1RR GH 3;
			M1RR IJKLMNOP 2;
		Loading:
			TNT1 A 0 {
				int ammoAmount = min(
					FindInventory(invoker.AmmoType1).maxAmount - CountInv(invoker.AmmoType1),
					CountInv(invoker.AmmoType2));

				if (ammoAmount <= 0) return ResolveState("Ready");

				GiveInventory(invoker.AmmoType1, ammoAmount);
				TakeInventory(invoker.AmmoType2, ammoAmount);

				return ResolveState("ReloadFinish");
			}
		ReloadEnd:
			TNT1 A 0 { invoker.m_Empty = false; }
			Goto Ready;
		
		Deselect:
			TNT1 A 0 A_BranchOnEmpty("EmptyDeselect", "ChamberedDeselect");
			Stop;

		ChamberedDeselect:
			M19I A 1 A_SetBaseOffset(3, 34);
			M19R A 1 A_SetBaseOffset(12, 38);
			M19R A 1 A_SetBaseOffset(28, 39);
			M19R A 1 A_SetBaseOffset(35, 55);
			M19R A 1 A_SetBaseOffset(65, 81);
			TNT1 A 0 A_SetBaseOffset(0, WEAPONBOTTOM);
			TNT1 A 4;
			TNT1 A 0 A_Lower(16);
			Loop;

		EmptyDeselect:
			M1FE I 1 A_SetBaseOffset(3, 34);
			M1FE I 1 A_SetBaseOffset(12, 38);
			M1FE I 1 A_SetBaseOffset(28, 39);
			M1FE I 1 A_SetBaseOffset(35, 55);
			M1FE I 1 A_SetBaseOffset(65, 81);
			TNT1 A 0 A_SetBaseOffset(0, WEAPONBOTTOM);
			TNT1 A 4;
			TNT1 A 0 A_Lower(16);
			Loop;
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

		A_SpawnEffect(
			"MuzzleSmoke",
			(10.5, 3.0, 20.0),
			FRandom(-6.0, 6.0),
			FRandom(-2.5, 2.5),
			4.0,
			true);
	}

	private action void A_SpawnCasing()
	{
		if (CVar.GetCVar("weapon_casings", invoker.owner.player).GetInt() <= Settings.OFF) return;
		
		A_SpawnEffect(
			"PistolCasing",
			(10.0, 3.25, 12.0),
			-90.0 + FRandom(0.0, 15.0),
			FRandom(20.0, 35.0),
			FRandom(4.0, 6.0),
			true);
	}

	private action State A_BranchOnEmpty(statelabel emptyState, statelabel nonEmptyState)
	{
		if (invoker.m_Empty) return invoker.FindState(emptyState, false);

		return invoker.FindState(nonEmptyState, false);
	}
}