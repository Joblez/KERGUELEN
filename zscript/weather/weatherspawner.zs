class WeatherSpawner : Thinker
{
	protected Sector m_Sector;
	protected class<WeatherParticle> m_ParticleType;

	protected double m_Frequency;
	protected double m_Range;
	protected double m_ProjectionLength;

	protected SectorTriangulation m_Triangulation;
	protected CVar m_WeatherAmountCVar;

	protected Agent m_WorldAgent;

	private double m_Time;

	static WeatherSpawner Create(double density, double range, Sector sec, class<WeatherParticle> particleType, double projectionTime = 1.0, Agent worldAgent = null)
	{
		WeatherSpawner spawner = new("WeatherSpawner");

		spawner.m_Range = range;
		spawner.m_Sector = sec;
		spawner.m_ParticleType = particleType;
		spawner.m_WeatherAmountCVar = CVar.GetCVar("weather_amount", players[consoleplayer]);
		spawner.m_Triangulation = SectorDataRegistry.GetTriangulation(sec);
		spawner.m_Frequency = density * spawner.m_Triangulation.GetArea() / 2048.0 / TICRATE;
		spawner.m_ProjectionLength = projectionTime * TICRATE;

		spawner.m_WorldAgent = worldAgent ? worldAgent : WorldAgentHandler.GetWorldAgent();

		return spawner;
	}

	override void Tick()
	{
		if (m_WorldAgent.IsFrozen()) return;

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
		return m_WeatherAmountCVar;
	}

	double GetAdjustedRange() const
	{
		int weatherSetting = m_WeatherAmountCVar.GetInt();

		if (weatherSetting == 6) weatherSetting += 2; // Increase even further for Ultra.
		return (m_Range * 2) * weatherSetting + m_Range;
	}

	double GetAdjustedFrequency() const
	{
		switch (m_WeatherAmountCVar.GetInt())
		{
			case 0: return 0.0;
			case 1: return m_Frequency * 0.2;
			case 2: return m_Frequency * 0.45;
			case 3: return m_Frequency * 0.7;
			case 4:
			default: return m_Frequency;
			case 5: return m_Frequency * 1.75;
			case 6: return m_Frequency * 2.5;
		}
	}

	void SetDensity(double density)
	{
		m_Frequency = density * m_Triangulation.GetArea() / 2048.0 / TICRATE;
	}

	protected virtual void SpawnWeatherParticle()
	{
		vector2 point = m_Triangulation.GetRandomPoint();

		// Project the player's position forward to ensure particles fall into view.
		vector2 projectedPosition = players[consoleplayer].mo.Pos.xy + (players[consoleplayer].mo.Vel.xy * m_ProjectionLength);

		if (MathVec2.SquareDistanceBetween(point, projectedPosition) > GetAdjustedRange() ** 2) return;
		vector3 position = (point.x, point.y, (m_Sector.HighestCeilingAt(point) - FRandom(2, 12)));

		Actor.Spawn(m_ParticleType, position);
	}
}