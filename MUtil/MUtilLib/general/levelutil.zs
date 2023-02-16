/** Contains level-related utilities. **/
class LevelUtil play
{
	/**
	 * Triangulates the geometry of the current level and returns an array with the
	 * resulting triangles.
	 *
	 * NOTE:
	 *		Certain triangles will lie outside the bounds of the level. You may prefer
	 *		using SectorDataRegistry.GetTriangulation() to get triangulations for
	 *		specific sectors.
	 *
	 *		Warning: large amounts of level geometry may cause the triangulation logic
	 *		to overflow the call stack. It is highly recommended to use per-sector
	 *		triangulation in such cases instead.
	**/
	static clearscope void TriangulateLevel(out array<DelaunayTriangle> triangles)
	{
		array<Vertex> vertices;
		array<Line> lines;

		foreach (l : level.Lines)
		{
			lines.Push(l);
		}

		if (!IsGeometryNonComplex(lines)) ThrowAbortException("Cannot triangulate intersecting edges.");
		GetUniqueVertices(lines, vertices);

		array<int> edgePairs;
		FindEdgeIndices(vertices, lines, edgePairs);

		array<TriangulationPoint> points;
		TriangulationUtil.VerticesToTriangulationPoints(vertices, points);

		ConstrainedPointSet pointSet = ConstrainedPointSet.Create(points, edgePairs);
		// PointSet pointSet = PointSet.Create(points);
		pointSet.Triangulate();

		triangles.Copy(pointSet.m_Triangles);
	}

	/**
	 * Returns the vertex at the coordinates of the given position, or null if no
	 * matching vertex is found.
	**/
	static clearscope Vertex FindVertex(vector2 position)
	{
		foreach (v : level.Vertexes)
		{
			if (abs(position.x - v.p.x) < Geometry.EPSILON && abs(position.y - v.p.y) < Geometry.EPSILON)
			{
				return v;
				break;
			}
		}

		return null;
	}

	/**
	 * Places all vertices among the given lines into the given vertices array without
	 * duplicates.
	**/
	static clearscope void GetUniqueVertices(array<Line> lines, out array<Vertex> vertices)
	{
		foreach (l : lines)
		{
			bool v1Found = false;
			bool v2Found = false;

			foreach (v : vertices)
			{
				if (v == l.v1)
				{
					v1Found = true;
					continue;
				}

				if (v == l.v2)
				{
					v2Found = true;
					continue;
				}
			}

			if (!v1Found) vertices.Push(l.v1);
			if (!v2Found) vertices.Push(l.v2);
		}
	}

	/**
	 * Returns the line comprised by the given vertices, or null if no matching line is
	 * found. The vertices need not be given in the order they are defined on the line.
	**/
	clearscope static Line FindLine(Vertex v1, Vertex v2)
	{
		Line result = null;

		foreach (l : level.Lines)
		{
			if ((l.v1 == v1 && l.v2 == v2) || (l.v2 == v1 && l.v1 == v2))
			{
				result = l;
				break;
			}
		}

		return result;
	}

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
	 * - hitActors: An optional array to retrieve references to the actors that were hit
	 *		by the explosion.
	**/
	static void Explode3D(
		vector3 origin,
		int damage,
		double thrustForce,
		double radius,
		EThrustTarget thrustTarget = THRTARGET_Center,
		array<Actor> exclusions = null,
		Actor source = null,
		Actor inflictor = null,
		vector3 thrustOffset = (0.0, 0.0, 0.0),
		bool checkHit = true,
		out array<Actor> hitActors = null)
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

			vector3 toTarget = LevelLocals.Vec3Diff(origin, position);
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

			if (hitActors) hitActors.Push(mo);
		}
	}

	private static clearscope bool IsGeometryNonComplex(array<Line> lines)
	{
		array<Edge> edges;
		Edge.LinesToEdges(lines, edges);

		foreach (e : edges)
		{
			foreach (f : edges)
			{
				if (e.Equals(f)) continue;

				if (Geometry.LinesIntersect(e.m_V1, e.m_V2, f.m_V1, f.m_V2))
				{
					// Check for touching ends false positives.
					vector2 fv1 = f.m_V1 + (Geometry.EPSILON, Geometry.EPSILON);
					vector2 fv2 = f.m_V2 + (Geometry.EPSILON, Geometry.EPSILON);
					if (!Geometry.LinesIntersect(e.m_V1, e.m_V2, fv1, fv2)) continue;

					fv1 = f.m_V1 - (Geometry.EPSILON, Geometry.EPSILON);
					fv2 = f.m_V2 - (Geometry.EPSILON, Geometry.EPSILON);
					if (!Geometry.LinesIntersect(e.m_V1, e.m_V2, fv1, fv2)) continue;

					Line le = FindLine(FindVertex(e.m_V1), FindVertex(e.m_V2));
					Line lf = FindLine(FindVertex(f.m_V1), FindVertex(f.m_V2));
					Console.Printf("Line %i intersects line %i.", le.Index(), lf.Index());
					return false;
				}
			}
		}

		return true;
	}

	private static clearscope void FindEdgeIndices(array<Vertex> vertices, array<Line> lines, out array<int> pairs)
	{
		foreach (l : lines)
		{
			int i1 = vertices.Find(l.v1);
			int i2 = vertices.Find(l.v2);

			if (i1 == vertices.Size() || i2 == vertices.Size()) ThrowAbortException("Vertices do not contain edge.");

			pairs.Push(i1);
			pairs.Push(i2);
		}
	}

}

enum EThrustTarget
{
	THRTARGET_Origin,
	THRTARGET_Center,
	THRTARGET_Top
}