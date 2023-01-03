class WeatherParticleSpawner : WeatherSpawner
{
	// FSpawnParticleParams doesn't serialize to save games, so all of these need to
	// be stored in the spawner.
	color m_Color;
	TextureID m_Texture;
	int m_Style;
	int m_Flags;
	int m_Lifetime;
	double m_Size;
	double m_SizeStep;
	vector3 m_Vel;
	vector3 m_Accel;
	double m_StartAlpha;
	double m_FadeStep;
	double m_StartRoll;
	float m_RollVel;
	float m_RollAcc;

	double m_SizeDeviation;
	double m_SizeStepDeviation;
	vector3 m_VelDeviation;
	vector3 m_AccelDeviation;
	double m_AlphaDeviation;
	double m_FadeDeviation;
	double m_RollDeviation;
	double m_RollVelDeviation;
	double m_RollAccDeviation;

	bool m_ShouldSimulateParticles;
	bool m_ShouldDoCallbackAtEndOfParticleLife;

	private double[TICRATE] elapsedTimes;

	protected array<WeatherParticleSimulation> m_SimulationData;

	static WeatherParticleSpawner Create(
		double density,
		double range,
		Sector sec,
		WeatherAgent agent,
		FSpawnParticleParams particleParams,
		double sizeDeviation = 0.0,
		double sizeStepDeviation = 0.0,
		double sizeDeviation = 0.0,
		double sizeStepDeviation = 0.0,
		vector3 velDeviation = (0.0, 0.0, 0.0),
		vector3 accelDeviation = (0.0, 0.0, 0.0),
		double alphaDeviation = 0.0,
		double fadeDeviation = 0.0,
		double rollDeviation = 0.0,
		double rollVelDeviation = 0.0,
		double rollAccDeviation = 0.0,
		double projectionTime = 1.0,
		bool shouldSimulateParticles = false,
		bool enableEndOfLifeCallbacks = false)
	{
		WeatherParticleSpawner spawner = new("WeatherParticleSpawner");

		spawner.Init(
			density,
			range,
			sec,
			agent,
			particleParams,
			sizeDeviation,
			sizeStepDeviation,
			velDeviation,
			accelDeviation,
			alphaDeviation,
			fadeDeviation,
			rollDeviation,
			rollVelDeviation,
			rollAccDeviation,
			projectionTime,
			shouldSimulateParticles,
			enableEndOfLifeCallbacks);

		return spawner;
	}

	void Init(
		double density,
		double range,
		Sector sec,
		WeatherAgent agent,
		FSpawnParticleParams particleParams,
		double sizeDeviation = 0.0,
		double sizeStepDeviation = 0.0,
		vector3 velDeviation = (0.0, 0.0, 0.0),
		vector3 accelDeviation = (0.0, 0.0, 0.0),
		double alphaDeviation = 0.0,
		double fadeDeviation = 0.0,
		double rollDeviation = 0.0,
		double rollVelDeviation = 0.0,
		double rollAccDeviation = 0.0,
		double projectionTime = 1.0,
		bool shouldSimulateParticles = false,
		bool enableEndOfLifeCallbacks = false)
	{
		Super.Init(density, range, sec, null, agent, projectionTime);

		m_Color = particleParams.color1;
		m_Texture = particleParams.texture;
		m_Style = particleParams.style;
		m_Flags = particleParams.flags;
		m_Lifetime = particleParams.lifetime;
		m_Size = particleParams.size;
		m_SizeStep = particleParams.sizestep;
		m_Vel = particleParams.vel;
		m_Accel = particleParams.accel;
		m_StartAlpha = particleParams.startalpha;
		m_FadeStep = particleParams.fadestep;
		m_StartRoll = particleParams.startroll;
		m_RollVel = particleParams.rollvel;
		m_RollAcc = particleParams.rollacc;

		m_SizeDeviation = sizeDeviation;
		m_SizeStepDeviation = sizeStepDeviation;
		m_VelDeviation = velDeviation;
		m_AccelDeviation = accelDeviation;
		m_AlphaDeviation = alphaDeviation;
		m_FadeDeviation = fadeDeviation;
		m_RollDeviation = rollDeviation;
		m_RollVelDeviation = rollVelDeviation;
		m_RollAccDeviation = rollAccDeviation;

		m_ShouldSimulateParticles = shouldSimulateParticles;
		m_ShouldDoCallbackAtEndOfParticleLife = enableEndOfLifeCallbacks;
	}

	override void Tick()
	{
		if (m_WeatherAgent.IsFrozen()) return;

		Super.Tick();
		for (int i = m_SimulationData.Size() - 1; i >= 0; --i)
		{
			WeatherParticleSimulation data = m_SimulationData[i];
			if (data.GetCurrentTime() >= data.GetLifetime())
			{
				if (m_ShouldDoCallbackAtEndOfParticleLife) ParticleEndOfLifeCallback(data);

				m_SimulationData.Delete(i);
				continue;
			}

			data.Tick();
		}

		if (level.time > TICRATE && level.time % TICRATE == 0.0)
		{
			double time = 0.0;
			foreach (timestamp : elapsedTimes)
			{
				time += timestamp;
			}

			time /= elapsedTimes.Size();
			// Console.Printf("Average time: %f ms", time);
		}
	}

	override void SpawnWeatherParticle()
	{
		Actor pawn = players[consoleplayer].mo;

		// Project the player's position forward to ensure particles fall into view.
		vector2 projectedPosition = ProjectPlayerPosition(m_Vel.z);

		vector2 point = m_Triangulation.GetRandomPoint();

		double distance = MathVec2.SquareDistanceBetween(point, projectedPosition);
		double range = m_Range ** 2.0;

		// Cull outside range.
		if (distance > range) return;

		// Attenuate amount over distance.
		double spawnScore = FRandom(0.0, 1.0);
		double spawnThreshold = Math.Remap(distance, 0.0, range, 0.0, 0.5);

		bool isOutOfView = Actor.absangle(pawn.Angle, vectorangle(point.x - pawn.Pos.x, point.y - pawn.Pos.y))
			>= players[consoleplayer].FOV * 0.5 * ScreenUtil.GetAspectRatio();

		// Reduce spawn chance outside of horizontal view range.
		if (isOutOfView) spawnThreshold += GetOutOfViewFrequencyReduction();

		if (spawnScore < spawnThreshold) return;

		vector3 spawnPosition = (point.x, point.y,
			(m_Sector.HighestCeilingAt(point)
				// Particles can exist outside of level geometry, spawn above ceiling to make it
				// seem as though the rain is falling from the sky.
				+ (GetSector().GetTexture(Sector.ceiling) == skyflatnum ? 512.0 : 0.0)
				- FRandom(2.0, 12.0)));

		FSpawnParticleParams outParams;

		outParams.color1 = m_Color;
		outParams.texture = m_Texture;
		outParams.style = m_Style;
		outParams.flags = m_Flags;
		outParams.lifetime = m_Lifetime;
		outParams.size = m_Size + FRandom(-m_SizeDeviation, m_SizeDeviation);
		outParams.sizestep = m_SizeStep + FRandom(-m_SizeStepDeviation, m_SizeStepDeviation);
		outParams.vel = m_Vel + Vec3Util.Random(-m_VelDeviation.x, m_VelDeviation.x, -m_VelDeviation.y, m_VelDeviation.y, -m_VelDeviation.z, m_VelDeviation.z);
		outParams.accel = m_Accel + Vec3Util.Random(-m_AccelDeviation.x, m_AccelDeviation.x, -m_AccelDeviation.y, m_AccelDeviation.y, -m_AccelDeviation.z, m_AccelDeviation.z);
		outParams.startalpha = m_StartAlpha + FRandom(-m_AlphaDeviation, m_AlphaDeviation);
		outParams.fadestep = m_FadeStep + FRandom(-m_FadeDeviation, m_FadeDeviation);
		outParams.startroll = m_StartRoll + FRandom(-m_RollDeviation, m_RollDeviation);
		outParams.rollvel = m_RollVel + FRandom(-m_RollVelDeviation, m_RollVelDeviation);
		outParams.rollacc = m_RollAcc + FRandom(-m_RollAccDeviation, m_RollAccDeviation);

		outParams.pos = spawnPosition;

		if (m_ShouldSimulateParticles)
		{
			WeatherParticleSimulation result = SimulateParticle(outParams);
			outParams.lifetime = result.GetLifetime();

			m_SimulationData.Push(result);
		}

		level.SpawnParticle(outParams);
	}

	// Only used to respawn particles lost to a save reload.
	virtual void ReconstructWeatherState()
	{
		for (int i = m_SimulationData.Size() - 1; i >= 0; --i)
		{
			FSpawnParticleParams params;

			params.color1 = m_Color;
			params.texture = m_Texture;
			params.style = m_Style;
			params.flags = m_Flags;

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

			// Spawn with reconstructed state.
			level.SpawnParticle(params);
		}
	}

	protected virtual void ParticleEndOfLifeCallback(WeatherParticleSimulation data) { }

	protected WeatherParticleSimulation SimulateParticle(FSpawnParticleParams params)
	{
		if (params.vel ~== Vec3Util.Zero() && params.accel ~== Vec3Util.Zero())
		{
			ThrowAbortException("Particle does not move, cannot simulate lifetime.");
		}

		int tics = 0;
		Sector sec = GetSector();
		vector3 position = params.pos;
		vector3 velocity = params.vel;
		vector3 acceleration = params.accel;

		double nextPlaneZ = GetApproachingPlaneZ(position, velocity, sec);

		vector3 endPosition;

		double startTime = MSTimeF();
		double endTime;

		if (velocity.xy ~== Vec2Util.Zero() && acceleration.xy ~== Vec2Util.Zero())
		{
			// One-dimensional trajectory, simulate without iteration.
			if (abs(acceleration.z) == 0.0)
			{
				// Constant velocity.
				tics = int(round(abs((nextPlaneZ - position.z) / velocity.z)));

				endTime = MSTimeF();
				elapsedTimes[level.time % TICRATE] = endTime - startTime;
			}
			else
			{
				[tics, endPosition] = SimulateParticleTravel(position, velocity, acceleration);

				endTime = MSTimeF();
				elapsedTimes[level.time % TICRATE] = endTime - startTime;

				// Breaks at higher distances, fall back to iterative for now.

				// double floorZ = sec.NextLowestFloorAt(position.x, position.y, position.z);
				// double ceilZ;

				// // Sky check.
				// if (sec.GetTexture(Sector.ceiling) == skyflatnum)
				// {
				// 	// Sky height should be treated as practically infinite.
				// 	ceilZ = Actor.ONCEILINGZ;
				// }
				// else
				// {
				// 	ceilZ = sec.NextHighestCeilingAt(position.x, position.y, position.z, position.z);
				// }

				// double fq = sqrt(velocity.z ** 2.0 - 4.0 * acceleration.z * (position.z - floorZ));
				// double cq = sqrt(velocity.z ** 2.0 - 4.0 * acceleration.z * (position.z - ceilZ));

				// double pfq = (-velocity.z + fq) / (2.0 * acceleration.z);
				// double nfq = (-velocity.z - fq) / (2.0 * acceleration.z);

				// double pcq = (-velocity.z + cq) / (2.0 * acceleration.z);
				// double ncq = (-velocity.z - cq) / (2.0 * acceleration.z);

				// fq = (pfq <= 0.0 || nfq <= 0.0) ? max(pfq, nfq) : min(pfq, nfq);
				// cq = (pcq <= 0.0 || ncq <= 0.0) ? max(pcq, ncq) : min(pcq, ncq);

				// double time = max(fq, cq);
				// tics = ceil(time);

				// // Clamp to three minutes in case particles move towards the sky
				// // tics = min(tics, TICRATE * 60 * 3);

				// endPosition = position + velocity * time + acceleration * time ** 2.0;

				// endTime = MSTimeF();
				// elapsedTimes[level.time % TICRATE] = endTime - startTime;
			}
		}
		else
		{
			[tics, endPosition] = SimulateParticleTravel(position, velocity, acceleration);

			endTime = MSTimeF();
			elapsedTimes[level.time % TICRATE] = endTime - startTime;
		}

		return WeatherParticleSimulation.Create(
			tics,
			params.pos,
			params.vel,
			params.size,
			params.startalpha,
			params.startroll,
			params.rollvel,
			params.sizestep,
			params.fadestep,
			params.accel,
			params.rollacc,
			sec,
			endPosition);
	}

	private int, vector3 SimulateParticleTravel(vector3 position, vector3 velocity, vector3 acceleration)
	{
		int tics;
		vector3 endPosition;
		Sector sec = GetSector();
		double nextPlaneZ = GetApproachingPlaneZ(position, velocity, sec);

		while (true)
		{
			// If a particle hasn't hit a plane in over three minutes, it likely never will.
			// Assume particle is stuck in a loop.
			if (tics >= TICRATE * 60 * 3) ThrowAbortException("Particle simulation stuck.");

			position += velocity;

			if (velocity.z < 0.0 && position.z < nextPlaneZ) break;
			if (velocity.z > 0.0 && position.z > nextPlaneZ) break;

			if ((acceleration != Vec3Util.Zero())) velocity += acceleration;

			// Recheck next plane Z in case acceleration or lateral velocity changed the trajectory.
			nextPlaneZ = GetApproachingPlaneZ(position, velocity, sec);

			tics++;
		}
		tics++; // Weather sometimes doesn't visibly touch the ground, add one extra tic.
		endPosition = (position.xy, nextPlaneZ);

		return tics, endPosition;
	}

	private double GetApproachingPlaneZ(vector3 position, vector3 velocity, out Sector sec)
	{
		if (velocity.xy ~== Vec2Util.Zero())
		{
			sec = GetSector();
		}
		else
		{
			sec = level.PointInSector(position.xy);
		}

		if (velocity.z < 0.0)
		{
			return sec.NextLowestFloorAt(position.x, position.y, position.z);
		}
		else
		{
			return sec.NextHighestCeilingAt(position.x, position.y, position.z, position.z);
		}
	}
}

