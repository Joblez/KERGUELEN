const SMAG = 10;

class sniperammo: ammo
{
	Default{
	Inventory.MaxAmount SMAG;
	Ammo.BackpackAmount 0;
	Ammo.BackpackMaxAmount SMAG;
	}
}

class Enfield : baseweapon {
	bool m_shouldered;
	bool m_isloading;	
	Default
	{
		Weapon.Kickback 20;
		Weapon.SlotNumber 6;
		Weapon.AmmoUse 0;
		Weapon.AmmoGive1 0;
		Weapon.AmmoGive2 10;
		Weapon.AmmoType1 "Sniperammo";
		Weapon.AmmoType2 "Ammo3006"; //still gotta rename this to .308
		Weapon.UpSound("sniper/raise");
		Inventory.PickupMessage "[6]";
		Tag "Enfield Sniper";
	}

	States
	{

	ZF:
		TNT1 A 1 A_VRecoil(0.9,1,4);
		TNT1 A 1 A_VRecoil(0.95,1,4);
		TNT1 A 1 A_VRecoil(1.0,1,4);
		stop;
	ZFScoped:
		TNT1 A 1 A_VRecoil(2.9,1,4);
		TNT1 A 1 A_VRecoil(2.95,1,4);
		TNT1 A 1 A_VRecoil(3.0,1,4);
		stop;		
	
	Ready:
		ISHI A 1 A_Weaponready(WRF_ALLOWRELOAD);		
		loop;	
		
		Empty:
		TNT1 A 0 A_StartSound("weapons/empty", 10,0,0.5);		
		ISHF EF 2;
		goto ready;
	Fire:
		TNT1 A 0 A_JumpIf((invoker.m_shouldered), "Shoulderedfire");
		TNT1 A 0 A_JumpIfInventory("Sniperammo", 1, 1);
		Goto Empty;			
		TNT1 A 0 A_FireBullets(5, 1, -1, 60, "Bullet_Puff");
		ISHF A 1 Bright {
			A_FRecoil(0.8);
			A_SingleSmoke(5, -3);
			A_TakeInventory("Sniperammo", 1);
			A_StartSound("fnc/fire", 1);
			A_AlertMonsters();
			A_GunFlash("ZF",GFF_NOEXTCHANGE);
		}
		ISHF BCDEF 2;
	Bolt:
		ISHB ABC 2;
		TNT1 A 0 A_startsound("sniper/boltback");
		ISHB DEFG 2;
		ISHB HIJ 1;
		TNT1 A 0 A_CasingRifle(18,-5);
		ISHB KL 2;
		TNT1 A 0 A_startsound("sniper/boltfor");		
		ISHB MN 1;
		ISHB OPQRSTUV 2;
		goto ready;
	
	Reload:
		ISRS ABCDE 2;
		ISRS FGHI 2;
		TNT1 A 0 A_startsound("sniper/boltback");
		ISRS JKLMNOPQRSTUV 2;
	ReloadRepeat:
		TNT1 A 0 A_JumpIfInventory("Sniperammo", SMAG, "ReloadEnd");
		TNT1 A 0 A_JumpIfInventory("Ammo3006", 1, "ProperReload");
		Goto ReloadEnd;

	ProperReload:
		ISRL ABCDEF 2;
		TNT1 A 0 A_startsound("sniper/load");
		ISRL GHIJKLMN 2;
		TNT1 A 0 {
			if (CheckInventory(invoker.AmmoType1, 0) || !CheckInventory(invoker.AmmoType2, 1))
			{
				return ResolveState("ReloadEnd");
			}

			int ammoAmount = min(
				FindInventory(invoker.AmmoType1).maxAmount - CountInv(invoker.AmmoType1),
				CountInv(invoker.AmmoType2));

			if (ammoAmount <= 0) return ResolveState("Ready");

			GiveInventory(invoker.AmmoType1, 1);
			TakeInventory(invoker.AmmoType2, 1);

			return ResolveState("ReloadRepeat");
		}	
	ReloadEnd:

		ISRE ABC 2;
		TNT1 A 0 A_startsound("sniper/boltfor");		
		ISRE DEFGHIJKLMNOPQRS 2;
		goto ready;
	
	Altfire:
	TNT1 A 0 {

		if (invoker.m_shouldered)
		{
			return ResolveState("Deshoulder");
		}
		else{

			return ResolveState("Shoulder");
		}

	}
	wait;

	Shoulder:
		TNT1 A 0 A_ZoomFactor(3.0);
		TNT1 A 0 A_SetCrosshair(3);
		ISAS ABCDE 2;
		TNT1 A 0 {invoker.m_shouldered = true;}
		goto altready;
	
	Deshoulder:
		TNT1 A 0 A_ZoomFactor(1.0);
		TNT1 A 0 A_SetCrosshair(0);		
		ISAS EDCBA 2;
		TNT1 A 0 {invoker.m_shouldered = false;}
		goto ready;	
	
	Altready:
		ISAI A 1 A_Weaponready();	
		loop;	

		EmptyScoped:
		TNT1 A 0 A_StartSound("weapons/empty", 10,0,0.5);		
		ISAF EF 2;
		goto altready;

	Shoulderedfire:
		TNT1 A 0 A_JumpIfInventory("Sniperammo", 1, 1);
		Goto EmptyScoped;		
		TNT1 A 0 A_FireBullets(1, 1, -1, 60, "Bullet_Puff");	
		ISAF A 2 BRIGHT {
			A_FRecoil(2.5); 
			A_SingleSmoke(0,0);
			A_TakeInventory("Sniperammo", 1);
			A_StartSound("fnc/fire", 1);
			A_AlertMonsters();
			A_Gunflash("ZFScoped");
		}
		ISAF BCDEF 2;
	
	ShoulderedBolt:
		TNT1 A 0 A_ZoomFactor(1.0);	
		ISRD ABCDEFGHIJ 2;
		TNT1 A 0 A_startsound("sniper/boltback");
		ISRD KLMNOPQ 1;
		TNT1 A 0 A_CasingRifle(-18,-5);		
		ISRD RSTUV 2;
		TNT1 A 0 A_startsound("sniper/boltfor");	
		ISRD WXYZ 2;
		ISR2 ABCDE 2;
		TNT1 A 0 A_ZoomFactor(3.0);		
		ISR2 FGHIJKL 2;
		goto altready;

	Select:
		SWAF A 0 { invoker.m_PSpritePosition.SetBaseY(WEAPONTOP); }
		SWAI A 0 A_Raise(16);
		Goto Ready;	
	Deselect:
		ITAI A 0 { invoker.m_PSpritePosition.SetBaseY(WEAPONBOTTOM); }
		TNT1 A 4;
		ITAI A 1 A_Lower(16);
		wait;	

	}
}