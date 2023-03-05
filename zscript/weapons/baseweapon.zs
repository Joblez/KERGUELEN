
//How did you even get here?

class BaseWeapon : DoomWeapon replaces DoomWeapon
{
	const SPAWN_OFFSET_DEPTH_FACTOR = 0.00805528;

	ModifiableVector2 m_PSpritePosition;
	ModifiableDouble m_PSpriteRotation;
	ModifiableVector2 m_PSpriteScale;

	meta class<HUDExtension> m_HUDExtensionType;
	property HUDExtensionType: m_HUDExtensionType;

	property BobStyle : BobStyle;

	//=================== Look Sway Parameters ================//

	meta double m_LookSwayXRange;
	property LookSwayXRange: m_LookSwayXRange;

	meta double m_LookSwayYRange;
	property LookSwayYRange: m_LookSwayYRange;

	meta double m_LookSwayStrengthX;
	property LookSwayStrengthX: m_LookSwayStrengthX;

	meta double m_LookSwayStrengthY;
	property LookSwayStrengthY: m_LookSwayStrengthY;

	meta double m_LookSwayResponseSpeed;
	property LookSwayResponse: m_LookSwayResponseSpeed;

	meta double m_LookSwayReturnSpeed;
	property LookSwayRigidity: m_LookSwayReturnSpeed;

	//=================== Move Sway Parameters ================//

	meta double m_MoveSwayUpRange;
	property MoveSwayUpRange: m_MoveSwayUpRange;

	meta double m_MoveSwayDownRange;
	property MoveSwayDownRange: m_MoveSwayDownRange;

	meta double m_MoveSwayLeftRange;
	property MoveSwayLeftRange: m_MoveSwayLeftRange;

	meta double m_MoveSwayRightRange;
	property MoveSwayRightRange: m_MoveSwayRightRange;

	meta double m_MoveSwayWeight;
	property MoveSwayWeight: m_MoveSwayWeight;

	meta double m_MoveSwayResponseSpeed;
	property MoveSwayResponse: m_MoveSwayResponseSpeed;

	protected WeaponSwayer m_WeaponMoveSwayer;
	protected WeaponSwayer m_WeaponLookSwayer;
	protected InterpolatedPSpriteTransform m_WeaponBobber;

	private double m_FallMomentum;
	private double m_BobPlayback;

	private double m_PreviousPlayerYaw;
	private double m_PreviousPlayerPitch;

	private HUDExtension m_HUDExtension;

	Default
	{
		Weapon.BobRangeX 8.0;
		Weapon.BobRangeY 4.0;
		Weapon.UpSound "weapon/select";

		BaseWeapon.BobStyle Bob_Alpha;

		BaseWeapon.MoveSwayUpRange 2.0;
		BaseWeapon.MoveSwayDownRange 10.0;
		BaseWeapon.MoveSwayLeftRange 8.0;
		BaseWeapon.MoveSwayRightRange 8.0;
		BaseWeapon.MoveSwayWeight 2.0;
		BaseWeapon.MoveSwayResponse 20.0;

		BaseWeapon.LookSwayXRange 26.0;
		BaseWeapon.LookSwayYRange 0.0;
		BaseWeapon.LookSwayResponse 20.0;
		BaseWeapon.LookSwayRigidity 8.0;
		BaseWeapon.LookSwayStrengthX 12.0;
		BaseWeapon.LookSwayStrengthY 0.0;

		BaseWeapon.HUDExtensionType "";

		Inventory.PickupSound "weapon/pickup";

		+WEAPON.NOAUTOFIRE;
		+WEAPON.NOALERT;
		+WEAPON.NOAUTOAIM;
		+WEAPON.DONTBOB; // Disable native bobbing in favor of custom implementation.
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
			maxTranslation: (m_LookSwayXRange, m_LookSwayYRange),
			maxRotation: 0.0,
			maxScale: (1.0, 1.0));
		m_WeaponLookSwayer.AddTransform(m_PSpritePosition, m_PSpriteRotation, m_PSpriteScale);
		m_WeaponLookSwayer.ForceSet((0.0, 0.0), 0.0, (1.0, 1.0));

