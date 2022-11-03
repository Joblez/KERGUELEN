class StepAudioPlayer : Thinker
{
	// Extents.
	const MAX_FORWARD_MOVE = 12800;
	const MAX_SIDE_MOVE = 10240;

	//the player footsteps are attached to.
	PlayerPawn m_PlayerPawn;

	array<string> m_StepSounds;
	array<int> m_StepTextures;
	string m_DefaultStepSound;

	double m_StepInterval;

	//VSO: only needed for debug.
	array<string> m_StepTextureNames;

	private vector3 m_PreviousPlayerVel;
	private double m_StepPlayback;

	static StepAudioPlayer Create(PlayerPawn inPlayer, double stepInterval)
	{
		StepAudioPlayer stepAudioPlayer = new("StepAudioPlayer");
		stepAudioPlayer.m_StepInterval = stepInterval * TICRATE;
		stepAudioPlayer.m_PlayerPawn = inPlayer;

		stepAudioPlayer.m_DefaultStepSound = StringTable.Localize("$STEP_DEFAULT");

		array<String> sSTEP_FLATS_List;
		StringTable.Localize("$STEP_FLATS").Split(sSTEP_FLATS_List, ":");

		for (int i = 0; i < sSTEP_FLATS_List.Size(); ++i)
		{
			String singleFLAT_Sound = StringTable.Localize(String.Format("$STEP_%s", sSTEP_FLATS_List[i]));
			if (singleFLAT_Sound.Length() != 0)
			{
				TextureID texID = TexMan.CheckForTexture(sSTEP_FLATS_List[i], TexMan.TYPE_ANY);

				if (texID.Exists()) {
					stepAudioPlayer.m_StepSounds.Push(singleFLAT_Sound);
					stepAudioPlayer.m_StepTextures.Push(int(texID));

					stepAudioPlayer.m_StepTextureNames.Push(sSTEP_FLATS_List[i]);
				}
			}
		}

		return stepAudioPlayer;
	}

	override void Tick()
	{
		if (CVar.GetCvar("fs_enabled").GetInt() == 0 || m_PlayerPawn.Pos.z - m_PlayerPawn.FloorZ > 0)
		{
			Super.Tick();
			m_PreviousPlayerVel = m_PlayerPawn.Vel;
			return;
		}

		double movementSpeed = m_PlayerPawn.Vel.xy.Length();
		double maxSpeed = m_PlayerPawn.Speed * 8.3333333 * m_PlayerPawn.ForwardMove1;

		double speedPercentage = min(movementSpeed / maxSpeed, 1.85);
		int forwardMove = m_PlayerPawn.GetPlayerInput(MODINPUT_FORWARDMOVE);
		int sideMove = m_PlayerPawn.GetPlayerInput(MODINPUT_SIDEMOVE);

		m_StepPlayback += 1 * speedPercentage;

		if (speedPercentage ~== 0.0)
		{
			m_StepPlayback = 0.0;
		}

		if (m_StepPlayback < m_StepInterval)
		{
			Super.Tick();
			m_PreviousPlayerVel = m_PlayerPawn.Vel;
			return;
		}

		double soundLevel = CVar.GetCvar("fs_volume_mul").GetFloat() * speedPercentage;

		int floorTextureID = int(self.m_PlayerPawn.floorpic);
		int foundIndex = m_StepTextures.Find(floorTextureID);

		if (foundIndex != m_StepTextures.Size())
		{
			S_StartSound(m_StepSounds[foundIndex], CHAN_AUTO, 0, soundLevel);
		}
		else
		{
			S_StartSound(m_DefaultStepSound, CHAN_AUTO,0, soundLevel);
		}

		m_StepPlayback = 0.0;

		Super.Tick();
		m_PreviousPlayerVel = m_PlayerPawn.Vel;
	}
}

class FootstepEventHandler : EventHandler
{
	array<StepAudioPlayer> m_StepAudioPlayers;

	override void PlayerEntered(PlayerEvent e)
	{
		let player = PlayerPawn(players[e.PlayerNumber].mo);

		//BEGIN VSO : Some Wads crash here with VM Abort because player can be NULL
		if (player == NULL) {
			return;
		}

		//VSO: Attach footsteps to player:
		m_StepAudioPlayers.Push(StepAudioPlayer.Create(player, 0.45));
	}
}
