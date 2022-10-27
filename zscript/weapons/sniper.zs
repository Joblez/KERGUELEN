const snipercap = 10;

class sniperammo: ammo
{
	Inventory.Amount snipercap;
	Inventory.MaxAmount snipercap;
	Ammo.BackpackAmount 0;
	Ammo.BackpackMaxAmount snipercap;
}

class Enfield : baseweapon {
	bool m_Shouldered;
	bool m_IsLoading;	

	Default
	{
		Weapon.Kickback 20;
		Weapon.SlotNumber 6;
		Weapon.AmmoUse 0;
		Weapon.AmmoGive1 0;
		Weapon.AmmoGive2 10;
		Weapon.AmmoType1 "Snipercap";
		Weapon.AmmoType2 "Ammo3006"; //still gotta rename this to .308
		Weapon.UpSound("sniper/raise");
		Inventory.PickupMessage "[6]";
		Tag "Enfield Sniper";
	}
	
	States
	{
	}
}