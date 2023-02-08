/** Represents a series of triangles encompassing the total area of a sector. **/
class SectorTriangulation
{
	private array<SectorTriangle> m_Triangles;
	private array<double> m_CumulativeDistribution;

	private Sector m_Sector;

	private double m_Area;

	static SectorTriangulation Create(Sector sec)
	{
		SectorTriangulation triangulation = new("SectorTriangulation");
		triangulation.m_Sector = sec;

		return triangulation;
	}

	static SectorTriangulation TriangulateSector(Sector sec)
	{
		// Console.Printf("Triangulating sector %i", sec.Index());

		if (sec.lines.Size() < 2
			|| DoesSectorGeometryIntersect(sec.lines)
			|| IsSectorGeometryCollinear(sec.lines))
		{
			return null;
		}

		// Need to approach these differently to avoid obscure triangulator bug.
		if (!IsSectorGeometryClosed(sec.lines))
		{
			// Console.Printf("Sector %i is not closed. Using alternative triangulation method...", sec.Index());
			return TriangulateNonClosed(sec);
		}
		else
		{
			array<SectorShape> trees;

			// Certain geometry can throw off the unclosed shape detection.
			// Check the result of BuildShapeTrees() in case open shapes are caught during tracing.
			if (!BuildShapeTrees(sec.lines, trees, sec))
			{
				return TriangulateNonClosed(sec);
			}

			array<SectorShape> flattened;
			for (int i = 0; i < trees.Size(); ++i)
			{
				ExtractShapesOrHoles(flattened, trees[i], false);
			}

			array<Polygon> polygons;
			for (int i = 0; i < flattened.Size(); ++i)
			{
				Polygon poly = Polygon.FromSectorShape(flattened[i]);
				polygons.Push(poly);
			}

			array<DelaunayTriangle> triangles;
			for (int i = 0; i < polygons.Size(); ++i)
			{
				polygons[i].Triangulate();
				triangles.Append(polygons[i].m_Triangles);
			}

			return SectorTriangulation.FromDelaunay(triangles, sec);
		}
	}

	/** Returns the SectorTriangle at the given index. **/
	SectorTriangle GetTriangle(int index) const
	{
		return m_Triangles[index];
	}

	/** Returns the amount of triangles in this SectorTriangulation. **/
	uint GetTriangleCount() const
	{
		return m_Triangles.Size();
	}

	/** Returns the sector that corresponds to this SectorTriangulation. **/
	Sector GetSector() const
	{
		return m_Sector;
	}

	/** Returns the total area of this SectorTriangulation. **/
	double GetArea() const
	{
		return m_Area;
	}

	/** Returns a random point within the area of this SectorTriangulation. **/
	vector2 GetRandomPoint() const
	{
		SectorTriangle target = GetWeightedRandomTriangle();

		return target.GetRandomPoint();
	}

	private SectorTriangle GetWeightedRandomTriangle() const
	{
		double target = FRandom(0.0, 1.0);

		int i;

		for (i = 0; i < m_CumulativeDistribution.Size() - 1; ++i)
		{
			if (target <= m_CumulativeDistribution[i]) break;
		}

		return m_Triangles[i];
	}

	void AddTriangle(DelaunayTriangle triangle)
	{
		m_Triangles.Push(SectorTriangle.FromDelaunay(triangle, m_Sector));
	}

	void RecalculateArea()
	{
		m_Area = 0.0;

		// Calculate area.
		foreach (secTriangle : m_Triangles)
		{
			m_Area += Geometry.GetTriangleArea(
				secTriangle.GetPoint(0),
				secTriangle.GetPoint(1),
				secTriangle.GetPoint(2));
		}
	}

	void RecalculateDistribution()
	{
		for (int i = 0; i < m_Triangles.Size(); ++i)
		{
			SectorTriangle secTriangle = m_Triangles[i];
			double previous = i > 0 ? m_CumulativeDistribution[i - 1] : 0.0;
			double next = (
				Geometry.GetTriangleArea(
					secTriangle.GetPoint(0),
					secTriangle.GetPoint(1),
					secTriangle.GetPoint(2))
				/ m_Area) + previous;

			m_CumulativeDistribution.Push(next);
		}
	}

