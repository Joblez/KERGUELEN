const Cmag = 8;

Class ColtMag : Ammo
{
	Default
	{
		Inventory.Amount Cmag;
		Inventory.MaxAmount Cmag;
		Ammo.BackpackAmount 0;
		Ammo.BackpackMaxAmount Cmag;
	}
}

class Colt : baseweapon
{

	Default
	{
		Weapon.Kickback 10;
		Weapon.SlotNumber 2;
		Weapon.AmmoUse 0;
		Weapon.AmmoGive1 0;
		Weapon.AmmoGive2 Cmag;
		Weapon.AmmoType1 "ColtMag";
		Weapon.AmmoType2 "Ammo45";
		Weapon.UpSound("sw/raise");
		Inventory.PickupMessage "[2] .45 Handgun";
		Tag "Colt M1911A1";	
	}
	
	bool m_empty;
	
	States
	{

	ZF:
		TNT1 A 1 A_VRecoil(0.96,1,4);
		TNT1 A 1 A_VRecoil(0.99,1,4);
		TNT1 A 1 A_VRecoil(1.0,1,4);
		Stop;
	
	Select:
		TNT1 A 1;
		M19R V 1 A_SetBaseOffset(-65, 81);
		M19R W 1 A_SetBaseOffset(-35, 55);
		M19R X 1 A_SetBaseOffset(-28, 39);
		M19R Y 1 A_SetBaseOffset(-12, 38);
		M19R Z 1 A_SetBaseOffset(3, 34);
		M19I A 1 A_SetBaseOffset(3, 34);
		M19I AAA 1;
		SWAF A 0 A_SetBaseOffset(0, WEAPONTOP);
		M19I A 1 A_Raise(16);
		Goto Ready;
	
	Ready:	
		M19I A 1 A_Weaponready(WRF_ALLOWRELOAD);
		loop;
	
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
		Goto Finalshot;	
		
		M19F A 1 BRIGHT {
			A_AlertMonsters();
			A_TakeInventory("ColtMag", 1);
			A_StartSound("colt/fire", CHAN_WEAPON);
			A_GunFlash("ZF",GFF_NOEXTCHANGE);
			A_FireBullets(3,3, -1, 15, "BulletPuff");
			A_FRecoil(1);
			A_SingleSmoke(6, -1);
		}
		M19F B 1 A_CasingPistol(18,5);
		M19F CDE 1;
		M19F FG 2 A_Weaponready(WRF_NOBOB);
		goto ready;
	
	Finalshot:
		M1FE A 1 BRIGHT {
			invoker.m_Empty = true;
			A_AlertMonsters();
			A_TakeInventory("ColtMag", 1);
			A_StartSound("colt/fire", CHAN_WEAPON);
			A_GunFlash("ZF",GFF_NOEXTCHANGE);
			A_FireBullets(3,3, -1, 10, "BulletPuff");
			A_FRecoil(1);
			A_SingleSmoke(6, -1);
		}
		M1FE B 1 A_CasingPistol(18,5);
		M1FE CEFGHI 1;
		goto altready;

	Altready:
		M1FE J 1 A_Weaponready(WRF_ALLOWRELOAD);
		loop;
	
	Empty:
		TNT1 A 0 A_StartSound("weapons/empty", 10,0,0.5);	
		M1FE HIJ 1;
		goto altready;
	
	Reload:
		TNT1 A 0 A_JumpIf((invoker.m_Empty), "Emptyreload");

		TNT1 A 0 A_JumpIfInventory("Ammo45", 1, 1);
		Goto Ready;
		TNT1 A 0 A_JumpIfInventory("ColtMag", CMAG, "Ready");
		
	ChamberedReload:
		M19R ABCD 1;
		TNT1 A 0 A_Startsound("colt/magout",CHAN_AUTO);
		M19R EF 2;
		M19R GHI 1;
		M19R JKLMNO 2;
		TNT1 A 0 A_Startsound("colt/magins",CHAN_AUTO);	
		M19R PQR 1;
		M19R STUVWXYZ 2;
		M199 AB 1;	
		goto Loading;
	
	EmptyReload:
		M1RE ABCDE 1;
		TNT1 A 0 A_Startsound("colt/magout",CHAN_AUTO);		
		M1RE FG 2;
		M1RE HIJ 1;
		M1RE KLMNOP 2;
		TNT1 A 0 A_Startsound("colt/magins",CHAN_AUTO);		
		M1RE QRST 1;
		M1RE UVWXYZ 2;
		M1RR ABC 1;
		TNT1 A 0 A_Startsound("colt/sliderel",CHAN_AUTO);		
		M1RR DEFGHIJKL 2;
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
	ReloadEnd:
		TNT1 A 0 {invoker.m_Empty = false;}
		goto ready;
	
	Deselect:
		M19I A 1 A_SetBaseOffset(3, 34);
		M19R Z 1 A_SetBaseOffset(-12, 38);
		M19R Y 1 A_SetBaseOffset(-28, 39);
		M19R X 1 A_SetBaseOffset(-35, 55);
		M19R W 1 A_SetBaseOffset(-65, 81);
		TNT1 A 0 A_SetBaseOffset(0, WEAPONBOTTOM);
		TNT1 A 4;
		TNT1 A 0 A_Lower(16);
		Loop;
	}

}