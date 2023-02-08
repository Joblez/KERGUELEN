/************************************************************************************
	Poly2Tri Copyright (c) 2009-2010, Poly2Tri Contributors
	http://code.google.com/p/poly2tri/

	All rights reserved.
	Redistribution and use in source and binary forms, with or without modification,
	are permitted provided that the following conditions are met:

	* Redistributions of source code must retain the above copyright notice,
	this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright notice,
	this list of conditions and the following disclaimer in the documentation
	and/or other materials provided with the distribution.
	* Neither the name of Poly2Tri nor the names of its contributors may be
	used to endorse or promote products derived from this software without specific
	prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
	EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
	PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
	PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
	LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*************************************************************************************/
enum EOrientation
{
	ORI_CW,
	ORI_CCW,
	ORI_Collinear
}

enum ETriangulationMode
{
	TM_Unconstrained,
	TM_Constrained,
	TM_Polygon
}

class Triangulatable abstract
{
	array<TriangulationPoint> m_Points;
	array<DelaunayTriangle> m_Triangles;

	abstract void AddTriangle(DelaunayTriangle t);
	abstract void AddTriangles(array<DelaunayTriangle> list);
	abstract void ClearTriangles();
	abstract void Prepare(DTSweepContext tcx);
	abstract ETriangulationMode GetTriangulationMode();

	void Triangulate()
	{
		DTSweepContext ctx = DTSweepContext.Create();

		ctx.PrepareTriangulation(self);
		DTSweep.Triangulate(ctx);

		foreach (triangle : m_Triangles)
		{
			array<TriangulationPoint> pointArray;
			pointArray.Push(triangle.m_Points[0]);
			pointArray.Push(triangle.m_Points[1]);
			pointArray.Push(triangle.m_Points[2]);

			TriangulationUtil.UnshiftPoints(pointArray);
		}
	}
}

class PointSet : Triangulatable
{
	static PointSet Create(array<TriangulationPoint> points)
	{
		PointSet ps = new("PointSet");
		ps.m_Points.Copy(points);
		return ps;
	}

	override ETriangulationMode GetTriangulationMode() { return TM_Unconstrained; }

	override void AddTriangle(DelaunayTriangle t)
	{
		m_Triangles.Push(t);
	}

	override void AddTriangles(array<DelaunayTriangle> list)
	{
		m_Triangles.Append(list);
	}

	override void ClearTriangles()
	{
		m_Triangles.Clear();
	}

	override void Prepare(DTSweepContext tcx)
	{
		m_Triangles.Clear();
		tcx.m_Points.Append(m_Points);
	}
}

class ConstrainedPointSet : PointSet
{
	private array<int> m_EdgePairs;

	static ConstrainedPointSet Create(array<TriangulationPoint> points, array<int> edgePairs)
	{
		ConstrainedPointSet ps = new("ConstrainedPointSet");
		ps.m_Points.Copy(points);
		ps.m_EdgePairs.Copy(edgePairs);
		return ps;
	}

	override ETriangulationMode GetTriangulationMode() { return TM_Constrained; }

	override void Prepare(DTSweepContext tcx)
	{
		m_Triangles.Clear();
		tcx.m_Points.Append(m_Points);

		for (int i = 0; i < m_EdgePairs.Size(); i += 2)
		{
			tcx.NewConstraint(m_Points[m_EdgePairs[i]], m_Points[m_EdgePairs[i + 1]]);
		}
	}
}

class TriangulationPoint
{
	double m_X;
	double m_Y;

	vector2 shiftDisplacement;

	array<DTSweepConstraint> m_Edges;

	static TriangulationPoint Create(double x, double y)
	{
		TriangulationPoint p = new("TriangulationPoint");
		p.m_X = x;
		p.m_Y = y;
		p.shiftDisplacement = (0.0, 0.0);
		return p;
	}

	static TriangulationPoint FromVec2(vector2 v)
	{
		return TriangulationPoint.Create(v.x, v.y);
	}

	static TriangulationPoint FromVertex(Vertex v)
	{
		TriangulationPoint p = new("TriangulationPoint");
		p.m_X = v.p.x;
		p.m_Y = v.p.y;
		return p;
	}


	vector2 ToVector2() const
	{
		return (m_X, m_Y);
	}

	bool HasEdges() const { return m_Edges.Size() > 0; }

	bool Equals(TriangulationPoint other) const
	{
		return m_X ~== other.m_X && m_Y ~== other.m_Y;
	}

	void AddEdge(DTSweepConstraint e)
	{
		m_Edges.Push(e);
	}
}

class TriangulationUtil
{
	const EPSILON = 0.000000001;

	static bool SmartInCircle(TriangulationPoint pa, TriangulationPoint pb, TriangulationPoint pc, TriangulationPoint pd)
	{
		double pdx = pd.m_X;
		double pdy = pd.m_Y;
		double adx = pa.m_X - pdx;
		double ady = pa.m_Y - pdy;
		double bdx = pb.m_X - pdx;
		double bdy = pb.m_Y - pdy;

		double adxbdy = adx * bdy;
		double bdxady = bdx * ady;
		double oabd = adxbdy - bdxady;
		if (oabd <= 0) return false;

		double cdx = pc.m_X - pdx;
		double cdy = pc.m_Y - pdy;

		double cdxady = cdx * ady;
		double adxcdy = adx * cdy;
		double ocad = cdxady - adxcdy;
		if (ocad <= 0) return false;

		double bdxcdy = bdx * cdy;
		double cdxbdy = cdx * bdy;

		double alift = adx * adx + ady * ady;
		double blift = bdx * bdx + bdy * bdy;
		double clift = cdx * cdx + cdy * cdy;

		double det = alift * (bdxcdy - cdxbdy) + blift * ocad + clift * oabd;

		return det > 0;
	}

	static bool InScanArea(TriangulationPoint pa, TriangulationPoint pb, TriangulationPoint pc, TriangulationPoint pd)
	{
		double pdx = pd.m_X;
		double pdy = pd.m_Y;
		double adx = pa.m_X - pdx;
		double ady = pa.m_Y - pdy;
		double bdx = pb.m_X - pdx;
		double bdy = pb.m_Y - pdy;

		double adxbdy = adx * bdy;
		double bdxady = bdx * ady;
		double oabd = adxbdy - bdxady;

		if (oabd <= 0)
		{
			return false;
		}

		double cdx = pc.m_X - pdx;
		double cdy = pc.m_Y - pdy;

		double cdxady = cdx * ady;
		double adxcdy = adx * cdy;
		double ocad = cdxady - adxcdy;

		if (ocad <= 0)
		{
			return false;
		}
		return true;
	}

	static EOrientation Orient2d(TriangulationPoint pa, TriangulationPoint pb, TriangulationPoint pc, bool moveCollinear = true)
	{
		double detleft = (pa.m_X - pc.m_X) * (pb.m_Y - pc.m_Y);
		double detright = (pa.m_Y - pc.m_Y) * (pb.m_X - pc.m_X);
		double val = detleft - detright;
		if (val > -EPSILON && val < EPSILON)
		{
			// ThrowAbortException("Collinear points not handled.");
			if (moveCollinear)
			{
				EOrientation shifted;
				do
				{
					ShiftPoint(pb);
					shifted = Orient2d(pa, pb, pc, false);
				}
				while (shifted == ORI_Collinear);

				return shifted;
			}
			else
			{
				return ORI_Collinear;
			}
		}
		else if (val > 0)
		{
			return ORI_CCW;
		}
		return ORI_CW;
	}

