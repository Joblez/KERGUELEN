struct ActorUtil
{
	static vector3 PosRelativeToActor(Actor this, Actor other)
	{
		return this.PosRelative(other.cursector);
	}

	static double PitchTo(Actor this, Actor other, bool absolute = false, bool centerHeight = true)
	{
		vector3 origin = this.Pos;
		vector3 target = absolute ? other.Pos : PosRelativeToActor(other, this);

		if (centerHeight)
		{
			origin.z += this.Height / 2.0;
			target.z += other.Height / 2.0;
		}

		return -VectorAngle((target.xy - origin.xy).Length(), target.z - origin.z);
	}
}