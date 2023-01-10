// NOTE: When documenting for usage example, make sure to mention how multiplayer will hurt performance.
class WeatherHandler : StaticEventHandler // Need to be save-game-aware to reconstruct the weather state from the sim.
{
	const RAIN_TAG = 3570;
	const SNOW_TAG = 3571;

	private WeatherAgent m_WeatherAgent;

	override void WorldLoaded(WorldEvent e)
	{
		if (!m_WeatherAgent) m_WeatherAgent = WeatherAgent(Actor.Spawn("WeatherAgent"));

		if (e.IsSaveGame)
		{
			// Already have spawners, respawn particles lost from loading the save.
			// Untested in multiplayer, likely to break.
			ReconstructWeatherParticleState();
			return;
		}

		// Create new spawners otherwise.
		CreateWeatherSpawners();
	}

	private void CreateWeatherSpawners()
	{
		SectorTagIterator iterator = level.CreateSectorTagIterator(RAIN_TAG);
		int i;

		while ((i = iterator.Next()) >= 0)
		{
			RainSpawner.Create(
				28,
				3200.0,
				level.Sectors[i],
				m_WeatherAgent);
		}

		iterator = level.CreateSectorTagIterator(SNOW_TAG);

		FSpawnParticleParams snowParams;
		snowParams.color1 = 0xFFFFFFFF;
		snowParams.texture = TexMan.CheckForTexture("SNOWA0");
		snowParams.style = STYLE_Add;
		snowParams.accel = (0.0, 0.0, 0.0);
		snowParams.startalpha = 0.635;
		snowParams.size = 12.0;
		snowParams.vel = (0.0, 0.0, -10.0);

		while ((i = iterator.Next()) >= 0)
		{
			WeatherParticleSpawner.Create(
				15,
				1700.0,
				level.Sectors[i],
				m_WeatherAgent,
				snowParams,
				sizeDeviation: 3.0,
				velDeviation: (2.0, 2.0, 1.0),
				shouldSimulateParticles: true);
		}
	}

	private void ReconstructWeatherParticleState()
	{
		let iter = ThinkerIterator.Create("WeatherParticleSpawner");

		WeatherParticleSpawner spawner = WeatherParticleSpawner(iter.Next());
		while (spawner)
		{
			spawner.ReconstructWeatherState();

			spawner = WeatherParticleSpawner(iter.Next());
		}
	}
}

/**
 * Subclass of agent for the weather to be frozen without freezing other agents.
**/
class WeatherAgent : Agent
{

}