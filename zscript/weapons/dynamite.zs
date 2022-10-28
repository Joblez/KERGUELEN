class Dynamite : BaseWeapon
{
	bool m_IsThrowing;
	double m_Throw;

	property BaseThrowFactor: m_Throw;

	Default
	{
		Weapon.Kickback 100;
		Weapon.SlotNumber 5;
		Weapon.AmmoUse 1;
		Weapon.AmmoGive 1;
		Weapon.AmmoType "Ammo40mm"; //still gotta rename this ammo type
		Weapon.UpSound("dynamite/equip");
		Inventory.PickupMessage "[5]";
		Dynamite.BaseThrowFactor 0.5;
		Tag "Dynamite";
	}

	States
	{
	Spawn:
		PICK D -1;
		Stop;

	Ready:
		DYNI ABCD 3 BRIGHT A_WeaponReady();
		Loop;

	Fire:
		DYNH AB 1 BRIGHT;
		DYNH CDE 1 BRIGHT;
		TNT1 A 0 A_StartSound("dynamite/fuse", 9);
		DYNH FHJLMN 1 BRIGHT;
		TNT1 A 0 A_StartSound("dynamite/close", 10);
		DYNH OP 1 BRIGHT;
	Hold:
		TNT1 A 0 { invoker.m_IsThrowing = true;}
		DYNH S 1 BRIGHT{ invoker.m_Throw = min(invoker.m_Throw + 1.0 / TICRATE, 2.5); }
		TNT1 A 0 { Console.Printf("invoker.m_Throw = %f",invoker.m_Throw); }
		TNT1 A 0 A_Refire();
	Release:
		TNT1 A 0 A_StartSound("hatchet/swing",10);
		DYNT ABC 1;
		TNT1 A 0 {
			Actor stick = A_FireProjectile("DynamiteStick", 0, 1, 0, 12 ,0, 0);
			stick.Vel *= invoker.m_Throw;
		}
		DYNT DE 2;
		DYNT FGHIJK 1;
		TNT1 A 0 A_JumpIfInventory("Ammo40mm", 1, 1);
		Goto Deselect;
	Newstick:
		TNT1 A 0 { invoker.m_IsThrowing = false; }
		TNT1 A 0 { invoker.m_Throw = invoker.default.m_Throw; }
		TNT1 A 0 A_StartSound("dynamite/open", 10);
		DYNS ABCD 2;
		TNT1 A 0 A_StartSound("dynamite/light", 10);
		DYNS EFGHI 2;
		Goto Ready;

	Select:

		DYNS A 2 A_SetBaseOffset(1, 85);
		DYNS B 2 A_SetBaseOffset(1, 60);
		TNT1 A 0 A_StartSound("dynamite/open", 10);
		DYNS CDE 2 A_SetBaseOffset(1, 50);
		TNT1 A 0 A_StartSound("dynamite/light", 10);
		DYNS FGHI 2 A_SetBaseOffset(1, 30);
		SWAF A 0 { invoker.m_PSpritePosition.SetBaseY(WEAPONTOP); }
		SWAI A 0 A_Raise(16);
		Goto Ready;

	Deselect:
		DYNS FEDCB 2;
		TNT1 A 0 A_StartSound("dynamite/close", 10);
		DYNS A 2;
		SWAF A 0 { invoker.m_PSpritePosition.SetBaseY(WEAPONBOTTOM); }
		SWAI A 0 A_Lower(16);
		Goto Ready;
	}
}

class DynamiteStick : Actor
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 20;
		Damage 0;
		Gravity 0.7;
		Scale 0.5;
		BounceType "Doom";
		DeathSound "";
		Obituary "$OB_GRENADE"; // "%o caught %k's grenade."
		DamageType "Explosive";
		Projectile;
		-NOGRAVITY;
		+NODAMAGETHRUST;
		+RANDOMIZE;
		+FORCEXYBILLBOARD;
		+DEHEXPLOSION;
	}
	States
	{
	Spawn:
		TNT1 A 0 A_StartSound("dynamite/fuseloop", CHAN_AUTO, CHANF_LOOP, 0.5);
		DYNP ABCDEFGH 2 Bright;
		Loop;
	Death:
		TNT1 A 0 { A_StopSound(7); A_NoGravity(); A_SetScale(1,1); A_StartSound("dynamite/explode",CHAN_AUTO);}
		TNT1 AAAAAAAAA 0 {
			if (GetCvar("weapon_particle_toggle") == 1)
			{
				A_SpawnProjectile ("RocketDebris", 0, 0, random (0, 360), 2, random (0, 360));
				A_SpawnProjectile ("MuzzleSmoke", 0, 0, random (0, 360), 2, random (0, 360));
				A_SpawnProjectile ("RocketDebris", 0, 0, random (0, 360), 2, random (0, 360));
				A_SpawnProjectile ("MuzzleSmoke", 0, 0, random (0, 360), 2, random (0, 360));
			}
		}
		TNT1 A 0 A_SetTranslucent(0.2);
		TNT1 A 0 { ActorUtil.RadiusThrust3D(Pos, 630.0, 384.0); }
		BOOM A 2 Bright {
			A_Explode(100 * FRandom(1.0, 2.0), 200.0);
		}
		BOOM BCDEFGHIJKLMOPQRSTUVWXY 2 Bright A_Quake(4, 4, 0, 4);
		Stop;
	Grenade:
		DYPP ABC 10 A_Die;
		Wait;
	Detonate:
		Stop;
	}
}