		m_WeaponMoveSwayer = WeaponSwayer.Create(
			1.0 / m_MoveSwayResponseSpeed,
			m_MoveSwayWeight / 16.0,
			maxRotation: 0.0,
			maxScale: (1.0, 1.0),
			maxTranslationSplit: (-m_MoveSwayLeftRange, m_MoveSwayRightRange, -m_MoveSwayUpRange, m_MoveSwayDownRange));
		m_WeaponMoveSwayer.AddTransform(m_PSpritePosition, m_PSpriteRotation, m_PSpriteScale);
		m_WeaponMoveSwayer.ForceSet((0.0, 0.0), 0.0, (1.0, 1.0));

		m_WeaponBobber = new("InterpolatedPSpriteTransform");
		m_WeaponBobber.InterpolatedInit(1.0 / TICRATE);
		m_WeaponBobber.AddTransform(m_PSpritePosition, m_PSpriteRotation, m_PSpriteScale);
		m_WeaponBobber.ForceSet((0.0, 0.0), 0.0, (1.0, 1.0));

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
			WeaponMoveSway();
			WeaponBob();

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
		PlayerPawn pawn = owner.Player.mo;

		// Bring to eye level.
		let spawnPoint = (0, 0, pawn.Player.viewz - pawn.Pos.z);
		vector3 viewOffset;

		if (pawn.ViewPos)
		{
			viewOffset = pawn.ViewPos.offset;

			// Rotate view offset offset to view direction
			viewOffset = MathVec3.Rotate(viewOffset, Vec3Util.Left(), pawn.Pitch + pawn.ViewPitch);
			viewOffset = MathVec3.Rotate(viewOffset, Vec3Util.Up(), pawn.Angle + pawn.ViewAngle);
		}

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

		// Remap offset coordinates.
		vector3 zxyOffset = (spawnOffset.z, -spawnOffset.x, -spawnOffset.y);

		// Rotate offset to view direction.
		zxyOffset = MathVec3.Rotate(zxyOffset, Vec3Util.Left(), pawn.Pitch + pawn.ViewPitch);
		zxyOffset = MathVec3.Rotate(zxyOffset, Vec3Util.Up(), pawn.Angle + pawn.ViewAngle);

		let position = spawnPoint + zxyOffset + viewOffset;

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