	private static SectorTriangulation FromDelaunay(array<DelaunayTriangle> triangles, Sector sec)
	{
		if (triangles.Size() == 0) return null;

		SectorTriangulation triangulation = new("SectorTriangulation");

		triangulation.m_Sector = sec;

		// Convert triangles.
		for (int i = 0; i < triangles.Size(); ++i)
		{
			if (level.PointInSector(triangles[i].Centroid().ToVector2()) != sec) continue;
			SectorTriangle secTriangle = SectorTriangle.FromDelaunay(triangles[i], sec);
			triangulation.m_Triangles.Push(secTriangle);
		}

		// Calculate area.
		foreach (secTriangle : triangulation.m_Triangles)
		{
			triangulation.m_Area += Geometry.GetTriangleArea(
				secTriangle.GetPoint(0),
				secTriangle.GetPoint(1),
				secTriangle.GetPoint(2));
		}

		// Calculate cumulative distribution.
		for (int i = 0; i < triangulation.m_Triangles.Size(); ++i)
		{
			SectorTriangle secTriangle = triangulation.m_Triangles[i];
			double previous = i > 0 ? triangulation.m_CumulativeDistribution[i - 1] : 0.0;
			double next = (
				Geometry.GetTriangleArea(
					secTriangle.GetPoint(0),
					secTriangle.GetPoint(1),
					secTriangle.GetPoint(2))
				/ triangulation.m_Area) + previous;

			triangulation.m_CumulativeDistribution.Push(next);
		}

		return triangulation;
	}

	private static bool BuildShapeTrees(array<Line> sectorLines, out array<SectorShape> trees, Sector sec)
	{
		array<Line> lines;
		lines.Copy(sectorLines);

		int recursionCount = 0;
		SortLinesHorizontally(recursionCount, lines);

		// Buffers for shape data.
		array<Vertex> vertexBuffer;
		array<Line> lineBuffer;

		Line currentLine = null;
		Vertex current = null;

		bool hasInternal = false;

		currentLine = lines[0];

		// Sweep until all lines are accounted for.
		while (lines.Size() > 0 || vertexBuffer.Size() > 0)
		{
			// Shape closed. Pick another starting line.
			if (vertexBuffer.Size() == 0)
			{
				currentLine = lines[0];
				lines.Delete(0);
				lineBuffer.Push(currentLine);

				if (currentLine.v1.p.x > currentLine.v2.p.x)
				{
					current = currentLine.v1;
					vertexBuffer.Push(currentLine.v2);
				}
				else
				{
					current = currentLine.v2;
					vertexBuffer.Push(currentLine.v1);
				}
			}

			bool connectionFound = false;

			// Check if any vertex on the current line connects back to the start.
			if (current == vertexBuffer[0])
			{
				// Found a polygon.
				SectorShape node = SectorShape.Create(vertexBuffer, lineBuffer, sec);

				if (!node) return false;

				// Try to nest child.
				bool nested = false;
				for (int i = 0; i < trees.Size(); ++i)
				{
					nested = trees[i].TryAddChild(node, hasInternal);

					if (nested) break;
				}

				// Add to root shapes if not nested.
				if (!nested)
				{
					node.m_Inner = false;
					trees.Push(node);
				}

				vertexBuffer.Clear();
				lineBuffer.Clear();
				hasInternal = false;
				continue;
			}

			for (int i = lines.Size() - 1; i >= 0; --i)
			{
				Line checkedLine = lines[i];

				// Ignore the current line.
				if (checkedLine.v1 == currentLine.v1
					&& checkedLine.v2 == currentLine.v2)
				{
					continue;
				}

				// Mark internal lines.
				if (!!checkedLine.sidedef[0] && !!checkedLine.sidedef[1]
					&& checkedLine.sidedef[0].sector == checkedLine.sidedef[1].sector)
				{
					hasInternal = true;
				}

				bool connected = false;

				// Check if any vertex on the checked line connects to the current line.
				if (current == checkedLine.v1)
				{
					current = checkedLine.v2;
					vertexBuffer.Push(checkedLine.v1);
					connected = true;
				}
				else if (current == checkedLine.v2)
				{
					current = checkedLine.v1;
					vertexBuffer.Push(checkedLine.v2);
					connected = true;
				}

				if (connected)
				{
					// Found a connected line.
					lines.Delete(i);
					currentLine = checkedLine;
					lineBuffer.Push(currentLine);
					connectionFound = true;
				}
			}

			// A polygon is open and wasn't caught in the geometry check, abort.
			if (!connectionFound)
			{
				return false;
			}
		}

		// Console.Printf("Sector %i, Root shapes: %i", sec.Index(), trees.Size());
		return true;
	}