class WeatherParticleSimulation
{
	private int m_Time;
	private int m_Lifetime;

	private vector3 m_StartPosition;
	private vector3 m_StartVelocity;
	private double m_StartSize;
	private double m_StartAlpha;
	private double m_StartRoll;
	private double m_StartRollVelocity;
	private Sector m_StartSector;

	private double m_SizeStep;
	private double m_FadeStep;
	private vector3 m_Acceleration;
	private double m_RollAcceleration;

	private vector3 m_EndPosition;
	private Sector m_EndSector;

	static WeatherParticleSimulation Create(
		int lifetime,
		vector3 startPosition,
		vector3 startVelocity,
		double startSize,
		double startAlpha,
		double startRoll,
		double startRollVelocity,
		double sizestep,
		double fadestep,
		vector3 acceleration,
		double rollAcceleration,
		Sector startSector,
		vector3 endPosition)
	{
		WeatherParticleSimulation sim = new("WeatherParticleSimulation");

		sim.m_Lifetime = lifetime;
		sim.m_StartPosition = startPosition;
		sim.m_StartVelocity = startVelocity;
		sim.m_StartSize = startSize;
		sim.m_StartAlpha = startAlpha;
		sim.m_StartRoll = startRoll;
		sim.m_StartRollVelocity = startRollVelocity;
		sim.m_SizeStep = sizestep;
		sim.m_FadeStep = fadestep;
		sim.m_Acceleration = acceleration;
		sim.m_RollAcceleration = rollAcceleration;
		sim.m_StartSector = startSector;

		sim.m_EndPosition = endPosition;
		sim.m_EndSector = level.PointInSector(endPosition.xy);

		return sim;
	}

