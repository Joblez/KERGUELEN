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

	override void SpawnWeatherParticle()
	{
		Super.SpawnWeatherParticle();

		// Spawn additional fake splashes outside of weather range.

		Actor pawn = players[consoleplayer].mo;

		// Spawn from max real splash range up to three times as far depending on FOV,
		// with higher odds depending on weather amount setting.
		double minRange = GetAdjustedRange() ** 2;
		double maxRange = minRange * Math.Remap(players[consoleplayer].FOV, 10, 120, 3.0, 1.0);

		vector2 position = pawn.Pos.xy;
		vector2 point = m_Triangulation.GetRandomPoint();;
		double distance = MathVec2.SquareDistanceBetween(point, position);;

		if (distance < minRange || distance >= maxRange) return;

		if (FRandom(0.0, 1.0) < 1.0 - GetFakeSplashChance()) return;

		vector3 spawnPosition = (point, m_Sector.NextLowestFloorAt(point.x, point.y, m_Sector.HighestCeilingAt(point)));

		double spawnScore = FRandom(0.0, 1.0);
		double spawnThreshold = Math.Remap(distance, minRange, maxRange, 0.5, 1.0);

		bool isOutOfView = Actor.absangle(pawn.Angle, vectorangle(point.x - pawn.Pos.x, point.y - pawn.Pos.y))
			>= players[consoleplayer].FOV * 0.5 * ScreenUtil.GetAspectRatio();
		
		// Fake splashes appear instantly, cull everything out of view.
		if (isOutOfView || spawnScore < spawnThreshold) return;

		if (m_Sector.GetFloorTerrain(Sector.floor).IsLiquid)
		{
			// Particles cannot be flat, fall back to actor.
			WaterRipple ripple = WaterRipple(Actor.Spawn("WaterRipple", spawnPosition));
			return;
		}
		else
		{
			// Spawn splash texture.

			FSpawnParticleParams params;

			params.color1 = 0xFFFFFFFF;
			params.texture = m_MainSplashTexture;
			params.style = STYLE_Add;
			params.flags = SPF_REPLACE;
			params.lifetime = 4;
			params.size = 10.0;
			params.pos = spawnPosition + (0.0, 0.0, 1.75);
			params.startalpha = 0.7;

			Level.SpawnParticle(params);
		}
	}

	override void ParticleEndOfLifeCallback(WeatherParticleCallbackData data)
	{
		Actor pawn = players[consoleplayer].mo;

		double distance = MathVec3.SquareDistanceBetween(data.m_EndPosition, pawn.Pos);
		double range = GetAdjustedRange();

		double spawnScore = FRandom(0.0, 1.0);
		double spawnThreshold = Math.Remap(distance, 0.0, range, 0.0, 0.5);

		bool isOutOfView = Actor.absangle(pawn.Angle, vectorangle(data.m_EndPosition.x - pawn.Pos.x, data.m_EndPosition.y - pawn.Pos.y))
			>= players[consoleplayer].FOV * 0.5 * ScreenUtil.GetAspectRatio();
		
		if (isOutOfView) spawnThreshold += GetOutOfViewFrequencyReduction();

		if (spawnScore >= spawnThreshold) return;

		// Spawn ripple effect when rain hits water.
		if (data.m_Sector.GetFloorTerrain(Sector.floor).IsLiquid)
		{
			// Particles cannot be flat, fall back to actor.
			WaterRipple ripple = WaterRipple(Actor.Spawn("WaterRipple", data.m_EndPosition));
			return;
		}
		else
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

		double splashParticleRange = GetSplashParticleDrawDistance() ** 2;

		// Don't spawn splash particles out of view or too far away.
		if (isOutOfView || distance > splashParticleRange) return;

		int splashParticleSetting = GetSplashParticlesCVar().GetInt();

		// Don't spawn if splash particles disabled.
		if (splashParticleSetting <= 0) return;

		if (splashParticleSetting == 6) // Extra detail for Ultra
		{
			FSpawnParticleParams params;

			params.color1 = 0xFFFFFFFF;
			params.style = STYLE_Normal;
			params.lifetime = 14;
			params.sizestep = -0.2;
			params.pos = data.m_EndPosition + (0.0, 0.0, 1.0);
			params.accel = (0.0, 0.0, -0.15);
			params.startalpha = 1.0;

			// Attenuate amount over distance.
			int amount = int(round(Math.Remap(distance, 0.0, splashParticleRange, 5.0, 0.0)));

			for (int i = 0; i < amount; ++i)
			{
				params.size = FRandom(2.5, 3.0);
				params.vel = MathVec3.Rotate(Vec3Util.Random(2.0, 4.5, 0.0, 0.0, 0.275, 1.55), Vec3Util.Up(), FRandom(0.0, 360.0));
				Level.SpawnParticle(params);
			}
		}

		FSpawnParticleParams params;

		params.color1 = 0xFFFFFFFF;
		params.style = STYLE_Normal;
		params.lifetime = 16;
		params.sizestep = -0.4;
		params.pos = data.m_EndPosition + (0.0, 0.0, 2.0);
		params.accel = (0.0, 0.0, -0.25);
		params.startalpha = 1.0;

		// Attenuate amount over distance.
		int amount = int(round(Math.Remap(distance, 0.0, splashParticleRange, splashParticleSetting, 0.0)));

		for (int i = 0; i < Random(amount - 3, amount); ++i)
		{
			params.size = FRandom(3.0, 6.0);
			params.vel = MathVec3.Rotate(Vec3Util.Random(0.75, 2.25, 0.0, 0.0, 0.5, 2.5), Vec3Util.Up(), FRandom(0.0, 360.0));
			Level.SpawnParticle(params);
		}
	}

	double GetFakeSplashChance() const
	{
		int setting = GetWeatherAmountCVar().GetInt();

		return max(0.0, setting * 0.2 - 0.2);
	}

	double GetSplashParticleDrawDistance() const
	{
		int setting = GetSplashParticlesCVar().GetInt();
		if (setting == 0) return 0.0;

		// Scale with FOV to avoid awkward cutoff at low values (e.g. sniper zoom).
		return 86 * setting + 256 * Math.Remap(players[consoleplayer].FOV, 10, 120, 12.0, 1.0);
	}
	
	CVar GetSplashParticlesCVar()
	{
		if (!m_SplashParticlesCVar) m_SplashParticlesCVar = CVar.GetCVar("splash_particles");
		return m_SplashParticlesCVar;
	}
}