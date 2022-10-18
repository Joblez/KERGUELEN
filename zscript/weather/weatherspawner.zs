class WeatherSpawner : Thinker
{
	private Sector m_Sector;
	private class<WeatherParticle> m_ParticleType;

	private double m_Frequency;
	private double m_Time;
	private SectorTriangulation m_Triangulation;

	static WeatherSpawner Create(double density, Sector sec, class<WeatherParticle> particleType)
	{
		WeatherSpawner spawner = new("WeatherSpawner");
		spawner.m_Sector = sec;
		spawner.m_ParticleType = particleType;
		spawner.m_Triangulation = SectorDataRegistry.GetTriangulation(sec);
		spawner.m_Frequency = density * sqrt(spawner.m_Triangulation.GetArea()) / TICRATE;

		Console.Printf("Sector: %i, Frequency: %f", sec.Index(), spawner.m_Frequency);
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

	void SpawnWeatherParticle()
	{
		vector2 point = m_Triangulation.GetRandomPoint();
		if (MathVec2.SquareDistanceBetween(point, players[consoleplayer].mo.Pos.xy) > 1536 * 1536) return;
		vector3 position = (point.x, point.y, (m_Sector.HighestCeilingAt(point) - 6));

		Actor.Spawn(m_ParticleType, position);
	}
}