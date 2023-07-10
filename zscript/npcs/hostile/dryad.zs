class Dryad : Actor replaces Stealthdoomimp
{
	Default
	{
	Monster;
	Radius 28;
	Height 36;
	Scale 1;
	Mass 180;
	Painchance 220;
	Health 400;
	GibHealth -100;
	BloodColor "42 97 51";
	DeathSound "Dryad/death";
	PainSound "seed/hit";
	Species "Plant";
	+LOOKALLAROUND;
	+NOINFIGHTING;
	+STANDSTILL;
	+SEEFRIENDLYMONSTERS;
	+DONTTHRUST;
	}
	States
	{
	Spawn:
		DRYD A 1 A_LookEx(0,0,1024,1024);
		Loop;

	See:
		DRYD A 1 A_Chase;
		loop;

	Missile:
	TNT1 A 0 A_Jump(64,"Altmissile");
	DRYD B 4 A_Facetarget;
	TNT1 A 0 A_SpawnProjectile("Dryadseed",56);
	DRYD CD 4;
	DRYD B 4;
	goto see;

	AltMissile:
	DRYD B 4 A_Facetarget;
	TNT1 A 0 A_SpawnProjectile("Dryadvinespawner",56);
	DRYD CD 4;
	DRYD B 4;
	goto see;

	Pain:
	DRYD C 8 A_Pain;
	goto See;

	Death:
		TNT1 A 0 A_Startsound("Dryad/death",CHAN_AUTO);
		DRYD E 1 A_XScream;
		DRYD FGHIJK 4;
		DRYD K -1 A_Noblocking;
		Stop;
	}
}

class Dryadseed : Actor
{
	Default
	{
	Alpha 1;
	Radius 6;
	Height 6;
	Speed 25;
	Scale 0.5;
	Damage (5);
	Projectile;
	Seesound "seed/pop";
	DamageType "Normal";
	+DONTTHRUST;
	+BLOODSPLATTER;
	}
	States
	{
	Spawn:
		SEED ABCDEGH 1;
		Loop;

	XDeath:
		TNT1 A 0 A_Startsound("seed/hit");
		Stop;

	Death:
		SEDD ABC 6 A_Startsound("seed/hit");
		Stop;
	}
}

class Huraseed : Dryadseed
{
	Default
	{
	Scale 0.5;
	Speed 32;
	Gravity 1.4;
	Damage (6);
	Radius 2;
	Height 2;
	-NOGRAVITY;
	}
	States
	{
	Spawn:
		SDAL ABCDEGH 1;
		Loop;

	Death:
		TNT1 A 0 A_Startsound("seed/hit");
		SDAD ABC 6 Bright;
		Stop;
	}	
}

class Dryadvinespawner : Dryadseed
{
	Default
	{
	Speed 30;
	-Nogravity;
	Gravity 0.2;
	}
	States
	{
	Spawn:
		TNT1 A 0 A_Startsound("vine/idle");
		SDAL ABCDEGH 2;
		Loop;

	Death:
		TNT1 A 0 A_JumpIf (Pos.Z <= floorz, "SpawnVine");
		TNT1 A 0 A_Startsound("seed/hit");
		SDAD ABC 6;
		Stop;

	SpawnVine:
		TNT1 A 0 A_SpawnProjectile("DryadVine",0);
		TNT1 A 0 A_Startsound("seed/hit");
		SDAD ABC 6;
		stop;

	}
}

class DryadVine : Actor
{	
	Default
	{
	Monster;
	Health 60;
	Mass 40;
	Radius 24;
	MeleeRange 52;
	Height 36;
	Scale 1;
	BloodColor "42 97 51";
	+LOOKALLAROUND;
	+NOINFIGHTING;
	+STANDSTILL;
	+DONTTHRUST;
	}
	States
	{
	Spawn:
		TNT1 A 0 A_LOOK();
		See:
		VIDL ABCDEFGHIJKLM 4 A_CustomMeleeAttack(2);
		Loop;

	Death:
		VDTH A 4 A_XScream;
		VDTH BCDE 4;
		TNT1 A 0 A_NoBlocking;
		VDTH E -1;
		Stop;
	}
}