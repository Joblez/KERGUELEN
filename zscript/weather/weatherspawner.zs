class WeatherSpawner : Thinker
{
	private Sector m_Sector;
	private class<WeatherParticle> m_ParticleType;

	private double m_Frequency;
	private double m_Range;
	private double m_Time;
	private SectorTriangulation m_Triangulation;

	static WeatherSpawner Create(double density, double range, Sector sec, class<WeatherParticle> particleType)
	{
		WeatherSpawner spawner = new("WeatherSpawner");
		spawner.m_Sector = sec;
		spawner.m_ParticleType = particleType;
		spawner.m_Triangulation = SectorDataRegistry.GetTriangulation(sec);
		spawner.m_Frequency = density * spawner.m_Triangulation.GetArea() / 2048.0 / TICRATE;
		spawner.m_Range = range;

		return spawner;
	}

	override void Tick()
	{
		m_Time += 1.0 / TICRATE;

		if (m_Time >= 1.0 / m_Frequency)
		{
			do
			{
				SpawnWeatherParticle();
				m_Time -= 1.0 / m_Frequency;
			}
			while (m_Time > 0.0);
			m_Time = 0.0;
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