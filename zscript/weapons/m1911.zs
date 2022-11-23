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

class Handgun : baseweapon
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
	States
	{

	ZF:
		TNT1 A 1 A_VRecoil(0.96,1,4);
		TNT1 A 1 A_VRecoil(0.99,1,4);
		TNT1 A 1 A_VRecoil(1.0,1,4);
		Stop;
	
	Select:
		TNT1 A 1;
		M19I A 1 A_SetBaseOffset(-65, 81);
		M19I A 1 A_SetBaseOffset(-35, 55);
		M19I A 1 A_SetBaseOffset(-28, 39);
		M19I A 1 A_SetBaseOffset(-12, 38);
		M19I A 1 A_SetBaseOffset(3, 34);
		M19I A 1 A_SetBaseOffset(3, 34);
		M19I AAA 1;
		SWAF A 0 A_SetBaseOffset(0, WEAPONTOP);
		M19I A 1 A_Raise(16);
		Goto Ready;
	
	Ready:	
		M19I A 1 A_Weaponready(WRF_ALLOWRELOAD);
		loop;
	
	Fire:
		M19F A 1 BRIGHT;
		M19F B 1;
		M19F CDEFG 1;
		goto ready;
	
	Lastshot:
		M1FE A 1 BRIGHT;
		M19E B 1;
		M19E CEFGHI 1;
		goto altready;

	Altready:
		M1FE J 1 A_Weaponready(WRF_ALLOWRELOAD);
		loop;
	
	Empty:
		M1FE HIJ 1;
		goto ready;
	
	Reload:
	ChamberedReload:
		goto reloadrepeat;
	
	EmptyReload:
	
	ReloadRepeat:
	ReloadEnd:
		goto ready;
	
	Deselect:
		M19I A 1 A_SetBaseOffset(3, 34);
		M19I A 1 A_SetBaseOffset(-12, 38);
		M19I A 1 A_SetBaseOffset(-28, 39);
		M19I A 1 A_SetBaseOffset(-35, 55);
		M19I A 1 A_SetBaseOffset(-65, 81);
		TNT1 A 0 A_SetBaseOffset(0, WEAPONBOTTOM);
		TNT1 A 4;
		TNT1 A 0 A_Lower(16);
		Loop;
	}

}