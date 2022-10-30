const SMAG = 10;

class sniperammo: ammo
{
	Default{
	Inventory.MaxAmount SMAG;
	Ammo.BackpackAmount 0;
	Ammo.BackpackMaxAmount SMAG;
	}
}

class Ishapore : baseweapon replaces Plasmarifle {
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
		Weapon.AmmoType2 "Ammo308";
		Weapon.UpSound("sniper/raise");
		Inventory.PickupMessage "[6].308 Hunting Rifle";
		Tag "Ishapore";
	}

	States
	{

	Spawn:
		PICK E -1;
		Stop;

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
		TNT1 A 0 A_SetBaseOffset(2, 32);
		ISHF FF 2;
		TNT1 A 0 A_SetBaseOffset(0, 30);
		goto ready;
	Fire:
		TNT1 A 0 A_JumpIf((invoker.m_shouldered), "Shoulderedfire");
		TNT1 A 0 A_JumpIfInventory("Sniperammo", 1, 1);
		Goto Empty;			
		TNT1 A 0 A_FireBullets(5, 1, -1, 80, "Bullet_Puff");
		ISHF A 1 Bright {
			A_FRecoil(2);
			A_SingleSmoke(5, -3);
			A_TakeInventory("Sniperammo", 1);
			A_StartSound("sniper/fire", 1);
			A_AlertMonsters();
			A_GunFlash("ZF",GFF_NOEXTCHANGE);
			A_SetBaseOffset(8, 36);
		}
		ISHF A 1 ;
		ISHF B 1 A_SetBaseOffset(4, 33);
		ISHF CDEF 2 A_SetBaseOffset(0, 30);
	Bolt:
		TNT1 A 0 A_SetBaseOffset(4, 34);	
		ISHB ABC 1;
		TNT1 A 0 A_startsound("sniper/boltback",9);
		TNT1 A 0 A_SetBaseOffset(3, 33);		
		ISHB DEFG 2;
		TNT1 A 0 A_SetBaseOffset(2, 32);		
		ISHB HIJ 1;
		TNT1 A 0 A_CasingRifle(18,-5);
		ISHB KL 2;	
		TNT1 A 0 A_startsound("sniper/boltfor",9);		
		ISHB MN 1;
		TNT1 A 0 A_SetBaseOffset(1, 31);			
		ISHB OPQR 2;
		ISHB STUV 2 A_Weaponready();
		TNT1 A 0 A_SetBaseOffset(0, 30);		
		goto ready;
	
	Reload:
		ISRS ABCDE 1;
		ISRS FGHI 1;
		TNT1 A 0 A_startsound("sniper/boltback",9);
		ISRS JKLMNOPQ 1;
		ISRS RSTUV 2;
	ReloadRepeat:
		TNT1 A 0 A_JumpIfInventory("Sniperammo", SMAG, "ReloadEnd");
		TNT1 A 0 A_JumpIfInventory("Ammo308", 1, "ProperReload");
		Goto ReloadEnd;

	ProperReload:	
		ISRL ABCDEF 1;
		TNT1 A 0 A_startsound("sniper/load",10);
		TNT1 A 0 A_SetBaseOffset(-1, 33);		
		ISRL GH 2;
		TNT1 A 0 A_SetBaseOffset(-1, 32);
		ISRL IJ 2;
		TNT1 A 0 A_SetBaseOffset(-1, 31);		
		ISRL KL 2;
		TNT1 A 0 A_SetBaseOffset(0, 30);	
		ISRL MN 2;
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
		ISRE ABC 1;
		TNT1 A 0 A_startsound("sniper/boltfor",9);
		TNT1 A 0 A_SetBaseOffset(-2, 32);		
		ISRE DEF 1;
		TNT1 A 0 A_SetBaseOffset(-1, 31);		
		ISRE GHIJKLMN 2;
		TNT1 A 0 A_SetBaseOffset(0, 30);			
		ISRE OP 2;
		ISRE QRS 2 A_Weaponready(); 
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
		TNT1 A 0 A_SetCrosshair(58);
		ISAS A 1 A_ZoomFactor(1.0, ZOOM_INSTANT);
		ISAS A 1 A_ZoomFactor(1.33, ZOOM_INSTANT);
		ISAS B 1 A_ZoomFactor(1.67, ZOOM_INSTANT);
		ISAS B 1 A_ZoomFactor(2.0, ZOOM_INSTANT);
		ISAS C 1 A_ZoomFactor(2.33, ZOOM_INSTANT);
		ISAS C 1 A_ZoomFactor(2.67, ZOOM_INSTANT);
		ISAS D 1 A_ZoomFactor(3.0, ZOOM_INSTANT);
		ISAS D 1 A_ZoomFactor(3.33, ZOOM_INSTANT);
		ISAS E 1 A_ZoomFactor(3.67, ZOOM_INSTANT);
		ISAS E 1 A_ZoomFactor(4.0, ZOOM_INSTANT);
		TNT1 A 0 { invoker.m_shouldered = true; }
		goto altready;
	
	Deshoulder:
		ISAS E 1 A_ZoomFactor(4.0, ZOOM_INSTANT);
		ISAS E 1 A_ZoomFactor(3.67, ZOOM_INSTANT);
		ISAS D 1 A_ZoomFactor(3.33, ZOOM_INSTANT);
		ISAS D 1 A_ZoomFactor(3.0, ZOOM_INSTANT);
		ISAS C 1 A_ZoomFactor(2.67, ZOOM_INSTANT);
		ISAS C 1 A_ZoomFactor(2.33, ZOOM_INSTANT);
		ISAS B 1 A_ZoomFactor(2.0, ZOOM_INSTANT);
		ISAS B 1 A_ZoomFactor(1.67, ZOOM_INSTANT);
		ISAS A 1 A_ZoomFactor(1.33, ZOOM_INSTANT);
		ISAS A 1 A_ZoomFactor(1.0, ZOOM_INSTANT);
		TNT1 A 0 A_SetCrosshair(0);
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
		TNT1 A 0 A_FireBullets(0, 0, -1, 80, "Bullet_Puff");
		ISAF A 2 BRIGHT {
			A_FRecoil(2.5);
			A_SingleSmoke(0,0);
			A_TakeInventory("Sniperammo", 1);
			A_StartSound("sniper/fire", 1);
			A_AlertMonsters();
			A_Gunflash("ZFScoped");
		}
		ISAF BCDEF 2;
	
	ShoulderedBolt:
		TNT1 A 0 A_ZoomFactor(1.0);
		ISRD ABC 2;
		ISRD DEFGHIJ 2;
		TNT1 A 0 A_startsound("sniper/boltback",9);
		ISRD KLMNOPQ 1;
		TNT1 A 0 A_CasingRifle(-18,-5);
		ISRD RSTUV 2;
		TNT1 A 0 A_startsound("sniper/boltfor",9);
		ISRD WXYZ 2;
		ISR2 ABCDE 2;
		TNT1 A 0 A_ZoomFactor(4.0);
		ISR2 FGHIJKL 2;
		goto altready;

	Select:
		TNT1 A 4 A_SetBaseOffset(-65, 81);
		ISR2 C 1 A_SetBaseOffset(-65, 81);
		ISR2 D 1 A_SetBaseOffset(-35, 55);
		ISR2 E 1 A_SetBaseOffset(-28, 39);
		ISR2 F 1 A_SetBaseOffset(-12, 37);
		ISR2 G 1 A_SetBaseOffset(1, 34);
		ISHB TUV 1 A_SetBaseOffset(0, 30);
		TNT1 A 0 A_SetBaseOffset(0, WEAPONTOP);
		TNT1 A 0 A_Raise(16);
		Goto Ready;
	Deselect:
		ISHI A 1 A_SetBaseOffset(1, 34);
		ISR2 G 1 A_SetBaseOffset(-12, 38);
		ISR2 F 1 A_SetBaseOffset(-28, 39);
		ISR2 E 1 A_SetBaseOffset(-35, 55);
		ISR2 D 1 A_SetBaseOffset(-65, 81);
		ISR2 C 1 A_SetBaseOffset(-65, 81);
		TNT1 A 0 A_SetBaseOffset(0, WEAPONBOTTOM);
		TNT1 A 4;
		ITAI A 0 A_Lower(16);
		Wait;

	}
}