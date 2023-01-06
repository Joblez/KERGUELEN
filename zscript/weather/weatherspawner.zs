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
		m_Frequency = density * m_Triangulation.GetArea() / 4096.0 / TICRATE;
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

	Sector GetSector() const { return m_Sector; }

	CVar GetWeatherAmountCVar() const
	{
		if (!m_WeatherAmountCVar) m_WeatherAmountCVar = CVar.GetCVar("weather_amount", players[consoleplayer]);
		return m_WeatherAmountCVar;
	}

	double GetAdjustedFrequency() const
	{
		int amount = GetWeatherAmountCVar().GetInt();

		if (amount == 6) return m_Frequency * 1.5;

		return amount * 0.2;
	}

	double GetOutOfViewFrequencyReduction() const { return GetWeatherAmountCVar().GetInt() * 0.05; }

	void SetDensity(double density)
	{
		m_Frequency = density * m_Triangulation.GetArea() / 2048.0 / TICRATE;
	}

	protected virtual void SpawnWeatherParticle()
	{
		vector2 point = m_Triangulation.GetRandomPoint();
		double spawnScore = FRandom(0.0, 1.0);
		if (!ShouldSpawn(point, spawnScore)) return;

		Actor.Spawn(m_WeatherType, (point.x, point.y, m_Sector.HighestCeilingAt(point) - FRandom(2, 12)));
	}

	protected virtual double GetWeatherVerticalSpeed() const { return abs(GetDefaultByType(m_WeatherType).Vel.z); }

	protected bool ShouldSpawn(vector2 point, double spawnScore)
	{
		foreach (player : players)
		{
			if (!player.mo) continue;

			// Project the player's position forward to ensure particles fall into view.
			vector2 projectedPosition = ProjectPlayerPosition(player.mo);

			double distance = MathVec2.SquareDistanceBetween(point, projectedPosition);
			double range = m_Range ** 2.0;

			// Cull outside range.
			if (distance > range) continue;

			// Attenuate amount over distance.
			double spawnThreshold = Math.Remap(distance, 0.0, range, 0.0, 0.5);

			// Screen dependency breaks multiplayer compat. Assume 16:9 for now.
			bool isOutOfView = Actor.absangle(player.mo.Angle, vectorangle(point.x - player.mo.Pos.x, point.y - player.mo.Pos.y))
				>= player.FOV * 0.5 * 1.77777777778; /* ScreenUtil.GetAspectRatio() */;

			// Reduce spawn chance outside of horizontal view range.
			if (isOutOfView) spawnThreshold += GetOutOfViewFrequencyReduction();

			if (spawnScore >= spawnThreshold) return true;
		}

		return false;
	}

	protected vector2 ProjectPlayerPosition(PlayerPawn pawn)
	{
		double ceilingZ = GetSector().HighestCeilingAt(pawn.Pos.xy);

		// Might be inaccurate because of slopes, but there is no way to get the height at
		// the projected position before projecting it.
		double targetZ = pawn.Pos.z;

		// Clamp to ten seconds.
		// Not sure how to account for acceleration here.
		double projectionTime = min(10.0, abs(ceilingZ - targetZ) / (max(double.Epsilon, abs(GetWeatherVerticalSpeed())) * m_Range)) * TICRATE ** 2.0;

		return pawn.Vel.xy * projectionTime + pawn.Pos.xy;
	}
}