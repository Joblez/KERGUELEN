class RainSpawner : WeatherParticleSpawner
{
	private transient CVar m_SplashParticlesCVar;
	private TextureID m_MainSplashTexture;

	static RainSpawner Create(
		double density,
		double range,
		Sector sec,
		WeatherAgent agent,
		color particleColor = 0xFFFFFFFF,
		int particleRenderStyle = STYLE_Add,
		int particleFlags = SPF_NO_XY_BILLBOARD,
		string particleTextureName = "RAINA0",
		int particleLifetime = 35,
		double particleSize = 28.0,
		double particleSizeDeviation = 2.0,
		vector3 initialParticleVelocity = (0.0, 0.0, -42.0),
		vector3 initialParticleVelocityDeviation = (0.0, 0.0, 2.0),
		vector3 particleAcceleration = (0.0, 0.0, 0.0),
		vector3 particleAccelerationDeviation = (0.0, 0.0, 0.0),
		double particleAlpha = 0.5,
		double particleFadeStep = 0.0,
		double projectionTime = 1.0,
		bool shouldSimulateParticles = true,
		bool enableEndOfLifeCallbacks = true)
	{
		RainSpawner spawner = new("RainSpawner");

		spawner.Init(
			density,
			range,
			sec,
			agent,
			particleColor,
			particleRenderStyle,
			particleFlags,
			particleTextureName,
			particleLifetime,
			particleSize,
			particleSizeDeviation,
			initialParticleVelocity,
			initialParticleVelocityDeviation,
			particleAcceleration,
			particleAccelerationDeviation,
			particleAlpha,
			particleFadeStep,
			projectionTime,
			shouldSimulateParticles,
			enableEndOfLifeCallbacks);

			spawner.m_SplashParticlesCVar = CVar.GetCVar("splash_particles");
			spawner.m_MainSplashTexture = TexMan.CheckForTexture("RSPLSH1");

		return spawner;
	}

	override void ParticleEndOfLifeCallback(WeatherParticleCallbackData data)
	{
		vector3 oldPosition = m_WeatherAgent.Pos;

		Actor pawn = players[consoleplayer].mo;

		bool isOutOfView = Actor.absangle(pawn.Angle, vectorangle(data.m_EndPosition.x - pawn.Pos.x, data.m_EndPosition.y - pawn.Pos.y))
			>= players[consoleplayer].FOV * 0.5 * ScreenUtil.GetAspectRatio();

		double distance = MathVec3.SquareDistanceBetween(data.m_EndPosition, pawn.Pos);
		double mainSplashRange = GetSplashTextureDrawDistance() ** 2 * (isOutOfView ? 0.5 : 1.0);

		// Cull splash texture by distance.
		// Do not entirely cull splash textures out of view in case player turns suddenly.
		if (distance > mainSplashRange) return;

		double spawnScore = FRandom(0.0, 1.0);
		double spawnThreshold = GetOutOfViewFrequencyReduction();

		// Spawn ripple effect when rain hits water.
		if (data.m_Sector.GetFloorTerrain(Sector.floor).IsLiquid)
		{
			// Particles cannot be flat, fall back to actor.
			if (!isOutOfView || spawnScore >= spawnThreshold) WaterRipple ripple = WaterRipple(Actor.Spawn("WaterRipple", data.m_EndPosition));
			return;
		}
		else if (!isOutOfView || spawnScore >= spawnThreshold * 2) // Splash textures are less prominent than ripple textures, cull more aggressively.
		{
			
		}
		else // Not on water and below splash threshold, do nothing.
		{
			return;
		}

		// Don't spawn splash particles out of view or too far away.
		if (isOutOfView || distance > GetSplashParticleDrawDistance() ** 2) return;

		if (!m_SplashParticlesCVar) m_SplashParticlesCVar = CVar.GetCVar("splash_particles");

		int splashParticleSetting = m_SplashParticlesCVar.GetInt();

		// Don't spawn if splash particles disabled.
		if (splashParticleSetting <= 0) return;

		if (splashParticleSetting == 6) // Extra detail for Ultra
		{
			for (int i = 0; i < 6; ++i)
			{
					m_WeatherAgent.A_SpawnParticle(
						0xFFFFFFFF,
						SPF_RELVEL,
						lifetime: 22,
						size: FRandom(2.0, 2.5),
						angle: FRandom(0.0, 360.0),
						zoff: 1.0,
						velx: FRandom(2.0, 4.0),
						velz: FRandom(0.25, 1.5),
						accelz: -0.25,
						fadestepf: 0,
						sizestep: -0.15);
			}
		}

		for (int i = 0; i < Random(splashParticleSetting, splashParticleSetting + 2); ++i)
		{
				m_WeatherAgent.A_SpawnParticle(
					0xFFFFFFFF,
					SPF_RELVEL | SPF_REPLACE,
					lifetime: 22,
					size: FRandom(2.5, 6.0),
					angle: FRandom(0.0, 360.0),
					zoff: 2.0,
					velx: FRandom(0.75, 2.25),
					velz: FRandom(0.5, 2.5),
					accelz: -0.25,
					fadestepf: 0,
					sizestep: -0.5);
		}
	}

	double GetSplashTextureDrawDistance() const
	{
		int setting = m_WeatherAmountCVar.GetInt();
		if (setting == 0) return 0.0;

		// Scale with FOV to avoid awkward cutoff at low values (e.g. sniper zoom).
		return 256 * setting + 256 * Math.Remap(players[consoleplayer].FOV, 10, 120, 10.0, 1.0);
	}

	double GetSplashParticleDrawDistance() const
	{
		int setting = m_SplashParticlesCVar.GetInt();
		if (setting == 0) return 0.0;

		// Scale with FOV to avoid awkward cutoff at low values (e.g. sniper zoom).
		return 96 * setting + 256 * Math.Remap(players[consoleplayer].FOV, 10, 120, 12.0, 1.0);
	}
}