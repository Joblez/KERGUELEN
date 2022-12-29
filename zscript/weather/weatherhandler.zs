class WeatherHandler : StaticEventHandler // Need to be save-game-aware to reconstruct the weather state from the sim.
{
	const RAIN_TAG = 3570;
	const SNOW_TAG = 3571;
	array<WeatherSpawner> m_WeatherSpawners;

	private WeatherAgent m_WeatherAgent;

	override void WorldLoaded(WorldEvent e)
	{
		Console.Printf("Spawners: %i", m_WeatherSpawners.Size());
		if (!m_WeatherAgent) m_WeatherAgent = WeatherAgent(Actor.Spawn("WeatherAgent"));

		if (e.IsSaveGame)
		{
			// Already have spawners, respawn particles lost from loading the save.
			ReconstructWeatherParticleState();
			return;
		}

		// Create new spawners otherwise.
		CreateWeatherSpawners();
	}

	override void WorldTick()
	{
		foreach (spawner : m_WeatherSpawners)
		{
			spawner.Tick();
		}
	}

	private void CreateWeatherSpawners()
	{
		SectorTagIterator iterator = level.CreateSectorTagIterator(RAIN_TAG);
		int i;

		while ((i = iterator.Next()) >= 0)
		{
			m_WeatherSpawners.Push(
				RainSpawner.Create(
					12,
					280.0,
					level.Sectors[i],
					m_WeatherAgent));
		}

		iterator = level.CreateSectorTagIterator(SNOW_TAG);

		FSpawnParticleParams snowParams;
		snowParams.color1 = 0xFFFFFFFF;
		snowParams.texture = TexMan.CheckForTexture("SNOWA0");
		snowParams.style = STYLE_Add;
		snowParams.accel = (0.0, 0.0, -0.05);
		snowParams.startalpha = 0.635;

		while ((i = iterator.Next()) >= 0)
		{
			snowParams.size = 8.0 + FRandom(-3.0, 3.0);
			snowParams.vel = (0.0, 0.0, -2.5) + Vec3Util.Random(-2.0, 2.0, -2.0, 2.0, -1.0, 1.0);

			m_WeatherSpawners.Push(
				WeatherParticleSpawner.Create(
					10,
					256.0,
					level.Sectors[i],
					m_WeatherAgent,
					snowParams,
					projectionTime: 3.0,
					shouldSimulateParticles: true));
		}
	}

	private void ReconstructWeatherParticleState()
	{
		foreach(spawner : m_WeatherSpawners)
		{
			spawner.m_WeatherAgent = m_WeatherAgent;
			WeatherParticleSpawner particleSpawner = WeatherParticleSpawner(spawner);

			if (particleSpawner) particleSpawner.ReconstructWeatherState();
		}
	}
}

/**
 * Subclass of agent for the weather to be frozen without freezing other agents.
**/
class WeatherAgent : Agent
{

}