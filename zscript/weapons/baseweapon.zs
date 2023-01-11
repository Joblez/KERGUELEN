
//How did you even get here?

class BaseWeapon : DoomWeapon replaces DoomWeapon
{
	const SPAWN_OFFSET_DEPTH_FACTOR = 0.00805528;

	ModifiableVector2 m_PSpritePosition;
	ModifiableDouble m_PSpriteRotation;
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
		BaseWeapon.LookSwayStrengthX 10.0;
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
		Super.BeginPlay();

		m_PSpritePosition = new("ModifiableVector2");
		m_PSpriteRotation = new("ModifiableDouble");
		m_PSpriteScale = new("ModifiableVector2");
		m_PSpritePosition.SetBaseValue((0.0, WEAPONBOTTOM));
		m_PSpriteRotation.SetBaseValue(0.0);
		m_PSpriteScale.SetBaseValue((1.0, 1.0));

		m_WeaponLookSwayer = WeaponSwayer.Create(
			1.0 / m_LookSwayResponseSpeed,
			1.0 / m_LookSwayReturnSpeed,
			maxTranslation: (m_LookSwayMaxTranslationX, m_LookSwayMaxTranslationY),
			maxRotation: 0.0,
			maxScale: (1.0, 1.0));
		m_WeaponLookSwayer.AddTransform(m_PSpritePosition, m_PSpriteRotation, m_PSpriteScale);
		m_WeaponLookSwayer.ForceSet((0.0, 0.0), 0.0, (1.0, 1.0));

		if (m_HUDExtensionType)
		{
			m_HUDExtension = HUDExtension(new(m_HUDExtensionType));
			m_HUDExtension.Init(self);
		}
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

			if (m_HUDExtension) m_HUDExtension.CallTick();
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

	virtual int GetAmmo() const
	{
		return -1;
	}

	virtual int GetReserveAmmo() const
	{
		return -1;
	}

	void SetBaseOffset(int x, int y)
	{
		m_PSpritePosition.SetBaseValue((x, y));
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
	
	// Smoke

	action void A_ShotgunSmoke(double x, double y)
	{
		if (GetCVar('smoke_toggle') == 1)
		{
			A_FireProjectile("SmokeSpawner", 0, 0, x, y);
			A_FireProjectile("SmokeSpawner", 0, 0, x, y);
			A_FireProjectile("SmokeSpawner", 0, 0, x, y);
			A_FireProjectile("SmokeSpawner", 0, 0, x, y);
		}
	}

	action void A_SingleSmoke(double x, double y)
	{
		if (GetCVar('smoke_toggle') == 1)
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

class WeaponSwayer : InterpolatedPSpriteTransform
{
	vector2 m_MaxTranslation;
	double m_MaxRotation;
	vector2 m_MaxScale;

	private double m_TargetSmoothTime;
	private vector2 m_TargetTranslationSpeed;
	private double m_TargetRotationSpeed;
	private vector2 m_TargetScaleSpeed;

	static WeaponSwayer Create(
		double smoothTime,
		double targetSmoothTime,
		vector2 translation = (0.0, 0.0),
		double rotation = 0.0,
		vector2 scale = (1.0, 1.0),
		vector2 maxTranslation = (double.Infinity, double.Infinity),
		double maxRotation = double.Infinity,
		vector2 maxScale = (double.Infinity, double.Infinity))
	{
		WeaponSwayer swayer = new("WeaponSwayer");
		swayer.SwayerInit(
			smoothTime,
			targetSmoothTime,
			translation,
			rotation,
			scale,
			maxTranslation,
			maxRotation,
			maxScale);
		return swayer;
	}

	void SwayerInit(
		double smoothTime,
		double targetSmoothTime,
		vector2 translation = (0.0, 0.0),
		double rotation = 0.0,
		vector2 scale = (1.0, 1.0),
		vector2 maxTranslation = (double.Infinity, double.Infinity),
		double maxRotation = double.Infinity,
		vector2 maxScale = (double.Infinity, double.Infinity))
	{
		InterpolatedInit(smoothTime, translation, rotation, scale);

		m_TargetSmoothTime = targetSmoothTime;
		m_MaxTranslation = maxTranslation;
		m_MaxRotation = maxRotation;
		m_MaxScale = maxScale;
	}

	override void Update()
	{
		m_InterpolatedTranslation.m_Target = (
			clamp(m_InterpolatedTranslation.m_Target.x, -m_MaxTranslation.x, m_MaxTranslation.x),
			clamp(m_InterpolatedTranslation.m_Target.y, -m_MaxTranslation.y, m_MaxTranslation.y));
		
		m_InterpolatedRotation.m_Target = clamp(m_InterpolatedRotation.m_Target, -m_MaxRotation, m_MaxRotation);

		m_InterpolatedScale.m_Target = (
			clamp(m_InterpolatedScale.m_Target.x, -m_MaxScale.x, m_MaxScale.x),
			clamp(m_InterpolatedScale.m_Target.y, -m_MaxScale.y, m_MaxScale.y));

		Super.Update();

		m_InterpolatedTranslation.m_Target = MathVec2.SmoothDamp(
			m_InterpolatedTranslation.m_Target,
			(0.0, 0.0),
			m_TargetTranslationSpeed,
			m_TargetSmoothTime,
			double.Infinity,
			1.0 / TICRATE);

		m_InterpolatedRotation.m_Target = Math.SmoothDamp(
			m_InterpolatedRotation.m_Target,
			0.0,
			m_TargetRotationSpeed,
			m_TargetSmoothTime,
			double.Infinity,
			1.0 / TICRATE);

		m_InterpolatedScale.m_Target = MathVec2.SmoothDamp(
			m_InterpolatedScale.m_Target,
			(1.0, 1.0),
			m_TargetScaleSpeed,
			m_TargetSmoothTime,
			double.Infinity,
			1.0 / TICRATE);

		m_Translation.SetValue(m_InterpolatedTranslation.GetValue());
		m_Rotation.SetValue(m_InterpolatedRotation.GetValue());
		m_Scale.SetValue(m_InterpolatedScale.GetValue());
	}

	void AddForce(vector2 translationForce, double rotationForce = 0.0, vector2 scaleForce = (0.0, 0.0))
	{
		m_InterpolatedTranslation.m_Target += translationForce;
		m_InterpolatedRotation.m_Target += rotationForce;
		m_InterpolatedScale.m_Target += scaleForce;
	}

	void SetForce(vector2 translationForce, double rotationForce = 0.0, vector2 scaleForce = (1.0, 1.0))
	{
		m_InterpolatedTranslation.m_Target = translationForce;
		m_InterpolatedRotation.m_Target = rotationForce;
		m_InterpolatedScale.m_Target = scaleForce;
	}
}

class ProjectileBase : Actor
{
	uint m_ProjectileFlags;

	flagdef DrawFromHitboxCenter: m_ProjectileFlags, 0;

	Default
	{
		RenderStyle "Normal";
		Alpha 1.0;
		Projectile;
		+FORCEXYBILLBOARD;
		+ProjectileBase.DRAWFROMHITBOXCENTER;
	}

	override void BeginPlay()
	{
		if (bDrawFromHitboxCenter)
		{
			A_SpriteOffset(0.0, -(Height / 2.0));
		}
	}
}