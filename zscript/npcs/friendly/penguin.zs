class Penguin : Actor
{
	Default
	{
	//$Category Friendlies
	Monster;
	Health 60;
	Radius 12;
	Height 48;
	Speed 3;
	Mass 100;
	Scale 0.8;
	PainChance 200;
	PainSound "penguin/pain";
	+FRIENDLY;
	+DONTFOLLOWPLAYERS;
	-COUNTKILL;
	}
	States
	{
	Spawn:
		PENG A 10 A_Look();
		Goto See;

	See:
		PENG BBBCCCDDDEEE 2 A_Wander;
		TNT1 A 0 A_Jump(10, "Noot");
		Loop;

	Melee:
		PENG F 6 A_FaceTarget;
		PENG G 12 A_CustomMeleeAttack(random(2, 5) * 3, "imp/melee", "Melee", "true");
		PENG F 6;
		Goto See;

	Pain:
		PENG F 6 A_Pain;
	RunAway:
		TNT1 A 0 {bFrightened = true;}
		TNT1 A 0 A_SetSpeed(6, AAPTR_DEFAULT);
		PENG BBCCDDEE 1 A_Chase;
		PENG BBCCDDEE 1 A_Chase;
		PENG BBCCDDEE 1 A_Chase;
		PENG BBCCDDEE 1 A_Chase;
		TNT1 A 0 A_SetSpeed(3, AAPTR_DEFAULT);
		TNT1 A 0 {bFrightened = false;}
		Goto See;

	Death:
		TNT1 A 0 A_Scream;
		TNT1 A 0 A_Startsound("penguin/death", 10);
		TNT1 A 0 { bNoBlockMonst = true; }
		TNT1 A 0 A_Noblocking;
		PEND ABCDE 4;
		PEND E -1;
		Stop;

	Noot:
		PENG A 10;
		PENG F 60 A_Startsound("penguin/noot",10,0,0.25);
		PENG A 10;
		Goto See;
	}
}