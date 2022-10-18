class WeatherHandler : EventHandler
{
	const WEATHER_TAG = 3570;
	array<WeatherSpawner> m_WeatherSpawners;

	override void WorldLoaded(WorldEvent e)
	{
		CreateWeatherSpawners();
	}

	private void CreateWeatherSpawners()
	{
		let iterator = Level.CreateSectorTagIterator(WEATHER_TAG);
		int i;

		while ((i = iterator.Next()) >= 0)
		{
			m_WeatherSpawners.Push(
				WeatherSpawner.Create(10, Level.Sectors[i], "RainDrop"));
		}
	}
}