	int GetCurrentTime() const { return m_Time; }
	int GetLifetime() const { return m_Lifetime; }

	double GetSizeStep() const { return m_SizeStep; }
	double GetFadeStep() const { return m_FadeStep; }
	vector3 GetAcceleration() const { return m_Acceleration; }
	double GetRollAcceleration() const { return m_RollAcceleration; }

	vector3 GetStartPosition() const { return m_StartPosition; }
	vector3 GetPositionAt(int time) const { return m_StartPosition + m_StartVelocity * time + m_Acceleration * time ** 2; }
	vector3 GetEndPosition() const { return m_EndPosition; }

	vector3 GetStartVelocity() const { return m_StartVelocity; }
	vector3 GetVelocityAt(int time) const { return m_StartVelocity + (m_Acceleration * time); }
	vector3 GetEndVelocity() const { return GetVelocityAt(m_Lifetime); }

	double GetStartSize() const { return m_StartSize; }
	double GetSizeAt(int time) { return m_StartSize + (m_SizeStep * time); }
	double GetEndSize() { return GetSizeAt(m_Lifetime); }

	double GetStartAlpha() const { return m_StartAlpha; }
	double GetAlphaAt(int time) const
	{
		return (m_FadeStep == -1.0)
			? Math.Remap(time, 0.0, m_Lifetime, m_StartAlpha, 0.0)
			: m_StartAlpha - max(0.0, m_FadeStep) * time;
	}
	double GetEndAlpha() const { return GetAlphaAt(m_Lifetime); }

	double GetStartRoll() const { return m_StartRoll; }
	double GetRollAt(int time) const { return m_StartRoll + m_StartRollVelocity * time + m_RollAcceleration * time ** 2; }
	double GetEndRoll() const { return GetRollAt(m_Lifetime); }

	double GetStartRollVelocity() const { return m_StartRollVelocity; }
	double GetRollVelocityAt(int time) const { return m_StartRollVelocity + (m_RollAcceleration * time); }
	double GetEndRollVelocity() const { return GetRollVelocityAt(m_Lifetime); }

	Sector GetStartSector() const { return m_StartSector; }
	Sector GetEndSector() const { return m_EndSector; }

	void Tick() { m_Time++; }
}

class WeatherParticleLineTracer : LineTracer
{
	override ETraceStatus TraceCallback()
	{
		if (Results.HitType != TRACE_HitFloor
			&& Results.HitType != TRACE_HitCeiling
			&& Results.HitType != TRACE_HitWall)
		{
			return TRACE_Skip;
		}
		return TRACE_Stop;
	}
}