
//How did you even get here?

class BaseWeapon : DoomWeapon replaces DoomWeapon
{
	Default
	{
		Weapon.BobRangeX 0.3;
		Weapon.BobRangeY 0.3;
		Weapon.BobSpeed 1.5;
		Weapon.BobStyle "Alpha";
		Weapon.UpSound "weapon/select";

		Inventory.PickupSound "weapon/pickup";

		Tag "Weapon";
		+WEAPON.NOAUTOFIRE;
		+WEAPON.NOALERT;
	}

	States
	{
		Load:
		FLAF ABCD 0;
	}

	// Recoil.

	action void A_AutoRecoil()
	{
		if (GetCvar("recoil_toggle") == 1)
		{
			A_SetPitch(pitch - 0.3);
			//A_Recoil(0.1);
			A_Quake(2,1,0,4);
		}
	}

	action void A_ShotgunRecoil()
	{
		if (GetCVar("recoil_toggle") == 1)
		{
			//A_Recoil(0.4);
			A_SetPitch(pitch - 2);
			A_Quake(6,4,0,10);
		}
	}

	action void A_RifleRecoil()
	{
		if (GetCVar("recoil_toggle") == 1)
		{
			//A_Recoil(0.1);
			A_SetPitch(pitch - 0.4);
			A_Quake(3,2,0,10);
		}
	}

	action void A_PistolRecoil()
	{
		if (GetCVar("recoil_toggle") == 1)
		{
			A_WeaponReady(WRF_NOPRIMARY);

			//A_Recoil(0.1);
			A_SetPitch(pitch - 1);
			A_Quake(3,2,0,4);
		}
	}

	// Casings.

	action void A_CasingRifle(double x, double y)
	{
		if (GetCVar("casing_toggle") == 1) A_FireProjectile("RifleSpawnerR", 0, 0, x, y);
	}

	action void A_CasingShotgun(double x, double y)
	{
		if (GetCVar("casing_toggle") == 1) A_FireProjectile("ShellSpawnerR", 0, 0, x, y);
	}

	action void A_CasingPistol(double x, double y)
	{
		if (GetCVar("casing_toggle") == 1) A_FireProjectile("PistolSpawnerR", 0, 0, x, y);
	}

	action void A_CasingGrenade(double x, double y)
	{
		if (GetCVar("casing_toggle") == 1) A_FireProjectile("GrenadeSpawnerR", 0, 0, x, y);
	}

	action void A_CasingRocket(double x, double y)
	{
		if (GetCVar("casing_toggle") == 1) A_FireProjectile("RocketSpawnerR", 0, 0, x, y);
	}

	action void A_CasingRevolver(double x, double y)
	{
		if (GetCVar("casing_toggle") == 1) A_FireProjectile("RevolverSpawnerR", 0, 0, x, y);
	}

	action void A_CasingRifleL(double x, double y)
	{
		if (GetCVar("casing_toggle") == 1) A_FireProjectile("RifleSpawnerL", 0, 0, x, y);
	}

	action void A_CasingShotgunL(double x, double y)
	{
		if (GetCVar("casing_toggle") == 1) A_FireProjectile("ShellSpawnerL", 0, 0, x, y);
	}

	action void A_CasingPistolL(double x, double y)
	{
		if (GetCVar("casing_toggle") == 1) A_FireProjectile("PistolSpawnerL", 0, 0, x, y);
	}

	action void A_CasingGrenadeL(double x, double y)
	{
		if (GetCVar("casing_toggle") == 1) A_FireProjectile("GrenadeSpawnerL", 0, 0, x, y);
	}

	action void A_CasingRevolverL(double x, double y)
	{
		if (GetCVar("casing_toggle") == 1) A_FireProjectile("RevolverSpawnerL", 0, 0, x, y);
	}

	// Smoke

	action void A_ShotgunSmoke (double x, double y)
	{
		if (GetCVar("smoke_toggle") == 1)
		{
			A_FireProjectile("SmokeSpawner", 0, 0, x, y);
			A_FireProjectile("SmokeSpawner", 0, 0, x, y);
			A_FireProjectile("SmokeSpawner", 0, 0, x, y);
			A_FireProjectile("SmokeSpawner", 0, 0, x, y);
		}
	}

	action void A_SingleSmoke(double x, double y)
	{
		if (GetCvar("smoke_toggle") == 1)
		{
			A_FireProjectile("SmokeSpawner", 0, 0, x, y);
		}
	}
}

