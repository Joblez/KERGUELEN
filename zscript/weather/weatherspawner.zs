class WeatherSpawner : Thinker
{
	private double m_Frequency;
	private Sector m_Sector;
	private class<WeatherParticle> m_ParticleType;

	private double m_Time;
	private SectorTriangulation m_Triangulation;

	static WeatherSpawner Create(double frequency, Sector sec, class<WeatherParticle> particleType)
	{
		WeatherSpawner spawner = new("WeatherSpawner");
		spawner.m_Frequency = frequency;
		spawner.m_Sector = sec;
		spawner.m_ParticleType = particleType;

		return spawner;
	}

	// static WeatherSpawner GetSpawnerOfType(name type)
	// {
	// 	switch (type)
	// 	{
	// 		case 'LightRain':

	// 	}
	// }

	override void Tick()
	{
		m_Time += 1.0 / TICRATE;

		Console.Printf("m_Time: %f", m_Time);

		if (m_Time >= 1.0 / m_Frequency)
		{
			do
			{
				SpawnWeatherParticle();
				Console.Printf("Particle spawned.");
				m_Time -= 1.0 / m_Frequency;
			}
			while (m_Time > 1.0 / TICRATE)
			m_Time = 0.0;
		}
	}

	void SpawnWeatherParticle()
	{
		if (!m_Triangulation)
		{
			m_Triangulation = SectorDataRegistry.GetTriangulation(m_Sector);
		}
		vector2 point = m_Triangulation.GetRandomPoint();
		vector3 position = (point.x, point.y, (m_Sector.HighestCeilingAt(point) - 6));

		Actor.Spawn(m_ParticleType, position);
	}
}