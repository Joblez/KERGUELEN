class WeatherHandler : EventHandler
{
	const RAIN_TAG = 3570;
	const SNOW_TAG = 3571;
	array<WeatherSpawner> m_WeatherSpawners;

	private Actor m_SpawnAgent;

	override void WorldLoaded(WorldEvent e)
	{
		if (!m_SpawnAgent) m_SpawnAgent = Actor.Spawn("NilActor", Vec3Util.Zero());
		CreateWeatherSpawners();
	}

	private void CreateWeatherSpawners()
	{
		SectorTagIterator iterator = Level.CreateSectorTagIterator(RAIN_TAG);
		int i;

		while ((i = iterator.Next()) >= 0)
		{
			m_WeatherSpawners.Push(
				WeatherSpawner.Create(14, Level.Sectors[i], "RainDrop"));
		}

		iterator = Level.CreateSectorTagIterator(SNOW_TAG);

		while ((i = iterator.Next()) >= 0)
		{
			m_WeatherSpawners.Push(
				WeatherParticleSpawner.Create(
					10,
					Level.Sectors[i],
					particleRenderStyle: STYLE_Add,
					particleTextureName: "SNOWA0",
					particleSize: 12.0,
					particleSizeDeviation: 3.0,
					initialParticleVelocity: (0.0, 0.0, -7.0),
					initialParticleVelocityDeviation: (2.0, 2.0, 3.0),
					particleAcceleration: (0.0, 0.0, -0.1),
					particleAlpha: 0.575,
					shouldSimulateParticles: true,
					spawnAgent: m_SpawnAgent));
		}
	}
}