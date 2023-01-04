// TODO: Document WeaponBase.

// Note: Make sure to mention how WeaponBase is much more opinionated than the rest of the codebase.
class WeaponBase : DoomWeapon abstract
{
	// Smart auto-aim modes.
	const SAIM_OFF = 0;
	const SAIM_ON = 1;
	const SAIM_NEVERFRIENDS = 2;
	const SAIM_ONLYMONSTERS = 3;

	// Conversion factors.
	const SPAWN_OFFSET_DEPTH_FACTOR = 0.00805528;

	// Extents.
	const MAX_FORWARD_MOVE = 12800;
	const MAX_SIDE_MOVE = 10240;

	meta class<HUDExtension> m_HUDExtensionType;
	property HUDExtensionType: m_HUDExtensionType;

	protected meta class<SMMachinePlay> m_StateMachineType;
	property MachineType: m_StateMachineType;

	ModifiableVector2 m_PSpritePosition;
	ModifiableDouble m_PSpriteRotation;
	ModifiableVector2 m_PSpriteScale;

	ButtonEventQueue m_InputQueue;

	int m_Damage;
	property Damage: m_Damage;

	double m_Range;
	property Range: m_Range;

	uint m_TicsPerAttack;
	property TicsPerAttack: m_TicsPerAttack;

	//================== Auto-Aim Parameters =================//

	double m_ForcedHorizontalAutoAim;
	property ForcedHorizontalAutoAim: m_ForcedHorizontalAutoAim;

	double m_ForcedVerticalAutoAim;
	property ForcedVerticalAutoAim: m_ForcedVerticalAutoAim;

	//=================== Recoil Parameters ==================//
	// TODO: Merge XY parameters into vectors once vector properties are supported.

	double m_RecoilMaxTranslationX;
	property MaxRecoilTranslationX: m_RecoilMaxTranslationX;

	double m_RecoilMaxTranslationY;
	property MaxRecoilTranslationY: m_RecoilMaxTranslationY;

	double m_RecoilMaxRotation;
	property MaxRecoilRotation: m_RecoilMaxRotation;

	double m_RecoilMaxScaleX;
	property MaxRecoilScaleX: m_RecoilMaxScaleX;

	double m_RecoilMaxScaleY;
	property MaxRecoilScaleY: m_RecoilMaxScaleY;

	double m_RecoilResponseSpeed;
	property RecoilResponse: m_RecoilResponseSpeed;

	double m_RecoilReturnSpeed;
	property RecoilRigidity: m_RecoilReturnSpeed;

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

	//====================== Bob Parameters ===================//

	double m_BobIntensity;
	property BobIntensity: m_BobIntensity;

	double m_BobSpeed;
	property BobSpeed: m_BobSpeed;

	double m_BobIntensityResponseTime;
	property BobIntensityResponseTime: m_BobIntensityResponseTime;

	double m_BobSpeedResponseTime;
	property BobSpeedResponseTime: m_BobIntensityResponseTime;

	string m_BobAnimName;
	property BobAnimation: m_BobAnimName;

	protected SMMachinePlay m_StateMachine;
	protected WeaponSwayer m_WeaponRecoilSwayer;
	protected WeaponSwayer m_WeaponLookSwayer;
	protected InterpolatedPSpriteTransform m_WeaponBobber;

	protected InterpolatedDouble m_BobAmplitude;
	protected InterpolatedDouble m_BobPlaybackSpeed;

	private int m_TicsSinceLastAttack;

	private HUDExtension m_HUDExtension;

	private double m_PreviousPlayerYaw;
	private double m_PreviousPlayerPitch;
	private vector3 m_PreviousPlayerVel;
	private BakedCurve m_BobAnim;
	private double m_BobPlayback;

