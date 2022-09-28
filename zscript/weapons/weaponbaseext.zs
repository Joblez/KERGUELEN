extend class WeaponBase
{
    // TODO: CLean this up omg.
    action void A_AutoRecoil() {
		if (GetCvar("recoil_toggle") == 1)
		{
			A_SetPitch(pitch - 0.3);	
			//A_Recoil(0.1);	
			A_Quake(2,1,0,4);		
			}
	 
		}

				
				


	action void A_ShotgunRecoil() {
		if (GetCvar("recoil_toggle") == 1)
		{				
			//A_Recoil(0.4);
			A_SetPitch(pitch - 2);
			A_Quake(6,4,0,10);
			}
		
		}
 
	action void A_RifleRecoil() {
 
		if (GetCvar("recoil_toggle") == 1)
		{
				
		//A_Recoil(0.1);
		A_SetPitch(pitch - 0.4);
		A_Quake(3,2,0,10);
		}
 
	}

	action void A_PistolRecoil() {
		if (GetCvar("recoil_toggle") == 1)
			{	
			A_WeaponReady(WRF_NOPRIMARY);
			
			//A_Recoil(0.1);
			A_SetPitch(pitch - 1);
			A_Quake(3,2,0,4);
			}
		}

//Casings

	action void A_CasingRifle (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("RifleSpawnerR",0,0,x,y); }
		}

	action void A_CasingShotgun (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("ShellSpawnerR",0,0,x,y); }
		}
	

	action void A_CasingPistol (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("PistolSpawnerR",0,0,x,y); }
		}		

	action void A_CasingGrenade (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("GrenadeSpawnerR",0,0,x,y); }
		}	

	action void A_CasingRocket (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("RocketSpawnerR",0,0,x,y); }
		}	
		
	action void A_CasingRevolver (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("RevolverSpawnerR",0,0,x,y); }
		}			

	action void A_CasingRifleL (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("RifleSpawnerL",0,0,x,y); }
		}

	action void A_CasingShotgunL (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("ShellSpawnerL",0,0,x,y); }
		}
	

	action void A_CasingPistolL (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("PistolSpawnerL",0,0,x,y); }
		}		

	action void A_CasingGrenadeL (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("GrenadeSpawnerL",0,0,x,y); }
		}	

	action void A_CasingRevolverL (Double x, Double y) {
			if (GetCvar("casing_toggle") == 1) { A_FireProjectile("RevolverSpawnerL",0,0,x,y); }
		}

//Smoke

	action void A_ShotgunSmoke (Double x, Double y) {
			if (GetCvar("smoke_toggle") == 1)
				{
					A_FireProjectile("SmokeSpawner",0,0,x,y);				
					A_FireProjectile("SmokeSpawner",0,0,x,y);				
					A_FireProjectile("SmokeSpawner",0,0,x,y);			
					A_FireProjectile("SmokeSpawner",0,0,x,y);			
				}
		}

	action void A_SingleSmoke(Double x, Double y) {

			if (GetCvar("smoke_toggle") == 1)
				{
			
					A_FireProjectile("SmokeSpawner",0,0,x,y);			
				}
		}
}