	static TriangulationPoint ToTriangulationPoint(vector2 v)
	{
		return TriangulationPoint.Create(v.x, v.y);
	}

	static PolygonPoint ToPolygonPoint(vector2 v)
	{
		return PolygonPoint.Create(v.x, v.y);
	}

	static void VerticesToTriangulationPoints(array<Vertex> vertices, out array<TriangulationPoint> points)
	{
		for (int i = 0; i < vertices.Size(); ++i)
		{
			points.Push(TriangulationPoint.FromVertex(vertices[i]));
		}
	}

	static void Vector2sToTriangulationPoints(array<BoxedVector2> vectors, out array<TriangulationPoint> points)
	{
		for (int i = 0; i < vectors.Size(); ++i)
		{
			points.Push(TriangulationPoint.FromVec2(vectors[i].m_Value));
		}
	}

	static void Vector2sToPolygonPoints(array<BoxedVector2> vectors, out array<PolygonPoint> points)
	{
		for (int i = 0; i < vectors.Size(); ++i)
		{
			points.Push(PolygonPoint.FromVec2(vectors[i].m_Value));
		}
	}

	static void SortPointsVertically(out array<TriangulationPoint> points, int left = -1, int right = -1)
	{
		if (left < 0) left = 0;
		if (right < 0) right = points.Size() - 1;

		if (left >= right) return;

		int partitionIndex = VerticalPointSortPartition(points, left, right);

		SortPointsVertically(points, left, partitionIndex - 1);
		SortPointsVertically(points, partitionIndex + 1, right);
	}

	static int VerticalPointSortPartition(out array<TriangulationPoint> points, int leftIndex, int rightIndex)
	{
		Vector2 pivot = points[rightIndex].ToVector2();

		int left = leftIndex;
		int right = rightIndex;

		while (left < right)
		{
			while (left < right && (points[left].m_Y < pivot.y || (points[left].m_Y == pivot.y && points[left].m_X <= pivot.x)))
			{
				++left;
			}
			while (left < right && (points[right].m_Y > pivot.y || (points[right].m_Y == pivot.y && points[right].m_X >= pivot.x)))
			{
				--right;
			}

			if (left < right)
			{
				TriangulationPoint swap = points[left];
				points[left] = points[right];
				points[right] = swap;
			}
		}

		TriangulationPoint pivotSwap = points[left];
		points[left] = points[rightIndex];
		points[rightIndex] = pivotSwap;

		return left;
	}

	static void ShiftPoint(TriangulationPoint p, vector2 displacement = (0.0, 0.0))
	{
		if (abs(displacement.x) <= TriangulationUtil.EPSILON) displacement.x = -TriangulationUtil.EPSILON * Random(1, 10);
		if (abs(displacement.y) <= TriangulationUtil.EPSILON) displacement.y = TriangulationUtil.EPSILON * Random(1, 10);
		p.m_X += displacement.x;
		p.m_Y += displacement.y;
		p.shiftDisplacement += displacement;
	}

	static void UnshiftPoint(TriangulationPoint p)
	{
		p.m_X -= p.shiftDisplacement.x;
		p.m_Y -= p.shiftDisplacement.y;
		p.shiftDisplacement = (0.0, 0.0);
	}

	static void UnshiftPoints(out array<TriangulationPoint> points)
	{
		foreach (point : points)
		{
			UnshiftPoint(point);
		}
	}
}

class PolygonPoint : TriangulationPoint
{
	static PolygonPoint Create(double x, double y)
	{
		PolygonPoint p = new("PolygonPoint");
		p.m_X = x;
		p.m_Y = y;
		return p;
	}

	static PolygonPoint FromVec2(vector2 v)
	{
		return PolygonPoint.Create(v.x, v.y);
	}

	static PolygonPoint FromVertex(Vertex v)
	{
		PolygonPoint p = new("PolygonPoint");
		p.m_X = v.p.x;
		p.m_Y = v.p.y;
		return p;
	}

	PolygonPoint m_Next;
	PolygonPoint m_Previous;
}

class Polygon : Triangulatable
{
	protected array<TriangulationPoint> m_SteinerPoints;
	protected array<Polygon> m_Holes;
	protected PolygonPoint m_Last;

	static Polygon Create(array<PolygonPoint> points)
	{
		Polygon poly = new("Polygon");
		int count = points.Size();
		if (count < 3) ThrowAbortException("Point array has fewer than 3 points.");
		if (points[0].Equals(points[count - 1])) points.Delete(count - 1);

		for (int i = 0; i < count; ++i)
		{
			poly.m_Points.Push(points[i]);
		}
		return poly;
	}

	static Polygon FromSectorShape(SectorShape shape)
	{
		array<PolygonPoint> points;

		foreach (point : shape.m_Points)
		{
			points.Push(PolygonPoint.FromVec2(point.m_Value));
		}

		Polygon poly = Polygon.Create(points);
		if (shape.m_Inner) return poly;

		foreach (child : shape.m_Children)
		{
			poly.AddHole(Polygon.FromSectorShape(child));
		}

		return poly;
	}

	override ETriangulationMode GetTriangulationMode() { return TM_Polygon; }

	void AddSteinerPoint(TriangulationPoint point)
	{
		m_SteinerPoints.Push(point);
	}

	void AddSteinerPoints(array<TriangulationPoint> points)
	{
		m_SteinerPoints.Append(points);
	}

	void ClearSteinerPoints()
	{
		m_SteinerPoints.Clear();
	}

	void AddHole(Polygon poly)
	{
		m_Holes.Push(poly);
	}

	void InsertPointAfter(PolygonPoint point, PolygonPoint newPoint)
	{
		int index = m_Points.Find(point);
		if (index == m_Points.Size())
		{
			ThrowAbortException("Tried to insert a point into a Polygon after a point not belonging to the Polygon");
		}
		newPoint.m_Next = point.m_Next;
		newPoint.m_Previous = point;
		point.m_Next.m_Previous = newPoint;
		point.m_Next = newPoint;
		m_Points.Insert(index + 1, newPoint);
	}

	void AddPoints(array<PolygonPoint> list)
	{
		PolygonPoint first;
		for (int i = 0; i < list.Size(); ++i)
		{
			PolygonPoint p = list[i];
			p.m_Previous = m_Last;
			if (m_Last != null)
			{
				p.m_Next = m_Last.m_Next;
				m_Last.m_Next = p;
			}
			m_Last = p;
			m_Points.Push(p);
		}
		first = PolygonPoint(m_Points[0]);
		m_Last.m_Next = first;
		first.m_Previous = m_Last;
	}

	void AddPoint(PolygonPoint p)
	{
		p.m_Previous = m_Last;
		p.m_Next = m_Last.m_Next;
		m_Last.m_Next = p;
		m_Points.Push(p);
	}

	void RemovePoint(PolygonPoint p)
	{
		PolygonPoint next, prev;

		next = p.m_Next;
		prev = p.m_Previous;
		prev.m_Next = next;
		next.m_Previous = prev;

		int index = m_Points.Find(p);

		if (index = m_Points.Size()) ThrowAbortException("m_Point not in polygon.");
		m_Points.Delete(index);
	}

	override void AddTriangle(DelaunayTriangle t)
	{
		m_Triangles.Push(t);
	}

	override void AddTriangles(array<DelaunayTriangle> list)
	{
		m_Triangles.Append(list);
	}

	override void ClearTriangles()
	{
		m_Triangles.Clear();
	}

