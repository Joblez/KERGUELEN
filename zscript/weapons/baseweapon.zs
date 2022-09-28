
//How did you even get here?

class BaseWeapon : Doomweapon replaces DoomWeapon
{
	Default
	{
        Weapon.BobRangeX 0.3;
        Weapon.BobRangeY 0.3;
        Weapon.BobSpeed 1.5;
        Weapon.BobStyle "Alpha";		
		Tag "Weapon";
		+Weapon.Noautofire;		
		inventory.pickupsound "weapon/pickup";		
		Weapon.UpSound "Weapon/select";	
		}
//Recoil

	action void A_AutoRecoil() {
		if (GetCvar("recoil_toggle") == 1)
		{
			A_SetPitch(pitch - 0.3);	
			//A_Recoil(0.1);	
			A_Quake(2,1,0,4);		
			}
	 
		}

				
				


	action void A_ShotgunRecoil() {
		if (GetCvar("recoil_toggle") == 1)
		{				
			//A_Recoil(0.4);
			A_SetPitch(pitch - 2);
			A_Quake(6,4,0,10);
			}
		
		}
 
	action void A_RifleRecoil() {
 
		if (GetCvar("recoil_toggle") == 1)
		{
				
		//A_Recoil(0.1);
		A_SetPitch(pitch - 0.4);
		A_Quake(3,2,0,10);
		}
 
	}

	action void A_PistolRecoil() {
		if (GetCvar("recoil_toggle") == 1)
			{	
			A_WeaponReady(WRF_NOPRIMARY);
			
			//A_Recoil(0.1);
			A_SetPitch(pitch - 1);
			A_Quake(3,2,0,4);
			}
		}

//Casings

	action void A_CasingRifle (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("RifleSpawnerR",0,0,x,y); }
		}

	action void A_CasingShotgun (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("ShellSpawnerR",0,0,x,y); }
		}
	

	action void A_CasingPistol (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("PistolSpawnerR",0,0,x,y); }
		}		

	action void A_CasingGrenade (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("GrenadeSpawnerR",0,0,x,y); }
		}	

	action void A_CasingRocket (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("RocketSpawnerR",0,0,x,y); }
		}	
		
	action void A_CasingRevolver (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("RevolverSpawnerR",0,0,x,y); }
		}			

	action void A_CasingRifleL (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("RifleSpawnerL",0,0,x,y); }
		}

	action void A_CasingShotgunL (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("ShellSpawnerL",0,0,x,y); }
		}
	

	action void A_CasingPistolL (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("PistolSpawnerL",0,0,x,y); }
		}		

	action void A_CasingGrenadeL (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("GrenadeSpawnerL",0,0,x,y); }
		}	

	action void A_CasingRevolverL (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("RevolverSpawnerL",0,0,x,y); }
		}

//Smoke

	action void A_ShotgunSmoke (Double x, Double y) {
			if (GetCvar("smoke_toggle") == 1)
				{
					A_FireProjectile("SmokeSpawner",0,0,x,y);				
					A_FireProjectile("SmokeSpawner",0,0,x,y);				
					A_FireProjectile("SmokeSpawner",0,0,x,y);			
					A_FireProjectile("SmokeSpawner",0,0,x,y);			
				}
		}

	action void A_SingleSmoke(Double x, Double y) {

			if (GetCvar("smoke_toggle") == 1)
				{
			
					A_FireProjectile("SmokeSpawner",0,0,x,y);			
				}
		}
		
	States
	{
		Load:
		FLAF ABCD 0;
	}
	
}	

class Bullet_Puff : Actor replaces BulletPuff	
{
	Default
	{
	+NOBLOCKMAP;
	+NOGRAVITY;
	+RANDOMIZE;
	+FLOORCLIP;
	+NOEXTREMEDEATH;
	RenderStyle "Add";
	Decal "BulletChip";
	Radius 1;
	Height 1;
	Scale 0.7;
	Alpha 0.7;
	Speed 0;
	}
	
	
		
