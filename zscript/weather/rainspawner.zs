class RainSpawner : WeatherParticleSpawner
{
	private transient CVar m_SplashParticlesCVar;
	private TextureID m_MainSplashTexture;

	static RainSpawner Create(
		double density,
		double range,
		Sector sec,
		WeatherAgent agent,
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
		params.size = 56.0;
		params.vel = (0.0, 0.0, -62.0);
		params.accel = (0.0, 0.0, 0.0);
		params.startalpha = 0.525;

		spawner.Init(
			density,
			range,
			sec,
			agent,
			params,
			sizeDeviation: 2.0,
			velDeviation: (0.0, 0.0, 2.0),
			shouldSimulateParticles: shouldSimulateParticles,
			enableEndOfLifeCallbacks: enableEndOfLifeCallbacks);

		spawner.m_SplashParticlesCVar = CVar.GetCVar("splash_particles");
		spawner.m_MainSplashTexture = TexMan.CheckForTexture("RSPLSH1");

		return spawner;
	}

	override void SpawnWeatherParticle()
	{
		Super.SpawnWeatherParticle();

		// Spawn additional fake splashes outside of weather range.
		SpawnFakeSplash();
	}

	// Nearly identical to super method, but need to plug in the scaling logic somewhere.
	override void ReconstructWeatherState()
	{
		for (int i = m_SimulationData.Size() - 1; i >= 0; --i)
		{
			FSpawnParticleParams params;

			params.color1 = m_Color;
			params.texture = m_Texture;
			params.style = m_Style;
			params.flags = m_Flags;

			Actor pawn = players[consoleplayer].mo;

			// Determine current state.
			int time = m_SimulationData[i].GetCurrentTime();
			params.lifetime = m_SimulationData[i].GetLifetime() - time;
			params.pos = m_SimulationData[i].GetPositionAt(time);
			params.vel = m_SimulationData[i].GetVelocityAt(time);
			params.accel = m_SimulationData[i].GetAcceleration();
			params.size = m_SimulationData[i].GetSizeAt(time);
			params.sizestep = m_SimulationData[i].GetSizeStep();
			params.startalpha = m_SimulationData[i].GetAlphaAt(time);
			params.fadestep = m_SimulationData[i].GetFadeStep();
			params.startroll = m_SimulationData[i].GetRollAt(time);
			params.rollvel = m_SimulationData[i].GetRollVelocityAt(time);
			params.rollacc = m_SimulationData[i].GetRollAcceleration();

			// Apply distant rain scaling.
			double distance = MathVec2.SquareDistanceBetween(params.pos.xy, pawn.Pos.xy);
			params.size *= Math.Remap(distance, 0.0, 4000.0 ** 2, 1.0, 1.5);

			// Spawn with reconstructed state.
			level.SpawnParticle(params);
		}
	}

	override void ParticleEndOfLifeCallback(WeatherParticleSimulation data)
	{
		Actor pawn = players[consoleplayer].mo;

		double distance = MathVec3.SquareDistanceBetween(data.GetEndPosition(), pawn.Pos);
		double range = m_Range;

		// Attenuate spawn chance over distance.
		double spawnScore = FRandom(0.0, 1.0);
		double spawnThreshold = Math.Remap(distance, 0.0, range, 0.0, 0.5);

		vector3 endPosition = data.GetEndPosition();
		bool isOutOfView = Actor.absangle(pawn.Angle, vectorangle(endPosition.x - pawn.Pos.x, endPosition.y - pawn.Pos.y))
			>= players[consoleplayer].FOV * 0.5 * ScreenUtil.GetAspectRatio();

		if (isOutOfView || spawnScore >= spawnThreshold) return;

		SpawnSplashEffect(data.GetEndPosition(), data.GetEndSector());

		double splashParticleRange = GetSplashParticleDrawDistance() ** 2;

		// Don't spawn splash particles too far away.
		if (distance > splashParticleRange) return;

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
			params.pos = data.GetEndPosition() + (0.0, 0.0, 1.0);
			params.accel = (0.0, 0.0, -0.15);
			params.startalpha = 1.0;

			// Attenuate amount over distance.
			int amount = int(round(Math.Remap(distance, 0.0, splashParticleRange, 5.0, 0.0)));

			for (int i = 0; i < amount; ++i)
			{
				params.size = FRandom(2.5, 3.0);
				params.vel = MathVec3.Rotate(Vec3Util.Random(2.0, 4.5, 0.0, 0.0, 0.275, 1.55), Vec3Util.Up(), FRandom(0.0, 360.0));
				level.SpawnParticle(params);
			}
		}

		FSpawnParticleParams params;

		params.color1 = 0xFFFFFFFF;
		params.style = STYLE_Normal;
		params.lifetime = 16;
		params.sizestep = -0.4;
		params.pos = data.GetEndPosition() + (0.0, 0.0, 2.0);
		params.accel = (0.0, 0.0, -0.25);
		params.startalpha = 1.0;

		// Attenuate amount over distance.
		int amount = int(round(Math.Remap(distance, 0.0, splashParticleRange, splashParticleSetting, 0.0)));

		for (int i = 0; i < Random(amount - 2, amount); ++i)
		{
			params.size = FRandom(3.0, 6.0);
			params.vel = MathVec3.Rotate(Vec3Util.Random(0.75, 2.25, 0.0, 0.0, 0.5, 2.5), Vec3Util.Up(), FRandom(0.0, 360.0));
			level.SpawnParticle(params);
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
		return 256 + 86 * setting * Math.Remap(players[consoleplayer].FOV, 10, 120, 12.0, 1.0);
	}
	
	CVar GetSplashParticlesCVar()
	{
		if (!m_SplashParticlesCVar) m_SplashParticlesCVar = CVar.GetCVar("splash_particles", players[consoleplayer]);
		return m_SplashParticlesCVar;
	}

	private void SpawnSplashEffect(vector3 spawnPosition, Sector sec) const
	{
		// Spawn ripple effect when rain hits liquids.
		if (sec.GetFloorTerrain(Sector.floor).IsLiquid)
		{
			// Particles cannot be flat, fall back to actor.
			Actor.Spawn("WaterRipple", spawnPosition);
			return;
		}
		else // Spawn splash effect.
		{
			FSpawnParticleParams params;

			params.color1 = 0xFFFFFFFF;
			params.texture = m_MainSplashTexture;
			params.style = STYLE_Add;
			params.flags = SPF_REPLACE;
			params.lifetime = 4;
			params.size = 10.0;
			params.pos = spawnPosition + (0.0, 0.0, 1.75);
			params.startalpha = 0.4;

			level.SpawnParticle(params);
		}
	}

	private void SpawnFakeSplash() const
	{
		Actor pawn = players[consoleplayer].mo;

		// Spawn from max real splash range up to four times as far depending on FOV.
		double minRange = m_Range ** 2.0;
		double maxRange = minRange * Math.Remap(players[consoleplayer].FOV, 10, 120, 4.0, 1.0);

		vector2 position = pawn.Pos.xy;
		vector2 point = m_Triangulation.GetRandomPoint();
		double distance = MathVec2.SquareDistanceBetween(point, position);

		// Cull if outside desired range.
		if (distance < minRange || distance >= maxRange) return;

		// Fake splashes are more likely to appear at higher weather settings.
		if (FRandom(0.0, 1.0) < 1.0 - GetFakeSplashChance()) return;

		// Could use a line trace to ensure this handles 3D floors correctly, but it's
		// too rare an edge case for an effect like this.
		vector3 spawnPosition = (point, m_Sector.NextLowestFloorAt(point.x, point.y, m_Sector.HighestCeilingAt(point)));

		// Attenuate spawn chance over distance.
		double spawnScore = FRandom(0.0, 1.0);
		double spawnThreshold = Math.Remap(distance, minRange, maxRange, 0.5, 0.9);

		bool isOutOfView = Actor.absangle(pawn.Angle, vectorangle(point.x - pawn.Pos.x, point.y - pawn.Pos.y))
			>= players[consoleplayer].FOV * 0.5 * 1.77777777778 /* ScreenUtil.GetAspectRatio() */;
		
		// Fake splashes appear instantly, cull everything out of view.
		if (isOutOfView || spawnScore < spawnThreshold) return;

		SpawnSplashEffect(spawnPosition, m_Sector);
	}
}