	override void Prepare(DTSweepContext tcx)
	{
		m_Triangles.Clear();
		int count = m_Points.Size();

		// Outer constraints
		for (int i = 0; i < count - 1; ++i)
		{
			DTSweepContext.NewConstraint(m_Points[i], m_Points[i + 1]);
		}
		DTSweepContext.NewConstraint(m_Points[0], m_Points[count - 1]);
		tcx.m_Points.Append(m_Points);

		// Hole constraints
		for(int i = 0; i < m_Holes.Size(); ++i)
		{
			Polygon p = m_Holes[i];
			int holeCount = p.m_Points.Size();
			for (int i = 0; i < holeCount - 1; ++i)
			{
				DTSweepContext.NewConstraint(p.m_Points[i], p.m_Points[i + 1]);
			}
			DTSweepContext.NewConstraint(p.m_Points[0], p.m_Points[holeCount - 1]);
			tcx.m_Points.Append(p.m_Points);
		}

		tcx.m_Points.Append(m_SteinerPoints);
	}
}

class DelaunayTriangle
{
	TriangulationPoint[3] m_Points;
	DelaunayTriangle[3] m_Neighbors;
	bool[3] m_EdgeIsConstrained;
	bool[3] m_EdgeIsDelaunay;
	bool m_IsInterior;

	static DelaunayTriangle Create(TriangulationPoint p1, TriangulationPoint p2, TriangulationPoint p3)
	{
		DelaunayTriangle triangle = new("DelaunayTriangle");

		triangle.m_Points[0] = p1;
		triangle.m_Points[1] = p2;
		triangle.m_Points[2] = p3;

		return triangle;
	}

	int FindInPoints(TriangulationPoint p)
	{
		int i;
		for (i = 0; i < 3; ++i)
		{
			if (m_Points[i] == p) break;
		}
		return i;
	}

	int IndexOf(TriangulationPoint p)
	{
		int index = FindInPoints(p);
		if (index == 3) ThrowAbortException("Calling index with a point that doesn't exist in triangle");
		return index;
	}

	int IndexCWFrom(TriangulationPoint p) { return (IndexOf(p) + 2) % 3; }
	int IndexCCWFrom(TriangulationPoint p) { return (IndexOf(p) + 1) % 3; }

	bool Contains(TriangulationPoint p) { return FindInPoints(p) < 3; }

	private void MarkNeighborPoints(TriangulationPoint p1, TriangulationPoint p2, DelaunayTriangle t)
	{
		int i = EdgeIndex(p1, p2);
		if (i == -1) ThrowAbortException("Error marking neighbors -- t doesn't contain edge p1-p2!");
		m_Neighbors[i] = t;
	}

	void MarkNeighbor(DelaunayTriangle t)
	{
		bool a = t.Contains(m_Points[0]);
		bool b = t.Contains(m_Points[1]);
		bool c = t.Contains(m_Points[2]);

		if (b && c)
		{
			m_Neighbors[0] = t; t.MarkNeighborPoints(m_Points[1], m_Points[2], self);
		}
		else if (a && c)
		{
			m_Neighbors[1] = t; t.MarkNeighborPoints(m_Points[0], m_Points[2], self);
		}
		else if (a && b)
		{
			m_Neighbors[2] = t; t.MarkNeighborPoints(m_Points[0], m_Points[1], self);
		}
		else
		{
			ThrowAbortException("Failed to mark neighbor, doesn't share an edge!");
		}
	}

	TriangulationPoint OppositePoint(DelaunayTriangle t, TriangulationPoint p)
	{
		if (t == self) { ThrowAbortException("Opposite triangle must not be self."); }
		return PointCWFrom(t.PointCWFrom(p));
	}

	DelaunayTriangle NeighborCWFrom(TriangulationPoint point) { return m_Neighbors[(FindInPoints(point) + 1) % 3]; }
	DelaunayTriangle NeighborCCWFrom(TriangulationPoint point) { return m_Neighbors[(FindInPoints(point) + 2) % 3]; }
	DelaunayTriangle NeighborAcrossFrom(TriangulationPoint point) { return m_Neighbors[FindInPoints(point)]; }

	TriangulationPoint PointCCWFrom(TriangulationPoint point) { return m_Points[(IndexOf(point) + 1) % 3]; }
	TriangulationPoint PointCWFrom(TriangulationPoint point) { return m_Points[(IndexOf(point) + 2) % 3]; }

	private void RotateCW()
	{
		let t = m_Points[2];
		m_Points[2] = m_Points[1];
		m_Points[1] = m_Points[0];
		m_Points[0] = t;
	}

	void Legalize(TriangulationPoint oPoint, TriangulationPoint nPoint)
	{
		RotateCW();
		m_Points[IndexCCWFrom(oPoint)] = nPoint;
	}

	void MarkNeighborEdges()
	{
		for (int i = 0; i < 3; ++i)
		{
			if (m_EdgeIsConstrained[i] && m_Neighbors[i] != null)
			{
				m_Neighbors[i].MarkConstrainedEdgePoints(m_Points[(i + 1) % 3], m_Points[(i + 2) % 3]);
			}
		}
	}

	void MarkEdge(DelaunayTriangle triangle)
	{
		for (int i = 0; i < 3; ++i)
		{
			if (m_EdgeIsConstrained[i])
			{
				triangle.MarkConstrainedEdgePoints(m_Points[(i + 1) % 3], m_Points[(i + 2) % 3]);
			}
		}
	}

	void MultiMarkEdge(array<DelaunayTriangle> tList)
	{
		for( int i = 0; i < tList.Size(); ++i)
		{
			DelaunayTriangle t = tList[i];
			for (int j = 0; j < 3; ++j)
			{
				if (t.m_EdgeIsConstrained[j])
				{
					MarkConstrainedEdgePoints(t.m_Points[(j + 1) % 3], t.m_Points[(j + 2) % 3]);
				}
			}
		}
	}

	void MarkConstrainedEdgeIndex(int index)
	{
		m_EdgeIsConstrained[index] = true;
	}

	void MarkConstrainedEdge(DTSweepConstraint edge)
	{
		MarkConstrainedEdgePoints(edge.m_P, edge.m_Q);
	}

	void MarkConstrainedEdgePoints(TriangulationPoint p, TriangulationPoint q)
	{
		int i = EdgeIndex(p, q);
		if (i != -1) m_EdgeIsConstrained[i] = true;
	}

	double Area()
	{
		double b = m_Points[0].m_X - m_Points[1].m_X;
		double h = m_Points[2].m_Y - m_Points[1].m_Y;

		return abs((b * h * 0.5));
	}

	TriangulationPoint Centroid()
	{
		double cx = (m_Points[0].m_X + m_Points[1].m_X + m_Points[2].m_X) / 3.0;
		double cy = (m_Points[0].m_Y + m_Points[1].m_Y + m_Points[2].m_Y) / 3.0;
		return TriangulationPoint.Create(cx, cy);
	}

	int EdgeIndex(TriangulationPoint p1, TriangulationPoint p2)
	{
		int i1 = FindInPoints(p1);
		int i2 = FindInPoints(p2);

		// m_Points of this triangle in the edge p1-p2
		bool a = (i1 == 0 || i2 == 0);
		bool b = (i1 == 1 || i2 == 1);
		bool c = (i1 == 2 || i2 == 2);

		if (b && c) return 0;
		if (a && c) return 1;
		if (a && b) return 2;
		return -1;
	}

