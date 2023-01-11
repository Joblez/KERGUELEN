class AmbientFollower : Agent
{
	const AUDIO_PLAYER_COUNT = 8;

	array<AmbientPlayer> m_AudioPlayers;

	override void BeginPlay()
	{
		for (int i = 0; i < AUDIO_PLAYER_COUNT; ++i)
		{
			m_AudioPlayers.Push(AmbientPlayer(Spawn("AmbientPlayer", Pos + (MathVec2.PolarToCartesian((128.0, double(i) / AUDIO_PLAYER_COUNT * 360.0)), 0), false)));
		}
	}
	override void Tick()
	{
		for (int i = 0; i < AUDIO_PLAYER_COUNT; ++i)
		{
			m_AudioPlayers[i].SetOrigin(Pos + (MathVec2.PolarToCartesian((128.0, double(i) / AUDIO_PLAYER_COUNT * 360.0)), 0), false);
		}

		PlayerPawn pawn = players[consoleplayer].mo;

		int sectorFollowerTID = pawn.cursector.GetUDMFInt('user_ambient_follower_tid');

		if (sectorFollowerTID == TID) SetOrigin((pawn.Pos.xy, players[consoleplayer].ViewZ), true);
	}
}

class AmbientPlayer : Agent
{
	override void BeginPlay()
	{
		A_StartSound("Rain", CHAN_AUTO, CHANF_LOOPING, 1.0 * 0.4 * sqrt(128.0), 0.4);
	}

	override void Tick()
	{
		FSpawnParticleParams p;
		p.pos = Pos;
		p.color1 = 0xFFFFFFFF;
		p.lifetime = 1;
		p.size = 30.0;
		p.startalpha = 1.0;
		p.fadestep = 0.0;
		level.SpawnParticle(p);
	}
}