	private static SectorTriangulation TriangulateNonClosed(Sector sec)
	{
		array<BoxedVector2> vectors;
		GetUniquePoints(sec.lines, vectors);

		array<Edge> edges;
		Edge.LinesToEdges(sec.lines, edges);

		array<int> edgePairs;
		FindEdgeIndices(vectors, edges, edgePairs);

		array<TriangulationPoint> triangulationPoints;
		TriangulationUtil.Vector2sToTriangulationPoints(vectors, triangulationPoints);

		ConstrainedPointSet pointSet = ConstrainedPointSet.Create(triangulationPoints, edgePairs);
		pointSet.Triangulate();

		SectorTriangulation triangulation = SectorTriangulation.FromDelaunay(pointSet.m_Triangles, sec);

		return triangulation;
	}

	private static bool IsSectorGeometryClosed(array<Line> lines)
	{
		Line currentLine = null;

		array<Vertex> vertices;
		LevelUtil.GetUniqueVertices(lines, vertices);

		foreach (v : vertices)
		{
			array<Line> connectedLines;
			foreach (l : lines)
			{
				if (l.v1 == v || l.v2 == v) connectedLines.Push(l);
			}

			// In any closed shape, each vertex should connect exactly two lines.
			if (connectedLines.Size() != 2) return false;
		}

		return true;
	}

	private static bool DoesSectorGeometryIntersect(array<Line> lines)
	{
		foreach (e : lines)
		{
			foreach (f : lines)
			{
				if (e == f) continue;

				if ((e.v1 == f.v1 && e.v2 == f.v2) || (e.v1 == f.v2 && e.v2 == f.v1))
				{
					Console.Printf("Line %i overlaps line %i.", e.Index(), f.Index());
					return true;
				}

				if (Geometry.LinesIntersect(e.v1.p, e.v2.p, f.v1.p, f.v2.p))
				{
					// Check for touching ends false positives.
					vector2 fv1 = f.v1.p + (Geometry.EPSILON, Geometry.EPSILON);
					vector2 fv2 = f.v2.p + (Geometry.EPSILON, Geometry.EPSILON);
					if (!Geometry.LinesIntersect(e.v1.p, e.v2.p, fv1, fv2)) continue;

					fv1 = f.v1.p - (Geometry.EPSILON, Geometry.EPSILON);
					fv2 = f.v2.p - (Geometry.EPSILON, Geometry.EPSILON);
					if (!Geometry.LinesIntersect(e.v1.p, e.v2.p, fv1, fv2)) continue;

					Console.Printf("Line %i intersects line %i.", e.Index(), f.Index());
					return true;
				}
			}
		}

		return false;
	}

	private static bool IsSectorGeometryCollinear(array<Line> lines)
	{
		double previousAngle = vectorangle(lines[0].delta.x, lines[0].delta.y);

		foreach (l : lines)
		{
			double angle = vectorangle(l.delta.x, l.delta.y);
			if (angle ~== previousAngle || (angle + 180.0) % 360.0 ~== previousAngle)
			{
				previousAngle = angle;
				continue;
			}

			return false;
		}

		Console.Printf("All sector lines are collinear.");
		return true;
	}

	private static void ExtractShapesOrHoles(out array<SectorShape> result, SectorShape shape, bool extractHoles = false)
	{
		if (shape.m_Inner == extractHoles) result.Push(shape);
		for (int i = shape.m_Children.Size() - 1; i >= 0; --i)
		{
			ExtractShapesOrHoles(result, shape.m_Children[i]);
		}
	}