	bool GetConstrainedEdgeCCW(TriangulationPoint p) { return m_EdgeIsConstrained[(IndexOf(p) + 2) % 3]; }
	bool GetConstrainedEdgeCW(TriangulationPoint p) { return m_EdgeIsConstrained[(IndexOf(p) + 1) % 3]; }
	bool GetConstrainedEdgeAcross(TriangulationPoint p) { return m_EdgeIsConstrained[IndexOf(p)]; }
	void SetConstrainedEdgeCCW(TriangulationPoint p, bool ce) { m_EdgeIsConstrained[(IndexOf(p) + 2) % 3] = ce; }
	void SetConstrainedEdgeCW(TriangulationPoint p, bool ce) { m_EdgeIsConstrained[(IndexOf(p) + 1) % 3] = ce; }
	void SetConstrainedEdgeAcross(TriangulationPoint p, bool ce) { m_EdgeIsConstrained[IndexOf(p)] = ce; }

	bool GetDelaunayEdgeCCW(TriangulationPoint p) { return m_EdgeIsDelaunay[(IndexOf(p) + 2) % 3]; }
	bool GetDelaunayEdgeCW(TriangulationPoint p) { return m_EdgeIsDelaunay[(IndexOf(p) + 1) % 3]; }
	bool GetDelaunayEdgeAcross(TriangulationPoint p) { return m_EdgeIsDelaunay[IndexOf(p)]; }
	void SetDelaunayEdgeCCW(TriangulationPoint p, bool ce) { m_EdgeIsDelaunay[(IndexOf(p) + 2) % 3] = ce; }
	void SetDelaunayEdgeCW(TriangulationPoint p, bool ce) { m_EdgeIsDelaunay[(IndexOf(p) + 1) % 3] = ce; }
	void SetDelaunayEdgeAcross(TriangulationPoint p, bool ce) { m_EdgeIsDelaunay[IndexOf(p)] = ce; }
}

class AdvancingFront
{
	AdvancingFrontNode m_Head;
	AdvancingFrontNode m_Tail;
	protected AdvancingFrontNode m_Search;

	static AdvancingFront Create(AdvancingFrontNode head, AdvancingFrontNode tail)
	{
		AdvancingFront front = new("AdvancingFront");
		front.m_Head = head;
		front.m_Tail = tail;
		front.m_Search = head;

		return front;
	}

	AdvancingFrontNode LocateNodeFromPoint(TriangulationPoint point) const { return LocateNode(point.m_X); }

	private AdvancingFrontNode LocateNode(double x)
	{
		AdvancingFrontNode node = m_Search;
		if (x < node.m_Value)
		{
			while ((node = node.m_Prev) != null)
			{
				if (x >= node.m_Value)
				{
					m_Search = node;
					return node;
				}
			}
		}
		else
		{
			while ((node = node.m_Next) != null)
			{
				if (x < node.m_Value)
				{
					m_Search = node.m_Prev;
					return node.m_Prev;
				}
			}
		}
		return null;
	}

	AdvancingFrontNode LocatePoint(TriangulationPoint point)
	{
		double px = point.m_X;
		AdvancingFrontNode node = m_Search;
		double nx = node.m_Point.m_X;

		if (px == nx)
		{
			if (point != node.m_Point)
			{
				if (point == node.m_Prev.m_Point)
				{
					node = node.m_Prev;
				}
				else if (point == node.m_Next.m_Point)
				{
					node = node.m_Next;
				}
				else
				{
					ThrowAbortException("Failed to find Node for given afront point");
				}
			}
		}
		else if (px < nx)
		{
			while ((node = node.m_Prev) != null)
			{
				if (point == node.m_Point) break;
			}
		}
		else
		{
			while ((node = node.m_Next) != null)
			{
				if (point == node.m_Point) break;
			}
		}
		m_Search = node;
		return node;
	}
}

class AdvancingFrontNode
{
	AdvancingFrontNode m_Next;
	AdvancingFrontNode m_Prev;
	double m_Value;
	TriangulationPoint m_Point;
	DelaunayTriangle m_Triangle;

	static AdvancingFrontNode Create(TriangulationPoint point)
	{
		AdvancingFrontNode node = new("AdvancingFrontNode");
		node.m_Point = point;
		node.m_Value = point.m_X;

		return node;
	}

	bool HasNext() const { return m_Next != null; }
	bool HasPrev() const { return m_Prev != null; }
}

class DTSweep
{
	const PI_3div4 = 3.0 * M_PI / 4.0;

	static void Triangulate(DTSweepContext tcx)
	{
		tcx.CreateAdvancingFront();

		Sweep(tcx);

		foreach (t : tcx.m_Triangles)
		{
			Legalize(tcx, t);
		}

		if (tcx.m_TriangulationMode == TM_Polygon)
		{
			FinalizationPolygon(tcx);
		}
		else
		{
			FinalizationConvexHull(tcx);
		}

		tcx.Done();
	}

	private static void Sweep(DTSweepContext tcx)
	{
		array<TriangulationPoint> points;
		points.Copy(tcx.m_Points);

		TriangulationPoint point;
		AdvancingFrontNode node;

		for (int i = 1; i < points.Size(); ++i)
		{
			point = points[i];
			node = PointEvent(tcx, point);
			if (point.HasEdges())
			{
				for (int j = 0; j < point.m_Edges.Size(); ++j)
				{
					EdgeEventAlt(tcx, point.m_Edges[j], node);
				}
			}
		}
	}

	private static void FinalizationConvexHull(DTSweepContext tcx)
	{
		AdvancingFrontNode n1, n2, n3;
		DelaunayTriangle t1;
		TriangulationPoint first, p1;

		n1 = tcx.m_Front.m_Head.m_Next;
		n2 = n1.m_Next;
		n3 = n2.m_Next;
		first = n1.m_Point;

		TurnAdvancingFrontConvex(tcx, n1, n2);

		n1 = tcx.m_Front.m_Tail.m_Prev;
		if (n1.m_Triangle.Contains(n1.m_Next.m_Point) && n1.m_Triangle.Contains(n1.m_Prev.m_Point))
		{
			t1 = n1.m_Triangle.NeighborAcrossFrom(n1.m_Point);
			RotateTrianglePair(n1.m_Triangle, n1.m_Point, t1, t1.OppositePoint(n1.m_Triangle, n1.m_Point));
			tcx.MapTriangleToNodes(n1.m_Triangle);
			tcx.MapTriangleToNodes(t1);
		}
		n1 = tcx.m_Front.m_Head.m_Next;
		if (n1.m_Triangle.Contains(n1.m_Prev.m_Point) && n1.m_Triangle.Contains(n1.m_Next.m_Point))
		{
			t1 = n1.m_Triangle.NeighborAcrossFrom(n1.m_Point);
			RotateTrianglePair(n1.m_Triangle, n1.m_Point, t1, t1.OppositePoint(n1.m_Triangle, n1.m_Point));
			tcx.MapTriangleToNodes(n1.m_Triangle);
			tcx.MapTriangleToNodes(t1);
		}

		first = tcx.m_Front.m_Head.m_Point;
		n2 = tcx.m_Front.m_Tail.m_Prev;
		t1 = n2.m_Triangle;
		p1 = n2.m_Point;

		do
		{
			tcx.RemoveFromList(t1);
			p1 = t1.PointCCWFrom(p1);
			if (p1 == first) break;
			t1 = t1.NeighborCCWFrom(p1);
		} while (true);


		first = tcx.m_Front.m_Head.m_Next.m_Point;
		p1 = t1.PointCWFrom(tcx.m_Front.m_Head.m_Point);
		t1 = t1.NeighborCWFrom(tcx.m_Front.m_Head.m_Point);

		do
		{
			tcx.RemoveFromList(t1);
			if (t1 == null)
			{
				Console.Printf("Failed to create convex hull for triangulatable.");
				break;
			}
			p1 = t1.PointCCWFrom(p1);
			if (t1 == null)
			{
				Console.Printf("Failed to create convex hull for triangulatable.");
				break;
			}
			t1 = t1.NeighborCCWFrom(p1);
		} while (p1 != first);


		tcx.FinalizeTriangulation();
	}

