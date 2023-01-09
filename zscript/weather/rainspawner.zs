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

		spawner.m_SplashParticlesCVar = CVar.GetCVar('splash_particles');
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
		vector3 endPosition = data.GetEndPosition();
		PlayerInfo spawnPlayer = null;
		double distance;

		// Check if any player meets splash effect criteria.
		// NOTE: Earlier players in the list take priority. Unfortunate but preferrable to
		// the host player having configuration authority. Could be fixed if particle spawns
		// could be made client-side only.
		foreach (player : players)
		{
			if (!player.mo) continue;

			distance = MathVec3.SquareDistanceBetween(endPosition, player.mo.Pos);
			double range = m_Range ** 2;

			// Attenuate spawn chance over distance.
			double spawnScore = FRandom[Weather](0.0, 1.0);

			// Gradually cull up to 50% of splashes along the radius.
			double spawnThreshold = Math.Remap(distance, 0.0, range, 0.0, 0.5);

			// Cull 70% of splash effects out of view.
			if (IsOutOfView(player, endPosition.xy) && spawnScore < 0.7) continue;

			if (spawnScore < spawnThreshold) continue;
			
			// All criteria met, splash should spawn for this player.
			spawnPlayer = player;
			break;
		}

		// No suitable player found, spawn nothing.
		if (!spawnPlayer) return;

		SpawnSplashEffect(endPosition, data.GetEndSector());

		int splashParticleSetting = CVar.GetCVar('splash_particles', spawnPlayer).GetInt();

		// Spawn player has splashes disabled, spawn nothing.
		if (splashParticleSetting <= 0) return;

		// Scale with FOV to avoid awkward cutoff at low values (e.g. sniper zoom).
		double splashParticleRange = m_Range ** 2.0 * Math.Remap(spawnPlayer.FOV, 10, 120, 2.0, 0.5);

		// Don't spawn splashes out of range.
		if (distance > splashParticleRange) return;

		FSpawnParticleParams params;

		params.color1 = 0xFFFFFFFF;
		params.style = STYLE_Normal;
		params.startalpha = 1.0;

		if (splashParticleSetting == 6) // Extra detail for Ultra.
		{
			params.lifetime = 8;
			params.pos = data.GetEndPosition() + (0.0, 0.0, 1.0);
			params.accel = (0.0, 0.0, -0.15);

			// Attenuate amount over distance.
			int amount = int(round(Math.Remap(distance, 0.0, splashParticleRange, 5.0, 0.0)));

			for (int i = 0; i < amount; ++i)
			{
				params.size = FRandom[Weather](2.5, 3.0);
				params.sizestep = -(params.size / params.lifetime);
				params.vel = MathVec3.Rotate(Vec3Util.Random(2.0, 4.5, 0.0, 0.0, 0.275, 1.55), Vec3Util.Up(), FRandom[Weather](0.0, 360.0));
				level.SpawnParticle(params);
			}
		}

		params.lifetime = 10;
		params.pos = data.GetEndPosition() + (0.0, 0.0, 2.0);
		params.accel = (0.0, 0.0, -0.25);

		// Attenuate amount over distance.
		int amount = int(round(Math.Remap(distance, 0.0, splashParticleRange, splashParticleSetting, 0.0)));

		for (int i = 0; i < Random(amount - 2, amount); ++i)
		{
			params.size = FRandom[Weather](3.0, 6.0);
			params.sizestep = -(params.size / params.lifetime);
			params.vel = MathVec3.Rotate(Vec3Util.Random(0.75, 2.25, 0.0, 0.0, 0.5, 2.5), Vec3Util.Up(), FRandom[Weather](0.0, 360.0));
			level.SpawnParticle(params);
		}
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
		// Check if any player meets fake splash criteria.
		foreach (player : players)
		{
			if (!player.mo) continue;

			// Spawn from max real splash range up to four times as far depending on FOV.
			double minRange = m_Range ** 2.0;
			double maxRange = minRange * Math.Remap(player.FOV, 10, 120, 4.0, 1.0);

			vector2 point = m_Triangulation.GetRandomPoint();

			// Could use a line trace to ensure this handles 3D floors correctly, but it's
			// too rare an edge case for an effect like this.
			vector3 spawnPosition = (point, m_Sector.NextLowestFloorAt(point.x, point.y, m_Sector.HighestCeilingAt(point)));
			double distance = MathVec3.SquareDistanceBetween(spawnPosition, player.mo.Pos);

			// Cull if outside desired range.
			if (distance < minRange || distance >= maxRange) continue;

			// Fake splashes are more likely to appear at higher weather settings.
			double fakeSplashThreshold = 1.0 - max(0.0, GetWeatherAmountCVar(player).GetInt() * 0.2 - 0.2);

			if (FRandom[Weather](0.0, 1.0) < fakeSplashThreshold) continue;

			// Attenuate spawn chance over distance.
			double spawnScore = FRandom[Weather](0.0, 1.0);
			double spawnThreshold = Math.Remap(distance, minRange, maxRange, 0.5, 0.9);

			bool isOutOfView = IsOutOfView(player, point);

			// Fake splashes appear instantly, cull everything out of view.
			if (isOutOfView || spawnScore < spawnThreshold) continue;

			// All criteria met, spawn fake splash.
			SpawnSplashEffect(spawnPosition, m_Sector);
			break;
		}
	}
}