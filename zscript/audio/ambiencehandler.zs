class AmbienceHandler : EventHandler
{
	const CHANNELS_START = 11000;

	const RAIN_RANGE = 4096.0;

	Map<Sound, AmbientSoundData> m_AmbienceData;

	override void WorldLoaded(WorldEvent event)
	{
		// Gather ambience data.
		let thingIter = ThinkerIterator.Create("AmbienceFollower");
		Thinker thing;
		while (!!(thing = thingIter.Next()))
		{
			AmbienceFollower follower = AmbienceFollower(thing);

			string soundName = follower.cursector.GetUDMFString('user_ambient_sound');
			if (!soundName) continue;

			follower.m_AmbientSoundName = soundName;

			Sound ambientSound = Sound(soundName);
			AmbientSoundData data = m_AmbienceData.Get(ambientSound);

			if (!data) data = AmbientSoundData.Create(ambientSound, CHANNELS_START + m_AmbienceData.CountUsed(), GetAmbientSoundRange(soundName));
			m_AmbienceData.Insert(ambientSound, data);

			data.m_Followers.Push(follower);
		}

		// Start ambient sounds.
		MapIterator<Sound, AmbientSoundData> dataIter;
		dataIter.Init(m_AmbienceData);

		while (dataIter.Next())
		{
			AmbientSoundData data = dataIter.GetValue();
			
			Console.Printf("Starting ambient sound on channel %i.", data.m_Channel);
			players[consoleplayer].mo.A_StartSound(data.m_Sound, data.m_Channel, 0, 1.0);
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
			
			AmbienceFollower closestFollower;

			foreach (follower : data.m_Followers)
			{
				if (!closestFollower)
				{
					closestFollower = follower;
					continue;
				}

				if (follower.Distance3D(pawn) < closestFollower.Distance3D(pawn))
				{
					closestFollower = follower;
				}
			}

			double volume = 1.0 - clamp(closestFollower.Distance3D(pawn) / data.m_Range, 0.0, 1.0);
			volume = Math.Ease(volume, EASE_IN_QUAD);

			Console.Printf("Volume: %f", volume);

			players[consoleplayer].mo.A_SoundVolume(data.m_Channel, volume);
		}
	}

	// I refuse to make a custom lump format for this.
	private double GetAmbientSoundRange(string soundName) const
	{
		switch (Name(soundName))
		{
			case 'Rain': return 4096.0;
			default: return 512.0;
		}
	}
}

class AmbientSoundData
{
	Sound m_Sound;
	int m_Channel;
	double m_Range;
	array<AmbienceFollower> m_Followers;

	static AmbientSoundData Create(Sound ambientSound, int channel, double range)
	{
		AmbientSoundData data = new("AmbientSoundData");

		data.m_Sound = ambientSound;
		data.m_Channel = channel;
		data.m_Range = range;

		return data;
	}
}