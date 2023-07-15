class Sheep : Actor 
{
	Default
	{
	//$Category Friendlies
	Monster;
	Health 50;
	Radius 20;
	Height 32;
	Speed 3;
	Mass 60;
	Scale 0.7;
	PainChance 255;
	SeeSound "sheep/sight";
	ActiveSound "sheep/sight";
	PainSound "sheep/sight";
	Deathsound "sheep/death";
	+FRIENDLY;
	+DONTFOLLOWPLAYERS;
	-COUNTKILL;
	}
	States
	{
	Spawn:
		SHEP A 10 A_Look();
		Goto See;

	See:
		TNT1 A 0 A_Jump(10, "Baa");
		SHEP BBBCCCDDDEEE 2 A_Wander;
		TNT1 A 0 A_Jump(10, "EatGrass");
		Loop;

	Pain:
		SHEP F 6 A_Pain;
		Goto Charge;

	Charge:	
		TNT1 A 0 {bFriendly = false;}
		TNT1 A 0 A_SetSpeed(6, AAPTR_DEFAULT);
		SHEP BBCCDDEE 1 A_Chase;
		SHEP BBCCDDEE 1 A_Chase;
		SHEP BBCCDDEE 1 A_Chase;
		SHEP BBCCDDEE 1 A_Chase;
		SHEP BBCCDDEE 1 A_Chase;
		SHEP BBCCDDEE 1 A_Chase;
		SHEP BBCCDDEE 1 A_Chase;
		SHEP BBCCDDEE 1 A_Chase;
		TNT1 A 0 {bFriendly = true;}
		TNT1 A 0 A_SetSpeed(3, AAPTR_DEFAULT);
		Goto See;

	Melee:
		SHEP IH 3;
		SHEP GF 2 A_CustomMeleeAttack(40, "imp/melee", "Melee", "true");
		SHEP A 2;
		Goto See;

	Death:
		TNT1 A 0 A_Scream;
		TNT1 A 0 A_NoBlocking;
		SHED ABCDEF 4;
		SHED F -1;
		Stop;

	Baa:
		TNT1 A 0 A_Startsound("sheep/sight");
		Goto See;

	EatGrass:
		SHEP G 6 A_Startsound("sheep/eat");
		SHEP HI 6;
		SHEP I 50;
		SHEP HG 6;
		Goto See;
	}
}