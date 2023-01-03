class WeatherSpawner : Thinker
{
	protected Sector m_Sector;
	protected class<WeatherActor> m_WeatherType;

	protected double m_Frequency;
	protected double m_Range;
	protected double m_ProjectionLength;

	protected SectorTriangulation m_Triangulation;
	protected transient CVar m_WeatherAmountCVar;

	WeatherAgent m_WeatherAgent;

	private double m_Time;

	static WeatherSpawner Create(double density, double range, Sector sec, class<WeatherActor> weatherType, WeatherAgent agent, double projectionTime = 1.0)
	{
		WeatherSpawner spawner = new("WeatherSpawner");
		spawner.Init(density, range, sec, weatherType, agent, projectionTime);
		return spawner;
	}

	void Init(double density, double range, Sector sec, class<WeatherActor> weatherType, WeatherAgent agent, double projectionTime = 1.0)
	{
		m_Range = range;
		m_Sector = sec;
		m_WeatherType = weatherType;
		m_WeatherAmountCVar = CVar.GetCVar("weather_amount", players[consoleplayer]);
		m_Triangulation = SectorDataRegistry.GetTriangulation(sec);
		m_Frequency = density * m_Triangulation.GetArea() / 2048.0 / TICRATE;
		m_ProjectionLength = projectionTime * TICRATE;
		m_WeatherAgent = agent;
	}

	override void Tick()
	{
		if (m_WeatherAgent.IsFrozen()) return;

		double frequency = GetAdjustedFrequency();
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

	Sector GetSector() const
	{
		return m_Sector;
	}

	CVar GetWeatherAmountCVar() const
	{
		if (!m_WeatherAmountCVar) m_WeatherAmountCVar = CVar.GetCVar("weather_amount", players[consoleplayer]);
		return m_WeatherAmountCVar;
	}

	double GetAdjustedFrequency() const
	{
		switch (GetWeatherAmountCVar().GetInt())
		{
			case 0: return 0.0;
			case 1: return m_Frequency * 0.2;
			case 2: return m_Frequency * 0.45;
			case 3: return m_Frequency * 0.7;
			case 4:
			default: return m_Frequency;
			case 5: return m_Frequency * 1.4;
			case 6: return m_Frequency * 2.0;
		}
	}

	double GetOutOfViewFrequencyReduction() const
	{
		return GetWeatherAmountCVar().GetInt() * 0.05;
	}

	void SetDensity(double density)
	{
		m_Frequency = density * m_Triangulation.GetArea() / 2048.0 / TICRATE;
	}

	protected virtual void SpawnWeatherParticle()
	{
		vector2 point = m_Triangulation.GetRandomPoint();

		// Project the player's position forward to ensure particles fall into view.
		vector2 projectedPosition = ProjectPlayerPosition(abs(GetDefaultByType(m_WeatherType).Vel.z));

		double distance = MathVec2.SquareDistanceBetween(point, projectedPosition);
		double range = m_Range ** 2.0;

		// Cull outside range.
		if (distance > range) return;

		// Attenuate amount over distance.
		double spawnThreshold = Math.Remap(distance, 0.0, range, 0.0, 0.5);
		if (FRandom(0.0, 1.0) < 1.0 - spawnThreshold) return;

		vector3 spawnPosition = (point.x, point.y, (m_Sector.HighestCeilingAt(point) - FRandom(2, 12)));

		Actor pawn = players[consoleplayer].mo;

		// Reduce spawn chance outside of horizontal view range.
		if (Actor.absangle(pawn.Angle, vectorangle(point.x - pawn.Pos.x, point.y - pawn.Pos.y))
				>= players[consoleplayer].FOV * 0.5 * ScreenUtil.GetAspectRatio()
			&& FRandom(0, 1) > GetOutOfViewFrequencyReduction())
		{
			Actor.Spawn(m_WeatherType, spawnPosition);
		}
		return;
	}

	protected vector2 ProjectPlayerPosition(double weatherVerticalSpeed)
	{
		Actor pawn = players[consoleplayer].mo;

		double ceilingZ = GetSector().HighestCeilingAt(players[consoleplayer].mo.Pos.xy);

		// Might be inaccurate because of slopes, but there is no way to get the height at
		// the projected position before projecting it.
		double targetZ = pawn.Pos.z;

		double projectionTime = abs(ceilingZ - targetZ) / (max(double.Epsilon, abs(weatherVerticalSpeed)) * m_Range) * TICRATE ** 2;

		return pawn.Vel.xy * projectionTime + pawn.Pos.xy;
	}
}