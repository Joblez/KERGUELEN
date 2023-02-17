Class Hura : Actor replaces ExplosiveBarrel
{
	Default
	{
		Health 20;
		Radius 16;
		Height 40;
		Scale 0.75;
		DamageType "normal";
		Bloodcolor "1c412b";
		Obituary "Amerigo hit a hura plant.";
		Species "Plant";
		+SOLID;
		+SHOOTABLE;
		+STANDSTILL;
		+DONTTHRUST;
		+ACTIVATEMCROSS;
		+NOICEDEATH;
	}

	States
	{
	Spawn:
		EFRT A 6;
		Loop;
	Death:	
	XDeath:
		TNT1 A 0 A_Startsound("Hura/die",CHAN_AUTO);
		EFEX AB 5 Bright ;
		EFEX CD 5 Bright ;
		TNT1 AAAAAAAA 0 { A_SpawnProjectile("Huraseed",36,0,random(-180,180));}	
		TNT1 A 0 A_Explode(10,256); 
		TNT1 A 0 A_Startsound("Dryad/Death",CHAN_AUTO);
		TNT1 A 0 A_XScream;			
		EFEX EFGHIJ 2 BRIGHT A_Noblocking; 
		EFEX J -1;
		Stop;
	}
}
