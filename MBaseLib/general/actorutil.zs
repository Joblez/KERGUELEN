class ActorUtil
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

	static play void Thrust3D(Actor target, vector3 direction, double force, bool overrideMomentum = false)
	{
		target.Vel = (overrideMomentum ? Vec3Util.Zero() : target.Vel) + (direction.Unit() * force);
	}

	static play void Explode3D(vector3 origin, int damage, double thrustForce, double radius, bool targetCenter = true, array<Actor> exclusions = null)
	{
		let iterator = BlockThingsIterator.CreateFromPos(origin.x, origin.y, origin.z, radius, radius, false);

		while (iterator.Next())
		{
			Actor mo = iterator.thing;

			if (!mo.bSolid || !mo.bShootable) continue;
			if (exclusions && exclusions.Size() > 0 && exclusions.Find(mo) == exclusions.Size()) continue;

			vector3 position = targetCenter ? (mo.Pos.xy, mo.Pos.z + (mo.Height / 2.0)) : mo.Pos;
			vector3 toTarget = position - origin;
			double distance = toTarget.Length();

			if (distance > radius) continue;

			TraceResults result;
			LineTracer tracer = new("LineTracer");
			if (!tracer.Trace(position, mo.cursector, toTarget.Unit(), distance, TRACE_NoSky)
				|| result.HitActor != mo)
			{
				return;
			}

			int attenuatedDamage = int(round((radius - distance) / radius * damage));
			double attenuatedForce = (radius - distance) / radius * thrustForce / (2 * mo.mass);

			mo.Health -= attenuatedDamage;
			Thrust3D(mo, toTarget, attenuatedForce);
		}
	}

	static play void RadiusThrust3D(vector3 origin, double force, double radius, bool targetCenter = true, array<Actor> exclusions = null)
	{
		let iterator = BlockThingsIterator.CreateFromPos(origin.x, origin.y, origin.z, radius, radius, false);

		while (iterator.Next())
		{
			Actor mo = iterator.thing;

			if (!mo.bSolid || !mo.bShootable) continue;
			if (exclusions && exclusions.Size() > 0 && exclusions.Find(mo) == exclusions.Size()) continue;

			vector3 position = targetCenter ? (mo.Pos.xy, mo.Pos.z + (mo.Height / 2.0)) : mo.Pos;
			vector3 toTarget = position - origin;
			double distance = toTarget.Length();

			if (distance > radius) continue;

			TraceResults result;
			LineTracer tracer = new("LineTracer");
			if (!tracer.Trace(position, mo.cursector, toTarget.Unit(), distance, TRACE_NoSky)
				|| result.HitActor != mo)
			{
				return;
			}

			double attenuatedForce = (radius - distance) / radius * force / (2 * mo.mass);

			Thrust3D(mo, toTarget, attenuatedForce);
		}
	}
}