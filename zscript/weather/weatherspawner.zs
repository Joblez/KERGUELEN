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
		m_ProjectionLength = projectionTime * TICRATE;
		m_WeatherAgent = agent;
		m_Triangulation = SectorDataRegistry.GetTriangulation(sec);
		m_Frequency = density * m_Triangulation.GetArea() / 4096.0 / TICRATE;
	}

	override void Tick()
	{
		if (m_WeatherAgent.IsFrozen()) return;

		if (m_Frequency == 0.0) return;

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

	Sector GetSector() const { return m_Sector; }

	CVar GetWeatherAmountCVar(PlayerInfo player) const
	{
		return CVar.GetCVar('weather_amount', player);
	}

	double GetSpawnChanceReduction(PlayerInfo player) const
	{
		switch (GetWeatherAmountCVar(player).GetInt())
		{
			default:
			case 0: return 0.0;		// Off.
			case 1: return 0.1;		// Very low.
			case 2: return 0.2;		// Low.
			case 3: return 0.35;	// Medium.
			case 4: return 0.5;		// High.
			case 5: return 0.75;	// Very high.
			case 6: return 1.0;		// Ultra.
		}
	}

	void SetDensity(double density)
	{
		m_Frequency = density * m_Triangulation.GetArea() / 2048.0 / TICRATE;
	}

	protected virtual void SpawnWeatherParticle() const
	{
		vector2 point = m_Triangulation.GetRandomPoint();
		double spawnScore = FRandom[Weather](0.0, 1.0);
		if (!ShouldSpawn(point, spawnScore, 0.0, 0.5, 0.3)) return;

		Actor.Spawn(m_WeatherType, (point.x, point.y, m_Sector.ceilingplane.ZatPoint(point) - FRandom[Weather](2, 12)));
	}

	protected virtual double GetWeatherVerticalSpeed() const { return abs(GetDefaultByType(m_WeatherType).Vel.z); }

	protected bool ShouldSpawn(
		vector2 point,
		double spawnScore,
		double minSpawnThreshold,
		double maxSpawnThreshold,
		double outOfViewThreshold = 0.0) const
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

			// Cull based on weather setting.
			if (spawnScore < 1.0 - GetSpawnChanceReduction(player)) continue;

			// Map spawn threshold along distance.
			double spawnThreshold = Math.Remap(distance, 0.0, range, minSpawnThreshold, maxSpawnThreshold);

			if (spawnScore < spawnThreshold) continue;
			
			// Additional threshold for out-of-view effects.
			if (IsOutOfView(player, point) && spawnScore < outOfViewThreshold) continue;

			return true;
		}

		return false;
	}

	protected bool IsOutOfView(PlayerInfo player, vector2 point) const
	{
		// Screen dependency breaks multiplayer compat. Assume 16:9 for now.
		return Actor.absangle(player.mo.Angle, vectorangle(point.x - player.mo.Pos.x, point.y - player.mo.Pos.y))
			>= player.FOV * 0.5 * 1.77777777778; /* ScreenUtil.GetAspectRatio() */;
	}

	protected vector2 ProjectPlayerPosition(PlayerPawn pawn) const
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