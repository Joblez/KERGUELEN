mixin class ProjectileExt
{
	PlayerInfo GetTargetPlayerOrConsolePlayer()
	{
		PlayerInfo targetPlayer;
		if (target && target.player)
		{
			return target.player;
		}
		else
		{
			return players[consoleplayer];
		}
	}
}