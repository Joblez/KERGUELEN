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