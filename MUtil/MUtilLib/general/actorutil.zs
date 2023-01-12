/** Contains several Actor-related utilities. **/
class ActorUtil
{
	/**
	 * Returns the pitch value that would point to the [other] Actor from the perspective
	 * of the [this] Actor. Equivalent to Actor.AngleTo(), but for the Y-axis.
	 *
	 * Parameters:
	 *	- this: The Actor used as a reference point.
	 *	- other: The target Actor.
	 *	- absolute: Whether or not the result should factor in portal offsets.
	 *	- centerHeight: Whether or not the method should aim from the vertical centers of
	 *		the Actors rather than their origins, which are usually at the bottom.
	**/
	static double PitchTo(Actor this, Actor other, bool absolute = false, bool centerHeight = true)
	{
		vector3 origin = this.Pos;
		vector3 target = absolute ? other.Pos : other.PosRelative(this.cursector);

		if (centerHeight)
		{
			origin.z += this.Height / 2.0;
			target.z += other.Height / 2.0;
		}

		return -VectorAngle((target.xy - origin.xy).Length(), target.z - origin.z);
	}

	/**
	 * Convenience method for calling LevelUtil.Explode3D using an Actor as a source.
	 * See LevelUtil.Explode3D for parameter info.
	**/
	static play void Explode3D(
		Actor origin,
		int damage,
		double thrustForce,
		double radius,
		EThrustTarget thrustTarget = THRTARGET_Center,
		array<Actor> exclusions = null,
		Actor inflictor = null,
		vector3 thrustOffset = (0.0, 0.0, 0.0),
		bool checkHit = true)
	{
		LevelUtil.Explode3D(origin.Pos, damage, thrustForce, radius, thrustTarget, exclusions, origin, inflictor, thrustOffset, checkHit);
	}

	/**
	 * Thrusts an actor using a 3D direction vector.
	 *
	 * Parameters:
	 *	- target: The Actor to thrust.
	 *	- direction: The direction of the force.
	 *	- force: The amount of force to apply.
	 *	- overrideMomentum: Whether or not the force should taker the target's current
	 *		velocity into account.
	 *	- ignoreMass: Whether or not to disregard the target Actor's mass property. When
	 *		false, the force applied will be divided by 17.5% of the target's mass.
	**/
	static play void Thrust3D(
		Actor target,
		vector3 direction,
		double force,
		bool overrideMomentum = false,
		bool ignoreMass = false)
	{
		if (target.bDontThrust) return;

		target.Vel = (overrideMomentum ? Vec3Util.Zero() : target.Vel)
			+ (direction.Unit() * force / (ignoreMass ? 1 : target.Mass * 0.175));
	}
}