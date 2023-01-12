class AmbienceHandler : EventHandler
{
	const CHANNELS_START = 11000;

	const RAIN_RANGE = 4096.0;

	Map<Sound, AmbientSoundData> m_AmbienceData;

	override void WorldLoaded(WorldEvent event)
	{
		// Gather ambience data.
		foreach (sec : level.Sectors)
		{
			// Check for ambient sound.
			string soundName = sec.GetUDMFString('user_ambient_sound');
			if (!soundName) continue;

			Console.Printf("Sound: %s", soundName);

			Sound ambientSound = Sound(soundName);
			AmbientSoundData data = m_AmbienceData.Get(ambientSound);

			if (!data) data = AmbientSoundData.Create(ambientSound, CHANNELS_START + m_AmbienceData.CountUsed(), GetAmbientSoundRange(soundName));
			m_AmbienceData.Insert(ambientSound, data);

			// Place followers at every sector triangle.
			SectorTriangulation triangulation = SectorDataRegistry.GetTriangulation(sec);

			for (int i = 0; i < triangulation.GetTriangleCount(); ++i)
			{
				AmbienceFollower follower = AmbienceFollower.Create(triangulation.GetTriangle(i));
				data.m_Followers.Push(follower);
			}
		}

		Console.Printf("Ambient sounds: %i", m_AmbienceData.CountUsed());

		// Start ambient sounds.
		MapIterator<Sound, AmbientSoundData> dataIter;
		dataIter.Init(m_AmbienceData);

		while (dataIter.Next())
		{
			AmbientSoundData data = dataIter.GetValue();
			
			players[consoleplayer].mo.A_StartSound(data.m_Sound, data.m_Channel, CHANF_LOOPING, 1.0);
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

			// foreach (follower : data.m_Followers)
			// {
			// 	FSpawnParticleParams params;
			// 	params.pos = (follower.m_Position.xy, follower.m_Position.z + 32.0);
			// 	params.color1 = 0xFFFFFFFF;
			// 	params.style = STYLE_Normal;
			// 	params.startalpha = 1.0;
			// 	params.size = 12.0;
			// 	params.lifetime = 1;
			// 	level.SpawnParticle(params);
			// }

			foreach (follower : data.m_Followers)
			{
				if (!closestFollower)
				{
					closestFollower = follower;
					continue;
				}

				if (follower.m_Triangle.ContainsPoint(pawn.Pos.xy))
				{
					follower.m_Position = pawn.Pos;
					closestFollower = follower;
					break;
				}

				if (MathVec3.DistanceBetween(pawn.Pos, follower.m_Position) < MathVec3.DistanceBetween(pawn.Pos, closestFollower.m_Position))
				{
					closestFollower = follower;
				}
			}

			double volume = 1.0 - clamp(MathVec3.DistanceBetween(closestFollower.m_Position, pawn.Pos) / data.m_Range, 0.0, 1.0);
			volume = Math.Ease(volume, EASE_IN_QUAD);

			Console.Printf("Volume: %f", volume);

			pawn.A_SoundVolume(data.m_Channel, volume);
		}
	}

	// I refuse to make a custom lump format for this.
	private double GetAmbientSoundRange(string soundName) const
	{
		switch (Name(soundName))
		{
			case 'Rain': return 3920.0;
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