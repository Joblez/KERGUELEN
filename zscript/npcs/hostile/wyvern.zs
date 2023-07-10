class Wyvern : Actor replaces Cacodemon
{
	Default
	{
	Health 350;
	Mass 80;
	Speed 14;
	Height 56;
	Radius 32;
	Painchance 220;
	Bloodcolor "e8 00 21";
	Monster;
	Obituary "Amerigo met a Wyvern.";
	Seesound "Wyvern/pain";
	Deathsound "Wyvern/death";
	painsound "Wyvern/pain";
	+FLOORCLIP;
	+FLOAT;
	+NOGRAVITY;
	}
	States
	{
	Spawn:
		WYVN ABC 5 A_Look;
		TNT1 A 0 A_Startsound("Wyvern/flap",CHAN_AUTO);
		WYVN DCB 5 A_Look;
		Loop;
	See:
		TNT1 A 0 A_JumpIf (health <= 100, "Rage");
		TNT1 A 0 A_Setspeed(14);
		WYVN ABC 3 A_Chase;
		TNT1 A 0 A_Startsound("Wyvern/flap",CHAN_AUTO);
		WYVN DCB 3 A_Chase;
		Loop;

	Rage:
		TNT1 A 0 A_Setspeed(20);
		WYVN ABC 2 A_Chase;
		TNT1 A 0 A_Startsound("Wyvern/flap",CHAN_AUTO);
		WYVN DCB 2 A_Chase;
		WYVN ABC 2 A_Chase;
		TNT1 A 0 A_Startsound("Wyvern/flap",CHAN_AUTO);
		WYVN DCB 2 A_Chase;
		WYVN ABC 2 A_Chase;
		TNT1 A 0 A_Startsound("Wyvern/flap",CHAN_AUTO);
		WYVN DCB 2 A_Chase;
		goto See;

	Missile:
		WYVN F 5 A_FaceTarget;
		WYVN E 5 A_FaceTarget;
		WYVN A 5 BRIGHT A_HeadAttack;
		Goto See;
	Pain:
		WYVN F 3;
		WYVN F 3 A_Pain;
		WYVN F 6;
		Goto See;
	Death:
		WYVD A 8 A_Startsound("Wyvern/scream",CHAN_AUTO);
		WYVD B 8 A_Scream;
		WYVD C 8;
		WYVD D 8;
		WYVD D 8;
		WYVD D 4 A_JumpIf (Pos.Z <= floorz, "Crash");
		Wait;
	Crash:
		TNT1 A 0 A_Startsound("Wyvern/fall",CHAN_AUTO);
		WYVD DE 5 A_NoBlocking;
		WYVD F -1;
		Stop;



	Raise:
		WYVD F 8 A_UnSetFloorClip;
		WYVD EDCBA 8;
		Goto See;
	}

}