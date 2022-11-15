class LevelUtil play
{
	static play void Explode3D(
		vector3 origin,
		int damage,
		double thrustForce,
		double radius,
		EThrustTarget thrustTarget = THRTARGET_Top,
		array<Actor> exclusions = null,
		Actor source = null,
		vector3 thrustOffset = (0.0, 0.0, 0.0))
	{
		let iterator = BlockThingsIterator.CreateFromPos(origin.x, origin.y, origin.z, radius, radius, false);

		while (iterator.Next())
		{
			Actor mo = iterator.thing;

			if (!mo.bSolid || !mo.bShootable) continue;
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

			if (distance > radius) continue;

			int attenuatedDamage = int(round((radius - distance) / radius * damage));
			double attenuatedForce = (radius - distance) / radius * thrustForce;

			if (!source) source = WorldAgentHandler.GetWorldAgent();

			vector3 oldPosition = source.Pos;

			source.SetOrigin(origin, false);

			FLineTraceData traceData;
			source.LineTrace(source.AngleTo(mo), radius, ActorUtil.PitchTo(source, mo), data: traceData);

			source.SetOrigin(oldPosition, false);

			if (traceData.HitActor != mo) continue;

			mo.DamageMobj(null, source, attenuatedDamage, 'Explosive', DMG_THRUSTLESS | DMG_EXPLOSION);

			toTarget = position - (origin + thrustOffset);
			ActorUtil.Thrust3D(mo, toTarget, attenuatedForce);
		}
	}

	static play void RadiusThrust3D(
		vector3 origin,
		double force,
		double radius,
		EThrustTarget thrustTarget = THRTARGET_Top,
		array<Actor> exclusions = null)
	{
		let iterator = BlockThingsIterator.CreateFromPos(origin.x, origin.y, origin.z, radius, radius, false);

		while (iterator.Next())
		{
			Actor mo = iterator.thing;

			if (!mo.bSolid || !mo.bShootable || mo.bDontThrust) continue;
			if (exclusions && exclusions.Find(mo) != exclusions.Size()) continue;

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

			if (distance > radius) continue;

			LineTracer tracer = new("LineTracer");
			bool traceHit = tracer.Trace(origin, Level.PointInSector(origin.xy), toTarget.Unit(), distance, 0);

			if (!traceHit || tracer.Results.HitType != TRACE_HitActor || tracer.Results.HitActor != mo)
			{
				continue;
			}

			double attenuatedForce = (radius - distance) / radius * force;

			ActorUtil.Thrust3D(mo, toTarget, attenuatedForce);
		}
	}
}

enum EThrustTarget
{
	THRTARGET_Origin,
	THRTARGET_Center,
	THRTARGET_Top
}