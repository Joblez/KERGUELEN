class Caribou : Actor
{
	Default
	{
	//$Category Friendlies
	Monster;
	Health 200;
	Radius 32;
	Height 48;
	Speed 6;
	Mass 100;
	Scale 0.8;
	PainChance 255;
	SeeSound "caribou/sight";
	ActiveSound "caribou/sight";
	PainSound "caribou/sight";
	+FRIENDLY;
	+DONTFOLLOWPLAYERS;
	-COUNTKILL;
	}
	States
	{
	Spawn:
		REIN A 10 A_Look();
		Goto See;

	See:
		REIN BBBCCCDDDEEE 2 A_Wander;
		Loop;

	Pain:
		REIN F 6 A_Pain;
		Goto Charge;

	Charge:
		TNT1 A 0 {bFriendly = false;}
		TNT1 A 0 A_SetSpeed(6, AAPTR_DEFAULT);
		REIN BBCCDDEE 1 A_Chase;
		REIN BBCCDDEE 1 A_Chase;
		REIN BBCCDDEE 1 A_Chase;
		REIN BBCCDDEE 1 A_Chase;
		REIN BBCCDDEE 1 A_Chase;
		REIN BBCCDDEE 1 A_Chase;
		REIN BBCCDDEE 1 A_Chase;
		REIN BBCCDDEE 1 A_Chase;
		TNT1 A 0 {bFriendly = true;}
		TNT1 A 0 A_SetSpeed(3, AAPTR_DEFAULT);
		Goto See;

	Melee:
		REIN IH 3;
		REIN GF 2 A_CustomMeleeAttack(40, "imp/melee", "Melee", "true");
		REIN A 2;
		Goto See;

	Death:
		TNT1 A 0 A_Scream;
		TNT1 A 0 A_Startsound("caribou/sight");
		TNT1 A 0 A_NoBlocking;
		REID ABCDEF 4;
		REID F -1;
		Stop;
	}
}
