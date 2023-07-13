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
	Scale 1;
	PainChance 255;
	SeeSound "caribou/idle";
	ActiveSound "caribou/idle";
	PainSound "caribou/pain";
	Deathsound "caribou/death";
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
		REIN AAABBBCCCDDD 2 A_Wander;
		Loop;

	Pain:
		REIN E 6 A_Pain;
		Goto Charge;

	Charge:
		TNT1 A 0 {bFriendly = false;}
		TNT1 A 0 A_SetSpeed(15, AAPTR_DEFAULT);
		Goto Rage;

	Rage:
		REIN AABBCCDD 2 A_Chase;
		Loop;

	Melee:
		REIN AC 2 A_Startsound("caribou/idle",CHAN_AUTO);
		REIN CA 2 A_CustomMeleeAttack(40, "imp/melee", "Melee", "true");
		REIN AA 2;
		Goto Rage;

	Death:
		TNT1 A 0 A_Scream;
		TNT1 A 0 A_Startsound("caribou/sight");
		TNT1 A 0 A_NoBlocking;
		REDD ABCDEF 3;
		REDD F -1;
		Stop;
	}
}
