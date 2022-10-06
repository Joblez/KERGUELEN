
//How did you even get here?

class BaseWeapon : DoomWeapon replaces DoomWeapon
{
	ModifiableVector2 m_PSpritePosition;
	ModifiableVector2 m_PSpriteScale;

	//=================== Look Sway Parameters ================//

	double m_LookSwayStrengthX;
	property LookSwayStrengthX: m_LookSwayStrengthX;

	double m_LookSwayStrengthY;
	property LookSwayStrengthY: m_LookSwayStrengthY;

	double m_LookSwayMaxTranslationX;
	property MaxLookSwayTranslationX: m_LookSwayMaxTranslationX;

	double m_LookSwayMaxTranslationY;
	property MaxLookSwayTranslationY: m_LookSwayMaxTranslationY;

	double m_LookSwayResponseSpeed;
	property LookSwayResponse: m_LookSwayResponseSpeed;

	double m_LookSwayReturnSpeed;
	property LookSwayRigidity: m_LookSwayReturnSpeed;

	protected WeaponSwayer m_WeaponLookSwayer;

	private double m_PreviousPlayerYaw;
	private double m_PreviousPlayerPitch;

	Default
	{
		Weapon.BobRangeX 0.3;
		Weapon.BobRangeY 0.3;
		Weapon.BobSpeed 1.7;
		Weapon.BobStyle "Alpha";
		Weapon.UpSound "weapon/select";

		BaseWeapon.LookSwayResponse 20.0;
		BaseWeapon.LookSwayRigidity 8.0;
		BaseWeapon.LookSwayStrengthX 8.0;
		BaseWeapon.LookSwayStrengthY 0.0;
		BaseWeapon.MaxLookSwayTranslationX 26.0;
		BaseWeapon.MaxLookSwayTranslationY 0.0;

		Inventory.PickupSound "weapon/pickup";
		+WEAPON.NOAUTOFIRE;
		+WEAPON.NOALERT;
	}

	States
	{
	Load:
		FLAF ABCD 0;
	}

	override void BeginPlay()
	{
		m_PSpritePosition = new("ModifiableVector2");
		m_PSpriteScale = new("ModifiableVector2");
		m_PSpritePosition.SetBaseValue((0.0, WEAPONBOTTOM));
		m_PSpriteScale.SetBaseValue((1.0, 1.0));

		m_WeaponLookSwayer = new("WeaponSwayer");
		m_WeaponLookSwayer.SwayerInit(
			1.0 / m_LookSwayResponseSpeed,
			1.0 / m_LookSwayReturnSpeed,
			'LookSwayTranslation',
			'LookSwayScale',
			(m_LookSwayMaxTranslationX, m_LookSwayMaxTranslationY),
			(0, 0));
		m_WeaponLookSwayer.AddTransform(m_PSpritePosition, m_PSpriteScale);
	}

	override void DoEffect()
	{
		if (IsSelected())
		{
			WeaponLookSway();
			m_WeaponLookSwayer.Update();

			let psp = owner.Player.GetPSprite(PSP_WEAPON);

			psp.x = m_PSpritePosition.GetX();
			psp.y = m_PSpritePosition.GetY();
			psp.scale = m_PSpriteScale.GetValue();
		}

		m_PreviousPlayerYaw = owner.Angle;
		m_PreviousPlayerPitch = owner.Pitch;
	}

	// Copied from WeaponBase.
	bool IsSelected() const
	{
		return owner
			&& owner.player
			&& owner.Player.ReadyWeapon
			&& owner.Player.ReadyWeapon == self;
	}

	void SetBaseOffset(int x, int y)
	{
		m_PSpritePosition.SetBaseValue((x, y));
	}

	action void A_SetBaseOffset(int x, int y)
	{
		invoker.SetBaseOffset(x, y);
	}

	//Visual Recoil (Zoomfactor)

	action void A_VRecoil(double zf, int quakeint, int quaketrem) {

		if (GetCvar("recoil_toggle") == 1)
		{
			A_ZoomFactor(zf,ZOOM_NOSCALETURNING);
			A_Quake(quakeint, 1, 0, quaketrem);
		}

	}

	// Felt Recoil.

	action void A_FRecoil(double sp) {

		A_SetPitch(pitch - sp);

	}

/*	action void A_Frecoilr(double rp) {
		A_WeaponReady(WRF_NOPRIMARY);
		A_SetPitch(pitch - rp);
	}*/

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

	private void WeaponLookSway()
	{
		let swayForce = (
			(owner.Angle - m_PreviousPlayerYaw) * (M_PI / 180) * -m_LookSwayStrengthX,
			(owner.Pitch - m_PreviousPlayerPitch) * (M_PI / 180) * m_LookSwayStrengthY);

		m_WeaponLookSwayer.AddForce(swayForce);
	}
}

