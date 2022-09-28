class Muzzlesmoke : actor

{
	Default
	{
	+NOGRAVITY
	+NOBLOCKMAP
	+FLOORCLIP
	+FORCEXYBILLBOARD
	+NOINTERACTION
	+DONTSPLASH
	+CLIENTSIDEONLY	
	Speed -1;
	RenderStyle "Add";
	Alpha 0.5;
	Radius 0;
	Height 0;
	Scale 0.5;
	}
	States
	{
	Spawn:
    TNT1 A 0 A_SetTranslucent(0.25);
	SMOK ABCDEFGHIJKLMNOPQ 2 A_FadeOut(0.005);
	stop;
	}	
}

class Muzzlesmoke2 : Muzzlesmoke
{
	Default
	{
	+NOGRAVITY
	+NOBLOCKMAP
	+FLOORCLIP
	+FORCEXYBILLBOARD
	+NOINTERACTION
	+DONTSPLASH
	Speed 1;
	+CLIENTSIDEONLY
	Alpha		0.3;
	Radius		0;
	Height		0;
	Scale		0.8;
	}
		
}

class Explosionsmoke : actor
{
	Default
	{
	+CLIENTSIDEONLY		
	RenderStyle "Add";
	Alpha 0.3;
	Radius 2;
	Height 2;
	Scale 0.8;
	Projectile;
	Speed 12;
	Gravity 0.65;
	-NOGRAVITY	
	}
	States
	{
	Spawn:
    TNT1 A 1 A_SetTranslucent(0.25);
	SMOK ABCDEFGHIJKLMNOPQ 2 BRIGHT A_SpawnItem("muzzlesmoke2");
	Death:
	stop;
	}
}

class ExplosiveSmokespawner : Actor
{
	Default
	{
	Speed 30;
	+NOCLIP
	}
	states
	{
	spawn:
	TNT1 A 0 A_SpawnProjectile("explosionsmoke",32,0,random(0, 360),2,random(0, 180));
	stop;
	}

}

class Smokespawner2 : actor
{
	Default
	{
	Speed 20;
	+NOCLIP
	}
	states
	{
	spawn:
	TNT1 A 1;	
	TNT1 A 0 A_SpawnProjectile("Muzzlesmoke2", 0, 0);
	stop;
	}
}


class Smokespawner : actor
{
	Default
	{
	Speed 20;
	+NOCLIP
	}
	states
	{
	spawn:
	TNT1 A 1;	
	TNT1 A 0 A_SpawnProjectile("Muzzlesmoke", 0, 0,random(-180,180),0,random(-180,180));
	stop;
	}
}

class WallSparks : actor
{
	Default
	{
		+THRUACTORS
		+GHOST
		-NOGRAVITY	
		+THRUGHOST 	
		+RANDOMIZE
		Damage 0;
		speed 75;
		alpha 0.4;
		scale 0.1;
	}
	States
	{
	Spawn:
		PRBM A 12 BRIGHT;
		Goto Death;
	Death:
		TNT1 A 0;
		Stop;
	XDeath:
		TNT1 A 0;
		Stop;
  }
}

class Rocketdebris : actor
{ 
	Default
	{
	+Missile
	+RANDOMIZE
	+FORCEXYBILLBOARD
	-NOGRAVITY
	+THRUACTORS
	+GHOST
	+THRUGHOST
	BounceType "Grenade";
	Damage 0;
	Gravity 0.3;
	bouncefactor 0.2;
	wallbouncefactor 0.2;
	RenderStyle "Add"; 
	speed 15;
	alpha 0.5;
	scale 0.6;
	}
  States
  {
  Spawn:
	PRBM A 4 BRIGHT A_SetTranslucent(0.8,1);
	TNT1 A 0 A_SpawnProjectile("RocketDebrisII", 0, 0, random (0, 360), 2, random (0, 360)); 
	TNT1 A 0 A_SpawnProjectile("RocketDebrisII", 0, 0, random (0, 360), 2, random (0, 360)); 
	PRBM A 4 BRIGHT A_SetTranslucent(0.7,1);
	TNT1 A 0 A_SpawnProjectile("RocketDebrisII", 0, 0, random (0, 360), 2, random (0, 180));
	TNT1 A 0 A_SpawnProjectile("RocketDebrisII", 0, 0, random (0, 360), 2, random (0, 180)); 	
	PRBM A 4 BRIGHT A_SetTranslucent(0.6,1);
	TNT1 A 0 A_SpawnProjectile("RocketDebrisII", 0, 0, random (0, 360), 2, random (0, 360)); 
	TNT1 A 0 A_SpawnProjectile("RocketDebrisII", 0, 0, random (0, 360), 2, random (0, 360)); 
	PRBM A 4 BRIGHT A_SetTranslucent(0.4,1);
	TNT1 A 0 A_SpawnProjectile("RocketDebrisII", 0, 0, random (0, 360), 2, random (0, 360)); 
	TNT1 A 0 A_SpawnProjectile("RocketDebrisII", 0, 0, random (0, 360), 2, random (0, 360)); 
	PRBM A 4 BRIGHT A_SetTranslucent(0.1,1);
	Goto Death;
  Death:
	TNT1 A 0;
	Stop;
  XDeath:
	TNT1 A 0;
	Stop;
  }
}

class RocketdebrisII : Rocketdebris
  {
	Default
		{
		Damage 0;
		Gravity 0.3;
		bouncefactor 0.2;
		wallbouncefactor 0.2;
		RenderStyle "Add";  
		speed 10;
		alpha 0.5;
		scale 0.3;
		}
	States
		{
		Spawn:
			PRBM A 4 BRIGHT A_SetTranslucent(0.8,1);
			PRBM A 4 BRIGHT A_SetTranslucent(0.7,1)	;
			PRBM A 4 BRIGHT A_SetTranslucent(0.6,1);
			PRBM A 4 BRIGHT A_SetTranslucent(0.4,1);
			PRBM A 4 BRIGHT A_SetTranslucent(0.1,1);
			Goto Death;
		Death:
			TNT1 A 0;
			Stop;
		XDeath:
			TNT1 A 0;
			Stop;
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