	private static void TurnAdvancingFrontConvex(DTSweepContext tcx, AdvancingFrontNode b, AdvancingFrontNode c)
	{
		AdvancingFrontNode first = b;
		while (c != tcx.m_Front.m_Tail)
		{
			if (TriangulationUtil.Orient2d(b.m_Point, c.m_Point, c.m_Next.m_Point) == ORI_CCW)
			{
				Fill(tcx, c);
				c = c.m_Next;
			}
			else
			{
				if (b != first && TriangulationUtil.Orient2d(b.m_Prev.m_Point, b.m_Point, c.m_Point) == ORI_CCW)
				{
					Fill(tcx, b);
					b = b.m_Prev;
				}
				else
				{
					b = c;
					c = c.m_Next;
				}
			}
		}
	}

	private static void FinalizationPolygon(DTSweepContext tcx)
	{
		DelaunayTriangle t = tcx.m_Front.m_Head.m_Next.m_Triangle;
		TriangulationPoint p = tcx.m_Front.m_Head.m_Next.m_Point;

		while (!t.GetConstrainedEdgeCW(p))
		{
			t = t.NeighborCCWFrom(p);
		}

		tcx.MeshClean(t);
	}

	private static AdvancingFrontNode PointEvent(DTSweepContext tcx, TriangulationPoint point)
	{
		AdvancingFrontNode node, newNode;

		node = tcx.LocateNode(point);
		newNode = NewFrontTriangle(tcx, point, node);

		if (point.m_X <= node.m_Point.m_X + TriangulationUtil.EPSILON) Fill(tcx, node);

		FillAdvancingFront(tcx, newNode);
		return newNode;
	}

	private static AdvancingFrontNode NewFrontTriangle(DTSweepContext tcx, TriangulationPoint point, AdvancingFrontNode node)
	{
		AdvancingFrontNode newNode;
		DelaunayTriangle triangle;

		triangle = DelaunayTriangle.Create(point, node.m_Point, node.m_Next.m_Point);
		triangle.MarkNeighbor(node.m_Triangle);
		tcx.m_Triangles.Push(triangle);

		newNode = AdvancingFrontNode.Create(point);
		newNode.m_Next = node.m_Next;
		newNode.m_Prev = node;
		node.m_Next.m_Prev = newNode;
		node.m_Next = newNode;

		if (!Legalize(tcx, triangle)) tcx.MapTriangleToNodes(triangle);

		return newNode;
	}

	private static void EdgeEventAlt(DTSweepContext tcx, DTSweepConstraint edge, AdvancingFrontNode node)
	{
		tcx.m_EdgeEvent.m_ConstrainedEdge = edge;
		tcx.m_EdgeEvent.m_Right = edge.m_P.m_X > edge.m_Q.m_X;

		if (IsEdgeSideOfTriangle(node.m_Triangle, edge.m_P, edge.m_Q)) return;
		FillEdgeEvent(tcx, edge, node);
		EdgeEvent(tcx, edge.m_P, edge.m_Q, node.m_Triangle, edge.m_Q);
	}

	private static void FillEdgeEvent(DTSweepContext tcx, DTSweepConstraint edge, AdvancingFrontNode node)
	{
		if (tcx.m_EdgeEvent.m_Right)
		{
			FillRightAboveEdgeEvent(tcx, edge, node);
		}
		else
		{
			FillLeftAboveEdgeEvent(tcx, edge, node);
		}
	}

	private static void FillRightConcaveEdgeEvent(DTSweepContext tcx, DTSweepConstraint edge, AdvancingFrontNode node)
	{
		Fill(tcx, node.m_Next);
		if (node.m_Next.m_Point != edge.m_P)
		{
			if (TriangulationUtil.Orient2d(edge.m_Q, node.m_Next.m_Point, edge.m_P) == ORI_CCW)
			{
				// Below
				if (TriangulationUtil.Orient2d(node.m_Point, node.m_Next.m_Point, node.m_Next.m_Next.m_Point) == ORI_CCW)
				{
					FillRightConcaveEdgeEvent(tcx, edge, node);
				}
			}
		}
	}

	private static void FillRightConvexEdgeEvent(DTSweepContext tcx, DTSweepConstraint edge, AdvancingFrontNode node)
	{
		if (TriangulationUtil.Orient2d(node.m_Next.m_Point, node.m_Next.m_Next.m_Point, node.m_Next.m_Next.m_Next.m_Point) == ORI_CCW)
		{
			FillRightConcaveEdgeEvent(tcx, edge, node.m_Next);
		}
		else
		{
			if (TriangulationUtil.Orient2d(edge.m_Q, node.m_Next.m_Next.m_Point, edge.m_P) == ORI_CCW)
			{
				FillRightConvexEdgeEvent(tcx, edge, node.m_Next);
			}
		}
	}

	private static void FillRightBelowEdgeEvent(DTSweepContext tcx, DTSweepConstraint edge, AdvancingFrontNode node)
	{
		if (node.m_Point.m_X < edge.m_P.m_X)
		{
			if (TriangulationUtil.Orient2d(node.m_Point, node.m_Next.m_Point, node.m_Next.m_Next.m_Point) == ORI_CCW)
			{
				FillRightConcaveEdgeEvent(tcx, edge, node);
			}
			else
			{
				FillRightConvexEdgeEvent(tcx, edge, node);
				FillRightBelowEdgeEvent(tcx, edge, node);
			}

		}
	}

	private static void FillRightAboveEdgeEvent(DTSweepContext tcx, DTSweepConstraint edge, AdvancingFrontNode node)
	{
		while (node.m_Next.m_Point.m_X < edge.m_P.m_X)
		{
			EOrientation o1 = TriangulationUtil.Orient2d(edge.m_Q, node.m_Next.m_Point, edge.m_P);
			if (o1 == ORI_CCW)
			{
				FillRightBelowEdgeEvent(tcx, edge, node);
			}
			else
			{
				node = node.m_Next;
			}
		}
	}

	private static void FillLeftConvexEdgeEvent(DTSweepContext tcx, DTSweepConstraint edge, AdvancingFrontNode node)
	{
		if (TriangulationUtil.Orient2d(node.m_Prev.m_Point, node.m_Prev.m_Prev.m_Point, node.m_Prev.m_Prev.m_Prev.m_Point) == ORI_CW)
		{
			FillLeftConcaveEdgeEvent(tcx, edge, node.m_Prev);
		}
		else
		{
			if (TriangulationUtil.Orient2d(edge.m_Q, node.m_Prev.m_Prev.m_Point, edge.m_P) == ORI_CW)
			{
				FillLeftConvexEdgeEvent(tcx, edge, node.m_Prev);
			}
		}
	}