	private static void GetUniquePoints(array<Line> lines, out array<BoxedVector2> points)
	{
		foreach (l : lines)
		{
			bool v1Found = false;
			bool v2Found = false;
			foreach (point : points)
			{
				if (point.m_Value ~== l.v1.p)
				{
					v1Found = true;
					continue;
				}

				if (point.m_Value ~== l.v2.p)
				{
					v2Found = true;
					continue;
				}
			}
			if (!v1Found) points.Push(BoxedVector2.FromVertex(l.v1));
			if (!v2Found) points.Push(BoxedVector2.FromVertex(l.v2));
		}
	}

	private static void FindEdgeIndices(array<BoxedVector2> points, array<Edge> edges, out array<int> pairs)
	{
		foreach (e : edges)
		{
			int i1 = points.Size();
			int i2 = i1;
			for (int i = 0; i < points.Size(); ++i)
			{
				if (points[i].m_Value ~== e.m_V1)
				{
					i1 = i;
				}

				if (points[i].m_Value ~== e.m_V2)
				{
					i2 = i;
				}
			}

			if (i1 == points.Size() || i2 == points.Size()) ThrowAbortException("Points do not contain edge.");

			pairs.Push(i1);
			pairs.Push(i2);
		}
	}

	private void PruneHoleTriangles(out array<SectorShape> holes)
	{
		for (int i = m_Triangles.Size() - 1; i >= 0; --i)
		{
			foreach (hole : holes)
			{
				if (Geometry.IsPointInPolygon(m_Triangles[i].GetCentroid(), hole.m_Lines))
				{
					m_Triangles.Delete(i);
					break;
				}
			}
		}
	}

	private void PruneOutOfBoundsTriangles(array<SectorShape> rootShapes)
	{
		for (int i = m_Triangles.Size() - 1; i >= 0; --i)
		{
			bool inBoundary = false;
			foreach (shape : rootShapes)
			{
				if (Geometry.IsPointInPolygon(m_Triangles[i].GetCentroid(), shape.m_Lines))
				{
					inBoundary = true;
					break;
				}
			}

			if (inBoundary) continue;
			m_Triangles.Delete(i);
		}
	}

	static bool CorrectEdgeOrientation(out array<Edge> edges)
	{
		if (edges.Size() < 3) return false;

		array<Edge> sorted;

		Edge currentEdge = edges[0];

		sorted.Push(currentEdge);
		edges.Delete(0);

		while (edges.Size() > 0)
		{
			bool connectionFound = false;
			for (int i = edges.Size() - 1; i >= 0; --i)
			{
				if (abs(currentEdge.m_V2.x - edges[i].m_V1.x) < Geometry.EPSILON
					&& abs(currentEdge.m_V2.y - edges[i].m_V1.y) < Geometry.EPSILON)
				{
					currentEdge = edges[i];
					sorted.Push(currentEdge);
					edges.Delete(i);
					connectionFound = true;
					continue;
				}

				if (abs(currentEdge.m_V2.x - edges[i].m_V2.x) < Geometry.EPSILON
					&& abs(currentEdge.m_V2.y - edges[i].m_V2.y) < Geometry.EPSILON)
				{
					// Flip edge.
					vector2 v2 = edges[i].m_V1;
					edges[i].m_V1 = edges[i].m_V2;
					edges[i].m_V2 = v2;

					currentEdge = edges[i];
					sorted.Push(currentEdge);
					edges.Delete(i);
					connectionFound = true;
					continue;
				}

				if (abs(currentEdge.m_V1.x - edges[i].m_V1.x) < Geometry.EPSILON
					&& abs(currentEdge.m_V1.y - edges[i].m_V1.y) < Geometry.EPSILON)
				{
					// Flip edge.
					vector2 v2 = currentEdge.m_V1;
					currentEdge.m_V1 = currentEdge.m_V2;
					currentEdge.m_V2 = v2;

					currentEdge = edges[i];
					sorted.Push(currentEdge);
					edges.Delete(i);
					connectionFound = true;
					continue;
				}
			}

			if (!connectionFound) return false;
		}

		edges.Move(sorted);
		return true;
	}

