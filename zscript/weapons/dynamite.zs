class Dynamite : baseweapon {

	bool m_isthrowing;
	double m_throw;
	Default
	{
		Weapon.Kickback 0;
		Weapon.SlotNumber 5;
		Weapon.AmmoUse 1;
		Weapon.AmmoGive 1;
		Weapon.AmmoType "Ammo40mm"; //still gotta rename this ammo type
		Weapon.UpSound("dynamite/raise");
		Inventory.PickupMessage "[5]";
		Tag "Dynamite";
	}
	
	States
	{
	Spawn:
		PICK D -1;
		Stop;

	Ready:
	DYNI ABCD 3 A_Weaponready();
	loop;
	
	Fire:
	DYNH AB 1;
	DYNH CDE 1;
	TNT1 A 0 A_Startsound("dynamite/fuse",9);
	DYNH FGHJLMN 1;
	TNT1 A 0 A_Startsound("dynamite/close",10);
	DYNH OP 1;
	Hold:
	TNT1 A 0 {invoker.m_isthrowing = true;}
	DYNH S 1 { invoker.m_throw += 0.5; }
	TNT1 A 0 { Console.PrintF("invoker.m_throw = %f",invoker.m_throw); }
	TNT1 A 0 A_Refire();
	Release:
		TNT1 A 0 A_StartSound("hatchet/swing",10);
		DYNT ABC 1;
		TNT1 A 0 A_Fireprojectile("Dynamitestick",0,1,0,12,0,0);		
		DYNT DE 2;
		DYNT FGHIJK 1;
	Newstick:
		TNT1 A 0 {invoker.m_isthrowing = false;}	
		TNT1 A 0 { invoker.m_throw = !invoker.m_throw; }
		TNT1 A 0 A_Startsound("dynamite/open",10);			
		DYNS ABCD 2;
		TNT1 A 0 A_Startsound("dynamite/light",10);			
		DYNS EFGHI 2;
		goto ready;
		
	Select:

		DYNS AB 2 A_SetBaseOffset(1, 45);
		TNT1 A 0 A_Startsound("dynamite/open",10);	
		DYNS CDE 2 A_SetBaseOffset(1, 40);
		TNT1 A 0 A_Startsound("dynamite/light",10);	
		DYNS FGHI 2 A_SetBaseOffset(1, 30);
		SWAF A 0 { invoker.m_PSpritePosition.SetBaseY(WEAPONTOP); }
		SWAI A 0 A_Raise(16);			
		Goto Ready;
		
	Deselect:
		DYNS FEDCB 2;
		TNT1 A 0 A_Startsound("dynamite/close",10);		
		DYNS A 2;
		SWAF A 0 { invoker.m_PSpritePosition.SetBaseY(WEAPONBOTTOM); }
		SWAI A 0 A_Lower(16);
		Goto Ready;
		
	}
}



class Dynamitestick : Actor
{

	Default
	{
		Radius 8;
		Height 8;
		Speed 10;
		Damage 20;
		Projectile;
		-NOGRAVITY;
		+RANDOMIZE;
		+FORCEXYBILLBOARD
		+DEHEXPLOSION;
		BounceType "Doom";
		Gravity 0.7;
		Scale 0.5;
		DeathSound "";
		Obituary "$OB_GRENADE"; // "%o caught %k's grenade."
		DamageType "Explosive";
		}
	States
	{
		Spawn:
		
			TNT1 A 0 {
			
			let DYN = Dynamite(invoker.target);
			
			if (DYN)
			{
				invoker.vel = invoker.vel * DYN.m_throw;
			}
			
			}	
		
			TNT1 A 0 A_StartSound("dynamite/fuseloop",CHAN_AUTO,CHANF_LOOP,0.5);
			DYNP ABCDEFGH 2 Bright ;
			Loop;
		Death:
			TNT1 A 0 A_StopSound(7);			
			TNT1 A 0 A_Nogravity();
			TNT1 A 0 A_Startsound("dynamite/explode",CHAN_AUTO);
			TNT1 A 0 A_Setscale(1,1);
		TNT1 AAAAAAAAA 0 { 
           if (GetCvar("weapon_particle_toggle") == 1)
            {		
				A_SpawnProjectile ("Rocketdebris", 0, 0, random (0, 360), 2, random (0, 360));				
				A_SpawnProjectile ("Muzzlesmoke", 0, 0, random (0, 360), 2, random (0, 360));	
				A_SpawnProjectile ("Rocketdebris", 0, 0, random (0, 360), 2, random (0, 360));				
				A_SpawnProjectile ("Muzzlesmoke", 0, 0, random (0, 360), 2, random (0, 360));	
				
				}	
			}				
			BOOM A 2 Bright A_Explode;
			BOOM BCDEFGHIJKLMOPQRSTUVWXY 2 Bright;
			Stop;
		
		Grenade:
			DYPP ABC 10 A_Die;
			Wait;
		Detonate:
			Stop;
  }
}