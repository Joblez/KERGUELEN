class WeatherSpawner : Thinker
{
	private Sector m_Sector;
	private class<WeatherParticle> m_ParticleType;

	private double m_Frequency;
	private double m_Range;
	private double m_Time;
	private SectorTriangulation m_Triangulation;
	private CVar m_WeatherAmountCVar;

	static WeatherSpawner Create(double density, double range, Sector sec, class<WeatherParticle> particleType)
	{
		WeatherSpawner spawner = new("WeatherSpawner");
		spawner.m_WeatherAmountCVar = CVar.GetCVar("weather_amount", players[consoleplayer]);
		spawner.m_Sector = sec;
		spawner.m_ParticleType = particleType;
		spawner.m_Triangulation = SectorDataRegistry.GetTriangulation(sec);
		spawner.m_Frequency = density * spawner.m_Triangulation.GetArea() / 2048.0 / TICRATE;
		spawner.m_Range = range;

		return spawner;
	}

	override void Tick()
	{
		double frequency = GetFrequencyAdjustedForSettings();
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

	double GetFrequencyAdjustedForSettings() const
	{
		switch (m_WeatherAmountCVar.GetInt())
		{
			case 0: return 0;
			case 1: return m_Frequency * 0.1;
			case 2: return m_Frequency * 0.4;
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

	private void SpawnWeatherParticle()
	{
		vector2 point = m_Triangulation.GetRandomPoint();
		if (MathVec2.SquareDistanceBetween(point, players[consoleplayer].mo.Pos.xy) > m_Range ** 2) return;
		vector3 position = (point.x, point.y, (m_Sector.HighestCeilingAt(point) - FRandom(2, 12)));

		Actor.Spawn(m_ParticleType, position);
	}
}