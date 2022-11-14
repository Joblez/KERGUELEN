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

	protected Actor m_SpawnAgent;

	private array<WeatherParticleCallbackData> pendingCallbackData;

	static WeatherParticleSpawner Create(
		double density,
		Sector sec,
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
		bool shouldSimulateParticles = false,
		bool enableEndOfLifeCallbacks = false,
		Actor spawnAgent = null)
	{
		WeatherParticleSpawner spawner = new("WeatherParticleSpawner");

		spawner.m_Sector = sec;
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
		spawner.m_SpawnAgent = spawnAgent ? spawnAgent : Actor.Spawn("NilActor", Vec3Util.Zero());
		spawner.m_WeatherAmountCVar = CVar.GetCVar("weather_amount", players[consoleplayer]);
		spawner.m_Triangulation = SectorDataRegistry.GetTriangulation(sec);
		spawner.m_Frequency = density * spawner.m_Triangulation.GetArea() / 2048.0 / TICRATE;

		return spawner;
	}

	override void Tick()
	{
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
		if (MathVec2.SquareDistanceBetween(point, players[consoleplayer].mo.Pos.xy) > GetAdjustedRange() ** 2) return;
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
		m_SpawnAgent.SetXYZ(position);

		m_SpawnAgent.A_SpawnParticleEx(
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

		m_SpawnAgent.SetXYZ(Vec3Util.Zero());
	}

	protected Actor GetSpawnAgent() const
	{
		return m_SpawnAgent;
	}

	protected virtual void ParticleEndOfLifeCallback(WeatherParticleCallbackData data)
	{
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
		else if (velocity.xy ~== Vec2Util.Zero() && acceleration.xy ~== Vec2Util.Zero())
		{
			// No lateral movement, use simple plane crossing check.
			SimulateParticle1D(result, position, velocity.z, acceleration.z);
		}
		// else
		// {
		// 	SimulateParticle3D(result, position, velocity, acceleration);
		// }
	}

	private void SimulateParticle1D(
		out WeatherParticleSimulationResult result,
		vector3 position,
		double velocity,
		double acceleration = 0.0)
	{
		int tics = 1;
		double nextPlaneZ;
		vector3 currentPosition = position;

		nextPlaneZ = GetApproachingPlaneZ(position, velocity);

		while (true)
		{
			currentPosition.z += velocity;

			if (velocity < 0.0 && currentPosition.z <= nextPlaneZ) break;
			if (velocity > 0.0 && currentPosition.z >= nextPlaneZ) break;

			if ((acceleration != 0.0))
			{
				velocity += acceleration;
				
				// Recheck next plane Z in case acceleration changed the trajectory.
				nextPlaneZ = GetApproachingPlaneZ(position, velocity);
			}

			tics++;
		}
		
		result.m_Lifetime = tics;
		result.m_EndPosition = (position.xy, nextPlaneZ);
		result.m_EndVelocity = (0.0, 0.0, velocity);
	}

	// protected void SimulateParticleLifetime3D(
	// 	out WeatherParticleSimulationResult result,
	// 	vector3 position,
	// 	vector3 velocity,
	// 	vector3 acceleration = (0.0, 0.0, 0.0))
	// {

	// }

	private double GetApproachingPlaneZ(vector3 position, double velocity)
	{
		if (velocity < 0.0)
		{
			return GetSector().NextLowestFloorAt(position.x, position.y, position.z);
		}
		else
		{
			return GetSector().NextHighestCeilingAt(position.x, position.y, position.z, position.z);
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