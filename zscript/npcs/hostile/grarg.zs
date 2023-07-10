class Grarg: Actor replaces Demon
{
	Default
	{
	Health 180;
	Radius 16;
	Height 56;
	Speed 12;
	PainChance 240;
	Mass 70;
	Scale 0.9;
	Monster;
	DamageFactor "Explosive", 1.5;
	Bloodcolor "e8 00 21";
	Dropitem "Ammo357",96;
	SeeSound "Grarg/Sight";
	DeathSound "Grarg/Death";
	ActiveSound "Grarg/Barks";
	PainSound "Grarg/Pain";
	Obituary "Amerigo was ripped to pieces by a Grarg.";
	+FLOORCLIP;
	+SEEFRIENDLYMONSTERS;
	}
	States
	{
	Spawn:
		TNT1 A 0 A_Jump(20, "Grumble");
		GRRG A 4 A_Look();
		Loop;

	See:
		GRRG AABBCCDD 2 A_Chase;
		Loop;

	Melee:
		TNT1 A 0 A_Startsound("Grarg/Bite");
		GRRG EF 6 A_FaceTarget;
		GRRG GH 6 A_CustomMeleeAttack(random(2, 4) * 3, "imp/melee", "Melee", "true");
		Goto See;

	Missile:
		TNT1 A 0 A_Startsound("Grarg/Bite");
		GRRG A 8 A_FaceTarget;
		TNT1 A 0 ThrustThingZ(0, 40, 0, 0);
		TNT1 A 0 ThrustThing(angle * 256 / 360, 15, 0, 0);
	Jumpup:
		GRRG I 6;
		GRRG J 2 A_CustomMeleeAttack(random(2, 4) * 3, "imp/melee", "Melee", "true");
	JumpDown:
		GRRG J 2 A_CheckFloor("Land");
		GRRG J 2;
		GRRG J 3 A_CustomMeleeAttack(random(2, 4) * 3, "imp/melee", "Melee", "true");
		Loop;

	Land:
		GRRG G 4;
		GRRG H 8 A_Stop;
		Goto See;

	Grumble:
		TNT1 A 0 A_Startsound("Grarg/Idle",CHAN_AUTO,0.25);
		Goto Spawn;

	Pain:
		GRRP A 8 A_Pain;
		Goto See;

	Death:
		TNT1 A 0 A_Scream;
		TNT1 A 0 A_Startsound("Grarg/Death");
		GRGD AB 4;
		GRGD CD 8;
		GRGD E 4;
		TNT1 A 0 A_NoBlocking;
		GRGD E -1;
		stop;
	}
}