class WeatherParticleSpawner : WeatherSpawner
{
	color m_Color;
	TextureID m_Texture;
	int m_RenderStyle;
	int m_Lifetime;
	int m_ParticleFlags;
	double m_Alpha;
	double m_FadeStep;
	double m_Size;
	double m_SizeDeviation;
	vector3 m_InitialVelocity;
	vector3 m_InitialVelocityDeviation;
	vector3 m_Acceleration;
	vector3 m_AccelerationDeviation;

	bool m_ShouldSimulateParticles;
	bool m_ShouldDoCallbackAtEndOfParticleLife;

	private array<WeatherParticleCallbackData> pendingCallbackData;

	static WeatherParticleSpawner Create(
		double density,
		double range,
		Sector sec,
		WeatherAgent agent,
		color particleColor = 0xFFFFFFFF,
		int particleRenderStyle = STYLE_Normal,
		int particleFlags = 0,
		string particleTextureName = "",
		int particleLifetime = 35,
		double particleSize = 1,
		double particleSizeDeviation = 0,
		vector3 initialParticleVelocity = (0.0, 0.0, 0.0),
		vector3 initialParticleVelocityDeviation = (0.0, 0.0, 0.0),
		vector3 particleAcceleration = (0.0, 0.0, 0.0),
		vector3 particleAccelerationDeviation = (0.0, 0.0, 0.0),
		double particleAlpha = 1.0,
		double particleFadeStep = 0.0,
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

		return spawner;
	}

	void Init(
		double density,
		double range,
		Sector sec,
		WeatherAgent agent,
		color particleColor,
		int particleRenderStyle,
		int particleFlags,
		string particleTextureName,
		int particleLifetime,
		double particleSize,
		double particleSizeDeviation,
		vector3 initialParticleVelocity,
		vector3 initialParticleVelocityDeviation,
		vector3 particleAcceleration,
		vector3 particleAccelerationDeviation,
		double particleAlpha,
		double particleFadeStep,
		double projectionTime,
		bool shouldSimulateParticles,
		bool enableEndOfLifeCallbacks)
	{
		Super.Init(density, range, sec, null, agent, projectionTime);

		m_Color = particleColor;
		m_Texture = TexMan.CheckForTexture(particleTextureName);
		m_RenderStyle = particleRenderStyle;
		m_ParticleFlags = particleFlags;
		m_Lifetime = particleLifetime;
		m_Size = particleSize;
		m_SizeDeviation = particleSizeDeviation;
		m_InitialVelocity = initialParticleVelocity;
		m_InitialVelocityDeviation = initialParticleVelocityDeviation;
		m_Acceleration = particleAcceleration;
		m_AccelerationDeviation = particleAccelerationDeviation;
		m_Alpha = particleAlpha;
		m_FadeStep = particleFadeStep;
		m_ShouldSimulateParticles = shouldSimulateParticles;
		m_ShouldDoCallbackAtEndOfParticleLife = enableEndOfLifeCallbacks;
	}

	override void Tick()
	{
		if (m_WeatherAgent.IsFrozen()) return;

		Super.Tick();

		for (int i = pendingCallbackData.Size() - 1; i >= 0; --i)
		{
			WeatherParticleCallbackData data = pendingCallbackData[i];
			if (data.m_Time >= data.m_Lifetime)
			{
				ParticleEndOfLifeCallback(data);
				pendingCallbackData.Delete(i);
				continue;
			}

			data.m_Time++;
		}
	}

