class WeatherHandler : EventHandler
{
	const RAIN_TAG = 3570;
	const SNOW_TAG = 3571;
	array<WeatherSpawner> m_WeatherSpawners;

	override void WorldLoaded(WorldEvent e)
	{
		CreateWeatherSpawners();
	}

	private void CreateWeatherSpawners()
	{
		SectorTagIterator iterator = Level.CreateSectorTagIterator(RAIN_TAG);
		int i;

		while ((i = iterator.Next()) >= 0)
		{
			m_WeatherSpawners.Push(
				WeatherSpawner.Create(12, 2048, Level.Sectors[i], "RainDrop"));
		}

		iterator = Level.CreateSectorTagIterator(SNOW_TAG);
		
		while ((i = iterator.Next()) >= 0)
		{
			Console.Printf("Creating snow spawner at %i", Level.Sectors[i].Index());
			m_WeatherSpawners.Push(
				WeatherSpawner.Create(6, 1024, Level.Sectors[i], "Snowflake"));
		}
	}
}