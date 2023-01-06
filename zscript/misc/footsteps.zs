class StepAudioData
{
	double m_StepInterval;
	double m_StepPlayback;

	static StepAudioData Create(double stepInterval)
	{
		StepAudioData stepAudioPlayer = new("StepAudioData");
		stepAudioPlayer.m_StepInterval = stepInterval;

		return stepAudioPlayer;
	}
}

class FootstepEventHandler : EventHandler
{
	const MAX_FORWARD_MOVE = 12800;
	const MAX_SIDE_MOVE = 10240;

	transient Map<int, StepAudioData> m_StepAudioDataMap;

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
		m_StepAudioDataMap.Insert(e.PlayerNumber, StepAudioData.Create(0.5 * TICRATE));
	}

	override void PlayerDisconnected(PlayerEvent e)
	{
		m_StepAudioDataMap.Remove(e.PlayerNumber);
	}

	override void WorldTick()
	{
		MapIterator<int, StepAudioData> it;
		it.Init(m_StepAudioDataMap);

		while (it.Next())
		{
			TickData(it.GetKey(), it.GetValue());
		}
	}

	void TickData(int playerIndex, StepAudioData data)
	{
		PlayerPawn pawn = PlayerPawn(players[playerIndex].mo);

		if (!CVar.GetCVar("fs_enabled", players[playerIndex]).GetBool() || pawn.Pos.z - pawn.FloorZ > 0)
		{
			return;
		}

		double movementSpeed = pawn.Vel.xy.Length();
		double maxSpeed = pawn.Speed * 8.3333333 * pawn.ForwardMove1;

		double speedPercentage = min(movementSpeed / maxSpeed, 1.85);
		int forwardMove = pawn.GetPlayerInput(MODINPUT_FORWARDMOVE);
		int sideMove = pawn.GetPlayerInput(MODINPUT_SIDEMOVE);

		data.m_StepPlayback += 1 * speedPercentage;

		if (speedPercentage ~== 0.0) data.m_StepPlayback = 0.0;

		if (data.m_StepPlayback < data.m_StepInterval) return;

		double soundLevel = CVar.GetCVar("fs_volume_mul").GetFloat() * speedPercentage;

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

		data.m_StepPlayback = 0.0;
	}
}