	private static void FillLeftConcaveEdgeEvent(DTSweepContext tcx, DTSweepConstraint edge, AdvancingFrontNode node)
	{
		Fill(tcx, node.m_Prev);
		if (node.m_Prev.m_Point != edge.m_P)
		{
			if (TriangulationUtil.Orient2d(edge.m_Q, node.m_Prev.m_Point, edge.m_P) == ORI_CW)
			{
				if (TriangulationUtil.Orient2d(node.m_Point, node.m_Prev.m_Point, node.m_Prev.m_Prev.m_Point) == ORI_CW)
				{
					FillLeftConcaveEdgeEvent(tcx, edge, node);
				}
			}
		}
	}

	private static void FillLeftBelowEdgeEvent(DTSweepContext tcx, DTSweepConstraint edge, AdvancingFrontNode node)
	{
		if (node.m_Point.m_X > edge.m_P.m_X)
		{
			if (TriangulationUtil.Orient2d(node.m_Point, node.m_Prev.m_Point, node.m_Prev.m_Prev.m_Point) == ORI_CW)
			{
				FillLeftConcaveEdgeEvent(tcx, edge, node);
			}
			else
			{
				FillLeftConvexEdgeEvent(tcx, edge, node);
				FillLeftBelowEdgeEvent(tcx, edge, node);
			}
		}
	}

	private static void FillLeftAboveEdgeEvent(DTSweepContext tcx, DTSweepConstraint edge, AdvancingFrontNode node)
	{
		while (node.m_Prev.m_Point.m_X > edge.m_P.m_X)
		{
			EOrientation o1 = TriangulationUtil.Orient2d(edge.m_Q, node.m_Prev.m_Point, edge.m_P);
			if (o1 == ORI_CW)
			{
				FillLeftBelowEdgeEvent(tcx, edge, node);
			}
			else
			{
				node = node.m_Prev;
			}
		}
	}

	private static bool IsEdgeSideOfTriangle(DelaunayTriangle triangle, TriangulationPoint ep, TriangulationPoint eq)
	{
		int index = triangle.EdgeIndex(ep, eq);
		if (index == -1) return false;
		triangle.MarkConstrainedEdgeIndex(index);
		triangle = triangle.m_Neighbors[index];
		if (triangle != null) triangle.MarkConstrainedEdgePoints(ep, eq);
		return true;
	}

	private static void EdgeEvent(DTSweepContext tcx, TriangulationPoint ep, TriangulationPoint eq, DelaunayTriangle triangle, TriangulationPoint point)
	{
		TriangulationPoint p1, p2;

		if (IsEdgeSideOfTriangle(triangle, ep, eq)) return;

		p1 = triangle.PointCCWFrom(point);
		EOrientation o1 = TriangulationUtil.Orient2d(eq, p1, ep);

		p2 = triangle.PointCWFrom(point);
		EOrientation o2 = TriangulationUtil.Orient2d(eq, p2, ep);

		if (o1 == o2)
		{
			if (o1 == ORI_CW)
			{
				triangle = triangle.NeighborCCWFrom(point);
			}
			else
			{
				triangle = triangle.NeighborCWFrom(point);
			}
			EdgeEvent(tcx, ep, eq, triangle, point);
		}
		else
		{
			FlipEdgeEvent(tcx, ep, eq, triangle, point);
		}
	}

	private static void FlipEdgeEvent(DTSweepContext tcx, TriangulationPoint ep, TriangulationPoint eq, DelaunayTriangle t, TriangulationPoint p)
	{
		DelaunayTriangle ot = t.NeighborAcrossFrom(p);
		TriangulationPoint op = ot.OppositePoint(t, p);

		if (ot == null)
		{
			ThrowAbortException("[BUG:FIXME] FLIP failed due to missing triangle");
		}

		bool inScanArea = TriangulationUtil.InScanArea(p, t.PointCCWFrom(p), t.PointCWFrom(p), op);
		if (inScanArea)
		{
			RotateTrianglePair(t, p, ot, op);
			tcx.MapTriangleToNodes(t);
			tcx.MapTriangleToNodes(ot);

			if (p == eq && op == ep)
			{
				if (eq == tcx.m_EdgeEvent.m_ConstrainedEdge.m_Q
					&& ep == tcx.m_EdgeEvent.m_ConstrainedEdge.m_P)
				{
					t.MarkConstrainedEdgePoints(ep, eq);
					ot.MarkConstrainedEdgePoints(ep, eq);
					Legalize(tcx, t);
					Legalize(tcx, ot);
				}
			}
			else
			{
				EOrientation o = TriangulationUtil.Orient2d(eq, op, ep);
				t = NextFlipTriangle(tcx, o, t, ot, p, op);
				FlipEdgeEvent(tcx, ep, eq, t, p);
			}
		}
		else
		{
			TriangulationPoint newP = NextFlipPoint(ep, eq, ot, op);
			FlipScanEdgeEvent(tcx, ep, eq, t, ot, newP);
			EdgeEvent(tcx, ep, eq, t, p);
		}
	}

	private static TriangulationPoint NextFlipPoint(TriangulationPoint ep, TriangulationPoint eq, DelaunayTriangle ot, TriangulationPoint op)
	{
		EOrientation o2d = TriangulationUtil.Orient2d(eq, op, ep);
		switch (o2d)
		{
			case ORI_CW: return ot.PointCCWFrom(op);
			case ORI_CCW: return ot.PointCWFrom(op);
			case ORI_Collinear:
			default:
				ThrowAbortException("Orientation not handled");
		}

		// Only here so the compiler doesn't complain.
		return null;
	}

	private static DelaunayTriangle NextFlipTriangle(DTSweepContext tcx, EOrientation o, DelaunayTriangle t, DelaunayTriangle ot, TriangulationPoint p, TriangulationPoint op)
	{
		int edgeIndex;
		if (o == ORI_CCW)
		{
			edgeIndex = ot.EdgeIndex(p, op);
			ot.m_EdgeIsDelaunay[edgeIndex] = true;
			Legalize(tcx, ot);
			ot.m_EdgeIsDelaunay[0] = false;
			ot.m_EdgeIsDelaunay[1] = false;
			ot.m_EdgeIsDelaunay[2] = false;
			return t;
		}

		edgeIndex = t.EdgeIndex(p, op);
		t.m_EdgeIsDelaunay[edgeIndex] = true;
		Legalize(tcx, t);
		t.m_EdgeIsDelaunay[0] = false;
		t.m_EdgeIsDelaunay[1] = false;
		t.m_EdgeIsDelaunay[2] = false;
		return ot;
	}

	private static void FlipScanEdgeEvent(DTSweepContext tcx, TriangulationPoint ep, TriangulationPoint eq, DelaunayTriangle flipTriangle, DelaunayTriangle t, TriangulationPoint p)
	{
		DelaunayTriangle ot;
		TriangulationPoint op, newP;
		bool inScanArea;

		ot = t.NeighborAcrossFrom(p);
		op = ot.OppositePoint(t, p);

		if (ot == null)
		{
			ThrowAbortException("[BUG:FIXME] FLIP failed due to missing triangle");
		}

		inScanArea = TriangulationUtil.InScanArea(eq, flipTriangle.PointCCWFrom(eq), flipTriangle.PointCWFrom(eq), op);
		if (inScanArea)
		{
			FlipEdgeEvent(tcx, eq, op, ot, op);
		}
		else
		{
			newP = NextFlipPoint(ep, eq, ot, op);
			FlipScanEdgeEvent(tcx, ep, eq, flipTriangle, ot, newP);
		}
	}