	States
	{
  Spawn:
	TNT1 A 0 A_SetScale(0.2);
    TNT1 A 1 A_SetTranslucent(0.25)	;
	TNT1 A 0 A_Startsound("weapons/ricochet",2);	
	FX57 A 1 BRIGHT;
	FX57 BC 1  BRIGHT A_SetTranslucent(.8,1);
	FX57 DE 1  BRIGHT A_SetTranslucent(.6,1);
    Stop;
	
	Crash:
		TNT1 A 0 A_Jump(128,"Crash2","Crash3");	
		TNT1 A 0 A_Startsound("weapons/ricochet",2);
		FX57 A 1 BRIGHT;
		FX57 BC 1  BRIGHT;
		FX57 D 1 BRIGHT;	
		FX57 E 1 Bright A_SetTranslucent(.5,1);
		Stop;
	Crash2: 
		TNT1 A 0 A_Startsound("weapons/ricochet",2);
		FX57 J 1 BRIGHT;
		FX57 KL 1  BRIGHT;
		FX57 M 1 BRIGHT;

		FX57 N 1 Bright A_SetTranslucent(.5,1);
		Stop;	
	Crash3:
		TNT1 A 0 A_Startsound("weapons/ricochet",2);
		FX57 F 1 BRIGHT;
		FX57 GH 1  BRIGHT;
		FX57 I 1 BRIGHT;

		Stop;	
	}
}

class Melee_Puff: Bullet_Puff
{

	Default
	{
	}
	States
	{
  Spawn:
	TNT1 A 0 A_SetScale(0.2);
    TNT1 A 1 A_SetTranslucent(0.25);
    Stop;
	
	Crash:
		TNT1 A 0 A_SetScale(0.5);
		FX57 A 1 BRIGHT	 A_startsound("hatchet/hitwall",12);
		FX57 BC 1  BRIGHT A_SetTranslucent(.8,1);
		FX57 DE 1  BRIGHT A_SetTranslucent(.6,1);
		FX57 FG 1  BRIGHT A_SetTranslucent(.4,1);
		FX57 HIJ 1 BRIGHT A_SetTranslucent(.2,1) ;
		Stop;
	Melee:	
	    FX57 A 0 BRIGHT A_startsound("hatchet/hit");
		TNT1 A 0 A_SetScale(0.5);
		Stop;	
	}

}


class Basecasing : Actor {
    Default
    {
        Height 4;
        Radius 2;
		Speed 8;
		Gravity 0.8;
        Bouncetype "Doom";
        BounceFactor 0.5;
        WallBounceFactor 0.5;
        +Missile
        +Dropoff
        +NoBlockMap
        +MoveWithSector
        +ThruActors
		+ForceXYBillboard
		+ACTIVATEIMPACT 
    }
}

class PistolCasing : Basecasing
{
	Default
	{
	Scale 0.14;
	Bouncesound "weapons/shell4";	
	}
	States {
	
	Spawn:
      CAS3 A 2;
	  CAS3 B 2;
	  CAS3 C 2;
 	  CAS3 D 2;
	  CAS3 E 2;
	  CAS3 F 2;
	  CAS3 G 2;
	  CAS3 H 2;
	  loop;
	  
	Death:
      CAS3 I 350;
      CAS3 I 3  A_SetTranslucent(0.8, 0);
      CAS3 I 3  A_SetTranslucent(0.6, 0);
      CAS3 I 3  A_SetTranslucent(0.4, 0);
      CAS3 I 3  A_SetTranslucent(0.2, 0);	
	  Stop;
	}
	
}

class RevolverCasing : Basecasing
{
	Default
	{
	Height 5;
	Scale 0.14;
	Bouncesound "weapons/shell4";
	}
	States
	{

   Spawn:
      CAS5 A 2;
	  CAS5 B 2;
	  CAS5 C 2;
	  CAS5 D 2;
	  CAS5 E 2;
	  CAS5 F 2;
	  CAS5 G 2;
	  CAS5 H 2;
	  CAS5 I 2;
		loop;
   Death:
      CAS5 I 350;
      CAS5 I 3  A_SetTranslucent(0.8, 0);
      CAS5 I 3  A_SetTranslucent(0.6, 0);
      CAS5 I 3  A_SetTranslucent(0.4, 0);
      CAS5 I 3  A_SetTranslucent(0.2, 0);
      Stop;	
	
	}
}

