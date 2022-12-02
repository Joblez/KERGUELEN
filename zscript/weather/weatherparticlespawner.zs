class WeatherParticleSpawner : WeatherSpawner
{
	color m_Color;
	TextureID m_Texture;
	int m_RenderStyle;
	int m_Lifetime;
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

		spawner.m_Sector = sec;
		spawner.m_Range = range;
		spawner.m_WeatherAgent = agent;
		spawner.m_Color = particleColor;
		spawner.m_Texture = TexMan.CheckForTexture(particleTextureName);
		spawner.m_RenderStyle = particleRenderStyle;
		spawner.m_Lifetime = particleLifetime;
		spawner.m_Size = particleSize;
		spawner.m_SizeDeviation = particleSizeDeviation;
		spawner.m_ShouldSimulateParticles = shouldSimulateParticles;
		spawner.m_ShouldDoCallbackAtEndOfParticleLife = enableEndOfLifeCallbacks;
		spawner.m_InitialVelocity = initialParticleVelocity;
		spawner.m_InitialVelocityDeviation = initialParticleVelocityDeviation;
		spawner.m_Acceleration = particleAcceleration;
		spawner.m_AccelerationDeviation = particleAccelerationDeviation;
		spawner.m_Alpha = particleAlpha;
		spawner.m_FadeStep = particleFadeStep;
		spawner.m_WeatherAmountCVar = CVar.GetCVar("weather_amount", players[consoleplayer]);
		spawner.m_Triangulation = SectorDataRegistry.GetTriangulation(sec);
		spawner.m_Frequency = density * spawner.m_Triangulation.GetArea() / 2048.0 / TICRATE;
		spawner.m_ProjectionLength = projectionTime * TICRATE;

		return spawner;
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
		vector3 position = (point.x, point.y, (m_Sector.HighestCeilingAt(point) - FRandom(2, 12)));

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
			SimulateParticle(result, position, velocity, acceleration);
			lifetime = result.m_Lifetime;

			if (m_ShouldDoCallbackAtEndOfParticleLife) pendingCallbackData.Push(result.CreateCallbackData());
		}
		else
		{
			lifetime = m_Lifetime;
		}

		// Move spawn agent to spawn location
		vector3 oldPosition = m_WeatherAgent.Pos;
		m_WeatherAgent.SetXYZ(position);

		m_WeatherAgent.A_SpawnParticleEx(
			m_Color,
			m_Texture,
			m_RenderStyle,
			0,
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

	protected Actor Getagent() const
	{
		return m_WeatherAgent;
	}

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

		int tics = 1;
		double nextPlaneZ = GetApproachingPlaneZ(position, velocity);

		// Constant straight-down trajectory, simulate without iteration.
		if (acceleration ~== Vec3Util.Zero() && velocity.xy ~== Vec2Util.Zero())
		{
			result.m_Lifetime = abs((nextPlaneZ - position.z) / velocity.z);
			result.m_EndPosition = (position.xy, nextPlaneZ);
			result.m_EndVelocity = velocity;
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
			nextPlaneZ = GetApproachingPlaneZ(currentPosition, velocity);

			tics++;
		}

		result.m_Lifetime = tics;
		result.m_EndPosition = (currentPosition.xy, nextPlaneZ);
		result.m_EndVelocity = velocity;
	}

	private double GetApproachingPlaneZ(vector3 position, vector3 velocity)
	{
		Sector sec;
		
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

	WeatherParticleCallbackData CreateCallbackData() const
	{
		WeatherParticleCallbackData data = new("WeatherParticleCallbackData");

		data.m_Lifetime = m_Lifetime;
		data.m_EndPosition = m_EndPosition;
		data.m_EndVelocity = m_EndVelocity;

		return data;
	}
}

class WeatherParticleCallbackData
{
	int m_Time;
	int m_Lifetime;
	vector3 m_EndPosition;
	vector3 m_EndVelocity;
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