	private static void FillAdvancingFront(DTSweepContext tcx, AdvancingFrontNode n)
	{
		AdvancingFrontNode node;
		double angle;

		node = n.m_Next;
		while (node.HasNext())
		{
			angle = HoleAngle(node);
			if (angle > M_PI_2 || angle < -M_PI_2) break;
			Fill(tcx, node);
			node = node.m_Next;
		}

		node = n.m_Prev;
		while (node.HasPrev())
		{
			angle = HoleAngle(node);
			if (angle > M_PI_2 || angle < -M_PI_2) break;
			Fill(tcx, node);
			node = node.m_Prev;
		}

		if (n.HasNext() && n.m_Next.HasNext())
		{
			angle = BasinAngle(n);
			if (angle < PI_3div4) FillBasin(tcx, n);
		}
	}

	private static void FillBasin(DTSweepContext tcx, AdvancingFrontNode node)
	{
		if (TriangulationUtil.Orient2d(node.m_Point, node.m_Next.m_Point, node.m_Next.m_Next.m_Point) == ORI_CCW)
		{
			tcx.m_Basin.m_LeftNode = node;
		}
		else
		{
			tcx.m_Basin.m_LeftNode = node.m_Next;
		}

		tcx.m_Basin.m_BottomNode = tcx.m_Basin.m_LeftNode;
		while (tcx.m_Basin.m_BottomNode.HasNext() && tcx.m_Basin.m_BottomNode.m_Point.m_Y >= tcx.m_Basin.m_BottomNode.m_Next.m_Point.m_Y)
		{
			tcx.m_Basin.m_BottomNode = tcx.m_Basin.m_BottomNode.m_Next;
		}

		if (tcx.m_Basin.m_BottomNode == tcx.m_Basin.m_LeftNode) return;

		tcx.m_Basin.m_RightNode = tcx.m_Basin.m_BottomNode;
		while (tcx.m_Basin.m_RightNode.HasNext() && tcx.m_Basin.m_RightNode.m_Point.m_Y < tcx.m_Basin.m_RightNode.m_Next.m_Point.m_Y)
		{
			tcx.m_Basin.m_RightNode = tcx.m_Basin.m_RightNode.m_Next;
		}

		if (tcx.m_Basin.m_RightNode == tcx.m_Basin.m_BottomNode) return;

		tcx.m_Basin.m_Width = tcx.m_Basin.m_RightNode.m_Point.m_X - tcx.m_Basin.m_LeftNode.m_Point.m_X;
		tcx.m_Basin.m_LeftHighest = tcx.m_Basin.m_LeftNode.m_Point.m_Y > tcx.m_Basin.m_RightNode.m_Point.m_Y;

		FillBasinReq(tcx, tcx.m_Basin.m_BottomNode);
	}

	private static void FillBasinReq(DTSweepContext tcx, AdvancingFrontNode node)
	{
		if (IsShallow(tcx, node)) return;

		Fill(tcx, node);
		if (node.m_Prev == tcx.m_Basin.m_LeftNode && node.m_Next == tcx.m_Basin.m_RightNode)
		{
			return;
		}
		else if (node.m_Prev == tcx.m_Basin.m_LeftNode)
		{
			EOrientation o = TriangulationUtil.Orient2d(node.m_Point, node.m_Next.m_Point, node.m_Next.m_Next.m_Point);
			if (o == ORI_CW) return;
			node = node.m_Next;
		}
		else if (node.m_Next == tcx.m_Basin.m_RightNode)
		{
			EOrientation o = TriangulationUtil.Orient2d(node.m_Point, node.m_Prev.m_Point, node.m_Prev.m_Prev.m_Point);
			if (o == ORI_CCW) return;
			node = node.m_Prev;
		}
		else
		{
			if (node.m_Prev.m_Point.m_Y < node.m_Next.m_Point.m_Y)
			{
				node = node.m_Prev;
			}
			else
			{
				node = node.m_Next;
			}
		}
		FillBasinReq(tcx, node);
	}

	private static bool IsShallow(DTSweepContext tcx, AdvancingFrontNode node)
	{
		double height;

		if (tcx.m_Basin.m_LeftHighest)
		{
			height = tcx.m_Basin.m_LeftNode.m_Point.m_Y - node.m_Point.m_Y;
		}
		else
		{
			height = tcx.m_Basin.m_RightNode.m_Point.m_Y - node.m_Point.m_Y;
		}
		if (tcx.m_Basin.m_Width > height)
		{
			return true;
		}
		return false;
	}

	private static double HoleAngle(AdvancingFrontNode node)
	{
		double px = node.m_Point.m_X;
		double py = node.m_Point.m_Y;
		double ax = node.m_Next.m_Point.m_X - px;
		double ay = node.m_Next.m_Point.m_Y - py;
		double bx = node.m_Prev.m_Point.m_X - px;
		double by = node.m_Prev.m_Point.m_Y - py;
		return atan2(ax * by - ay * bx, ax * bx + ay * by);
	}

	private static double BasinAngle(AdvancingFrontNode node)
	{
		double ax = node.m_Point.m_X - node.m_Next.m_Next.m_Point.m_X;
		double ay = node.m_Point.m_Y - node.m_Next.m_Next.m_Point.m_Y;
		return atan2(ay, ax);
	}

	private static void Fill(DTSweepContext tcx, AdvancingFrontNode node)
	{
		DelaunayTriangle triangle = DelaunayTriangle.Create(node.m_Prev.m_Point, node.m_Point, node.m_Next.m_Point);

		triangle.MarkNeighbor(node.m_Prev.m_Triangle);
		triangle.MarkNeighbor(node.m_Triangle);
		tcx.m_Triangles.Push(triangle);

		node.m_Prev.m_Next = node.m_Next;
		node.m_Next.m_Prev = node.m_Prev;

		if (!Legalize(tcx, triangle)) tcx.MapTriangleToNodes(triangle);
	}

	private static bool Legalize(DTSweepContext tcx, DelaunayTriangle t)
	{
		for (int i = 0; i < 3; i++)
		{
			if (t.m_EdgeIsDelaunay[i]) continue;

			DelaunayTriangle ot = t.m_Neighbors[i];
			if (ot == null) continue;

			TriangulationPoint p = t.m_Points[i];
			TriangulationPoint op = ot.OppositePoint(t, p);
			int oi = ot.IndexOf(op);
			if (ot.m_EdgeIsConstrained[oi] || ot.m_EdgeIsDelaunay[oi])
			{
				t.m_EdgeIsConstrained[i] = ot.m_EdgeIsConstrained[oi];
				continue;
			}

			if (!TriangulationUtil.SmartInCircle(p, t.PointCCWFrom(p), t.PointCWFrom(p), op)) continue;

			t.m_EdgeIsDelaunay[i] = true;
			ot.m_EdgeIsDelaunay[oi] = true;

			RotateTrianglePair(t, p, ot, op);

			if (!Legalize(tcx, t)) tcx.MapTriangleToNodes(t);
			if (!Legalize(tcx, ot)) tcx.MapTriangleToNodes(ot);

			t.m_EdgeIsDelaunay[i] = false;
			ot.m_EdgeIsDelaunay[oi] = false;

			return true;
		}
		return false;
	}

