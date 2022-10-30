class Kick_Puff: Melee_Puff
{
	States
	{
	Melee:
		FIPP A 0 Bright A_StartSound("kick/hit", 11);
		FIPP AB 2 Bright;
		TNT1 A 0 A_SetScale(0.5);
		Stop;
	}
}

class Hatchet : BaseWeapon
{
	int m_FistCheck;

	Default
	{
		Weapon.Kickback 50;
		Weapon.SlotNumber 1;
		BaseWeapon.LookSwayResponse 0.0;
		Weapon.UpSound("hatchet/draw");
		DamageType "Hatchet";
		+WEAPON.MELEEWEAPON;
		+WEAPON.AMMO_OPTIONAL;
	}

	States
	{
	Ready:
		HATI A 4 A_WeaponReady();
		Loop;

	Deselect:
		TNT1 A 0 SetPlayerProperty(0, 1, 2);
		HATI A 1 A_SetBaseOffset(22, 58);
		HATI A 1 A_SetBaseOffset(32, 69);
		HATI A 1 A_SetBaseOffset(54, 81);
		HATI A 1 A_SetBaseOffset(67, 100);
		HATI A 1 A_SetBaseOffset(0, WEAPONBOTTOM);
		TNT1 A 0 A_Lower(16);
		Goto Ready;

	Select:
		TNT1 A 0 SetPlayerProperty(0, 1, 2);
		TNT1 A 1 A_SetBaseOffset(60, 80);
		HAF1 G 1 A_SetBaseOffset(40, 60);
		HAF1 H 1 A_SetBaseOffset(20, 50);
		HAF1 I 1 A_SetBaseOffset(5, 40);
		HAF1 JKL 1 A_SetBaseOffset(1, 30);
		HAF1 M 1 A_SetBaseOffset(0, WEAPONTOP);
		TNT1 A 0 A_Raise(16);
		Goto Ready;

	Fire:
		TNT1 A 0 A_JumpIf((invoker.m_FistCheck == 2),"Punch1");
		TNT1 A 0 A_JumpIf((invoker.m_FistCheck == 3),"Punch2"); // LPunch.
		HAF1 A 1 A_StartSound("hatchet/swing");
		HAF1 B 1;
		HAF1 C 1 A_CustomPunch(10, 0, 0, "Melee_Puff", 96);
		TNT1 A 0 { invoker.m_FistCheck = invoker.m_FistCheck + 1; }
		HAF1 D 1;
		HAF1 EFGH 1;
		HAF1 HIJKLM 2 A_WeaponReady();
		Goto Ready;

	Punch1:

		HAF2 A 1 A_StartSound("hatchet/swing");
		HAF2 B 1;
		HAF2 C 1;
		TNT1 A 0 { invoker.m_FistCheck = invoker.m_FistCheck + 1; }
		HAF2 D 1;
		HAF2 E 1 A_CustomPunch(10, 0, 0, "Melee_Puff", 96);
		HAF2 FGH 1;
		HAF2 IJKLMNOP 2 A_WeaponReady();
		Goto Ready;

	Punch2:
		TNT1 A 0 { invoker.m_FistCheck = invoker.m_FistCheck - 3; }
		HAF1 A 1 A_StartSound("hatchet/swing");
		HAF1 B 1;
		HAF1 C 1 A_CustomPunch(10, 0, 0, "Melee_Puff", 96);
		TNT1 A 0 { invoker.m_FistCheck = invoker.m_FistCheck + 1; }
		HAF1 D 1;
		HAF1 EFGH 1;
		HAF1 IJKLM 2 A_WeaponReady();
		Goto Ready;
	}
}