	override void SpawnWeatherParticle()
	{
		vector2 point = m_Triangulation.GetRandomPoint();

		// Project the player's position forward to ensure particles are in view.
		vector2 projectedPosition = players[consoleplayer].mo.Pos.xy + (players[consoleplayer].mo.Vel.xy * m_ProjectionLength);

		if (MathVec2.SquareDistanceBetween(point, projectedPosition) > GetAdjustedRange() ** 2) return;

		vector3 spawnPosition = (point.x, point.y, (m_Sector.HighestCeilingAt(point) - FRandom(2, 12)));

		// Move spawn agent to spawn location
		vector3 oldPosition = m_WeatherAgent.Pos;
		m_WeatherAgent.SetXYZ(spawnPosition);

		Actor pawn = players[consoleplayer].mo;
		double delta = Actor.absangle(pawn.Angle, pawn.AngleTo(m_WeatherAgent));
		Console.Printf("Angle delta: %f", delta);

		if (Actor.absangle(pawn.Angle, pawn.AngleTo(m_WeatherAgent)) >= 90.0
			&& FRandom(0, 1) < GetOutOfViewFrequencyReduction()) // Reduce chances of particle spawning when out of view.
		{
			m_WeatherAgent.SetXYZ(oldPosition);
			return;
		}

		int lifetime;
		vector3 velocity = m_InitialVelocity;
		velocity.x += FRandom(-m_InitialVelocityDeviation.x, m_InitialVelocityDeviation.x);
		velocity.y += FRandom(-m_InitialVelocityDeviation.y, m_InitialVelocityDeviation.y);
		velocity.z += FRandom(-m_InitialVelocityDeviation.z, m_InitialVelocityDeviation.z);

		vector3 acceleration = m_Acceleration;
		acceleration.x += FRandom(-m_AccelerationDeviation.x, m_AccelerationDeviation.x);
		acceleration.y += FRandom(-m_AccelerationDeviation.y, m_AccelerationDeviation.y);
		acceleration.z += FRandom(-m_AccelerationDeviation.z, m_AccelerationDeviation.z);

		if (m_ShouldSimulateParticles)
		{
			WeatherParticleSimulationResult result;
			SimulateParticle(result, spawnPosition, velocity, acceleration);
			lifetime = result.m_Lifetime;

			if (m_ShouldDoCallbackAtEndOfParticleLife) pendingCallbackData.Push(result.CreateCallbackData());
		}
		else
		{
			lifetime = m_Lifetime;
		}


		m_WeatherAgent.A_SpawnParticleEx(
			m_Color,
			m_Texture,
			m_RenderStyle,
			m_ParticleFlags,
			lifetime,
			m_Size + FRandom(-m_SizeDeviation, m_SizeDeviation),
			velx: velocity.x,
			vely: velocity.y,
			velz: velocity.z,
			accelx: acceleration.x,
			accely: acceleration.y,
			accelz: acceleration.z,
			startalphaf: m_Alpha,
			fadestepf: m_FadeStep
		);

		m_WeatherAgent.SetXYZ(oldPosition);
	}

	protected virtual void ParticleEndOfLifeCallback(WeatherParticleCallbackData data) { }

	protected void SimulateParticle(
		out WeatherParticleSimulationResult result,
		vector3 position,
		vector3 velocity,
		vector3 acceleration)
	{
		if (velocity ~== Vec3Util.Zero() && acceleration ~== Vec3Util.Zero())
		{
			ThrowAbortException("Particle does not move, cannot simulate lifetime.");
		}

		Sector sec = GetSector();
		int tics = 1;
		double nextPlaneZ = GetApproachingPlaneZ(position, velocity, sec);

		// Constant straight-down trajectory, simulate without iteration.
		if (acceleration ~== Vec3Util.Zero() && velocity.xy ~== Vec2Util.Zero())
		{
			result.m_Lifetime = abs((nextPlaneZ - position.z) / velocity.z);
			result.m_EndPosition = (position.xy, nextPlaneZ);
			result.m_EndVelocity = velocity;
			result.m_Sector = sec;
			return;
		}

		vector3 currentPosition = position;

		while (true)
		{
			currentPosition += velocity;

			if (velocity.z < 0.0 && currentPosition.z <= nextPlaneZ) break;
			if (velocity.z > 0.0 && currentPosition.z >= nextPlaneZ) break;

			if ((acceleration != Vec3Util.Zero())) velocity += acceleration;

			// Recheck next plane Z in case acceleration or lateral velocity changed the trajectory.
			nextPlaneZ = GetApproachingPlaneZ(currentPosition, velocity, sec);

			tics++;
		}

		result.m_Lifetime = tics;
		result.m_EndPosition = (currentPosition.xy, nextPlaneZ);
		result.m_EndVelocity = velocity;
		result.m_Sector = sec;
	}

	private double GetApproachingPlaneZ(vector3 position, vector3 velocity, out Sector sec)
	{
		if (velocity.xy ~== Vec2Util.Zero())
		{
			sec = GetSector();
		}
		else
		{
			sec = Level.PointInSector(position.xy);
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

struct WeatherParticleSimulationResult
{
	int m_Lifetime;
	vector3 m_EndPosition;
	vector3 m_EndVelocity;
	Sector m_Sector;

	WeatherParticleCallbackData CreateCallbackData() const
	{
		WeatherParticleCallbackData data = new("WeatherParticleCallbackData");

		data.m_Lifetime = m_Lifetime;
		data.m_EndPosition = m_EndPosition;
		data.m_EndVelocity = m_EndVelocity;
		data.m_Sector = m_Sector;

		return data;
	}
}

class WeatherParticleCallbackData
{
	int m_Time;
	int m_Lifetime;
	vector3 m_EndPosition;
	vector3 m_EndVelocity;
	Sector m_Sector;
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