const Rmag = 30;

class riflemag: ammo { Default { inventory.maxamount Rmag;}}

//FN FNC

Class FNC : baseweapon replaces Chaingun
{

	Default
	{
	Inventory.Pickupmessage "(4)";
	Weapon.Ammouse 0;
	Weapon.Ammogive1 0;
	Weapon.Ammogive2 30;
	Weapon.Ammotype2 "Ammo223";
	Weapon.Ammotype1 "riflemag";
	Damagetype "Normal";
	Tag "FNC";		
	Weapon.slotnumber 4;	
	}
	
	bool m_fireselect;
	
	States
	{

 	Spawn:
		PICK C -1;
		Loop;
	
	Ready:
		FNCI A 1 A_Weaponready(WRF_ALLOWRELOAD);
		loop;

	Select:
		TNT1 A 0 Setplayerproperty(0,1,2);	
		TNT1 A 1;
		FNCI A 1 Offset(67, 100);
		FNCI A 1 Offset(54, 81);
		FNCI A 1 Offset(32, 69);
		FNCI A 1 Offset(22, 58);
		FNCI A 1 Offset(2, 34);
		FNCF CDE 1;
		FNCI A 1 A_Raise(16);
		goto ready;	
	
	Deselect:
		FNCI A 1 Offset(2, 34);
		FNCI A 1 Offset(22, 58);	
		FNCI A 1 Offset(32, 69);
		FNCI A 1 Offset(54, 81);		
		FNCI A 1 Offset(67, 100);
		TNT1 A 4;
		FNCI A 1 A_Lower(16);
		loop;

	Empty:
	TNT1 A 0 A_Stopsound(1);	
	TNT1 A 0 A_Startsound("weapons/empty",10);		
	FNCF DEF 2;
	goto ready;	

	Fire:
	
		TNT1 A 0 A_JumpIfInventory("Riflemag",1,1);				
		Goto empty;

		TNT1 A 0 A_Jumpif((invoker.m_fireselect == 1),"Automatic");
		Single:
		TNT1 A 0 A_Firebullets(3,1,-1,10,"Bulletpuff");
		FNFL A 1 BRIGHT {
		A_Riflerecoil();
		A_CasingRifle(16,-3);
		A_SingleSmoke(5,-3);
		A_Takeinventory("Riflemag",1);
		A_Startsound("fnc/fire",1);
		A_Alertmonsters();
			let psp = player.FindPSprite(PSP_Weapon); 
			if (psp)
			psp.frame = random(0,3); 	
		}
		FNCF A 1;
		FNCF B 1;
		FNCF C 1 A_Weaponready(WRF_NOSWITCH);
		FNCF DEF 2 A_Weaponready(WRF_NOSWITCH);
		goto ready;
	Automatic:	
		Hold:
		TNT1 A 0 A_JumpIfInventory("Riflemag",1,1);				
		Goto empty;		
		TNT1 A 0 A_Firebullets(5,2,-1,10,"Bulletpuff");
		FNFL A 1 BRIGHT {
		A_Riflerecoil();
		A_CasingRifle(16,-3);
		A_SingleSmoke(5,-3);
		A_Takeinventory("Riflemag",1);
		A_Alertmonsters();
		//A_Startsound("fnc/fire",1);		
		A_Startsound("fnc/loop",1,CHANF_LOOPING);
	
			let psp = player.FindPSprite(PSP_Weapon); 
			if (psp)
			psp.frame = random(0,3); 	
		}   
		FNCF A 1;
		FNCF B 1;
		TNT1 A 0 A_Refire;
		TNT1 A 0 A_Stopsound(1);		
		TNT1 A 0 A_Startsound("fnc/loopend",11);		
		
		FNCF CDEF 2 A_Weaponready(WRF_NOSWITCH);
		goto ready;
	
	Finalshot:	
		TNT1 A 0 A_Stopsound(1);
		TNT1 A 0 A_Startsound("weapons/empty",10);		
		TNT1 A 0 A_Startsound("fnc/loopend",11);
		FNCF DEF 2;		
		goto ready;
	Reload:
	TNT1 A 0 A_JumpIfInventory("Ammo223", 1, 1);
	goto ready;	
	
		TNT1 A 0 A_JumpIfInventory("Riflemag", Rmag, "Ready");	
	
		FNRS ABCDEFG 2;

		FNRS HI 1 ;
		FNRO AB 1 ;
		TNT1 A 0 A_Startsound("fnc/magout",9);		
		FNRO CD 1;
		TNT1 A 0 A_Startsound("Weapon/cloth2",10);		
		FNRO EFGHI 2;
		FNIN A 2 ;
		FNIN BC 1;
		FNIN D 2;
		TNT1 A 0 A_Startsound("fnc/magins",9);			
		FNIN EFG 2;
		FNIN HIJ 2;	
		FNBT ABC 1;
		TNT1 A 0 A_JumpIfInventory("riflemag",1,"Notempty");		
		FNBT DE 2;
		FNBT FG 2;	
		TNT1 A 0  A_Startsound("fnc/boltback",9);		
		FNBT H 1;
		FNBT IJKL 2;
		TNT1 A 0  A_Startsound("fnc/boltrel",9);			
		FNBT M 2;
		FNBT NO 2;
		FNBT P 1;
		FNCE ABCDEFGH 2;		
		Loading:
		TNT1 A 0 {

	            if (CheckInventory (invoker.ammoType1, 0) || !CheckInventory (invoker.ammoType2, 1))
                return ResolveState ("Ready");
            int ammoAmount = min (FindInventory (invoker.ammoType1).maxAmount - CountInv (invoker.ammoType1), CountInv (invoker.ammoType2));
            if (ammoAmount <= 0)
                return ResolveState ("Ready");

            GiveInventory (invoker.ammoType1, ammoAmount);
            TakeInventory (invoker.ammoType2, ammoAmount);

            return ResolveState ("ReloadFinish");
			
			}		
			
		Reloadfinish:	
		goto ready;
		
		Notempty:
		FNCE CDEFGH 2;	
		TNT1 A 0 {

	            if (CheckInventory (invoker.ammoType1, 0) || !CheckInventory (invoker.ammoType2, 1))
                return ResolveState ("Ready");
            int ammoAmount = min (FindInventory (invoker.ammoType1).maxAmount - CountInv (invoker.ammoType1), CountInv (invoker.ammoType2));
            if (ammoAmount <= 0)
                return ResolveState ("Ready");

            GiveInventory (invoker.ammoType1, ammoAmount);
            TakeInventory (invoker.ammoType2, ammoAmount);

            return ResolveState ("ReloadFinish");
			
			}	
		goto ready;	
	
	Altfire:	
		TNT1 A 0 A_Jumpif((invoker.m_fireselect == 1),"Semiauto");
		TNT1 A 0 A_Print("Full Auto");
		TNT1 A 0 {invoker.m_fireselect = invoker.m_fireselect + 1; }			
		FNCF DEF 2;	
		TNT1 A 0 A_Startsound("weapons/firemode",1);	
		goto ready;

	Semiauto:
		TNT1 A 0 A_Print("Semi Auto");
		TNT1 A 0 {invoker.m_fireselect = invoker.m_fireselect - 1; }		
		FNCF DEF 2;	
		TNT1 A 0 A_Startsound("weapons/firemode",1);	
		goto ready;
	
	}

}
