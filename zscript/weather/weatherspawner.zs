class WeatherSpawner : Thinker
{
	protected Sector m_Sector;
	protected class<WeatherParticle> m_ParticleType;

	protected double m_Frequency;
	protected double m_Range;
	protected double m_ProjectionLength;

	protected SectorTriangulation m_Triangulation;
	protected transient CVar m_WeatherAmountCVar;

	protected Agent m_WeatherAgent;

	private double m_Time;

	static WeatherSpawner Create(double density, double range, Sector sec, class<WeatherParticle> particleType, WeatherAgent agent, double projectionTime = 1.0)
	{
		WeatherSpawner spawner = new("WeatherSpawner");
		spawner.Init(density, range, sec, particleType, agent, projectionTime);
		return spawner;
	}

	void Init(double density, double range, Sector sec, class<WeatherParticle> particleType, WeatherAgent agent, double projectionTime = 1.0)
	{
		m_Range = range;
		m_Sector = sec;
		m_ParticleType = particleType;
		m_WeatherAmountCVar = CVar.GetCVar("weather_amount", players[consoleplayer]);
		m_Triangulation = SectorDataRegistry.GetTriangulation(sec);
		m_Frequency = density * m_Triangulation.GetArea() / 2048.0 / TICRATE;
		m_ProjectionLength = projectionTime * TICRATE;
		m_WeatherAgent = agent;
	}

	override void Tick()
	{
		if (m_WeatherAgent.IsFrozen()) return;

		double frequency = GetAdjustedFrequency();
		if (frequency == 0) return;

		m_Time += 1.0 / TICRATE;

		if (m_Time >= 1.0 / frequency)
		{
			do
			{
				SpawnWeatherParticle();
				m_Time -= 1.0 / frequency;
			}
			while (m_Time > 0.0);
			m_Time = 0.0;
		}
	}

	Sector GetSector() const
	{
		return m_Sector;
	}

	CVar GetWeatherAmountCVar() const
	{
		if (!m_WeatherAmountCVar) m_WeatherAmountCVar = CVar.GetCVar("weather_amount", players[consoleplayer]);
		return m_WeatherAmountCVar;
	}

	double GetAdjustedRange() const
	{
		int weatherSetting = GetWeatherAmountCVar().GetInt();

		return (m_Range * 2) * weatherSetting + m_Range;
	}

	double GetAdjustedFrequency() const
	{
		switch (GetWeatherAmountCVar().GetInt())
		{
			case 0: return 0.0;
			case 1: return m_Frequency * 0.2;
			case 2: return m_Frequency * 0.45;
			case 3: return m_Frequency * 0.7;
			case 4:
			default: return m_Frequency;
			case 5: return m_Frequency * 1.4;
			case 6: return m_Frequency * 2.0;
		}
	}

	double GetOutOfViewFrequencyReduction() const
	{
		return min(GetWeatherAmountCVar().GetInt() * 0.075, 0.4);
	}

	void SetDensity(double density)
	{
		m_Frequency = density * m_Triangulation.GetArea() / 2048.0 / TICRATE;
	}

	protected virtual void SpawnWeatherParticle()
	{
		vector2 point = m_Triangulation.GetRandomPoint();

		// Project the player's position forward to ensure particles fall into view, but
		// divide by setting because it may look jarring with higher densities.
		double attenuatedProjectionLength = m_ProjectionLength / (max(1.0, GetWeatherAmountCVar().GetInt()) * 2.0);
		
		Console.Printf("Projection length: %.2f", attenuatedProjectionLength);

		vector2 projectedPosition = players[consoleplayer].mo.Pos.xy
			+ (players[consoleplayer].mo.Vel.xy * attenuatedProjectionLength);

		double distance = MathVec2.SquareDistanceBetween(point, projectedPosition);
		double range = GetAdjustedRange() ** 2;

		// Cull outside range.
		if (distance > range) return;

		// Attenuate amount over distance.
		double spawnThreshold = Math.Remap(distance, 0.0, range, 0.0, 0.5);
		if (FRandom(0.0, 1.0) < 1.0 - spawnThreshold) return;

		vector3 spawnPosition = (point.x, point.y, (m_Sector.HighestCeilingAt(point) - FRandom(2, 12)));

		Actor pawn = players[consoleplayer].mo;

		// Reduce spawn chance outside of horizontal view range.
		if (Actor.absangle(pawn.Angle, vectorangle(point.x - pawn.Pos.x, point.y - pawn.Pos.y))
				>= players[consoleplayer].FOV * 0.5 * ScreenUtil.GetAspectRatio()
			&& FRandom(0, 1) > GetOutOfViewFrequencyReduction())
		{
			Actor.Spawn(m_ParticleType, spawnPosition);
		}
		return;
	}
}