class AmbienceHandler : EventHandler
{
	const AMBIENCE_UDMF_PROPERTY = "user_ambient_sound";
	const AMBIENCE_CHANNELS_START = 11000;
	const AMBIENCE_REBALANCE_AMOUNT = 0.5;
	const DEFAULT_SOUND_RANGE = 4096.0;

	Map<Sound, AmbientSoundData> m_AmbienceData;

	override void WorldLoaded(WorldEvent event)
	{
		// Gather ambience data.
		foreach (sec : level.Sectors)
		{
			// Check for ambient sound.
			string soundName = sec.GetUDMFString(AMBIENCE_UDMF_PROPERTY);
			if (soundName == "") continue;

			// Console.Printf("Sound: %s", soundName);

			Sound ambientSound = Sound(soundName);
			AmbientSoundData data = m_AmbienceData.Get(ambientSound);

			if (!data) data = AmbientSoundData.Create(ambientSound, AMBIENCE_CHANNELS_START + m_AmbienceData.CountUsed(), GetAmbientSoundRange(soundName));

			m_AmbienceData.Insert(ambientSound, data);
			data.m_Sectors.Push(sec);
		}

		// Console.Printf("Ambient sounds: %i", m_AmbienceData.CountUsed());

		// Start ambient sounds.
		MapIterator<Sound, AmbientSoundData> dataIter;
		dataIter.Init(m_AmbienceData);

		PlayerPawn pawn = players[consoleplayer].mo;

		while (dataIter.Next())
		{
			AmbientSoundData data = dataIter.GetValue();

			pawn.A_StartSound(data.m_Sound, data.m_Channel, CHANF_LOOPING, 1.0);
		}
	}

	override void WorldTick()
	{
		MapIterator<Sound, AmbientSoundData> dataIter;
		dataIter.Init(m_AmbienceData);

		PlayerPawn pawn = players[consoleplayer].mo;

		double totalVolume = 0.0;

		// Gather base volume per sound.
		while (dataIter.Next())
		{
			AmbientSoundData data = dataIter.GetValue();

			if (data.m_Sectors.Find(pawn.cursector) < data.m_Sectors.Size())
			{
				// Full volume when pawn is in sector.
				data.m_Volume = 1.0;
			}
			else
			{
				double shortestDistance = double.Infinity;

				// Find shortest distance between pawn and sector.
				foreach (sector : data.m_Sectors)
				{
					foreach(l : sector.lines)
					{
						double distance = Geometry.DistanceToLine(pawn.Pos.xy, l.v1.p, l.v2.p);

						if (distance < shortestDistance) shortestDistance = distance;
					}
				}

				data.m_Volume = 1.0 - clamp(shortestDistance / data.m_Range, 0.0, 1.0);
				data.m_Volume = Math.Ease(data.m_Volume, EASE_IN_SINE);
			}

			totalVolume += data.m_Volume;
		}

		// Console.Printf("Total volume: %f", totalVolume);

		dataIter.Reinit();

		// Set all sound channel volumes.
		while (dataIter.Next())
		{
			AmbientSoundData data = dataIter.GetValue();

			double attenuationFactor = totalVolume;

			// An amount of 0.0 doesn't attenuate, an amount of 1.0 rebalances all channel volumes to add up to 1.0;
			attenuationFactor = Math.Remap(clamp(AMBIENCE_REBALANCE_AMOUNT, 0.0, 1.0), 0.0, 1.0, 1.0, totalVolume);

			pawn.A_SoundVolume(data.m_Channel, data.m_Volume / attenuationFactor);

			// Console.Printf("Channel: %i, Volume: %f", data.m_Channel, data.m_Volume / attenuationFactor);
		}
	}

	// I refuse to make a custom lump format for this.
	private double GetAmbientSoundRange(string soundName) const
	{
		switch (Name(soundName))
		{
			case 'Rain': return 3600.0;
			case 'Cave': return 520.0;
			default: return DEFAULT_SOUND_RANGE;
		}
	}
}

class AmbientSoundData
{
	Sound m_Sound;
	int m_Channel;
	double m_Range;
	double m_Volume;
	array<Sector> m_Sectors;

	static AmbientSoundData Create(Sound ambientSound, int channel, double range)
	{
		AmbientSoundData data = new("AmbientSoundData");

		data.m_Sound = ambientSound;
		data.m_Channel = channel;
		data.m_Range = range;

		return data;
	}
}