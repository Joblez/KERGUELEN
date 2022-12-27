class RainSpawner : WeatherParticleSpawner
{
	private transient CVar m_SplashParticlesCVar;
	private TextureID m_MainSplashTexture;

	static RainSpawner Create(
		double density,
		double range,
		Sector sec,
		WeatherAgent agent,
		double projectionTime = 1.0,
		bool shouldSimulateParticles = true,
		bool enableEndOfLifeCallbacks = true)
	{
		RainSpawner spawner = new("RainSpawner");

		FSpawnParticleParams params;
		params.color1 = 0xFFFFFFFF;
		params.texture = TexMan.CheckForTexture("RAINA0");
		params.style = STYLE_Add;
		params.flags = SPF_NO_XY_BILLBOARD | SPF_RELVEL;
		params.lifetime = 35;
		params.size = 28.0 + FRandom(-2.0, 2.0);
		params.vel = (0.0, 0.0, -42.0 + FRandom(-2.0, 2.0));
		params.startalpha = 0.5;

		spawner.Init(
			density,
			range,
			sec,
			agent,
			params,
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
			// Spawn splash texture.

			FSpawnParticleParams params;

			params.color1 = 0xFFFFFFFF;
			params.texture = m_MainSplashTexture;
			params.style = STYLE_Add;
			params.flags = SPF_REPLACE;
			params.lifetime = 4;
			params.size = 10.0;
			params.pos = data.m_EndPosition + (0.0, 0.0, 1.75);
			params.startalpha = 0.7;

			Level.SpawnParticle(params);
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
			FSpawnParticleParams params;

			params.color1 = 0xFFFFFFFF;
			params.style = STYLE_Normal;
			params.lifetime = 22;
			params.sizestep = -0.15;
			params.pos = data.m_EndPosition + (0.0, 0.0, 1.0);
			params.accel = (0.0, 0.0, -0.15);
			params.startalpha = 1.0;

			for (int i = 0; i < 6; ++i)
			{
				params.size = FRandom(2.0, 2.5);
				params.vel = MathVec3.Rotate(Vec3Util.Random(2.0, 4.0, 0.0, 0.0, 0.25, 1.5), Vec3Util.Up(), FRandom(0.0, 360.0));
				Level.SpawnParticle(params);
			}
		}

		FSpawnParticleParams params;

		params.color1 = 0xFFFFFFFF;
		params.style = STYLE_Normal;
		params.lifetime = 22;
		params.sizestep = -0.5;
		params.pos = data.m_EndPosition + (0.0, 0.0, 2.0);
		params.accel = (0.0, 0.0, -0.25);
		params.startalpha = 1.0;

		for (int i = 0; i < Random(splashParticleSetting, splashParticleSetting + 2); ++i)
		{
			params.size = FRandom(2.5, 6.0);
			params.vel = MathVec3.Rotate(Vec3Util.Random(0.75, 2.25, 0.0, 0.0, 0.5, 2.5), Vec3Util.Up(), FRandom(0.0, 360.0));
			Level.SpawnParticle(params);
		}

		m_WeatherAgent.SetXYZ(oldPosition);
	}

	double GetSplashTextureDrawDistance() const
	{
		int setting = m_WeatherAmountCVar.GetInt();
		if (setting == 0) return 0.0;

		// Scale with FOV to avoid awkward cutoff at low values (e.g. sniper zoom).
		return 384 * setting + 256 * Math.Remap(players[consoleplayer].FOV, 10, 120, 10.0, 1.0);
	}

	double GetSplashParticleDrawDistance() const
	{
		int setting = m_SplashParticlesCVar.GetInt();
		if (setting == 0) return 0.0;

		// Scale with FOV to avoid awkward cutoff at low values (e.g. sniper zoom).
		return 96 * setting + 256 * Math.Remap(players[consoleplayer].FOV, 10, 120, 12.0, 1.0);
	}
}