class RifleCasing : BaseCasing {

	Default
	{
	Height 8;
	Radius 6;
	Speed 8;
	Scale 0.14;	
	Bouncesound "weapons/shell2";	
	}
	States {
	
   Spawn:
      CAS4 A 2;
	  CAS4 B 2;
	  CAS4 C 2;
	  CAS4 D 2;
	  CAS4 E 2;
	  CAS4 F 2;
	  CAS4 G 2;
	  CAS4 H 2;
      Loop;
   Death:	   
      CAS4 I 350;
      CAS4 I 3  A_SetTranslucent(0.8, 0);
      CAS4 I 3  A_SetTranslucent(0.6, 0);
      CAS4 I 3  A_SetTranslucent(0.4, 0);
      CAS4 I 3  A_SetTranslucent(0.2, 0);
	  CAS4 I 3 A_SetTranslucent(0.0, 0);
	  stop;	
	
	}
}

class ShotgunCasing : BaseCasing
{
	Default
	{
	Height 6;
	Radius 4;
	Speed 4;
	Scale 0.18; 	
	Bouncesound "weapons/shell3";		
	}
	States {

   Spawn:
      CAS2 A 2;
	  CAS2 B 2;
	  CAS2 C 2;
	  CAS2 D 2;
	  CAS2 E 2;
	  CAS2 F 2;
	  CAS2 G 2;
	  CAS2 H 2;
      Loop;
   Death:
      CAS2 I 350 ;
      CAS2 I 3  A_SetTranslucent(0.8, 0);
      CAS2 I 3  A_SetTranslucent(0.6, 0);
      CAS2 I 3  A_SetTranslucent(0.4, 0);
      CAS2 I 3  A_SetTranslucent(0.2, 0);
	  CAS2 I 3	A_SetTranslucent(0.0, 0);
      Stop;	
	
	}
	
}

class GrenadeCasing : BaseCasing
{
	Default
	{
	Height 8;
	Radius 6;
	Speed 4;
	Scale 0.5 ; 	
	Bouncesound "weapons/shell3";	
	}
	
	States {
   Spawn:
      CAS6 A 2;
	  CAS6 B 2; 
	  CAS6 C 2;
      CAS6 D 2;
	  CAS6 E 2;
	  CAS6 F 2;
	  CAS6 G 2;
	  CAS6 H 2;
      Loop;
   Death:
      CAS6 I 350;
      CAS6 I 3  A_SetTranslucent(0.8, 0);
      CAS6 I 3  A_SetTranslucent(0.6, 0);
      CAS6 I 3  A_SetTranslucent(0.4, 0);
      CAS6 I 3  A_SetTranslucent(0.2, 0);
      Stop;	
	}
	
}

class RocketCasing : BaseCasing
{
	Default
	{
	Height 6;
	Radius 12;
	Speed 6;	
	Bouncesound "weapons/shell5";
	}
	States {
	
   Spawn:
      RCCA A 2;
      LOOP;
   Death:
      RCCA A 350;
      RCCA A 3  A_SetTranslucent(0.8, 0);
      RCCA A 3  A_SetTranslucent(0.6, 0);
      RCCA A 3  A_SetTranslucent(0.4, 0);
      RCCA A 3  A_SetTranslucent(0.2, 0);
      Stop;
	
	}
	
}

class Basespawner: Actor
{
	double x;
	double y;
	double angle;

	Default
	{
   Speed 35;
   PROJECTILE;
   +NOCLIP;
   +dontsplash;
   +notimefreeze;
   -ACTIVATEIMPACT;
   }
   States
	{
	
   }
}   

Class PistolSpawnerR : Basespawner
{
   Default
   {
   
	}
   
   States
   {
   Spawn:
	  TNT1 A 0;
      TNT1 A 1 A_SpawnProjectile("PistolCasing",0,random(-1,1),random(80,90),0);
      Stop;
   }
}