	private static void RotateTrianglePair(DelaunayTriangle t, TriangulationPoint p, DelaunayTriangle ot, TriangulationPoint op)
	{
		DelaunayTriangle n1, n2, n3, n4;
		n1 = t.NeighborCCWFrom(p);
		n2 = t.NeighborCWFrom(p);
		n3 = ot.NeighborCCWFrom(op);
		n4 = ot.NeighborCWFrom(op);

		bool ce1, ce2, ce3, ce4;
		ce1 = t.GetConstrainedEdgeCCW(p);
		ce2 = t.GetConstrainedEdgeCW(p);
		ce3 = ot.GetConstrainedEdgeCCW(op);
		ce4 = ot.GetConstrainedEdgeCW(op);

		bool de1, de2, de3, de4;
		de1 = t.GetDelaunayEdgeCCW(p);
		de2 = t.GetDelaunayEdgeCW(p);
		de3 = ot.GetDelaunayEdgeCCW(op);
		de4 = ot.GetDelaunayEdgeCW(op);

		t.Legalize(p, op);
		ot.Legalize(op, p);

		ot.SetDelaunayEdgeCCW(p, de1);
		t.SetDelaunayEdgeCW(p, de2);
		t.SetDelaunayEdgeCCW(op, de3);
		ot.SetDelaunayEdgeCW(op, de4);

		ot.SetConstrainedEdgeCCW(p, ce1);
		t.SetConstrainedEdgeCW(p, ce2);
		t.SetConstrainedEdgeCCW(op, ce3);
		ot.SetConstrainedEdgeCW(op, ce4);

		t.m_Neighbors[0] = null;
		t.m_Neighbors[1] = null;
		t.m_Neighbors[2] = null;

		ot.m_Neighbors[0] = null;
		ot.m_Neighbors[1] = null;
		ot.m_Neighbors[2] = null;

		if (n1 != null) ot.MarkNeighbor(n1);
		if (n2 != null) t.MarkNeighbor(n2);
		if (n3 != null) t.MarkNeighbor(n3);
		if (n4 != null) ot.MarkNeighbor(n4);
		t.MarkNeighbor(ot);
	}
}

class DTSweepBasin
{
	AdvancingFrontNode m_LeftNode;
	AdvancingFrontNode m_BottomNode;
	AdvancingFrontNode m_RightNode;
	float m_Width;
	bool m_LeftHighest;
}

class DTSweepConstraint
{
	TriangulationPoint m_P;
	TriangulationPoint m_Q;

	static DTSweepConstraint Create(TriangulationPoint p1, TriangulationPoint p2)
	{
		DTSweepConstraint t = new("DTSweepConstraint");
		t.m_P = p1;
		t.m_Q = p2;
		if (p1.m_Y > p2.m_Y)
		{
			t.m_Q = p1;
			t.m_P = p2;
		}
		else if (p1.m_Y == p2.m_Y)
		{
			if (p1.m_X > p2.m_X)
			{
				t.m_Q = p1;
				t.m_P = p2;
			}
		}
		t.m_Q.AddEdge(t);

		return t;
	}
}

class DTSweepContext
{
	const ALPHA = 0.7;

	array<DelaunayTriangle> m_Triangles;
	array<TriangulationPoint> m_Points;

	ETriangulationMode m_TriangulationMode;
	Triangulatable m_Triangulatable;

	int m_StepCount;

	AdvancingFront m_Front;
	TriangulationPoint m_Head;
	TriangulationPoint m_Tail;

	DTSweepBasin m_Basin;
	DTSweepEdgeEvent m_EdgeEvent;

	static DTSweepContext Create()
	{
		DTSweepContext ctx = new("DTSweepContext");
		ctx.m_Basin = new("DTSweepBasin");
		ctx.m_EdgeEvent = new("DTSweepEdgeEvent");
		ctx.Clear();

		return ctx;
	}

	void Done()
	{
		m_StepCount++;
	}

	void RemoveFromList(DelaunayTriangle triangle)
	{
		m_Triangles.Delete(m_Triangles.Find(triangle));
	}

	void MeshClean(DelaunayTriangle triangle)
	{
		MeshCleanReq(triangle);
	}

	private void MeshCleanReq(DelaunayTriangle triangle)
	{
		if (triangle && !triangle.m_IsInterior)
		{
			triangle.m_IsInterior = true;
			m_Triangulatable.AddTriangle(triangle);

			for (int i = 0; i < 3; ++i)
			{
				if (!triangle.m_EdgeIsConstrained[i])
				{
					MeshCleanReq(triangle.m_Neighbors[i]);
				}
			}
		}
	}

	void Clear()
	{
		m_Points.Clear();
		m_StepCount = 0;
		m_Triangles.Clear();
	}

	AdvancingFrontNode LocateNode(TriangulationPoint point)
	{
		return m_Front.LocateNodeFromPoint(point);
	}

	void CreateAdvancingFront()
	{
		AdvancingFrontNode head, tail, middle;

		DelaunayTriangle iTriangle = DelaunayTriangle.Create(m_Points[0], m_Tail, m_Head);
		m_Triangles.Push(iTriangle);

		head = AdvancingFrontNode.Create(iTriangle.m_Points[1]);
		head.m_Triangle = iTriangle;
		middle = AdvancingFrontNode.Create(iTriangle.m_Points[0]);
		middle.m_Triangle = iTriangle;
		tail = AdvancingFrontNode.Create(iTriangle.m_Points[2]);

		m_Front = AdvancingFront.Create(head, tail);

		m_Front.m_Head.m_Next = middle;
		middle.m_Next = m_Front.m_Tail;
		middle.m_Prev = m_Front.m_Head;
		m_Front.m_Tail.m_Prev = middle;
	}

	void MapTriangleToNodes(DelaunayTriangle t)
	{
		for (int i = 0; i < 3; i++)
		{
			if (t.m_Neighbors[i] == null)
			{
				AdvancingFrontNode n = m_Front.LocatePoint(t.PointCWFrom(t.m_Points[i]));
				if (n != null) n.m_Triangle = t;
			}
		}
	}

	void PrepareTriangulation(Triangulatable t)
	{
		m_Triangulatable = t;
		m_TriangulationMode = t.GetTriangulationMode();
		t.Prepare(self);

		float xmax, xmin;
		float ymax, ymin;

		xmax = xmin = m_Points[0].m_X;
		ymax = ymin = m_Points[0].m_Y;

		// Calculate bounds. Should be combined with the sorting
		for(int i = 0; i < m_Points.Size(); ++i)
		{
			TriangulationPoint p = m_Points[i];
			if (p.m_X > xmax) xmax = p.m_X;
			if (p.m_X < xmin) xmin = p.m_X;
			if (p.m_Y > ymax) ymax = p.m_Y;
			if (p.m_Y < ymin) ymin = p.m_Y;
		}

		float deltaX = ALPHA * (xmax - xmin);
		float deltaY = ALPHA * (ymax - ymin);
		TriangulationPoint p1 = TriangulationPoint.Create(xmax + deltaX, ymin - deltaY);
		TriangulationPoint p2 = TriangulationPoint.Create(xmin - deltaX, ymin - deltaY);

		m_Head = p1;
		m_Tail = p2;

		TriangulationUtil.SortPointsVertically(m_Points);
	}

	void FinalizeTriangulation()
	{
		m_Triangulatable.AddTriangles(m_Triangles);
		m_Triangles.Clear();
	}

	static DTSweepConstraint NewConstraint(TriangulationPoint a, TriangulationPoint b)
	{
		return DTSweepConstraint.Create(a, b);
	}
}

class DTSweepEdgeEvent
{
	DTSweepConstraint m_ConstrainedEdge;
	bool m_Right;
}