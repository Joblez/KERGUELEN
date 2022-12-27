class WeatherHandler : EventHandler
{
	const RAIN_TAG = 3570;
	const SNOW_TAG = 3571;
	array<WeatherSpawner> m_WeatherSpawners;

	private WeatherAgent m_WeatherAgent;

	override void WorldLoaded(WorldEvent e)
	{
		if (!m_WeatherAgent) m_WeatherAgent = WeatherAgent(Actor.Spawn("WeatherAgent"));

		CreateWeatherSpawners();
	}

	private void CreateWeatherSpawners()
	{
		SectorTagIterator iterator = Level.CreateSectorTagIterator(RAIN_TAG);
		int i;

		while ((i = iterator.Next()) >= 0)
		{
			// TODO: Replace with particle spawner once particle billboarding can be disabled.
			m_WeatherSpawners.Push(
				RainSpawner.Create(
					12,
					256.0,
					Level.Sectors[i],
					m_WeatherAgent));
		}

		iterator = Level.CreateSectorTagIterator(SNOW_TAG);

		FSpawnParticleParams snowParams;
		snowParams.color1 = 0xFFFFFFFF;
		snowParams.texture = TexMan.CheckForTexture("SNOWA0");
		snowParams.style = STYLE_Add;
		snowParams.size = 8.0 + FRandom(-3.0, 3.0);
		snowParams.vel = (0.0, 0.0, -2.5) + Vec3Util.Random(-2.0, 2.0, -2.0, 2.0, -1.0, 1.0);
		snowParams.accel = (0.0, 0.0, -0.05);
		snowParams.startalpha = 0.635;

		while ((i = iterator.Next()) >= 0)
		{
			m_WeatherSpawners.Push(
				WeatherParticleSpawner.Create(
					10,
					384.0,
					Level.Sectors[i],
					m_WeatherAgent,
					snowParams,
					projectionTime: 3.0,
					shouldSimulateParticles: true));
		}
	}
}

/**
 * Subclass of agent for the weather to be frozen without freezing other agents.
**/
class WeatherAgent : Agent
{

}