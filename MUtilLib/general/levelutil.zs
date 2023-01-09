/** Contains level-related utilities. **/
class LevelUtil play
{
	/**
	 * Damages and thrusts Actors within a spherical radius, like an explosion.
	 *
	 * Parameters:
	 * - origin: The origin point of the explosion.
	 * - damage: The damage at the center of the explosion.
	 * - thrustForce: The thrusting force at the center of the explosion.
	 * - radius: The range of the explosion. Damage and thrust force are attenuated
	 *		linearly along this range.
	 * - thrustTarget: Whether the thrust should aim at the bottom of the target, the
	 *		center, or the top, to approximate center of mass.
	 * - exclusions: Any Actors that should not be affected by the explosion.
	 * - source: An optional Actor to be used as the source of the explosion. If not
	 *		provided, a placeholder Actor will be used instead.
	 * - inflictor: An optional Actor to be specified as the inflictor when the explosion
	 *		damages an Actor.
	 * - thrustOffset: Offset to the position that will be used to determine thrust
	 *		direction.
	 * - checkHit: Whether or not to check for blocking geometry or Actors when checking
	 *		for affected Actors. When false, the explosion will go through walls.
	**/
	static play void Explode3D(
		vector3 origin,
		int damage,
		double thrustForce,
		double radius,
		EThrustTarget thrustTarget = THRTARGET_Center,
		array<Actor> exclusions = null,
		Actor source = null,
		Actor inflictor = null,
		vector3 thrustOffset = (0.0, 0.0, 0.0),
		bool checkHit = true)
	{
		let iterator = BlockThingsIterator.CreateFromPos(origin.x, origin.y, origin.z, radius, radius, false);

		while (iterator.Next())
		{
			Actor mo = iterator.thing;

			// Ignore Actors that wouldn't normally take explosion damage.
			if (!mo.bSolid || !mo.bShootable) continue;

			// Ensure map object is not among exclusions.
			if (exclusions && exclusions.Size() > 0 && exclusions.Find(mo) != exclusions.Size()) continue;

			vector3 position;
			switch (thrustTarget)
			{
				case THRTARGET_Center:
					position = (mo.Pos.xy, mo.Pos.z + (mo.Height / 2.0));
					break;
				case THRTARGET_Top:
					position = (mo.Pos.xy, mo.Pos.z + mo.Height);
					break;
				case THRTARGET_Origin:
				default:
					position = mo.Pos;
					break;
			}

			vector3 toTarget = position - origin;
			double distance = toTarget.Length();

			// Avoid division by zero and negative radius.
			if (radius <= 0.0) radius = double.Epsilon;

			if (distance > radius) continue;

			if (!source) source = WorldAgentHandler.GetWorldAgent();

			vector3 oldPosition = source.Pos;

			source.SetOrigin(origin, false);

			FLineTraceData traceData;
			source.LineTrace(source.AngleTo(mo), radius, ActorUtil.PitchTo(source, mo), data: traceData);

			source.SetOrigin(oldPosition, false);

			if (checkHit && traceData.HitActor != mo) continue;

			int attenuatedDamage = int(round((radius - distance) / radius * damage));
			double attenuatedForce = (radius - distance) / radius * thrustForce;

			mo.DamageMobj(inflictor, source, attenuatedDamage, 'Explosive', DMG_THRUSTLESS | DMG_EXPLOSION);

			ActorUtil.Thrust3D(mo, toTarget + thrustOffset, attenuatedForce);
		}
	}
}

enum EThrustTarget
{
	THRTARGET_Origin,
	THRTARGET_Center,
	THRTARGET_Top
}