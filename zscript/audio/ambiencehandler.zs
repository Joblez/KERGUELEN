class AmbienceHandler : EventHandler
{
	const AMBIENCE_CHANNELS_START = 11000;

	const SOUND_RANGE = 4096.0;

	Map<Sound, AmbientSoundData> m_AmbienceData;

	override void WorldLoaded(WorldEvent event)
	{
		// Gather ambience data.
		foreach (sec : level.Sectors)
		{
			// Check for ambient sound.
			string soundName = sec.GetUDMFString('user_ambient_sound');
			if (!soundName) continue;

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

		while (dataIter.Next())
		{
			AmbientSoundData data = dataIter.GetValue();
			double volume;

			if (data.m_Sectors.Find(pawn.cursector) < data.m_Sectors.Size())
			{
				// Full volume when player is in sector.
				volume = 1.0;
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

				volume = 1.0 - clamp(shortestDistance / data.m_Range, 0.0, 1.0);
				volume = Math.Ease(volume, EASE_IN_SINE);
			}

			// Console.Printf("Volume: %f", volume);
			pawn.A_SoundVolume(data.m_Channel, volume);
		}
	}

	// I refuse to make a custom lump format for this.
	private double GetAmbientSoundRange(string soundName) const
	{
		switch (Name(soundName))
		{
			case 'Rain': return 4800.0;
			default: return 512.0;
		}
	}
}

class AmbientSoundData
{
	Sound m_Sound;
	int m_Channel;
	double m_Range;
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