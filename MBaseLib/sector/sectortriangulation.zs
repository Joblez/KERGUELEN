class SectorTriangulation
{
	private array<SectorTriangle> m_Triangles;
	private array<double> m_CumulativeDistribution;

	private Sector m_Sector;

	private double m_Area;

	static SectorTriangulation Create(Sector sec)
	{
		array<SectorShape> trees;
		array<Line> lines;
		lines.Copy(sec.lines);
		BuildShapeTrees(lines, trees);
		array<SectorShape> flattened;

		for (int i = 0; i < trees.Size(); ++i)
		{
			FlattenTree(flattened, trees[i]);
		}

		array<Polygon> polygons;

		for (int i = 0; i < flattened.Size(); ++i)
		{
			polygons.Push(Polygon.FromSectorShape(flattened[i]));
		}

		array<DelaunayTriangle> triangles;

		for (int i = 0; i < polygons.Size(); ++i)
		{
			polygons[i].Triangulate();
			triangles.Append(polygons[i].m_Triangles);
		}

		return SectorTriangulation.FromDelaunay(triangles, sec);
	}

	private static SectorTriangulation FromDelaunay(array<DelaunayTriangle> triangles, Sector sec)
	{
		SectorTriangulation triangulation = new("SectorTriangulation");

		// Convert triangles and generate random distribution.
		for (int i = 0; i < triangles.Size(); ++i)
		{
			SectorTriangle secTriangle = SectorTriangle.FromDelaunay(triangles[i], sec);
			triangulation.m_Area += Geometry.GetTriangleArea(
				secTriangle.GetPoint(0),
				secTriangle.GetPoint(1),
				secTriangle.GetPoint(2));

			triangulation.m_Triangles.Push(secTriangle);
		}

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

		triangulation.m_Sector = sec;

		return triangulation;
	}

	SectorTriangle GetTriangle(int index) const
	{
		return m_Triangles[index];
	}

	uint GetTriangleCount() const
	{
		return m_Triangles.Size();
	}

	Sector GetSector() const
	{
		return m_Sector;
	}

	double GetArea() const
	{
		return m_Area;
	}

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

	private static void BuildShapeTrees(array<Line> lines, out array<SectorShape> trees, bool counterClockwise = false)
	{
		int recursionCount = 0;
		SortDebug(recursionCount, lines);

		// Buffers for shape data.
		array<Vertex> vertexBuffer;
		array<Line> lineBuffer;

		Line currentLine = null;
		Vertex current = null;

		// Sweep until all lines are accounted for.
		while (lines.Size() > 0 || vertexBuffer.Size() > 0)
		{
			// Shape closed. Pick another starting line.
			if (vertexBuffer.Size() == 0)
			{
				currentLine = lines[0];
				lines.Delete(0);
				lineBuffer.Push(currentLine);

				if (counterClockwise)
				{
					vertexBuffer.Push(currentLine.v1);
					current = currentLine.v2;
				}
				else
				{
					vertexBuffer.Push(currentLine.v2);
					current = currentLine.v1;
				}
			}

			bool connectionFound = false;

			// Check if any vertex on the current line connects back to the start.
			if (current.p ~== vertexBuffer[0].p)
			{
				// Found a polygon.
				SectorShape node = SectorShape.Create(vertexBuffer, lineBuffer);

				// Try to nest child.
				bool nested = false;
				for (int i = 0; i < trees.Size(); ++i)
				{
					nested = trees[i].TryAddChild(node);

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
				continue;
			}

			for (int i = lines.Size() - 1; i >= 0; --i)
			{
				Line checkedLine = lines[i];

				// Ignore the current line.
				if (checkedLine.v1.p ~== currentLine.v1.p
					&& checkedLine.v2.p ~== currentLine.v2.p)
				{
					continue;
				}

				// Ignore internal lines.
				if (!!(checkedLine.sidedef[0])
					&& !!(checkedLine.sidedef[1])
					&& checkedLine.sidedef[0].sector == checkedLine.sidedef[1].sector)
				{
					lines.Delete(i);
					continue;
				}

				bool connected = false;

				// Check if any vertex on the checked line connects to the current line.
				if (current.p ~== checkedLine.v1.p)
				{
					current = checkedLine.v2;
					vertexBuffer.Push(checkedLine.v1);
					connected = true;
				}
				else if (current.p ~== checkedLine.v2.p)
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

			// A polygon is open, abort.
			if (!connectionFound) ThrowAbortException("Open polygon detected.");
		}
	}

	private static void FlattenTree(out array<SectorShape> result, SectorShape shape)
	{
		if (!shape.m_Inner) result.Push(shape);
		for (int i = shape.m_Children.Size() - 1; i >= 0; --i)
		{
			FlattenTree(result, shape.m_Children[i]);
			if (!shape.m_Children[i].m_Inner) shape.m_Children.Delete(i);
		}
	}

	private static void SortDebug(out int recursionCount, out array<Line> lines)
	{
		SortLinesHorizontally(recursionCount, lines);
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
			while (lines[left].v1.p.x < pivot.v1.p.x || (lines[left].v1.p.x ~== pivot.v1.p.x && lines[left].v1.p.y < pivot.v1.p.y))
			{
				++left;
			}
			while (lines[right].v1.p.x > pivot.v1.p.x || (lines[right].v1.p.x ~== pivot.v1.p.x && lines[right].v1.p.y > pivot.v1.p.y))
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
	array<Vertex> m_Points;
	array<Line> m_Lines;
	array<SectorShape> m_Children;

	bool m_Inner;

	static SectorShape Create(out array<Vertex> vertices, out array<Line> lines)
	{
		SectorShape node = new("SectorShape");
		node.m_Points.Move(vertices);
		node.m_Lines.Move(lines);
		node.m_Inner = false;
		return node;
	}

	bool TryAddChild(SectorShape other)
	{
		if (other.m_Points.Size() == 0) return false;

		for (int i = 0; i < m_Children.Size(); ++i)
		{
			SectorShape child = m_Children[i];
			if (child.TryAddChild(other)) return true;
		}

		if (other.IsInsideShape(self))
		{
			other.m_Inner = !m_Inner;
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

		array<Edge> outerEdges;

		// Brute force for now.
		for (int i = 0; i < outer.m_Lines.Size(); ++i)
		{
			Line outerLine = outer.m_Lines[i];
			outerEdges.Push(Edge.FromLine(outerLine));

			for (int j = 0; j < m_Lines.Size(); ++j)
			{
				Line innerLine = m_Lines[j];

				if (Geometry.IntersectionOf(
					innerLine.v1.p,
					innerLine.v2.p,
					outerLine.v1.p,
					outerLine.v2.p) != Vec2Util.Inf())
				{
					return false;
				}
			}
		}

		// If no lines intersect, check that at least one point is inside.
		return Geometry.IsPointInPolygon(m_Points[0].p, outerEdges);
	}

	vector2, vector2 GetBoundingBox()
	{
		array<BoxedVector2> points;

		for (int i = 0; i < m_Points.Size(); ++i)
		{
			points.Push(BoxedVector2.FromVertex(m_Points[i]));
		}

		vector2 bl, tr;
		[bl, tr] = Geometry.GetBoundingBox(points);
		return bl, tr;
	}
}

class SectorTriangle
{
	private vector2[3] m_Points;
	private Sector m_Sector;

	static SectorTriangle Create(vector2 a, vector2 b, vector2 c, Sector sec)
	{
		SectorTriangle triangle = new("SectorTriangle");
		triangle.m_Points[0] = a;
		triangle.m_Points[1] = b;
		triangle.m_Points[2] = c;
		triangle.m_Sector = sec;

		return triangle;
	}

	static SectorTriangle FromDelaunay(DelaunayTriangle triangle, Sector sec)
	{
		vector2 a = (triangle.m_Points[0].m_X, triangle.m_Points[0].m_Y);
		vector2 b = (triangle.m_Points[1].m_X, triangle.m_Points[1].m_Y);
		vector2 c = (triangle.m_Points[2].m_X, triangle.m_Points[2].m_Y);

		return SectorTriangle.Create(a, b, c, sec);
	}

	vector2 GetPoint(int index) const
	{
		return m_Points[index];
	}

	Sector GetSector() const
	{
		return m_Sector;
	}

	vector2 GetRandomPoint() const
	{
		double x = FRandom(0.0, 1.0);
		double y = FRandom(0.0, 1.0);

		double q = abs(x - y);

		double s = q;
		double t = 0.5 * (x + y - q);
		double u = 1 - 0.5 * (q + x + y);

		vector2 a = m_Points[0];
		vector2 b = m_Points[1];
		vector2 c = m_Points[2];

		return (s * a.x + t * b.x + u * c.x, s * a.y + t * b.y + u * c.y);
	}
}