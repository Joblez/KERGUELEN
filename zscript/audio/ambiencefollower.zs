class AmbienceFollower : DebugAgent
{
	string m_AmbientSoundName;

	override void Tick()
	{
		string sectorAmbientSound = players[consoleplayer].mo.cursector.GetUDMFString('user_ambient_sound');

		if (m_AmbientSoundName == sectorAmbientSound) SetOrigin(players[consoleplayer].mo.Pos, true);
	}
}