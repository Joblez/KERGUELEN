// TODO: Replace individual particle arguments with FSpawnParticleParams.
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

	FSpawnParticleParams m_ParticleParams;

	bool m_ShouldSimulateParticles;
	bool m_ShouldDoCallbackAtEndOfParticleLife;

	private array<WeatherParticleCallbackData> pendingCallbackData;

	static WeatherParticleSpawner Create(
		double density,
		double range,
		Sector sec,
		WeatherAgent agent,
		FSpawnParticleParams particleParams,
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
		double projectionTime,
		bool shouldSimulateParticles,
		bool enableEndOfLifeCallbacks)
	{
		Super.Init(density, range, sec, null, agent, projectionTime);

		// TODO: Clean up if struct assignment is ever implemented.
		m_ParticleParams.color1 = particleParams.color1;
		m_ParticleParams.texture = particleParams.texture;
		m_ParticleParams.style = particleParams.style;
		m_ParticleParams.flags = particleParams.flags;
		m_ParticleParams.lifetime = particleParams.lifetime;
		m_ParticleParams.size = particleParams.size;
		m_ParticleParams.sizestep = particleParams.sizestep;
		m_ParticleParams.pos = particleParams.pos;
		m_ParticleParams.vel = particleParams.vel;
		m_ParticleParams.accel = particleParams.accel;
		m_ParticleParams.startalpha = particleParams.startalpha;
		m_ParticleParams.fadestep = particleParams.fadestep;
		m_ParticleParams.startroll = particleParams.startroll;
		m_ParticleParams.rollvel = particleParams.rollvel;
		m_ParticleParams.rollacc = particleParams.rollacc;

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
		Actor pawn = players[consoleplayer].mo;

		// Project the player's position forward to ensure particles fall into view, but
		// divide by setting because it may look jarring with higher densities.
		double attenuatedProjectionLength = m_ProjectionLength / (max(1.0, GetWeatherAmountCVar().GetInt()) * 2.0);
		
		Console.Printf("Projection length: %.2f", attenuatedProjectionLength);

		vector2 projectedPosition = players[consoleplayer].mo.Pos.xy
			+ (players[consoleplayer].mo.Vel.xy * attenuatedProjectionLength);
		vector2 point = m_Triangulation.GetRandomPoint();

		double distance = MathVec2.SquareDistanceBetween(point, projectedPosition);
		double range = GetAdjustedRange() ** 2.0;

		// Cull outside range.
		if (distance > range) return;

		// Attenuate amount over distance.
		double spawnScore = FRandom(0.0, 1.0);
		double spawnThreshold = Math.Remap(distance, 0.0, range, 0.0, 0.5);

		// Reduce spawn chance outside of horizontal view range.
		bool isOutOfView = Actor.absangle(pawn.Angle, vectorangle(projectedPosition.x - pawn.Pos.x, projectedPosition.y - pawn.Pos.y))
			>= players[consoleplayer].FOV * 0.5 * ScreenUtil.GetAspectRatio();
		if (isOutOfView) spawnThreshold += GetOutOfViewFrequencyReduction();

		if (spawnScore < spawnThreshold) return;

		vector3 spawnPosition = (point.x, point.y, (m_Sector.HighestCeilingAt(point) - FRandom(2, 12)));


		// Copy params for simulated lifetime.
		// TODO: Clean up if struct assignment is ever implemented.
		FSpawnParticleParams outParams;

		outParams.color1 = m_ParticleParams.color1;
		outParams.texture = m_ParticleParams.texture;
		outParams.style = m_ParticleParams.style;
		outParams.flags = m_ParticleParams.flags;
		outParams.lifetime = m_ParticleParams.lifetime;
		outParams.size = m_ParticleParams.size;
		outParams.sizestep = m_ParticleParams.sizestep;
		outParams.vel = m_ParticleParams.vel;
		outParams.accel = m_ParticleParams.accel;
		outParams.startalpha = m_ParticleParams.startalpha;
		outParams.fadestep = m_ParticleParams.fadestep;
		outParams.startroll = m_ParticleParams.startroll;
		outParams.rollvel = m_ParticleParams.rollvel;
		outParams.rollacc = m_ParticleParams.rollacc;

		outParams.pos = spawnPosition;

		if (m_ShouldSimulateParticles)
		{
			WeatherParticleSimulationResult result;
			SimulateParticle(result, outParams.pos, outParams.vel, outParams.accel);
			outParams.lifetime = result.m_Lifetime;

			if (m_ShouldDoCallbackAtEndOfParticleLife) pendingCallbackData.Push(result.CreateCallbackData());
		}

		Level.SpawnParticle(outParams);
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