	Default
	{
		// Disable default bob in favor of WeaponBase's custom bobbing.
		+WEAPON.DONTBOB;

		WeaponBase.MachineType "SMWeaponMachine";
		WeaponBase.HUDExtensionType "";
		WeaponBase.Damage 7;
		WeaponBase.Range 8192.0;
		WeaponBase.TicsPerAttack 8;

		// Defaults approximate native behavior.
		WeaponBase.ForcedHorizontalAutoAim 0.0;
		WeaponBase.ForcedVerticalAutoAim -1.0;

		WeaponBase.RecoilResponse 26.0;
		WeaponBase.RecoilRigidity 12.0;
		WeaponBase.MaxRecoilTranslationX 50.0;
		WeaponBase.MaxRecoilTranslationY 50.0;
		WeaponBase.MaxRecoilRotation 0.0;
		WeaponBase.MaxRecoilScaleY 1.5;
		WeaponBase.MaxRecoilScaleY 1.5;

		WeaponBase.LookSwayResponse 20.0;
		WeaponBase.LookSwayRigidity 8.0;
		WeaponBase.LookSwayStrengthX 8.0;
		WeaponBase.LookSwayStrengthY 8.0;
		WeaponBase.MaxLookSwayTranslationX 26.0;
		WeaponBase.MaxLookSwayTranslationY 6.0;

		WeaponBase.BobIntensity 1.0;
		WeaponBase.BobSpeed 1.0;
		WeaponBase.BobIntensityResponseTime 2.0 / TICRATE;
		WeaponBase.BobSpeedResponseTime 2.0 / TICRATE;
	}

	States
	{
	// Select and Deselect are used as equip and unequip notifiers.
	Select:
		TNT1 A 0 A_SendEventToSM('WeaponSelected');
		Stop;
	Deselect:
		TNT1 A 0 A_SendEventToSM('WeaponDeselected');
		Stop;
	SwitchingIn:
		RPLC A 1 A_RaiseSMNotify(10);
		Loop;
	SwitchingOut:
		RPLC A 1 A_LowerSMNotify(10);
		Loop;

	Spawn:
		UNKN A -1;
		Stop;

	Ready:
	Fire:
		TNT1 A 0;	// Need these dummy labels so the compiler doesn't complain.
		Stop;
	}

	override void BeginPlay()
	{
		m_PSpritePosition = new("ModifiableVector2");
		m_PSpriteRotation = new("ModifiableDouble");
		m_PSpriteScale = new("ModifiableVector2");
		m_PSpritePosition.SetBaseValue((0.0, WEAPONBOTTOM));
		m_PSpriteRotation.SetBaseValue(0.0);
		m_PSpriteScale.SetBaseValue((1.0, 1.0));

		m_WeaponRecoilSwayer = WeaponSwayer.Create(
			1.0 / m_RecoilResponseSpeed,
			1.0 / m_RecoilReturnSpeed,
			(m_RecoilMaxTranslationX, m_RecoilMaxTranslationY),
			m_RecoilMaxRotation,
			(m_RecoilMaxScaleX, m_RecoilMaxScaleY));
		m_WeaponRecoilSwayer.AddTransform(m_PSpritePosition, m_PSpriteRotation, m_PSpriteScale);

		m_WeaponLookSwayer = WeaponSwayer.Create(
			1.0 / m_LookSwayResponseSpeed,
			1.0 / m_LookSwayReturnSpeed,
			(m_LookSwayMaxTranslationX, m_LookSwayMaxTranslationY),
			0.0,
			(0.0, 0.0));
		m_WeaponLookSwayer.AddTransform(m_PSpritePosition, m_PSpriteRotation, m_PSpriteScale);

		m_BobAmplitude = new("InterpolatedDouble");
		m_BobAmplitude.m_SmoothTime = m_BobIntensityResponseTime;
		m_BobPlaybackSpeed = new("InterpolatedDouble");
		m_BobPlaybackSpeed.m_SmoothTime = m_BobSpeedResponseTime;

		m_WeaponBobber = new("InterpolatedPSpriteTransform");
		m_WeaponBobber.InterpolatedInit(1.0 / TICRATE);
		m_WeaponBobber.AddTransform(m_PSpritePosition, m_PSpriteRotation, m_PSpriteScale);

		if (m_BobAnimName != 'None') m_BobAnim = BakedCurve.LoadCurve(m_BobAnimName);

		m_StateMachine = SMMachinePlay(new(m_StateMachineType));
		m_StateMachine.m_Data = self;
		m_StateMachine.CallBuild();
		m_StateMachine.Start();

		if (m_HUDExtensionType)
		{
			m_HUDExtension = HUDExtension(new(m_HUDExtensionType));
			m_HUDExtension.Init(self);
		}
	}

	override void Travelled()
	{
		if (!m_InputQueue) m_InputQueue = new("ButtonEventQueue").Init(PlayerPawn(owner));

		if (IsSelected())
		{
			m_StateMachine.SendEvent('TravelledWhileEquipped');
		}
	}

