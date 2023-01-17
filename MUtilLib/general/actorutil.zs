/** Contains several Actor-related utilities. **/
class ActorUtil
{
	/**
	 * Convenience method for calling Actor.PitchTo() with offsets set to the vertical
	 * centers of the given actors.
	**/
	static double PitchTo(Actor this, Actor other, bool absolute = false, bool centerHeight = true)
	{
		return this.PitchTo(other, (centerHeight ? this.Height / 2.0 : 0.0), (centerHeight ? other.Height / 2.0 : 0.0), absolute);
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