	private static void SortLinesHorizontally(out int recursionCount, out array<Line> lines, int left = -1, int right = -1)
	{
		if (lines.Size() < 2) return;

		if (left < 0) left = 0;
		if (right < 0) right = lines.Size() - 1;

		int recursionMax = 500;
		if (recursionCount > recursionMax)
		{
			ThrowAbortException("Recursion count > %i", recursionMax);
		}

		if (left < right)
		{
			recursionCount++;
			int pivotIndex = left + (right - left) / 2;
			int partitionIndex = HorizontalLineSortPartition(lines, left, right, pivotIndex);

			SortLinesHorizontally(recursionCount, lines, left, partitionIndex - 1);
			SortLinesHorizontally(recursionCount, lines, partitionIndex + 1, right);
		}

		recursionCount--;
	}

	private static int HorizontalLineSortPartition(out array<Line> lines, int left, int right, int pivotIndex)
	{
		Line pivot = lines[pivotIndex];

		while (left <= right)
		{
			while (lines[left].v1.p.x < pivot.v1.p.x || (lines[left].v1.p.x == pivot.v1.p.x && lines[left].v1.p.y < pivot.v1.p.y))
			{
				++left;
			}
			while (lines[right].v1.p.x > pivot.v1.p.x || (lines[right].v1.p.x == pivot.v1.p.x && lines[right].v1.p.y > pivot.v1.p.y))
			{
				--right;
			}

			if (left <= right)
			{
				Line swap = lines[left];
				lines[left] = lines[right];
				lines[right] = swap;

				++left;
				--right;
			}
		}

		return left;
	}
}

class SectorShape
{
	Sector m_Sector;
	array<BoxedVector2> m_Points;
	array<Edge> m_Lines;
	array<SectorShape> m_Children;

	bool m_Inner;

	private double m_Area;
	private bool m_IsAreaSet;

	static SectorShape Create(array<Vertex> vertices, array<Line> lines, Sector sec)
	{
		SectorShape node = new("SectorShape");

		foreach (v : vertices)
		{
			node.m_Points.Push(BoxedVector2.FromVertex(v));
		}

		Edge.LinesToEdges(lines, node.m_Lines);

		if (!SectorTriangulation.CorrectEdgeOrientation(node.m_Lines)) return null;

		node.m_Sector = sec;
		node.m_Inner = false;
		return node;
	}

	bool TryAddChild(SectorShape other, bool isInternal = false)
	{
		if (other.m_Points.Size() == 0) return false;

		for (int i = 0; i < m_Children.Size(); ++i)
		{
			SectorShape child = m_Children[i];
			if (child.TryAddChild(other)) return true;
		}

		if (other.IsInsideShape(self))
		{
			if (!isInternal) other.m_Inner = !m_Inner;
			m_Children.Push(other);
			return true;
		}

		return false;
	}

	bool IsInsideShape(SectorShape outer)
	{
		int vertexCount = m_Points.Size();
		int lineCount = m_Lines.Size();
		if (outer.m_Lines.Size() < 3 || vertexCount == 0) return false;

		vector2 bottomLeft, topRight, outerBottomLeft, outerTopRight;

		// Early bounds check to potentially avoid checking edges.
		[bottomLeft, topRight] = GetBoundingBox();
		[outerBottomLeft, outerTopRight] = outer.GetBoundingBox();

		if (Geometry.IsBoxInBounds(bottomLeft, topRight, outerBottomLeft, outerTopRight))
		{
			return true;
		}

		// Lines are guaranteed not to intersect, check that at least one point is inside.
		return Geometry.IsPointInPolygon(m_Points[0].m_Value, outer.m_Lines);
	}

	double GetArea() const
	{
		if (!m_IsAreaSet)
		{
			m_Area = Geometry.GetPolygonArea(m_Points);
			m_IsAreaSet = true;
		}

		return m_Area;
	}

	vector2, vector2 GetBoundingBox() const
	{
		vector2 bl, tr;
		[bl, tr] = Geometry.GetBoundingBox(m_Points);
		return bl, tr;
	}
}