	action void A_FireBulletsEx(vector2 spread, double distance, int damage, int count = 1, int flags = 0)
	{
		vector3 offset;
		if (ViewPos) offset = -ViewPos.Offset;

		vector2 angles = spread;

		for (int i = 0; i < count; ++i)
		{
			if (!(flags & FBF_EXPLICITANGLE))
			{
				angles.x = FRandom(-spread.x, spread.x);
				angles.y = FRandom(-spread.y, spread.y);
			}

			LineAttack(
				Angle + ViewAngle + angles.x,
				distance,
				Pitch + ViewPitch + angles.y,
				damage,
				'None',
				"Bullet_Puff",
				LAF_NORANDOMPUFFZ,
				null,
				offset.z,
				-offset.x,
				offset.y);
			}
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
			KergPlayer(self.player.mo).AddFOVForce(zf);
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

	action void A_SpawnFlash(double x, double y, int duration = 1)
	{
		WeaponFlash flash = WeaponFlash(A_FireProjectile("WeaponFlash", 0, 0, 6, -1));
		flash.m_Duration = duration;
	}

	action void A_SingleSmoke(double x, double y)
	{
		if (GetCVar('smoke_toggle') == 1)
		{
			A_FireProjectile("SmokeSpawner", 0, 0, x, y);
		}
	}

	protected action void A_SpawnTrail(FSpawnParticleParams particleParams, vector3 start, vector3 end, double spacing)
	{
		invoker.SpawnTrail(particleParams, start, end, spacing);
	}

	protected void SpawnTrail(FSpawnParticleParams particleParams, vector3 start, vector3 end, double spacing)
	{
		int weaponEffectSetting = CVar.GetCVar("weapon_effects", owner.player).GetInt();

		if (weaponEffectSetting <= Settings.OFF) return;

		double factor = Math.Remap(double(weaponEffectSetting) / Settings.ULTRA, 0.0, 1.0, 4.0, 1.0);
		spacing *= factor;

		vector3 direction = LevelLocals.Vec3Diff(start, end);
		double delta = direction.Length();
		direction = direction.Unit();

		for (double step = 0.0; step < delta; step += spacing)
		{
			particleParams.Pos = start + direction * step;
			level.SpawnParticle(particleParams);
		}
	}

	protected action void A_SpawnSmokeTrail(FLineTraceData t, vector3 origin, double size = 10.0, int lifetime = 35, double spacing = 1.0, double spread = 1.0)
	{
		int weaponEffectSetting = CVar.GetCVar("weapon_effects", invoker.owner.player).GetInt();

		if (weaponEffectSetting <= Settings.OFF) return;

		spacing *= Settings.ULTRA + 1.0 - weaponEffectSetting;

		FSpawnParticleParams params;

		params.color1 = 0xFFFFFFFF;
		params.texture = TexMan.CheckForTexture("SMOK01");
		params.style = STYLE_Translucent;
		params.lifetime = lifetime;
		params.size = size;
		params.sizestep = spread * 0.5;
		// params.vel.z += 0.125;
		params.startalpha = 0.1 * spacing;

		Actor effectOrigin = invoker.SpawnEffect("Agent", origin, 0.0, 0.0, 0.0, false);

		vector3 endpoint = t.HitLocation;

		if (t.HitTexture.IsValid()) Console.Printf("Hit texture: %s", TexMan.GetName(t.HitTexture));

		if (t.HitTexture == skyflatnum)
		{
			endpoint += t.HitDir.Unit() * 8192.0;
		}

		invoker.SpawnSmokeTrail(params, effectOrigin.Pos, endpoint, spacing, spread);

		effectOrigin.Destroy();
	}

	protected void SpawnSmokeTrail(FSpawnParticleParams particleParams, vector3 start, vector3 end, double spacing, double spread)
	{
		int weaponEffectSetting = CVar.GetCVar("weapon_effects", owner.player).GetInt();

		if (weaponEffectSetting <= Settings.OFF) return;

		double factor = Math.Remap(double(weaponEffectSetting) / Settings.ULTRA, 0.0, 1.0, 4.0, 1.0);
		spacing *= factor;

		vector3 direction = LevelLocals.Vec3Diff(start, end);
		double delta = direction.Length();
		direction = direction.Unit();

		for (double step = 0.0; step < delta; step += spacing)
		{
			particleParams.Pos = start + direction * step;

			vector3 moveDir;
			double angle = FRandom(0.0, 360.0);

			vector3 p = (direction cross (abs(direction.z) ~== 1.0 ? Vec3Util.Right() : Vec3Util.Up())).Unit();
			Quat rot = Quat.AxisAngle(direction, angle);
			moveDir = rot * p;

			particleParams.vel = moveDir * spread * particleParams.size * 0.01;
			particleParams.startalpha *= 0.9995;
			particleParams.fadestep = particleParams.startalpha / particleParams.lifetime;
			level.SpawnParticle(particleParams);
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
			(owner.Angle - m_PreviousPlayerYaw) * (M_PI / 180.0) * -m_LookSwayStrengthX,
			(owner.Pitch - m_PreviousPlayerPitch) * (M_PI / 180.0) * m_LookSwayStrengthY);

		m_WeaponLookSwayer.AddForce(swayForce);
		m_WeaponLookSwayer.Update();
	}

	private void WeaponMoveSway()
	{
		vector2 swayForce;

		swayForce.y = owner.Vel.z * m_MoveSwayWeight / 16.0;

		if (!owner.Player.onground && owner.Vel.z < 0.0)
		{
			m_FallMomentum += -owner.Vel.z * m_MoveSwayWeight / 16.0;
		}
		else
		{
			m_WeaponMoveSwayer.AddForce((0.0, m_FallMomentum));
			m_FallMomentum = 0.0;
		}

		m_WeaponMoveSwayer.AddForce(swayForce);
		m_WeaponMoveSwayer.Update();
	}

	private void WeaponBob()
	{
		KergPlayer pawn = KergPlayer(owner);
	
		double bobPlayback = pawn.GetBobPlayback();

		double xAmplitude = BobRangeX * pawn.GetBobAmplitude();
		double yAmplitude = BobRangeY * pawn.GetBobAmplitude();

		vector2 bobPosition = ProceduralWeaponBob(bobPlayback, xAmplitude, yAmplitude, pawn.m_BobTime);

		m_WeaponBobber.SetTargetTranslation(bobPosition);
		m_WeaponBobber.Update();
	}
	
	private vector2 ProceduralWeaponBob(double playback, double xRange, double yRange, double frequency)
	{
		double a = playback / TICRATE * 360.0 * (1.0 / (frequency * 2.0));

		switch (BobStyle)
		{
			case Bob_Normal:
				return (
					xRange * cos(a),
					yRange * abs(sin(a)));

			case Bob_Inverse:
				return (
					xRange * cos(a),
					yRange * (1.0 - abs(sin(a))));

			case Bob_Alpha:
				return (
					xRange * sin(a),
					yRange * abs(sin(a)));

			case Bob_InverseAlpha:
				return (
					xRange * sin(a),
					yRange * (1.0 - abs(sin(a))));

			case Bob_Smooth:
				return (
					xRange * cos(a),
					0.5 * (yRange * (1.0 - cos(a * 2.0))));

			case Bob_InverseSmooth:
				return (
					xRange * cos(a),
					0.5 * (yRange * (1.0 + cos(a * 2.0))));

			case Bob_FigureEight:
			default:
				return (
					xRange * sin(a / 2.0),
					yRange * cos(a));

			case Bob_Snap:
				return (
					BobRangeX * Math.Sign(sin(a)),
					BobRangeY * Math.Sign(cos(a * 2.0)));
		}
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
	vector2 m_MaxTranslationXRange;
	vector2 m_MaxTranslationYRange;
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
		vector2 maxScale = (double.Infinity, double.Infinity),
		vector4 maxTranslationSplit = (double.Infinity, double.Infinity, double.Infinity, double.Infinity))
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
			maxScale,
			maxTranslationSplit);
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
		vector2 maxScale = (double.Infinity, double.Infinity),
		vector4 maxTranslationSplit = (double.Infinity, double.Infinity, double.Infinity, double.Infinity))
	{
		InterpolatedInit(smoothTime, translation, rotation, scale);

		m_TargetSmoothTime = targetSmoothTime;
		m_MaxRotation = maxRotation;
		m_MaxTranslationXRange = (-maxTranslation.x, maxTranslation.x);
		m_MaxTranslationYRange = (-maxTranslation.y, maxTranslation.y);
		m_MaxScale = maxScale;

		if (maxTranslationSplit != (double.Infinity, double.Infinity, double.Infinity, double.Infinity))
		{
			m_MaxTranslationXRange = (maxTranslationSplit.x, maxTranslationSplit.y);
			m_MaxTranslationYRange = (maxTranslationSplit.z, maxTranslationSplit.w);
		}
	}

	override void Update()
	{
		// Console.Printf("Translation target: %s", ToStr.Vec2(m_InterpolatedTranslation.m_Target));

		m_InterpolatedTranslation.m_Target = (
			clamp(m_InterpolatedTranslation.m_Target.x, m_MaxTranslationXRange.x, m_MaxTranslationXRange.y),
			clamp(m_InterpolatedTranslation.m_Target.y, m_MaxTranslationYRange.x, m_MaxTranslationYRange.y));

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

		// Console.Printf("Dampened translation target: %s", ToStr.Vec2(m_InterpolatedTranslation.m_Target));

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