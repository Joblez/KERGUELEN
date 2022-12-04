Class Hura : Actor replaces ExplosiveBarrel
{
	Default
	{
		Health 20;
		Radius 10;
		Height 34;
		Scale 0.75;
		DamageType "normal";
		DeathSound("dynamite/explode");
		Bloodcolor "1c412b";
		Obituary "Amerigo hit a hura plant.";
		Species "Plant";
		+SOLID;
		+SHOOTABLE;
		+STANDSTILL;
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
		EFEX AB 2 Bright ;
		TNT1 A 0 A_Startsound("Dynamite/explode",CHAN_AUTO);
		TNT1 A 0 A_XScream;	
		TNT1 AAAAAAAA 0 { A_SpawnProjectile("Huraseed",36,0,random(-180,180));}
		EFEX CD 3 Bright A_Explode(); 
		EFEX EFGHIJ 3 BRIGHT A_Noblocking; 
		EFEX J -1;
		Stop;
	}
}
