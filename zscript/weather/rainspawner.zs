class RainSpawner : WeatherParticleSpawner
{
	private CVar m_SplashParticlesCVar;
	private TextureID m_MainSplashTexture;

	static WeatherParticleSpawner Create(
		double density,
		double range,
		Sector sec,
		WeatherAgent agent,
		color particleColor = 0xFFFFFFFF,
		int particleRenderStyle = STYLE_Add,
		int particleFlags = SPF_NO_XY_BILLBOARD,
		string particleTextureName = "RAINA0",
		int particleLifetime = 35,
		double particleSize = 20.0,
		double particleSizeDeviation = 2.0,
		vector3 initialParticleVelocity = (0.0, 0.0, -42.0),
		vector3 initialParticleVelocityDeviation = (0.0, 0.0, 2.0),
		vector3 particleAcceleration = (0.0, 0.0, 0.0),
		vector3 particleAccelerationDeviation = (0.0, 0.0, 0.0),
		double particleAlpha = 0.6,
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
		m_WeatherAgent.SetXYZ(data.m_EndPosition);

		// Spawn ripple effect when rain hits water.
		if (data.m_Sector.GetFloorTerrain(Sector.floor).IsLiquid)
		{
			// Particles cannot be flat, fall back to actor.
			WaterRipple ripple = WaterRipple(Actor.Spawn("WaterRipple", data.m_EndPosition));
			return;
		}
		else // Spawn splash texture.
		{
			m_WeatherAgent.A_SpawnParticleEx(
				0xFFFFFFFF,
				m_MainSplashTexture,
				STYLE_Add,
				0,
				4,
				10.0,
				0.0,
				0.0, 0.0, 1.75,
				0.0, 0.0, 0.0,
				0.0, 0.0, 0.0,
				0.7,
				0.0,
				0.0);
		}

		int splashParticleSetting = m_SplashParticlesCVar.GetInt();

		if (splashParticleSetting <= 0)
		{
			m_WeatherAgent.SetXYZ(oldPosition);
			return;
		}
		
		if (m_WeatherAgent.Distance3DSquared(players[consoleplayer].mo) <= GetSplashParticleDrawDistance() ** 2)
		{
			if (splashParticleSetting == 6) // Extra detail for Ultra
			{
				for (int i = 0; i < Random(6, 9); ++i)
				{
					m_WeatherAgent.A_SpawnParticle(
						0xFFFFFFFF,
						SPF_RELVEL,
						lifetime: 22,
						size: FRandom(1.5, 2.5),
						angle: FRandom(0.0, 360.0),
						zoff: 1.0,
						velx: FRandom(1.5, 4.0),
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
					SPF_RELVEL,
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

		m_WeatherAgent.SetXYZ(oldPosition);
	}

	double GetSplashParticleDrawDistance() const
	{
		int setting = m_SplashParticlesCVar.GetInt();
		if (setting == 0) return 0.0;
		return 128 * setting + 128;
	}
}