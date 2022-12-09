
//How did you even get here?

class BaseWeapon : DoomWeapon replaces DoomWeapon
{
	const SPAWN_OFFSET_DEPTH_FACTOR = 0.00805528;

	ModifiableVector2 m_PSpritePosition;
	ModifiableVector2 m_PSpriteScale;

	meta class<HUDExtension> m_HUDExtensionType;
	property HUDExtensionType: m_HUDExtensionType;

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

	private HUDExtension m_HUDExtension;

	Default
	{
		Weapon.BobRangeX 0.4;
		Weapon.BobRangeY 0.4;
		Weapon.BobSpeed 1.7;
		Weapon.BobStyle "Alpha";
		Weapon.UpSound "weapon/select";

		BaseWeapon.LookSwayResponse 20.0;
		BaseWeapon.LookSwayRigidity 8.0;
		BaseWeapon.LookSwayStrengthX 8.0;
		BaseWeapon.LookSwayStrengthY 0.0;
		BaseWeapon.MaxLookSwayTranslationX 26.0;
		BaseWeapon.MaxLookSwayTranslationY 0.0;
		BaseWeapon.HUDExtensionType "";

		Inventory.PickupSound "weapon/pickup";

		+WEAPON.NOAUTOFIRE;
		+WEAPON.NOALERT;
		+WEAPON.NOAUTOAIM;
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

	HUDExtension GetHUDExtension() const
	{
		return m_HUDExtension;
	}

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

	void RegisterWeaponHUD()
	{
		if (!m_HUDExtensionType) return;

		if (!m_HUDExtension)
		{
			m_HUDExtension = HUDExtension(new(m_HUDExtensionType));
			m_HUDExtension.Init(self);
		}

		HUDExtensionRegistry.AddExtension(self, m_HUDExtension);
	}

	void UnregisterWeaponHUD()
	{
		if (!m_HUDExtension) return;
		HUDExtensionRegistry.RemoveExtension(m_HUDExtension);
	}

	Actor SpawnEffect(
		class<Actor> effectType,
		vector3 spawnOffset = (0, 0, 0),
		double yaw = 0.0,
		double pitch = 0.0,
		double velocity = double.Infinity,
		bool addPawnVelocity = false,
		bool adjustForFov = true,
		bool followPSpriteOffset = true,
		bool directionRelativeToPawn = true)
	{
		let pawn = PlayerPawn(owner);

		// Bring to eye level
		let spawnPoint = (0, 0, pawn.Player.viewz - pawn.Pos.z);
		if (pawn.ViewPos) spawnPoint += pawn.ViewPos.Offset;

		if (followPSpriteOffset)
		{
			let factor = SPAWN_OFFSET_DEPTH_FACTOR * spawnOffset.z;
			let offsetX = m_PSpritePosition.GetX() - m_PSpritePosition.GetBaseX();
			let offsetY = m_PSpritePosition.GetY() - m_PSpritePosition.GetBaseY();
			spawnOffset.x += abs(offsetX) * factor * Math.Sign(offsetX);
			spawnOffset.y += abs(offsetY) * factor * Math.Sign(offsetY);
		}

		if (adjustForFov)
		{
			spawnOffset.x /= GetSpawnOffsetFovFactor();
			spawnOffset.y /= GetSpawnOffsetFovFactor();
			spawnOffset.z *= GetSpawnOffsetFovFactor();
		}

		// Remap offset coordinates
		vector3 zxyOffset = (spawnOffset.z, -spawnOffset.x, -spawnOffset.y);

		// Rotate offset to view direction
		zxyOffset = MathVec3.Rotate(zxyOffset, Vec3Util.Left(), pawn.Pitch);
		zxyOffset = MathVec3.Rotate(zxyOffset, Vec3Util.Up(), pawn.Angle);

		let position = spawnPoint + zxyOffset;

		if (directionRelativeToPawn)
		{
			vector3 direction = Vec3Util.FromAngles(yaw, pitch);
			direction = MathVec3.Rotate(direction, Vec3Util.Right(), pawn.Pitch);
			direction = MathVec3.Rotate(direction, Vec3Util.Up(), pawn.Angle);
			vector2 angles = MathVec3.ToYawAndPitch(direction);
			yaw = angles.x;
			pitch = angles.y;
		}

		let effect = SpawnProjectile(effectType, (position.x, position.y, position.z), yaw, pitch, velocity);
		if (addPawnVelocity) effect.Vel += pawn.Vel;
		return effect;
	}

	action void A_SpawnEffect(class<Actor> effectType, vector3 spawnOffset = (0, 0, 0), double yaw = 0.0, double pitch = 0.0, double velocity = 0.0, bool addPawnVelocity = false)
	{
		let weapon = BaseWeapon(invoker);
		weapon.SpawnEffect(effectType, spawnOffset, yaw, pitch, velocity, addPawnVelocity);
	}

	action void A_SetBaseOffset(int x, int y)
	{
		invoker.SetBaseOffset(x, y);
	}

	// Visual Recoil (Zoomfactor).

	action void A_VRecoil(double zf, int quakeInt, int quakeTrem) {

		if (GetCVar("recoil_toggle") == 1)
		{
			A_ZoomFactor(zf, ZOOM_NOSCALETURNING);
			A_Quake(quakeInt, 1, 0, quakeTrem);
		}

	}

	// Felt Recoil.

	action void A_FRecoil(double sp)
	{
		A_SetPitch(pitch - sp);
	}

	action void A_CasingGrenade(double x, double y)
	{
		if (GetCVar("casing_toggle") == 1) A_FireProjectile("GrenadeSpawnerR", 0, 0, x, y);
	}

	action void A_CasingRocket(double x, double y)
	{
		if (GetCVar("casing_toggle") == 1) A_FireProjectile("RocketSpawnerR", 0, 0, x, y);
	}

	action void A_CasingGrenadeL(double x, double y)
	{
		if (GetCVar("casing_toggle") == 1) A_FireProjectile("GrenadeSpawnerL", 0, 0, x, y);
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

	protected double GetSpawnOffsetFovFactor() const
	{
		let factor = Math.Remap(owner.Player.FOV, 75.0, 120.0, 1.6, 1.0);
		return factor;
	}

	private void WeaponLookSway()
	{
		let swayForce = (
			(owner.Angle - m_PreviousPlayerYaw) * (M_PI / 180) * -m_LookSwayStrengthX,
			(owner.Pitch - m_PreviousPlayerPitch) * (M_PI / 180) * m_LookSwayStrengthY);

		m_WeaponLookSwayer.AddForce(swayForce);
	}

	private Actor SpawnProjectile(class<Actor> projectileType, vector3 position, double yaw, double pitch, double speed = double.Infinity)
	{
		position += owner.Pos;
		if (position.z != ONFLOORZ && position.z != ONCEILINGZ)
		{
			if (position.z < owner.FloorZ)
			{
				position.z = owner.FloorZ;
			}
		}

		let projectile = Spawn(projectileType, position, ALLOW_REPLACE);
		projectile.Target = owner;
		projectile.Angle = yaw;
		projectile.Pitch = pitch;

		if (projectile.bFloorHugger && projectile.bCeilingHugger)
		{
			projectile.VelFromAngle();
		}
		else
		{
			if (speed == double.Infinity) speed = projectile.Speed;
			projectile.Vel3DFromAngle(speed, yaw, pitch);
		}

		if (projectile.bSPECTRAL)
		{
			projectile.SetFriendPlayer(owner.player);
		}

		return projectile;
	}
}