/** Represents a single triangle in a SectorTriangulation. **/
class SectorTriangle
{
	private Vertex[3] m_Vertices;
	private vector2[2] m_BoundingBox;
	private Sector m_Sector;

	static SectorTriangle Create(vector2 a, vector2 b, vector2 c, Sector sec)
	{
		SectorTriangle triangle = new("SectorTriangle");
		Vertex va = LevelUtil.FindVertex(a);
		Vertex vb = LevelUtil.FindVertex(b);
		Vertex vc = LevelUtil.FindVertex(c);

		if (!va || !vb || !vc) ThrowAbortException("Missing triangle vertex.");

		triangle.m_Vertices[0] = va;
		triangle.m_Vertices[1] = vb;
		triangle.m_Vertices[2] = vc;
		triangle.m_Sector = sec;

		// Calculate bounding box.
		vector2 min = (triangle.m_Vertices[0].p.x, triangle.m_Vertices[0].p.y);
		vector2 max = min;

		for (int i = 1; i < triangle.m_Vertices.Size(); ++i)
		{
			vector2 point = triangle.m_Vertices[i].p;
			if (point.x < min.x) min.x = point.x;
			if (point.x > max.x) max.x = point.x;
			if (point.y < min.y) min.y = point.y;
			if (point.y > max.y) max.y = point.y;
		}

		triangle.m_BoundingBox[0] = min;
		triangle.m_BoundingBox[1] = max;

		return triangle;
	}

	static SectorTriangle FromDelaunay(DelaunayTriangle triangle, Sector sec)
	{
		vector2 a = (triangle.m_Points[0].m_X, triangle.m_Points[0].m_Y);
		vector2 b = (triangle.m_Points[1].m_X, triangle.m_Points[1].m_Y);
		vector2 c = (triangle.m_Points[2].m_X, triangle.m_Points[2].m_Y);

		return SectorTriangle.Create(a, b, c, sec);
	}

	/** Returns the point at the given index. **/
	Vertex GetVertex(int index) const
	{
		return m_Vertices[index];
	}

	/** Returns the point at the given index. **/
	vector2 GetPoint(int index) const
	{
		return m_Vertices[index].p;
	}

	/** Returns the sector that corresponds to this SectorTriangle. **/
	Sector GetSector() const
	{
		return m_Sector;
	}

	/** returns a random point within this SectorTriangle's area. **/
	vector2 GetRandomPoint() const
	{
		double x = FRandom(0.0, 1.0);
		double y = FRandom(0.0, 1.0);

		double q = abs(x - y);

		double s = q;
		double t = 0.5 * (x + y - q);
		double u = 1 - 0.5 * (q + x + y);

		vector2 a = m_Vertices[0].p;
		vector2 b = m_Vertices[1].p;
		vector2 c = m_Vertices[2].p;

		return (s * a.x + t * b.x + u * c.x, s * a.y + t * b.y + u * c.y);
	}

	vector2 GetCentroid() const
	{
		double cx = (m_Vertices[0].p.x + m_Vertices[1].p.x + m_Vertices[2].p.x) / 3.0;
		double cy = (m_Vertices[0].p.y + m_Vertices[1].p.y + m_Vertices[2].p.y) / 3.0;
		return (cx, cy);
	}

	vector2, vector2 GetBoundingBox() const
	{
		return m_BoundingBox[0], m_BoundingBox[1];
	}

	bool ContainsPoint(vector2 point) const
	{
		vector2 bl, tr;
		[bl, tr] = GetBoundingBox();
		if (!Geometry.IsPointInBounds(point, bl, tr)) return false;

		array<Edge> boxedTriangle;
		boxedTriangle.Push(Edge.Create(m_Vertices[0].p, m_Vertices[1].p));
		boxedTriangle.Push(Edge.Create(m_Vertices[1].p, m_Vertices[2].p));
		boxedTriangle.Push(Edge.Create(m_Vertices[2].p, m_Vertices[0].p));

		return Geometry.IsPointInPolygon(point, boxedTriangle);
	}
}