	override bool TryPickup(in out Actor toucher)
	{
		if (!Super.TryPickup(toucher))
		{
			return false;
		}

		m_InputQueue = new("ButtonEventQueue").Init(PlayerPawn(owner));
		return true;
	}

	override void DoEffect()
	{
		m_TicsSinceLastAttack++;

		// Could be cleaner, but it'll take a little refactoring...
		if (IsSelected())
		{
			WeaponLookSway();
			WeaponBob();

			m_StateMachine.Update();
			m_WeaponRecoilSwayer.Update();
			m_WeaponLookSwayer.Update();
			m_WeaponBobber.Update();

			let psp = owner.Player.GetPSprite(PSP_WEAPON);
			if (!psp) return;

			psp.x = m_PSpritePosition.GetX();
			psp.y = m_PSpritePosition.GetY();
			psp.scale = m_PSpriteScale.GetValue();

			ButtonEventQueue queue = GetInputQueue();
			if (!queue) return;

			int buttonEvent, eventType;
			[buttonEvent, eventType] = queue.TryConsumeEvent();

			if (buttonEvent != 0 && eventType != 0)
			{
				TryHandleButtonEvent(buttonEvent, eventType);
			}

			if (m_HUDExtension) m_HUDExtension.CallTick();
		}

		// Monitor actor properties even if not selected to avoid sudden spikes.
		m_PreviousPlayerYaw = owner.Angle;
		m_PreviousPlayerPitch = owner.Pitch;
		m_PreviousPlayerVel = owner.Vel;
	}

	virtual void TryHandleButtonEvent(int event, int eventType) { }

