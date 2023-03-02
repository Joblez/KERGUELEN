class FootstepEventHandler : EventHandler
{
	const MAX_FORWARD_MOVE = 12800;
	const MAX_SIDE_MOVE = 10240;

	transient Map<int, double> m_StepPlaybackMap;

	transient array<string> m_StepSounds;
	transient array<int> m_StepTextures;
	transient string m_DefaultStepSound;

	override void OnRegister()
	{
		m_DefaultStepSound = StringTable.Localize("$STEP_DEFAULT");

		array<String> sSTEP_FLATS_List;
		StringTable.Localize("$STEP_FLATS").Split(sSTEP_FLATS_List, ":");

		for (int i = 0; i < sSTEP_FLATS_List.Size(); ++i)
		{
			String singleFLAT_Sound = StringTable.Localize(String.Format("$STEP_%s", sSTEP_FLATS_List[i]));
			if (singleFLAT_Sound.Length() != 0)
			{
				TextureID texID = TexMan.CheckForTexture(sSTEP_FLATS_List[i], TexMan.TYPE_ANY);

				if (texID.Exists()) {
					m_StepSounds.Push(singleFLAT_Sound);
					m_StepTextures.Push(int(texID));
				}
			}
		}
	}

	override void PlayerEntered(PlayerEvent e)
	{
		m_StepPlaybackMap.Insert(e.PlayerNumber, 0.0);
	}

	override void PlayerDisconnected(PlayerEvent e)
	{
		m_StepPlaybackMap.Remove(e.PlayerNumber);
	}

	override void WorldTick()
	{
		MapIterator<int, double> it;
		it.Init(m_StepPlaybackMap);

		while (it.Next())
		{
			it.SetValue(TickPlayback(it.GetKey()));
		}
	}

	double TickPlayback(int playerIndex)
	{
		KergPlayer pawn = KergPlayer(players[playerIndex].mo);

		double playback = m_StepPlaybackMap.Get(playerIndex);

		if (!CVar.GetCVar('fs_enabled', players[playerIndex]).GetBool() || !pawn.Player.onground)
		{
			playback = 0.0;
			return playback;
		}

		double delta = pawn.GetBobPlaybackDelta();

		if (delta ~== 0.0)
		{
			playback = 0.0;
			return playback;
		}

		playback += delta;

		if (playback >= TICRATE * pawn.m_BobTime)
		{
			double speedPercentage = delta / 1.0;

			double soundLevel = CVar.GetCVar('fs_volume_mul').GetFloat() * speedPercentage;

			TextureID floorTextureID = pawn.floorpic;
			int foundIndex = m_StepTextures.Find(int(floorTextureID));

			if (foundIndex != m_StepTextures.Size())
			{
				pawn.A_StartSound(m_StepSounds[foundIndex], CHAN_AUTO, 0, soundLevel);
			}
			else
			{
				pawn.A_StartSound(m_DefaultStepSound, CHAN_AUTO, 0, soundLevel);
			}

			playback = 0.0;
		}

		return playback;
	}
}