Class PistolSpawnerL : Basespawner
{
   Default
   {
   
	}
   
   States
   {
   Spawn:
	  TNT1 A 0;
      TNT1 A 1 A_SpawnProjectile("PistolCasing",0,random(-1,1),random(-80,-90),0);
      Stop;
   }
}

Class RevolverSpawnerR : Basespawner
{
   Default
   {
   
	}
   
   States
   {
   Spawn:
	  TNT1 A 0;
      TNT1 A 1 A_SpawnProjectile("RevolverCasing",0,random(-1,1),random(80,90),0);
      Stop;
   }
}

Class RevolverSpawnerL : Basespawner
{
   Default
   {
   
	}
   
   States
   {
   Spawn:
	  TNT1 A 0;
      TNT1 A 1 A_SpawnProjectile("RevolverCasing",0,random(-1,1),random(-80,-90),0);
      Stop;
   }
}

Class ShellSpawnerR : Basespawner
{
   Default
   {
   
	}
   
   States
   {
   Spawn:
	  TNT1 A 0;
      TNT1 A 1 A_SpawnProjectile("ShotgunCasing",0,random(-1,1),random(80,90),0);
      Stop;
   }
}

Class ShellSpawnerL : Basespawner
{
   Default
   {
   
	}
   
   States
   {
   Spawn:
	  TNT1 A 0;
      TNT1 A 1 A_SpawnProjectile("ShotgunCasing",0,random(-1,1),random(-80,-90),0);
      Stop;
   }
}


Class RifleSpawnerR : Basespawner
{

   Default
   {
	}
   
   States   
   {
   Spawn:
	  TNT1 A 0;
      TNT1 A 1 A_SpawnProjectile("RifleCasing",0,random(-1,1),random(80,90),0);
      Stop;
   }
}

Class RifleSpawnerL : Basespawner
{

   Default
   {
	}
   
   States   
   {
   Spawn:
	  TNT1 A 0;
      TNT1 A 1 A_SpawnProjectile("RifleCasing",0,random(-1,1),random(-80,-90),0);
      Stop;
   }
}

Class GrenadeSpawnerR : Basespawner
{
   Default
   {
   
	}
   
   States
   {
   Spawn:
	  TNT1 A 0;
      TNT1 A 1 A_SpawnProjectile("GrenadeCasing",0,random(-1,1),random(80,90),0);
      Stop;
   }
}

Class GrenadeSpawnerL : Basespawner
{
   Default
   {
   
	}
   
   States
   {
   Spawn:
	  TNT1 A 0;
      TNT1 A 1 A_SpawnProjectile("GrenadeCasing",0,random(-1,1),random(-80,-90),0);
      Stop;
   }
}

Class RocketSpawnerR : Basespawner
{
   Default
   {
   
	}
   
   States
   {
   Spawn:
	  TNT1 A 0;
      TNT1 A 1 A_SpawnProjectile("RocketCasing",0,random(-1,1),random(80,90),0);
      Stop;
   }
}

class Rocket_Trail : Actor
{
	Default
	{
  Height 1;
  Radius 1;
  Mass 0;
  +Missile;
  +NoBlockMap;
  +NoGravity;
  +DontSplash;
  +FORCEXYBILLBOARD;
  +CLIENTSIDEONLY;
  +THRUACTORS;
  +GHOST;
  +THRUGHOST;
  RenderStyle "Add";
  Scale 0.1;
  }
  States
  {
  Spawn:
    SPRK AAAAAAA 1 BRIGHT;
	SPRK AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 1 Bright A_FadeOut(0.02);
    Stop;
  }
}


class Rocket_Trail2 : Rocket_Trail
{
Default
	{
	Radius 1;
	Height 1;
	Alpha 1.0;
	RenderStyle "Add";
	Scale 0.1;
	Speed 4;
	Gravity 0.2;
	+BOUNCEONCEILINGS;
	+BOUNCEONWALLS;
	-SKYEXPLODE;
	-NOGRAVITY;
	}
}