	ButtonEventQueue GetInputQueue() const
	{
		return m_InputQueue;
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

	bool AreButtonsHeld(int buttonFlags)
	{
		return owner.Player.cmd.buttons & buttonFlags;
	}

	int GetTicsSinceLastAttack() const
	{
		return m_TicsSinceLastAttack;
	}

	bool Interval(int time) const
	{
		return level.time % time == 0;
	}

	void ResetTicsSinceLastAttack()
	{
		m_TicsSinceLastAttack = 0;
	}

	void SendEventToSM(name eventId)
	{
		m_StateMachine.SendEvent(eventId);
	}

	void FireBullet(vector2 spread = (4, 4), int damage = -1, double range = -1.0, int ammoCost = -1, int fireType = PrimaryFire)
	{
		FTranslatedLineTarget t;
		double yaw = owner.Angle;
		double pitch = owner.Pitch;

		if (damage < 0) damage = m_Damage;
		if (range <= 0.0) range = m_Range;

		if (CheckShouldAutoAim())
		{
			[yaw, pitch] = GetAutoAimRotation(yaw, pitch, range, t);
		}

		FireBulletInternal(spread, damage, range, yaw, pitch, t);
		DoAttackSideEffects(ammoCost, fireType);
	}

	void FireBullets(int amount = 1, vector2 spread = (4, 4), int damage = -1, double range = -1.0, int ammoCost = -1, int fireType = PrimaryFire)
	{
		if (amount < 1) return;

		FTranslatedLineTarget t;
		double yaw = owner.Angle;
		double pitch = owner.Pitch;

		if (damage < 0) damage = m_Damage;
		if (range <= 0.0) range = m_Range;

		if (CheckShouldAutoAim())
		{
			[yaw, pitch] = GetAutoAimRotation(yaw, pitch, range, t);
		}

		for (int i = 0; i < amount; ++i) FireBulletInternal(spread, damage, range, yaw, pitch, t);
		DoAttackSideEffects(ammoCost, fireType);
	}

	Actor FireProjectile(class<Actor> projectileType, vector2 spread = (4, 4), vector3 spawnOffset = (0, 0, 0), int ammoCost = -1, int fireType = PrimaryFire)
	{
		FTranslatedLineTarget t;
		double yaw = owner.Angle;
		double pitch = owner.Pitch;
		readonly<Actor> projectileDefault = GetDefaultByType(projectileType);

		double autoAimRange = projectileDefault.maxtargetrange > 0.0
			? projectileDefault.maxtargetrange * 64.0
			: 4096.0;

		if (CheckShouldAutoAim())
		{
			[yaw, pitch] = GetAutoAimRotation(yaw, pitch, autoAimRange, t);
		}

		let projectile = FireProjectileInternal(projectileType, spread, spawnOffset, yaw, pitch, t);
		DoAttackSideEffects(ammoCost, fireType);
		return projectile;
	}

	void FireProjectiles(class<Actor> projectileType, int amount = 1, vector2 spread = (4, 4), vector3 spawnOffset = (0, 0, 0), int ammoCost = -1, int fireType = PrimaryFire)
	{
		if (amount < 1) return;

		FTranslatedLineTarget t;
		double yaw = owner.Angle;
		double pitch = owner.Pitch;
		readonly<Actor> projectileDefault = GetDefaultByType(projectileType);

		double autoAimRange = projectileDefault.maxtargetrange > 0.0
			? projectileDefault.maxtargetrange * 64.0
			: 16.0 * 64.0;

		if (CheckShouldAutoAim())
		{
			[yaw, pitch] = GetAutoAimRotation(yaw, pitch, autoAimRange, t);
		}

		for (int i = 0; i < amount; ++i) FireProjectileInternal(projectileType, spread, spawnOffset, yaw, pitch, t);
		DoAttackSideEffects(ammoCost, fireType);
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

	void SetBaseOffset(int x, int y)
	{
		m_PSpritePosition.SetBaseValue((x, y));
	}

	void WeaponRecoil(vector2 offsetForce, vector2 scaleForce = (0.0, 0.0))
	{
		m_WeaponRecoilSwayer.AddForce(offsetForce, scaleForce);
	}

	void HardResetSway()
	{
		m_WeaponRecoilSwayer.HardReset();
		m_WeaponLookSwayer.HardReset();
		m_WeaponBobber.HardReset();

		m_WeaponRecoilSwayer.Update();
		m_WeaponLookSwayer.Update();
		m_WeaponBobber.Update();

		let psp = owner.Player.GetPSprite(PSP_WEAPON);
		if (!psp) return;

		psp.x = m_PSpritePosition.GetX();
		psp.y = m_PSpritePosition.GetY();

		psp.scale = m_PSpriteScale.GetValue();
	}

	void WeaponReadyNoFire(int flags = 0)
	{
		if (!owner.player) return;

		DoReadyWeaponToSwitch(owner.player, !(flags & WRF_NoSwitch));

		if (!(flags & WRF_NoBob)) DoReadyWeaponToBob(owner.player);

		owner.Player.WeaponState |= GetButtonStateFlags(flags);
		DoReadyWeaponDisableSwitch(owner.player, flags & WRF_DisableSwitch);
	}

	action void A_SendEventToSM(name eventId)
	{
		invoker.SendEventToSM(eventId);
	}

	/**
	 * Modified version of A_Raise that notifies the weapon's state machine
	 * instead of setting the PSprite directly.
	 */
	action void A_RaiseSMNotify(int raisespeed = 6)
	{
		let player = player;
		if (!player) return;

		if (player.PendingWeapon != WP_NOCHANGE)
		{
			player.mo.DropWeapon();
			return;
		}
		if (player.ReadyWeapon == null) return;

		let weapon = WeaponBase(invoker);

		weapon.m_PSpritePosition.SetBaseY(weapon.m_PSpritePosition.GetBaseY() - raisespeed);

		if (weapon.m_PSpritePosition.GetBaseY() > WEAPONTOP)
		{
			return;
		}
		weapon.m_PSpritePosition.SetBaseY(WEAPONTOP);

		A_SendEventToSM('AnimComplete');
	}

	/**
	 * Modified version of A_Lower that notifies the weapon's state machine
	 * instead of setting the PSprite directly.
	 */
	action void A_LowerSMNotify(int lowerspeed = 6)
	{
		let player = player;
		if (!player) return;

		let weapon = WeaponBase(invoker);

		if (player.morphTics || player.cheats & CF_INSTANTWEAPSWITCH)
		{
			invoker.m_PSpritePosition.SetBaseY(WEAPONBOTTOM);
		}
		else
		{
			invoker.m_PSpritePosition.SetBaseY(invoker.m_PSpritePosition.GetBaseY() + lowerspeed);
		}
		if (invoker.m_PSpritePosition.GetBaseY() < WEAPONBOTTOM)
		{
			return;
		}

		A_SendEventToSM('AnimComplete');
	}

	action void A_SetBaseOffset(int x, int y)
	{
		invoker.SetBaseOffset(x, y);
	}

	/**
	 * Stripped version of A_WeaponReady that only readies the weapon
	 * for switching and bobbing.
	 */
	action void A_WeaponReadyNoFire(int flags = 0)
	{
		WeaponBase(invoker).WeaponReadyNoFire();
	}

	action void A_WeaponRecoil(vector2 offsetForce, vector2 scaleForce = (0.0, 0.0))
	{
		let weapon = WeaponBase(invoker);
		weapon.WeaponRecoil(offsetForce, scaleForce);
	}

	action void A_SpawnEffect(
		class<Actor> effectType,
		vector3 spawnOffset = (0, 0, 0),
		double yaw = 0.0,
		double pitch = 0.0,
		double velocity = 0.0,
		bool addPawnVelocity = false,
		bool adjustForFov = true,
		bool followPSpriteOffset = true,
		bool directionRelativeToPawn = true)
	{
		let weapon = WeaponBase(invoker);
		weapon.SpawnEffect(effectType, spawnOffset, yaw, pitch, velocity, addPawnVelocity);
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

	// TODO: Use input weight to adjust bobbing.
	private void WeaponBob()
	{
		double normalizedForwardMove = Math.Remap(
			owner.player.mo.GetPlayerInput(MODINPUT_FORWARDMOVE),
				-MAX_FORWARD_MOVE, MAX_FORWARD_MOVE,
				-1.0, 1.0);
		double normalizedSideMove = Math.Remap(
			owner.player.mo.GetPlayerInput(MODINPUT_SIDEMOVE),
				-MAX_SIDE_MOVE, MAX_SIDE_MOVE,
				-1.0, 1.0);

		double moveInputStrength = MathVec2.Clamp((normalizedForwardMove, normalizedSideMove), -1.0, 1.0).Length();

		double previousMovementSpeed = (m_PreviousPlayerVel.x, m_PreviousPlayerVel.y).Length();
		double movementSpeed = (owner.Vel.x, owner.Vel.y).Length();
		double maxSpeed =
			owner.Speed
			* 8.33333333 // ??????? [10/2/2022]: (Pythagorean theorem apparently)
			* owner.Player.mo.ForwardMove1;

		double speedPercentage = movementSpeed / maxSpeed;

		m_BobAmplitude.m_Target = m_BobIntensity * owner.Player.GetMoveBob() * min(1.0, min(moveInputStrength, speedPercentage));

		// Ease out of bob animation when movement input stops.
		if (moveInputStrength ~== 0.0)
		{
			m_BobAmplitude.m_SmoothTime = m_BobIntensityResponseTime * 3.0;
		}
		else
		{
			m_BobAmplitude.m_SmoothTime = previousMovementSpeed < movementSpeed
				? m_BobIntensityResponseTime * 0.7
				: m_BobIntensityResponseTime; // TODO: Make these properties.
		}

		m_BobAmplitude.Update();
		m_BobPlaybackSpeed.m_Target = speedPercentage;
		m_BobPlaybackSpeed.Update();

		m_BobPlayback += 1 * m_BobPlaybackSpeed.GetValue();

		if (m_BobAmplitude.GetValue() < 0.001) m_BobPlayback = 0.0;

		if (!m_BobAnim)
		{
			ProceduralWeaponBob(speedPercentage);
		}
		else
		{
			m_WeaponBobber.SetTargetTranslation(
				(m_BobAnim.Sample(m_BobPlayback % m_BobAnim.GetLength(), 0) * m_BobAmplitude.GetValue(),
				m_BobAnim.Sample(m_BobPlayback % m_BobAnim.GetLength(), 1) * m_BobAmplitude.GetValue()));
		}
	}

	private void ProceduralWeaponBob(double speedPercentage)
	{
		double amplitude = m_BobAmplitude.GetValue() * 4.0;
		double frequency = m_BobSpeed * 0.75;
		m_WeaponBobber.SetTargetTranslation((
			cos(m_BobPlayback * TICRATE * frequency / 2.0) * amplitude * 2.0,
			sin(m_BobPlayback * TICRATE * frequency) * amplitude));
	}

	private void FireBulletInternal(vector2 spread, int damage, double range, double yaw, double pitch, out FTranslatedLineTarget t)
	{
		let pawn = owner.Player.mo;

		if (!pawn) return;

		yaw += (spread.x * Random2() / 255.0);
		pitch += (spread.y * Random2() / 255.0);

		let puff = pawn.LineAttack(yaw, range, pitch, damage, 'Hitscan', "BulletPuff", 0, t);
	}

	private Actor FireProjectileInternal(class<Actor> projectileType, vector2 spread, vector3 spawnOffset, double yaw, double pitch, out FTranslatedLineTarget t)
	{
		readonly<Actor> projectileDefault = GetDefaultByType(projectileType);

		let pawn = owner.Player.mo;

		// Bring to eye level
		let spawnPoint = (0, 0, pawn.Player.viewz - pawn.Pos.z);
		if (pawn.ViewPos) spawnPoint += pawn.ViewPos.Offset;

		// Remap offset coordinates
		vector3 zxyOffset = (spawnOffset.z, -spawnOffset.x, -spawnOffset.y);

		// Rotate offset to view direction
		zxyOffset = MathVec3.Rotate(zxyOffset, Vec3Util.Left(), pawn.Pitch);
		zxyOffset = MathVec3.Rotate(zxyOffset, Vec3Util.Up(), pawn.Angle);

		let position = spawnPoint + zxyOffset;

		yaw += (spread.x * Random2() / 255.0);
		pitch += (spread.y * Random2() / 255.0);

		let projectile = SpawnProjectile(projectileType, (position.x, position.y, position.z), yaw, pitch);

		if (projectile && t.linetarget && !t.unlinked && projectile.bSeekerMissile)
		{
			projectile.tracer = t.linetarget;
		}
		return projectile;
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

	private double, double GetAutoAimRotation(double yaw, double pitch, double targetRange, out FTranslatedLineTarget t) const
	{
		// Ensure full rotations don't throw off angle comparisons.
		yaw = Normalize180(yaw);
		pitch = Normalize180(pitch);

		BlockThingsIterator iterator = BlockThingsIterator.Create(owner, targetRange);
		array<Actor> nonMonsters;

		Actor closestAligned = null;
		double closestAlignment = -1.0;
		bool ignoreNotAutoAimed = CVar.GetCVar('cl_doautoaim').GetBool();
		int smartAimMode = GetCVar('sv_smartaim');

		while (iterator.Next())
		{
			let mo = iterator.thing;

			// Either skip non-monsters or queue for checking after monsters
			// depending on smart aim mode.
			if (!mo.bIsMonster)
			{
				if (smartAimMode == SAIM_ONLYMONSTERS) continue;

				if (smartAimMode != SAIM_OFF)
				{
					nonMonsters.Push(mo);
					continue;
				}
			}

			if (!CheckIfAutoAimable(mo, targetRange, smartAimMode, ignoreNotAutoAimed)) continue;

			// Aim from player view position to target center.
			vector3 originPosition = (owner.Pos.xy, owner.Player.viewz);
			if (owner.ViewPos) originPosition += owner.ViewPos.Offset;
			vector3 targetPosition = (mo.Pos.xy, mo.Pos.z + (mo.Height / 2.0));

			vector3 lookDirection = Vec3Util.FromAngles(yaw, pitch);
			vector3 targetDirection = Vec3Util.Direction(originPosition, targetPosition);

			double alignment = lookDirection dot targetDirection; // Name is incorrect, but meh.

			if (alignment > closestAlignment)
			{
				closestAligned = mo;
				closestAlignment = alignment;
			}
		}

		// All smart aim modes (besides off) handle non-monsters after
		// monsters, if at all.
		if (closestAligned == null)
		{
			for (int i = 0; i < nonMonsters.Size(); ++i)
			{
				let mo = nonMonsters[i];
				if (!CheckIfAutoAimable(mo, targetRange, smartAimMode, ignoreNotAutoAimed)) continue;

				vector3 originPosition = (owner.Pos.xy, owner.Player.viewz);
				if (owner.ViewPos) originPosition += owner.ViewPos.Offset;
				vector3 targetPosition = (mo.Pos.xy, mo.Pos.z + (mo.Height / 2.0));

				vector3 lookDirection = Vec3Util.FromAngles(yaw, pitch);
				vector3 targetDirection = Vec3Util.Direction(originPosition, targetPosition);

				double alignment = lookDirection dot targetDirection;

				if (alignment > closestAlignment)
				{
					closestAligned = mo;
					closestAlignment = alignment;
				}
			}
		}

		if (closestAligned != null)
		{
			//double horizontalAutoAim = m_ForcedHorizontalAutoAim >= 0.0
			//	? m_ForcedHorizontalAutoAim
			//	: CVar.GetCVar('horizontalAutoAim').GetFloat();
			double horizontalAutoAim = m_ForcedHorizontalAutoAim;
			double verticalAutoAim = m_ForcedVerticalAutoAim >= 0.0
				? m_ForcedVerticalAutoAim
				: owner.Player.GetAutoaim();

			// Actor.AngleTo and ActorUtil.PitchTo won't work here because the
			// auto-aim needs the actual position of the player's view.
			vector3 origin = (owner.Pos.xy, owner.Player.viewz);
			if (owner.ViewPos) origin += owner.ViewPos.Offset;
			vector3 target = (closestAligned.Pos.xy, closestAligned.Pos.z + (closestAligned.Height / 2.0));

			double yawToTarget = VectorAngle(target.x - origin.x, target.y - origin.y);
			double pitchToTarget = -VectorAngle((target.xy - origin.xy).Length(), target.z - origin.z);

			// The redundancy is unfortunately needed.
			double yawDiff = abs(abs(yaw) - abs(yawToTarget));
			double pitchDiff = abs(abs(pitch) - abs(pitchToTarget));

			// Check alignment to auto-aim thresholds once the closest-aligned
			// target is found.
			if (yawDiff <= horizontalAutoAim) yaw = yawToTarget;
			if (pitchDiff <= verticalAutoAim && yawDiff <= 6.5) // Ignore actors too far to the sides.
			{
				pitch = pitchToTarget;
			}
		}

		return yaw, pitch;
	}

	private void DoAttackSideEffects(int ammoCost, int fireType)
	{
		ResetTicsSinceLastAttack();
		let pawn = owner.Player.mo;
		if (!bNoAlert) pawn.SoundAlert(pawn, false);

		if (ammoCost == 0) return;
		DepleteAmmo(fireType, true, ammoCost);
	}

	private bool CheckShouldAutoAim() const
	{
		double autoaim = owner.Player.GetAutoaim();
		bool allowAutoaim = GetCVar('sv_autoaim') == 1;
		bool freelook = CVar.GetCVar('freelook', owner.player).GetBool();

		return allowAutoaim && (autoaim > 0.5 && !bNoAutoAim) || (freelook && !level.IsFreelookAllowed());
	}

	private bool CheckIfAutoAimable(Actor mo, double targetRange, int smartAimMode, bool ignoreNotAutoAimed) const
	{
		bool autoAimable;

		autoAimable = mo != owner
			&& mo.bShootable
			&& mo.bSolid
			&& (!mo.bNotAutoAimed || ignoreNotAutoAimed)
			&& owner.Distance2D(mo) <= targetRange
			&& owner.IsVisible(mo, false);

		if (smartAimMode == SAIM_NEVERFRIENDS) autoAimable = autoAimable && !mo.bFriendly;

		return autoAimable;
	}
}

//=================================================//
//                State Definitions                //
//=================================================//

class SMWeaponState : SMStatePlay
{
	WeaponBase GetWeapon() const
	{
		return WeaponBase(GetData());
	}

	PlayerPawn GetPlayerPawn() const
	{
		let weapon = GetWeapon();
		if (!weapon) return null;

		return PlayerPawn(GetWeapon().owner);
	}

	PlayerInfo GetPlayerInfo() const
	{
		let pawn = GetPlayerPawn();
		if (!pawn) return null;

		return GetPlayerPawn().player;
	}

	PSprite GetWeaponSprite() const
	{
		return GetPlayerInfo().GetPSprite(PSP_WEAPON);
	}

	bool IsWeaponSelected() const
	{
		WeaponBase data = GetWeapon();
		return data.IsSelected();
	}

	bool IsWeaponSpriteInState(StateLabel label) const
	{
		let psp = GetPlayerInfo().GetPSprite(PSP_WEAPON);
		return !!psp && psp.curState == GetWeapon().ResolveState(label);
	}

	void SetWeaponSprite(StateLabel label)
	{
		let info = GetPlayerInfo();

		if (!info) return;

		let weapon = GetWeapon();
		info.SetPSprite(PSP_WEAPON, weapon.ResolveState(label));
	}
}

class SMWeaponUnequipped : SMWeaponState
{
	override void EnterState()
	{
		let queue = GetWeapon().GetInputQueue();
		if (queue) queue.StopListening();

		let pawn = GetPlayerPawn();

		if (!pawn || pawn.Player.PendingWeapon == WP_NOCHANGE) return;

		pawn.BringUpWeapon();
	}
}

class SMWeaponSwitchingIn : SMWeaponState
{
	override void EnterState()
	{
		SetWeaponSprite("SwitchingIn");
	}
}

class SMWeaponEquipped : SMWeaponState
{
	ButtonEventQueue queue;

	override void UpdateState()
	{
		// Doing this every frame is a bit redundant, but SkipRaiseAnimWhenTravelling
		// can prevent this from happening on entry (no clue why).
		if (!queue) queue = GetWeapon().GetInputQueue();
		queue.StartListening();
	}
}

class SMWeaponSwitchingOut : SMWeaponState
{
	override void EnterState()
	{
		SetWeaponSprite("SwitchingOut");
	}

	override void ExitState()
	{
		GetWeapon().HardResetSway();
	}
}

class SMWeaponSkipRaiseAnimWhenTravelling : SMWeaponState
{
	override bool TryHandleEvent(name eventId)
	{
		switch (eventId)
		{
			case 'TravelledWhileEquipped':
				let weapon = GetWeapon();

				weapon.m_PSpritePosition.SetBaseY(WEAPONTOP);
				return true;

			default:
				return false;
		}
	}
}

class SMWeaponMachine : SMMachinePlay
{
	override void Build()
	{
		AddChild(new("SMWeaponUnequipped"));
		AddChild(new("SMWeaponSwitchingIn"));
		AddChild(new("SMWeaponEquipped"));
		AddChild(new("SMWeaponSwitchingOut"));

		AddTransition(new("SMTransitionPlay")
			.From("SMWeaponSwitchingIn")
			.To("SMWeaponEquipped")
			.On('AnimComplete')
		);
		AddTransition(new("SMTransitionPlay")
			.To("SMWeaponSwitchingIn")
			.On('WeaponSelected')
		);
		AddTransition(new("SMTransitionPlay")
			.To("SMWeaponSwitchingOut")
			.On('WeaponDeselected')
		);
		AddTransition(new("SMTransitionPlay")
			.From("SMWeaponSwitchingOut")
			.To("SMWeaponUnequipped")
			.On('AnimComplete')
		);
	}

	SMWeaponEquipped GetEquippedState() const
	{
		return SMWeaponEquipped(GetChild("SMWeaponEquipped"));
	}

	SMWeaponUnequipped GetUnequippedState() const
	{
		return SMWeaponUnequipped(GetChild("SMWeaponUnequipped"));
	}

	SMWeaponSwitchingIn GetSwitchingInState() const
	{
		return SMWeaponSwitchingIn(GetChild("SMWeaponSwitchingIn"));
	}

	SMWeaponSwitchingOut GetSwitchingOutState() const
	{
		return SMWeaponSwitchingOut(GetChild("SMWeaponSwitchingOut"));
	}
}

//=================================================//
//                  Miscellaneous                  //
//=================================================//

class WeaponSwayer : InterpolatedPSpriteTransform
{
	private WeaponBase m_Weapon;

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
		Init(smoothTime, translation, rotation, scale);

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

		m_InterpolatedScale.m_Target = MathVec2.SmoothDamp(
			m_InterpolatedScale.m_Target,
			(0.0, 0.0),
			m_TargetScaleSpeed,
			m_TargetSmoothTime,
			double.Infinity,
			1.0 / TICRATE);

		m_Translation.SetValue(m_InterpolatedTranslation.GetValue());
		m_Scale.SetValue(m_InterpolatedScale.GetValue());
	}

	void AddForce(vector2 xyForce, vector2 scaleForce = (0.0, 0.0))
	{
		m_InterpolatedTranslation.m_Target += xyForce;
		m_InterpolatedScale.m_Target += scaleForce;
	}

	void SetForce(vector2 xyForce, vector2 scaleForce = (0.0, 0.0))
	{
		m_InterpolatedTranslation.m_Target = xyForce;
		m_InterpolatedScale.m_Target = scaleForce;
	}
}

class ProjectileBase : Actor
{
	uint m_ProjectileFlags;

	flagdef DrawFromHitboxCenter: m_ProjectileFlags, 0;

	Default
	{
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