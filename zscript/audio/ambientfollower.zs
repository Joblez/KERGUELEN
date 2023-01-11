class AmbientFollower : Agent
{
	const AMB_COUNT = 8;

	array<AmbientPlayer> m_AudioPlayers;

	override void BeginPlay()
	{
		for (int i = 0; i < AMB_COUNT; ++i)
		{
			m_AudioPlayers.Push(AmbientPlayer(Spawn("AmbientPlayer", Pos, false)));
		}
	}
	override void Tick()
	{
		PlayerPawn pawn = players[consoleplayer].mo;

		for (int i = 0; i < AMB_COUNT; ++i)
		{
			m_AudioPlayers[i].SetOrigin(Pos + (MathVec2.PolarToCartesian((256.0, double(i - 0.5 % AMB_COUNT) / AMB_COUNT * 360.0 + pawn.Angle)), 0), false);
		}

		int sectorFollowerTID = pawn.cursector.GetUDMFInt('user_ambient_follower_tid');

		if (sectorFollowerTID == TID) SetOrigin((pawn.Pos.xy, players[consoleplayer].ViewZ), true);
	}
}

class AmbientPlayer : Agent
{
	override void BeginPlay()
	{
		A_StartSound("Rain", CHAN_AUTO, CHANF_LOOPING, 1.0 * 0.2 * sqrt(256.0), 0.4);
	}
}