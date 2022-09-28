
	// { S&W Model 19} 

const BCyn = 6;

Class revocylinder : Ammo
{
	Default
	{
	Inventory.Amount BCyn;
	Inventory.MaxAmount BCyn;
	Ammo.BackpackAmount 0;
	Ammo.BackpackMaxAmount BCyn;
}
}

class Revolver : baseweapon 
{
	Default
	{
		Weapon.Kickback 20;
		Weapon.SlotNumber 2;
		Inventory.PickupMessage "[2].357 Revolver";
		Tag "Model 19";		
		Weapon.AmmoUse 0;
		Weapon.Ammogive1 0;
		Weapon.Ammogive2 6;
		Weapon.AmmoType2 "Ammo357";
		Weapon.AmmoType "revocylinder";
		Obituary "%o was smoked by %k.";
		Weapon.Slotnumber 2;		
		Weapon.Upsound("sw/raise");
		}

		
		bool m_action;
		States
		{
		
	Spawn:
		PICK A -1; 
		stop;

			
		Shoot:					
		TNT1 A 0 A_JumpIfInventory("revocylinder",1,1);
        Goto empty;		
		SWDA E 0 BRIGHT {
		A_AlertMonsters();	
		A_TakeInventory("revocylinder",1);
		A_Startsound("sw/fire",1);
		A_Firebullets(1,1,-1,30,"Bulletpuff");
		A_PistolRecoil();
		A_ShotgunSmoke(3,3);
		}
		TNT1 A 0 { invoker.m_action = invoker.m_action - 1; }			
		goto postshot;


	FIRE:
		TNT1 A 0 A_Jumpif((invoker.m_action == 1),"Shoot"); 
		
		Doubleaction:
		TNT1 A 0 A_Startsound("sw/cock",3); 		
		SWDA A 1 ;
		SWDA B 1 ;
		SWDA C 1 ;				
		TNT1 A 0 A_JumpIfInventory("revocylinder",1,1);
        Goto empty;		
		SWDA A 0 BRIGHT {
		A_AlertMonsters();	
		A_TakeInventory("revocylinder",1);
		A_Startsound("sw/fire",1);
		A_Firebullets(4,3,-1,30,"Bulletpuff");
		A_PistolRecoil();
		A_ShotgunSmoke(3,3);
		}

	postshot:
		SWAF A 1 BRIGHT;
		SWAF B 2 BRIGHT;
		SWAF C 2 ;
		SWAF D 2;
		SWAF E 1;
		SWAF F 1;
		SWAF G 1 ;
	postpostshot:
		SWAF I 1 ;
		TNT1 A 0 A_ReFire("postpostshot");
		Goto Ready;

	Altfire:	
		TNT1 A 0 A_Jumpif((invoker.m_action == 1),"Altready"); 
		SWSA ABCD 2;	
		TNT1 A 0 A_Startsound("sw/cock",10);
		SWSA EFGHIJKLMN 1;	
		TNT1 A 0 { invoker.m_action = invoker.m_action + 1; }		
		goto altready;
		
		
	Altready:
		SWSA N 4 A_Weaponready(WRF_ALLOWRELOAD );		
		loop;
	
	READY:
		SWAI A 4 A_Weaponready(WRF_ALLOWRELOAD );
		loop;
	
	empty:
		TNT1 A 0 { invoker.m_action == 0; }		
		SWAI A 0 A_Startsound("weapons/empty",1);		
		SWDA A 2;				
		goto ready;
	
	RELOAD:
		TNT1 A 0 A_JumpIfInventory("Ammo357", 1, 1);
		goto ready;		
		TNT1 A 0 A_JumpIfInventory("revocylinder", BCyn, "Ready");		
		SWEJ ABCD 1;
		SWEJ E 2;
		TNT1 A 0  A_Startsound("sw/open", CHAN_AUTO);		
		SWEJ FG 2;		
		SWEJ HI 1;
		SWEJ JK 1;
		TNT1 A 0 A_Startsound("sw/eject", CHAN_AUTO);	
		TNT1 A 0 A_Takeinventory("revocylinder",BCyn);		
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
		SWEJ Q 2 ;	
		SWEJ R 1;
		SWEJ ST 1;		
		SWEJ U 2 ;
		Loading:
		TNT1 A 0 {
	            if (CheckInventory (invoker.ammoType1, 0) || !CheckInventory (invoker.ammoType2, 1))
                return ResolveState ("Reloadfinish");		
					int ammoAmount = min (FindInventory (invoker.ammoType1).maxAmount - CountInv (invoker.ammoType1), CountInv (invoker.ammoType2));
					if (ammoAmount <= 0)
					return ResolveState ("Ready");

				GiveInventory (invoker.ammoType1, 1);
				TakeInventory (invoker.ammoType2, 1);

				return ResolveState ("Load");
			
				}		
				
		load:
		SWLD ABCD 1;		
		TNT1 A 0 A_Startsound("sw/load", CHAN_AUTO);
		SWLD EFG 2;
		SWLD HIJ 1;
		goto loading;
	Reloadfinish:	
	Close:
		SWCL ABCD 2;
		SWCL A 0 A_Startsound("sw/close", CHAN_AUTO);
		SWCL EFGHIJKLMN 2;
		goto ready;		
	
	select:
		TNT1 A 0 Setplayerproperty(0,1,2);	
		TNT1 A 1;
		SWAI A 1 Offset(67, 100);
		SWAI A 1 Offset(54, 81);
		SWAI A 1 Offset(32, 69);
		SWAI A 1 Offset(22, 58);
		SWAI A 1 Offset(2, 34);
		SWAF HI 1;
		SWAI A 1 A_Raise(16);
		goto ready;	
	deselect:
		SWAI A 1 Offset(2, 34);
		SWAI A 1 Offset(22, 58);	
		SWAI A 1 Offset(32, 69);
		SWAI A 1 Offset(54, 81);		
		SWAI A 1 Offset(67, 100);
		TNT1 A 4;
		SWAI A 1 A_Lower(16);
		loop;
		}
}	

