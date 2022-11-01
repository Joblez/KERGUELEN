class ActorUtil
{
	enum EThrustTarget
	{
		THRTARGET_Origin,
		THRTARGET_Center,
		THRTARGET_Top
	}

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

	static play void Thrust3D(Actor target, vector3 direction, double force, bool overrideMomentum = false, bool ignoreMass = false)
	{
		if (target.bDontThrust) return;

		target.Vel = (overrideMomentum ? Vec3Util.Zero() : target.Vel) + (direction.Unit() * force / (ignoreMass ? 1 : target.Mass * 0.175));
	}

	// static play void Explode3D(Actor origin, int damage, double thrustForce, double radius, EThrustTarget thrustTarget = THRTARGET_Top, array<Actor> exclusions = null)
	// {
	// 	let iterator = BlockThingsIterator.CreateFromPos(origin.Pos.x, origin.Pos.y, origin.Pos.z, radius, radius, false);

	// 	while (iterator.Next())
	// 	{
	// 		Actor mo = iterator.thing;

	// 		if (!mo.bSolid || !mo.bShootable) continue;
	// 		if (exclusions && exclusions.Size() > 0 && exclusions.Find(mo) != exclusions.Size()) continue;

	// 		vector3 position;
	// 		switch (thrustTarget)
	// 		{
	// 			case THRTARGET_Center:
	// 				position = (mo.Pos.xy, mo.Pos.z + (mo.Height / 2.0));
	// 				break;
	// 			case THRTARGET_Top:
	// 				position = (mo.Pos.xy, mo.Pos.z + mo.Height);
	// 				break;
	// 			case THRTARGET_Origin:
	// 			default:
	// 				position = mo.Pos;
	// 				break;
	// 		}

	// 		vector3 toTarget = position - origin.Pos;
	// 		double distance = toTarget.Length();

	// 		if (distance > radius) continue;

	// 		int attenuatedDamage = int(round((radius - distance) / radius * damage));
	// 		double attenuatedForce = (radius - distance) / radius * thrustForce;

	// 		vector2 angleAndPitch = MathVec3.ToYawAndPitch(toTarget.Unit());

	// 		Actor a = origin.LineAttack(angleAndPitch.x, radius, angleAndPitch.y, attenuatedDamage, 'None', null, offsetz: 1.0);
	// 		if (a) Thrust3D(mo, toTarget, attenuatedForce);
	// 	}
	// }

	static play void RadiusThrust3D(vector3 origin, double force, double radius, EThrustTarget thrustTarget = THRTARGET_Top, array<Actor> exclusions = null)
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
			bool traceHit = tracer.Trace(position, mo.cursector, toTarget.Unit(), distance, TRACE_NoSky);
			string hitType;
			switch (tracer.results.HitType)
			{
				case TRACE_HitNone:			hitType = "TRACE_HitNone"; break;
				case TRACE_HitFloor:		hitType = "TRACE_HitFloor"; break;
				case TRACE_HitCeiling:		hitType = "TRACE_HitCeiling"; break;
				case TRACE_HitWall:			hitType = "TRACE_HitWall"; break;
				case TRACE_HitActor:		hitType = "TRACE_HitActor"; break;
				case TRACE_CrossingPortal:	hitType = "TRACE_CrossingPortal"; break;
				case TRACE_HasHitSky:		hitType = "TRACE_HasHitSky"; break;
				default: break;
			}
			Console.Printf("Trace hit?: %s", traceHit ? "Yes" : "No");
			if (traceHit) Console.Printf("Hit type: %s", hitType);
			if (!traceHit || tracer.results.HitType != TRACE_HitActor)
			{
				continue;
			}

			double attenuatedForce = (radius - distance) / radius * force;

			Thrust3D(mo, toTarget, attenuatedForce);
		}
	}
}