class Lesco : Actor replaces ZombieMan
{
	Default
	{
	Health 30;
	Radius 16;
	Height 48;
	Speed 10;
	PainChance 255;
	Mass 50;
	Scale 0.7;
	Monster;
	Dropitem "Ammo45",96;
	Bloodcolor "e8 00 21";
	SeeSound "GLG/Attack";
	DeathSound "GLG/Death";
	ActiveSound "GLG/Idle";
	PainSound "GLG/Pain";
	Obituary "Amerigo was slashed to ribbons by a Lesco.";
	+FLOORCLIP;
	+SEEFRIENDLYMONSTERS;
	+JUMPDOWN;
	}
	States
	{
	Spawn:
		TNT1 A 0 A_Jump(2, "Grumble");
		GGLG A 4 A_Look();
		Loop;

	JumpDown:
		GGLG C 1 A_CheckFloor("Land");
		GGLG C 1;
		GGLG C 1 A_CustomMeleeAttack(random(3, 5) * 5, "imp/melee", "Melee", "true");
		Loop;

	Land:
		GGLG FA 2 A_Stop;
		Goto See;

	See:
		GGLG AABBCCDD 2 A_Chase;
		Loop;

	Missile:
		GGLG EF 6 A_FaceTarget;
		TNT1 A 0 A_SpawnProjectile("RockProjectile", 56);
		TNT1 A 0 A_Startsound("GLG/Attack");
		GGLG G 6;
		Goto See;

	Melee:
		TNT1 A 0 A_Startsound("GLG/Attack");
		GGLG EF 6 A_FaceTarget;
		GGLG G 6 A_CustomMeleeAttack(random(2, 5) * 3, "imp/melee", "Melee", "true");
		Goto See;

	Grumble:
		TNT1 A 0 A_Startsound("GLG/Idle",CHAN_AUTO,CHANF_DEFAULT,0.25);
		GGLG A 16 A_Look();
		Goto Spawn;

	Pain:
		GGLG H 6 A_Pain;
		Goto See;
	XDeath:
	Death:
		TNT1 A 0 A_Scream;
		TNT1 A 0 A_Startsound("GLG/Death");
		GGLD A 7;
		GGLD BCD 4;
		TNT1 A 0 A_NoBlocking;
		GGLD E -1;
		Stop;

	}
}

class RockProjectile : Actor
{
	Default
	{
	Alpha 1;
	Radius 8;
	Height 8;
	MissileHeight 8;
	Speed 30;
	Gravity 0.3;
	Scale 0.7;
	Damage (10);
	Projectile;
	Seesound "rock/bounce";
	DamageType "Normal";
	+BLOODSPLATTER;
	+DOOMBOUNCE;
	-NOGRAVITY;
	}
	States
	{
	Spawn:
		PROC ABCDEGHABCDEGH 3 A_AttachLightDef('Lighter','Lighter');
		TNT1 A 0 A_SetGravity(0.5);
		Loop;

	XDeath:
		TNT1 A 0 A_Startsound("rock/ow");
		Stop;

	Death:
		PROC A 12 A_RemoveLight('Lighter');
		Stop;
	}
}
