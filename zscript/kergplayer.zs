class KergPlayer : PlayerPawn
{
	meta int m_BobStyle;
	property BobStyle : m_BobStyle;

	meta double m_BobXRange;
	property BobXRange : m_BobXRange;

	meta double m_BobYRange;
	property BobYRange : m_BobYRange;

	meta double m_BobRollAmplitude;
	property BobRollAmplitude : m_BobRollAmplitude;

	meta double m_BobTime;
	property BobTime: m_BobTime;

	meta double m_BobAcceleratingResponseTime;
	property BobAcceleratingResponseTime: m_BobAcceleratingResponseTime;
	
	meta double m_BobDeceleratingResponseTime;
	property BobDeceleratingResponseTime: m_BobDeceleratingResponseTime;

	meta double m_ViewTiltDistance;
	property ViewTiltDistance: m_ViewTiltDistance;

	meta double m_ViewTiltResponseTime;
	property ViewTiltResponseTime: m_ViewTiltResponseTime;

	meta double m_FOVAdjustResponseTime;
	property FOVAdjustResponse: m_FOVAdjustResponseTime;

	meta double m_FOVAdjustReturnSpeed;
	property FOVAdjustRigidity: m_FOVAdjustReturnSpeed;

	meta double m_ZoomFactorResponseTime;
	property ZoomResponseTime: m_ZoomFactorResponseTime;

	private InterpolatedVector2 m_ViewTilt;

	private InterpolatedDouble m_FOVAdjust;
	private InterpolatedDouble m_BobInput;
	private InterpolatedDouble m_BobAmplitude;
	private InterpolatedDouble m_ZoomFactor;

	protected InterpolatedDouble m_BobPlaybackSpeed;
	private double m_BobPlayback;
	private double m_BobPlaybackDelta;

	private double m_FOVAdjustTargetSpeed;

	private double m_MaxPlayerVelocity;

	private double m_PrevSpeed;

	Default
	{
		Player.ViewHeight 50.0;
		Player.AttackZOffset 22.0;
		Player.JumpZ 9.5;
		Player.DisplayName "Amerigo";
		Player.StartItem "Colt", 1;
		Player.StartItem "Hatchet", 1;
		Player.StartItem "Ammo45", 48;
		Player.Startitem "RevoCylinder", 6;
		Player.SoundClass "player";
		Player.WeaponSlot 1, "Hatchet";
		Player.WeaponSlot 2, "Colt","Revolver";
		Player.WeaponSlot 3, "Ithaca";
		Player.WeaponSlot 4, "M2C";
		Player.WeaponSlot 5, "Dynamite";
		Player.WeaponSlot 6, "Ishapore";
		Player.CrouchSprite "PLYC";

		KergPlayer.BobXRange 7.0;
		KergPlayer.BobYRange 3.5;
		// KergPlayer.BobXRange 32.0;
		// KergPlayer.BobYRange 16.0;
		KergPlayer.BobRollAmplitude 0.325;
		// KergPlayer.BobRollAmplitude 10.0;
		KergPlayer.BobTime 0.325;
		KergPlayer.BobAcceleratingResponseTime 0.033;
		KergPlayer.BobDeceleratingResponseTime 0.125;
		KergPlayer.BobStyle Bob_Alpha;

		KergPlayer.ViewTiltDistance 12.0;
		KergPlayer.ViewTiltResponseTime 0.165;

		KergPlayer.FOVAdjustResponse 0.045;
		KergPlayer.FOVAdjustRigidity 16.0;

		KergPlayer.ZoomResponseTime 0.08;

		Radius 16.025;
		// Speed 16;
		Speed 2.4;
		// Speed 0.65;
		Friction 0.93;

		Gravity 1.0;
		DamageFactor "Explosive", 0.7;
		+NOSKIN
	}

	override void BeginPlay()
	{
		Super.BeginPlay();

		m_ZoomFactor = new("InterpolatedDouble");
		m_ZoomFactor.m_SmoothTime = m_ZoomFactorResponseTime;
		m_ZoomFactor.ForceSet(1.0);

		m_FOVAdjust = new("InterpolatedDouble");
		m_FOVAdjust.m_SmoothTime = m_FOVAdjustResponseTime;
		m_FOVAdjust.ForceSet(players[consoleplayer].DesiredFOV);

		m_ViewTilt = new("InterpolatedVector2");
		m_ViewTilt.m_SmoothTime = m_ViewTiltResponseTime;

		m_BobAmplitude = new("InterpolatedDouble");
		m_BobAmplitude.m_SmoothTime = m_BobAcceleratingResponseTime;

		m_BobPlaybackSpeed = new("InterpolatedDouble");

		m_BobInput = new("InterpolatedDouble");
		m_BobInput.m_SmoothTime = m_BobAcceleratingResponseTime;

		CalculateMaxPlayerVelocity();
		m_PrevSpeed = Speed;
	}

	override void PlayerThink()
	{
		Super.PlayerThink();
		BobPlayer();

		m_FOVAdjust.m_Target = Math.SmoothDamp(
			m_FOVAdjust.m_Target,
			player.DesiredFOV,
			m_FOVAdjustTargetSpeed,
			1.0 / m_FOVAdjustReturnSpeed,
			double.Infinity,
			1.0 / TICRATE);

		m_ZoomFactor.m_Target = max(0.0001, m_ZoomFactor.m_Target);

		m_FOVAdjust.Update();
		m_ZoomFactor.Update();

		player.FOV = m_FOVAdjust.GetValue() / m_ZoomFactor.GetValue();

		if (Speed != m_PrevSpeed)
		{
			CalculateMaxPlayerVelocity();
			m_PrevSpeed = Speed;
		}
	}

	// Same as vanilla, but without view bobbing.
	override void CalcHeight()
	{
		let player = self.player;
		double angle;
		double bob;
		bool still = false;

		// Regular movement bobbing
		// (needs to be calculated for gun swing even if not on ground)

		// killough 10/98: Make bobbing depend only on player-applied motion.
		//
		// Note: don't reduce bobbing here if on ice: if you reduce bobbing here,
		// it causes bobbing jerkiness when the player moves from ice to non-ice,
		// and vice-versa.

		if (player.cheats & CF_NOCLIP2)
		{
			player.bob = 0;
		}
		else if (bNoGravity && !player.onground)
		{
			player.bob = 0.5;
		}
		else
		{
			player.bob = player.Vel dot player.Vel;
			if (player.bob == 0)
			{
				still = true;
			}
			else
			{
				player.bob *= player.GetMoveBob();

				if (player.bob > MAXBOB)
					player.bob = MAXBOB;
			}
		}

		double defaultviewheight = ViewHeight + player.crouchviewdelta;

		if (player.cheats & CF_NOVELOCITY)
		{
			player.viewz = pos.Z + defaultviewheight;

			if (player.viewz > ceilingz-4)
				player.viewz = ceilingz-4;

			return;
		}

		if (still)
		{
			if (player.health > 0)
			{
				angle = Level.maptime / (120 * TICRATE / 35.) * 360.;
				bob = player.GetStillBob() * sin(angle);
			}
			else
			{
				bob = 0;
			}
		}
		else
		{
			angle = Level.maptime / (20 * TICRATE / 35.) * 360.;
			bob = player.bob * sin(angle) * (waterlevel > 1 ? 0.25f : 0.5f);
		}

		if (player.playerstate == PST_LIVE)
		{
			player.viewheight += player.deltaviewheight;

			if (player.viewheight > defaultviewheight)
			{
				player.viewheight = defaultviewheight;
				player.deltaviewheight = 0;
			}
			else if (player.viewheight < (defaultviewheight/2))
			{
				player.viewheight = defaultviewheight/2;
				if (player.deltaviewheight <= 0)
					player.deltaviewheight = 1 / 65536.;
			}
			
			if (player.deltaviewheight)	
			{
				player.deltaviewheight += 0.25;
				if (!player.deltaviewheight)
					player.deltaviewheight = 1/65536.;
			}
		}

		player.viewz = Pos.z + player.viewheight;

		if (Floorclip && player.playerstate != PST_DEAD
			&& pos.Z <= floorz)
		{
			player.viewz -= Floorclip;
		}
		if (player.viewz > ceilingz - 4)
		{
			player.viewz = ceilingz - 4;
		}
		if (player.viewz < floorz + 4)
		{
			player.viewz = floorz + 4;
		}
	}

	override void MovePlayer()
	{
		UserCmd cmd = player.cmd;

		// [RH] 180-degree turn overrides all other yaws
		if (player.turnticks)
		{
			player.turnticks--;
			Angle += (180. / TURN180_TICKS);
		}
		else
		{
			Angle += cmd.yaw * (360./65536.);
		}

		player.onground = (pos.z <= floorz) || bOnMobj || bMBFBouncer || (player.cheats & CF_NOCLIP2);

		if (cmd.forwardmove | cmd.sidemove)
		{
			vector2 input = GetNormalizedInput();

			input = RotateVector(input, Angle);

			double moveforce = Speed * input.Length();

			if (!player.onground && !bNoGravity && !waterlevel)
			{
				// [RH] allow very limited movement if not on ground.
				moveforce *= level.aircontrol;
			}

			// When crouching, speed and bobbing have to be reduced
			if (CanCrouch() && player.crouchfactor != 1)
			{
				moveforce *= player.crouchfactor;
			}

			Thrust(moveforce, vectorangle(input.x, input.y));
			Bob(vectorangle(input.x, input.y), moveforce, false);

			if (!(player.cheats & CF_PREDICTING) && (moveforce != 0.0))
			{
				PlayRunning();
			}

			if (player.cheats & CF_REVERTPLEASE)
			{
				player.cheats &= ~CF_REVERTPLEASE;
				player.camera = player.mo;
			}
		}
	}

	void SetZoomFactor(double factor)
	{
		m_ZoomFactor.m_Target = factor;
	}

	void AddFOVForce(double force)
	{
		m_FOVAdjust.m_Target += force;
	}

	double GetBobAmplitude() const
	{
		return m_BobAmplitude.GetValue();
	}

	double GetBobPlayback() const
	{
		return m_BobPlayback;
	}

	double GetBobPlaybackDelta() const
	{
		return m_BobPlaybackDelta;
	}

	double GetMaxPlayerVelocity() const
	{
		return m_MaxPlayerVelocity;
	}

	vector2 GetNormalizedInput() const
	{
		UserCmd cmd = player.cmd;

		vector2 input = MathVec2.Clamp((double(cmd.forwardmove) / MAX_FORWARD_MOVE, -double(cmd.sidemove) / MAX_SIDE_MOVE), 0.0, 1.0);

		// Ensure keyboard walking is properly normalized.
		if ((cmd.buttons & BT_FORWARD || cmd.buttons & BT_BACK || cmd.buttons & BT_MOVELEFT || cmd.buttons & BT_MOVERIGHT))
		{
			if (input.Length() != 0.0) input = input.Unit();

			if (!(cmd.buttons & BT_RUN)) input *= 0.5;
		}

		return input;
	}

	private void BobPlayer()
	{
		vector2 input = GetNormalizedInput();

		double inputStrength = input.Length();

		// View bob.

		m_BobInput.m_SmoothTime = (m_BobInput.GetValue() <= inputStrength
			? m_BobAcceleratingResponseTime
			: m_BobDeceleratingResponseTime);

		m_BobInput.m_Target = player.onground ? inputStrength : 0.0;
		m_BobInput.Update();

		m_BobAmplitude.m_Target = min(m_BobInput.GetValue(), player.Vel.Length() / m_MaxPlayerVelocity);
		m_BobAmplitude.m_SmoothTime = m_BobInput.m_SmoothTime;
		m_BobAmplitude.Update();
	
		m_BobPlaybackSpeed.m_Target = m_BobAmplitude.m_Target;
		m_BobPlaybackSpeed.m_SmoothTime = m_BobInput.m_SmoothTime;
		m_BobPlaybackSpeed.Update();

		m_BobPlaybackDelta = m_BobPlaybackSpeed.GetValue();
		m_BobPlayback += m_BobPlaybackDelta;

		if (m_BobPlaybackDelta ~== 0.0) m_BobPlayback = 0.0;

		vector2 viewBob;
		double roll;
		[viewBob, roll] = ProceduralViewBob();

		// View tilt.

		m_ViewTilt.m_Target = input * m_ViewTiltDistance * min(inputStrength, player.Vel.Length() / m_MaxPlayerVelocity);
		m_ViewTilt.Update();

		vector3 viewTilt = (m_ViewTilt.GetValue(), 0.0);

		// Rotate view tilt to negate pitch.
		viewTilt = MathVec3.Rotate(viewTilt, Vec3Util.Left(), -Pitch);

		// Combined view offset.

		vector3 offset;

		offset.x = viewTilt.x;
		offset.y = viewBob.x + viewTilt.y;
		offset.z = viewBob.y + viewTilt.z;

		// View stabilization.

		vector3 lookTarget = (4000.0, 0.0, 0.0);
		vector3 lookVector = level.Vec3Diff(offset, lookTarget);
		vector2 angles = MathVec3.ToYawAndPitch(lookVector);

		SetViewPos(offset);
		A_SetViewAngle(angles.x, SPF_INTERPOLATE);
		A_SetViewPitch(angles.y, SPF_INTERPOLATE);
		A_SetViewRoll(roll, SPF_INTERPOLATE);
	}

	private vector2, double ProceduralViewBob()
	{
		double xRange = m_BobXRange * m_BobAmplitude.GetValue();
		double yRange = m_BobYRange * m_BobAmplitude.GetValue();

		double a = m_BobPlayback / TICRATE * 360.0 * (1.0 / (m_BobTime * 2.0));

		vector2 viewBob;

		switch (m_BobStyle)
		{
			case Bob_Normal:
				viewBob = (
					xRange * cos(a),
					yRange * abs(sin(a)));
					break;

			case Bob_Inverse:
				viewBob = (
					xRange * cos(a),
					yRange * (1.0 - abs(sin(a))));
					break;

			case Bob_Alpha:
				viewBob = (
					xRange * sin(a),
					yRange * abs(sin(a)));
					break;

			case Bob_InverseAlpha:
				viewBob = (
					xRange * sin(a),
					yRange * (1.0 - abs(sin(a))));
					break;

			case Bob_Smooth:
				viewBob = (
					xRange * cos(a),
					0.5 * (yRange * (1.0 - cos(a * 2.0))));
					break;

			case Bob_InverseSmooth:
				viewBob = (
					xRange * cos(a),
					0.5 * (yRange * (1.0 + cos(a * 2.0))));
					break;

			case Bob_FigureEight:
			default:
				viewBob = (
					xRange * sin(a),
					yRange * cos(a * 2.0));
					break;

			case Bob_Snap:
				viewBob = (
					m_BobXRange * Math.Sign(sin(a)),
					m_BobYRange * Math.Sign(cos(a * 2.0)));
					break;
		}

		double roll = -a;
		double rollAmplitude = m_BobRollAmplitude * m_BobAmplitude.GetValue();

		if (m_BobStyle == Bob_Alpha || m_BobStyle == Bob_InverseAlpha)
		{
			roll = sin(roll);
		}
		else if (m_BobStyle == Bob_Snap)
		{
			roll = Math.Sign(sin(roll));
			rollAmplitude = m_BobRollAmplitude;
		}
		else
		{
			roll = cos(roll);
		}

		roll *= rollAmplitude;

		return viewBob, roll;
	}

	private void CalculateMaxPlayerVelocity()
	{
		vector2 velocity = AngleToVector(90, Speed);
		for (int i = 0; i < 800; ++i)
		{
			velocity.x *= ORIG_FRICTION;
			velocity.y *= ORIG_FRICTION;
			velocity += AngleToVector(90, Speed);
		}

		m_MaxPlayerVelocity = velocity.Length();
	}

	States
	{
	Spawn:
		PLAY A -1;
		Loop;

	See:
		PLAY A 6;
		PLAY B 6;
		PLAY C 6;
		PLAY D 6;
		Goto Spawn;

	Melee:
		PLAY E 2;
		PLAY F 6 Bright;
		PLAY E 2;
		Goto Spawn;

	Missile:
		PLAY E 4;
		PLAY E 4;
		Goto Spawn;

	Pain:
		PLAY G 4;
		PLAY G 4 A_Pain;
		Goto Spawn;

	Death:
		TNT1 A 0 A_StopSound(1);
		PLAD A 3 A_PlayerScream;
		PLAD B 3;
		PLAD C 3 A_NoBlocking;
		PLAD D 3;
		PLAD E 3;
		PLAD E -1;
		Stop;
	}
}


