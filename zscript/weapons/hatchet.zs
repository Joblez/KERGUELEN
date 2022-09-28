class Kick_puff: Melee_Puff
{
	Default
	{
	}
	States
	{
	Melee:	
	    FIPP A 0 BRIGHT A_startsound("kick/hit",11);
		FIPP AB 2 BRIGHT;
		TNT1 A 0 A_SetScale(0.5);
		Stop;		
	}
}

class Hatchet : baseweapon
{
	Default
	{
	Weapon.Kickback 50;
	Weapon.SlotNumber 1;
	+WEAPON.MELEEWEAPON;
	+WEAPON.AMMO_OPTIONAL;
	+WEAPON.WIMPY_WEAPON;
	+WEAPON.NOALERT;
	+Weapon.Noautofire;
	Damagetype "Fist";
  }
	int m_fistcheck;
    States
	{
	
	Ready:
	HATI A 4 A_Weaponready();
	loop;

  Deselect:
		TNT1 A 0 Setplayerproperty(0,1,2);	
		HATI A 1 Offset(22, 58);
		HATI A 1 Offset(32, 69);		
		HATI A 1 Offset(54, 81);
		HATI A 1 Offset(67, 100);		
		CRWI A 0 A_Lower(16);
		goto ready;
  Select: 
		TNT1 A 0 Offset(1, 30);  
		TNT1 A 0 Setplayerproperty(0,1,2);	
		TNT1 A 1;
		HATI A 1 Offset(67, 100);
		HATI A 1 Offset(54, 81);
		HATI A 1 Offset(32, 69);
		HATI A 1 Offset(22, 58);
		CRWI A 0 A_Raise(16);
		goto ready;
	
	Fire:
		TNT1 A 0 A_Jumpif((invoker.m_fistcheck == 2),"punch1");
		TNT1 A 0 A_Jumpif((invoker.m_fistcheck == 3),"punch2");		//LPunch
	punch0:	
		//TNT1 A 0 A_Combocheck();		
		HAF1 A 1 A_Startsound("hatchet/swing");
		HAF1 B 1;
		HAF1 C 1 A_CustomPunch(10,0,0,"Melee_Puff",128);
		TNT1 A 0 {invoker.m_fistcheck = invoker.m_fistcheck + 1; }	
		HAF1 D 1 ;
		HAF1 E 1 ;
		HAF1 FGHIJKLM 2 A_Weaponready();
		goto ready;
	
	punch1:
	//TNT1 A 0 A_Combocheck();		
		HAF2 A 1 A_Startsound("hatchet/swing");
		HAF2 B 1;
		HAF2 C 1 ;
		TNT1 A 0 { invoker.m_fistcheck = invoker.m_fistcheck + 1; }	
		HAF2 D 1 ;
		HAF2 E 1 A_CustomPunch(10,0,0,"Melee_Puff",128); 
		HAF2 FGHIJKLMNOP 2 A_Weaponready();	
		goto ready;
	
	punch2:
		TNT1 A 0 { invoker.m_fistcheck = invoker.m_fistcheck - 3; }			
		HAF1 A 1 A_Startsound("hatchet/swing");
		HAF1 B 1;
		HAF1 C 1 A_CustomPunch(10,0,0,"Melee_Puff",128);
		TNT1 A 0 {invoker.m_fistcheck = invoker.m_fistcheck + 1; }	
		HAF1 D 1;
		HAF1 E 1 ;
		HAF1 FGHIJKLM 2 A_Weaponready(); 
		goto ready;
	
	Altfire:
	Kick:
		//TNT1 A 0 A_Combocheck();		
		KICK A 2 A_Startsound("kick/swing");
		KICK B 1;
		KICK C 2;
		KICK D 2 A_CustomPunch(30,0,0,"Kick_Puff",96);
		KICK E 2;
		KICK F 1 A_Weaponready();
		KICK G 2 A_Weaponready();
		TNT1 C 1 A_Weaponready();
		TNT1 B 1 A_Weaponready(); 
		TNT1 A 1 A_Weaponready();	
		TNT1 A 4 A_Weaponready();	
		goto ready;	
	}
}	
