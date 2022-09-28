const Stube = 8;

class Sh12tube: ammo { Default { inventory.maxamount Stube;}}

//Ithaca M37

Class Ithaca: Baseweapon replaces Shotgun
{
	Default
	{
	Inventory.Pickupmessage "(3)";
	Weapon.Ammouse 0;
	Weapon.Ammogive1 0;
	Weapon.Ammogive2 8;
	Weapon.Ammotype2 "Ammo12";
	Weapon.Ammotype1 "Sh12tube";
	Damagetype "Normal";
	Tag "Ithaca";		
	Weapon.slotnumber 3;	
	}
	
	bool m_chambered;
	
	States
	{

 	Spawn:
		PICK B -1;
		stop;
	
	Ready:
    TNT1 A 0 A_JumpIfInventory("Sh12tube",1,1);	
	ITAI A 1 A_Weaponready(WRF_ALLOWRELOAD);
	loop;
	
	Fire:
		TNT1 A 0 A_JumpIfInventory("Sh12tube",1,1);				
		Goto empty;	
		TNT1 A 0 {invoker.m_chambered = invoker.m_chambered - 1; }	
		TNT1 A 0 A_Firebullets(4.5,4,12,3,"Bulletpuff");	
		ITAF A 2 BRIGHT {
			A_Shotgunrecoil();
			A_Alertmonsters();
			A_ShotgunSmoke(4,-4);
			A_ShotgunSmoke(4,-4);			
			A_Takeinventory("Sh12tube",1);
			A_Startsound("shotgun/fire",1);	
			}	
		ITAF B 1 BRIGHT;
		ITAF CDE 1;
		ITAF FGHI 2;
	TNT1 A 0 
	{
		if (CountInv("Sh12tube") == 0) {
			return ResolveState("Ready");
		}	
		else {	
			return ResolveState("Pump");	
		}
	}				
	Pump:
		TNT1 A 0 A_Startsound("shotgun/pumpback",9);
		ITAP ABC 2;
		ITAP DE 2;
		TNT1 A 0 A_Startsound("shotgun/pumpfor",9);		
		TNT1 A 0 A_CasingShotgunL(10,-22);  
		ITAP FG 2;
		TNT1 A 0 {invoker.m_chambered = invoker.m_chambered + 1; }				
		ITAP HIJ 2 A_Weaponready();
		goto ready;

	Empty:
	TNT1 A 0 A_Startsound("weapons/empty",10);		
	ITAF FGH 2;
	goto ready;	

	Charge:
		TNT1 A 0 A_Startsound("shotgun/pumpback",9);
		ITAP ABC 2;	
		ITAP DE 2;
		TNT1 A 0 A_Startsound("shotgun/pumpfor",9);			
		ITAP FG 2;
		TNT1 A 0 {invoker.m_chambered = invoker.m_chambered + 1; }		
		ITAP HIJ 2 A_Weaponready();
		goto ready;
	
	Select:
		TNT1 A 0 Setplayerproperty(0,1,2);	
		TNT1 A 1;
		ITAI A 1 Offset(67, 100);
		ITAI A 1 Offset(54, 81);
		ITAI A 1 Offset(32, 69);
		ITAI A 1 Offset(22, 58);
		ITAI A 2 Offset(2, 34);
		ITAF FGH 2;
		ITAI A 1 A_Raise(16);
		goto ready;	
	
	Deselect:
		ITAI A 2 Offset(2, 34);
		ITAI A 1 Offset(22, 58);	
		ITAI A 1 Offset(32, 69);
		ITAI A 1 Offset(54, 81);		
		ITAI A 1 Offset(67, 100);
		TNT1 A 4;
		ITAI A 1 A_Lower(16);
		loop;

	Reload:
		TNT1 A 0 A_JumpIfInventory("Sh12tube", Stube, "Ready");	
		TNT1 A 0 A_JumpIfInventory("Ammo12", 1,1);
		goto ready;		
	Reloadstart:
		TNT1 A 0 A_Startsound("Weapon/cloth2",9);				
		ITRS ABCDE 1 A_Weaponready(WRF_NOFIRE);
		ITRS FGH 2 A_Weaponready(WRF_NOFIRE);
	ReloadRepeat:
		TNT1 A 0 A_JumpIfInventory("Sh12tube", Stube, "Reloadend");
		TNT1 A 0 A_JumpIfInventory("Ammo12", 1, "ProperReload");
		Goto ReloadEnd;
	ProperReload:
		TNT1 A 0 A_Weaponready(WRF_NOSWITCH);
		ITRL ABCDEF 1 A_Weaponready(WRF_NOSWITCH);
		TNT1 A 0 A_Startsound("shotgun/load",10);	
		ITRL G 1 A_Weaponready(WRF_NOSWITCH);
		ITRL HIJ 2 A_Weaponready(WRF_NOSWITCH);
		ITRL KL 2 A_Weaponready(WRF_NOSWITCH);
		ITRL M 2 A_Weaponready(WRF_NOSWITCH);
		TNT1 A 0 {

	            if (CheckInventory (invoker.ammoType1, 0) || !CheckInventory (invoker.ammoType2, 1))
                return ResolveState ("Reloadend");
            int ammoAmount = min (FindInventory (invoker.ammoType1).maxAmount - CountInv (invoker.ammoType1), CountInv (invoker.ammoType2));
            if (ammoAmount <= 0)
                return ResolveState ("Ready");

            GiveInventory (invoker.ammoType1, 1);
            TakeInventory (invoker.ammoType2, 1);

            return ResolveState ("ReloadRepeat");
			
			}			
	Reloadend:
		ITRE ABCDEF 2 A_Weaponready(WRF_NOSWITCH);			
 		ITRE GHIJ 1 A_Weaponready(WRF_NOSWITCH);
		TNT1 A 0 A_Jumpif((invoker.m_chambered == 1),"Ready");			
		goto charge;
	
	}

}