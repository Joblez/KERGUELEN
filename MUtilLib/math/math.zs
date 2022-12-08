// TODO: [Long-term] Learn way more math.

class Math
{
	static double Sign(double num)
	{
		return num >= 0.0 ? 1.0 : -1.0;
	}

	static double Lerp(double start, double end, double step)
	{
		return start + (end - start) * step;
	}

	static double Remap(double value, double aMin, double aMax, double bMin, double bMax)
	{
		return bMin + (value - aMin) * (bMax - bMin) / (aMax - aMin);
	}

	static double PosMod(double a, double b)
	{
		b = abs(b);

		if (b == 0.0) ThrowAbortException("\"a mod 0\" is undefined.");

		double remainder = a % b;
		return remainder < 0 ? remainder + b : remainder;
	}

	static double Wrap(double value, double start, double end)
	{
		if (value < start)
		{
			value = end - (start - value) % (end - start);
		}
		else
		{
			value = start + (value - start) % (end - start);
		}

		return value;
	}

	static double DegToRad(double degrees)
	{
		return degrees * (M_PI / 180.0);
	}

	static double RadToDeg(double radians)
	{
		return (180.0 / M_PI) * radians;
	}

	static double SmoothDamp(
		double from,
		double to,
		out double currentSpeed,
		double smoothTime,
		double maxSpeed,
		double delta)
	{
		smoothTime = max(0.001, smoothTime);
		double omega = 2.0 / smoothTime;
		double x = omega * delta;
		double exponent = 1 / (1 + x + (0.48 * x * x) + (0.235 * x * x * x));
		double difference = from - to;
		double originalTo = to;

		double maxDifference = maxSpeed * smoothTime;
		difference = clamp(difference, -maxDifference, maxDifference);
		to = from - difference;
		double temp = (currentSpeed + (omega * difference)) * delta;
		currentSpeed = (currentSpeed - (omega * temp)) * exponent;
		double result = to + ((difference + temp) * exponent);

		if (originalTo - from > 0.0 == result > originalTo)
		{
			result = originalTo;
			currentSpeed = (result - originalTo) / delta;
		}

		return result;
	}
}

class MathF
{
	static float Sign(float num)
	{
		return num >= 0.0 ? 1.0 : -1.0;
	}

	static float Lerp(float start, float end, float step)
	{
		return start + (end - start) * step;
	}

	static float Remap(float value, float aMin, float aMax, float bMin, float bMax)
	{
		return bMin + (value - aMin) * (bMax - bMin) / (aMax - aMin);
	}

	static float PosMod(float a, float b)
	{
		b = abs(b);

		if (b == 0.0) ThrowAbortException("\"a mod 0\" is undefined.");

		float remainder = a % b;
		return remainder < 0.0 ? remainder + b : remainder;
	}

	static float Wrap(float value, float start, float end)
	{
		if (value < start)
		{
			value = end - (start - value) % (end - start);
		}
		else
		{
			value = start + (value - start) % (end - start);
		}

		return value;
	}

	static float DegToRad(float degrees)
	{
		return degrees * (M_PI / 180.0);
	}

	static float RadToDeg(float radians)
	{
		return (180.0 / M_PI) * radians;
	}

	static float SmoothDamp(
		float from,
		float to,
		out float currentSpeed,
		float smoothTime,
		float maxSpeed,
		float delta)
	{
		smoothTime = max(0.001, smoothTime);
		float omega = 2.0 / smoothTime;
		float x = omega * delta;
		float exponent = 1 / (1 + x + (0.48 * x * x) + (0.235 * x * x * x));
		float difference = from - to;
		float originalTo = to;

		float maxDifference = maxSpeed * smoothTime;
		difference = clamp(difference, -maxDifference, maxDifference);
		to = from - difference;
		float temp = (currentSpeed + (omega * difference)) * delta;
		currentSpeed = (currentSpeed - (omega * temp)) * exponent;
		float result = to + ((difference + temp) * exponent);

		if (originalTo - from > 0.0 == result > originalTo)
		{
			result = originalTo;
			currentSpeed = (result - originalTo) / delta;
		}

		return result;
	}
}

class MathI
{
	static int Sign(int num)
	{
		return num >= 0 ? 1 : -1;
	}

	static int Lerp(int start, int end, int step)
	{
		return start + (end - start) * step;
	}

	static int Remap(int value, int aMin, int aMax, int bMin, int bMax)
	{
		return bMin + (value - aMin) * (bMax - bMin) / (aMax - aMin);
	}

	static int PosMod(int a, int b)
	{
		b = abs(b);

		if (b == 0) ThrowAbortException("\"a mod 0\" is undefined.");

		int remainder = a % b;
		return remainder < 0 ? remainder + b : remainder;
	}

	static int Wrap(int value, int start, int end)
	{
		if (value < start)
		{
			value = end - (start - value) % (end - start);
		}
		else
		{
			value = start + (value - start) % (end - start);
		}

		return value;
	}
}

class MathVec2
{
	static vector2 Clamp(vector2 vector, double minLength, double maxLength)
	{
		if (minLength < 0.0) minLength = 0.0;

		double length = vector.Length();
		double targetLength = length;

		if (length < minLength)
		{
			targetLength = minLength;
		}
		else if (length > maxLength)
		{
			targetLength = maxLength;
		}

		if (targetLength == length)
		{
			return vector;
		}

		return vector = (vector.x * (targetLength / length), vector.y * (targetLength / length));
	}

	static double DistanceBetween(vector2 a, vector2 b)
	{
		return sqrt((b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y));
	}

	static double SquareDistanceBetween(vector2 a, vector2 b)
	{
		return (b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y);
	}

	static vector2 Rotate(vector2 vector, double angle)
	{
		return (vector.x * cos(angle) - vector.y * sin(angle), vector.x * sin(angle) + vector.y * cos(angle));
	}

	static vector2 RotateAround(vector2 vector, vector2 pivot, double angle)
	{
		return pivot + Rotate(vector - pivot, angle);
	}

	static vector2 CartesianToPolar(vector2 coords)
	{
		return (sqrt(coords.x * coords.x + coords.y * coords.y), atan(coords.y / coords.x));
	}

	static vector2 PolarToCartesian(vector2 coords)
	{
		return (coords.x * cos(coords.y), coords.x * sin(coords.y));
	}

	static vector2 SmoothDamp(
		vector2 from,
		vector2 to,
		out vector2 currentSpeed,
		double smoothTime,
		double maxSpeed,
		double delta)
	{
		smoothTime = max(0.001, smoothTime);
		double omega = 2.0 / smoothTime;
		double x = omega * delta;
		double exponent = 1.0 / (1.0 + x + (0.48 * x * x) + (0.235 * x * x * x));
		double xDifference = from.x - to.x;
		double yDifference = from.y - to.y;
		vector2 originalTo = to;

		double maxDifference = maxSpeed * smoothTime;
		double maxDifferenceSquared = maxDifference * maxDifference;


		double squareMagnitude = (xDifference * xDifference) + (yDifference * yDifference);

		if (squareMagnitude > maxDifferenceSquared)
		{
			double magnitude = sqrt(squareMagnitude);
			xDifference = xDifference / magnitude * maxDifference;
			yDifference = yDifference / magnitude * maxDifference;
		}

		to.x = from.x - xDifference;
		to.y = from.y - yDifference;

		double xTemp = (currentSpeed.x + (omega * xDifference)) * delta;
		double yTemp = (currentSpeed.y + (omega * yDifference)) * delta;
		currentSpeed.x = (currentSpeed.x - (omega * xTemp)) * exponent;
		currentSpeed.y = (currentSpeed.y - (omega * yTemp)) * exponent;

		double xResult = to.x + ((xDifference + xTemp) * exponent);
		double yResult = to.y + ((yDifference + yTemp) * exponent);

		double bXDifference = originalTo.x - from.x;
		double bYDifference = originalTo.y - from.y;
		double bXResult = xResult - originalTo.x;
		double bYResult = yResult - originalTo.y;

		if ((bXDifference * bXResult) + (bYDifference * bYResult) > 0)
		{
			xResult = originalTo.x;
			yResult = originalTo.y;
			currentSpeed.x = (xResult - originalTo.x) / delta;
			currentSpeed.y = (yResult - originalTo.y) / delta;
		}

		return (xResult, yResult);
	}
}

class MathVec3
{
	static vector3 Clamp(vector3 vector, double minLength, double maxLength)
	{
		double length = vector.Length();
		double targetLength = length;

		if (length < minLength)
		{
			targetLength = minLength;
		}
		else if (length > maxLength)
		{
			targetLength = maxLength;
		}

		if (targetLength == length)
		{
			return vector;
		}

		return vector = (vector.x * (targetLength / length), vector.y * (targetLength / length), vector.z * (targetLength / length));
	}

	static double DistanceBetween(vector3 a, vector3 b)
	{
		return sqrt((b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y) + (b.z - a.z) * (b.z - a.z));
	}

	static double SquareDistanceBetween(vector3 a, vector3 b)
	{
		return (b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y) + (b.z - a.z) * (b.z - a.z);
	}

	static vector3 Rotate(vector3 vector, vector3 axis, double angle)
	{
		vector3 a = axis cross vector;
		vector3 b = axis cross a;
		return vector + sin(angle) * a + (1 - cos(angle)) * b;
	}

	static vector3 RotateAround(vector3 vector, vector3 pivot, vector3 axis, double angle)
	{
		return pivot + Rotate(vector - pivot, axis, angle);
	}

	static vector2 ToYawAndPitch(vector3 vector)
	{
		return (atan2(vector.y, vector.x), atan(vector.z / sqrt(vector.x * vector.x + vector.y * vector.y)));
	}

	static vector3 SmoothDamp(
		vector3 from,
		vector3 to,
		out vector3 currentSpeed,
		double smoothTime,
		double maxSpeed,
		double delta)
	{
		smoothTime = max(0.001, smoothTime);
		double omega = 2.0 / smoothTime;
		double x = omega * delta;
		double exponent = 1.0 / (1.0 + x + (0.48 * x * x) + (0.235 * x * x * x));
		double xDifference = from.x - to.x;
		double yDifference = from.y - to.y;
		double zDifference = from.z - to.z;
		vector3 originalTo = to;

		double maxDifference = maxSpeed * smoothTime;
		double maxDifferenceSquared = maxDifference * maxDifference;
		double squareMagnitude = (xDifference * xDifference) + (yDifference * yDifference) + (zDifference * zDifference);

		if (squareMagnitude > maxDifferenceSquared)
		{
			double magnitude = sqrt(squareMagnitude);
			xDifference = xDifference / magnitude * maxDifference;
			yDifference = yDifference / magnitude * maxDifference;
			zDifference = zDifference / magnitude * maxDifference;
		}

		to.x = from.x - xDifference;
		to.y = from.y - yDifference;
		to.z = from.z - zDifference;
		double xTemp = (currentSpeed.x + (omega * xDifference)) * delta;
		double yTemp = (currentSpeed.y + (omega * yDifference)) * delta;
		double zTemp = (currentSpeed.z + (omega * zDifference)) * delta;
		currentSpeed.x = (currentSpeed.x - (omega * xTemp)) * exponent;
		currentSpeed.y = (currentSpeed.y - (omega * yTemp)) * exponent;
		currentSpeed.z = (currentSpeed.z - (omega * zTemp)) * exponent;

		double xResult = to.x + ((xDifference + xTemp) * exponent);
		double yResult = to.y + ((yDifference + yTemp) * exponent);
		double zResult = to.z + ((zDifference + zTemp) * exponent);

		double bXDifference = originalTo.x - from.x;
		double bYDifference = originalTo.y - from.y;
		double bZDifference = originalTo.z - from.z;
		double bXResult = xResult - originalTo.x;
		double bYResult = yResult - originalTo.y;
		double bZResult = zResult - originalTo.z;

		if ((bXDifference * bXResult) + (bYDifference * bYResult) + (bZDifference * bZResult) > 0.0)
		{
			xResult = originalTo.x;
			yResult = originalTo.y;
			zResult = originalTo.z;
			currentSpeed.x = (xResult - originalTo.x) / delta;
			currentSpeed.y = (yResult - originalTo.y) / delta;
			currentSpeed.z = (zResult - originalTo.z) / delta;
		}

		return (xResult, yResult, zResult);
	}
}

class Geometry
{
	/**
	 * Returns the bounding box of a shape, where the first value is the
	 * bottom-left corner and the second value is the top-right corner.
	**/
	static vector2, vector2 GetBoundingBox(array<BoxedVector2> points)
	{
		if (points.Size() < 2)
		{
			ThrowAbortException("Cannot determine boinding box of less than two points.");
		}

		vector2 min = (points[0].X(), points[0].Y());
		vector2 max = min;

		for (int i = 1; i < points.Size(); ++i)
		{
			vector2 point = points[i].m_Value;
			if (point.x < min.x) min.x = point.x;
			if (point.x > max.x) max.x = point.x;
			if (point.y < min.y) min.y = point.y;
			if (point.y > max.y) max.y = point.y;
		}

		return min, max;
	}

	/**
	 * Returns whether or not the given point is within the bounding box, defined
	 * as bottom-left and top-right corners.
	**/
	static bool IsPointInBounds(vector2 point, vector2 bottomLeft, vector2 topRight)
	{
		return point.x > bottomLeft.x
			&& point.y > bottomLeft.y
			&& point.x < topRight.x
			&& point.y < topRight.y;
	}

	static bool IsBoxInBounds(vector2 bottomLeft, vector2 topRight, vector2 boundsBottomLeft, vector2 boundsTopRight)
	{
		return bottomLeft.x < topRight.x
			&& bottomLeft.y < topRight.y
			&& bottomLeft.x > boundsBottomLeft.x
			&& bottomLeft.y > boundsBottomLeft.y
			&& topRight.x < boundsTopRight.x
			&& topRight.y < boundsTopRight.y;
	}

	static bool IsPointInPolygon(vector2 point, array<Edge> shape)
	{
		array<BoxedVector2> vertices;

		// Deconstruct lines.
		for (int i = 0; i < shape.Size(); ++i)
		{
			vertices.Push(BoxedVector2.Create(shape[i].m_V1));
		}

		vector2 tl, br;
		[tl, br] = GetBoundingBox(vertices);
		if (!IsPointInBounds(point, tl, br)) return false;

		bool inside = false;

		for (int i = 0; i < shape.Size(); ++i)
		{
			Edge line = shape[i];

			if ((line.m_V1.y <= point.y) && (line.m_V2.y > point.y)
				|| (line.m_V2.y <= point.y) && (line.m_V1.y > point.y))
			{
				double intersection =
					(line.m_V2.x - line.m_V1.x) * (point.y - line.m_V1.y) / (line.m_V2.y - line.m_V1.y) + line.m_V1.x;

				if (intersection < point.x)
					inside = !inside;
			}
		}

		return inside;
	}

	/**
	 * Returns whether or not lines A and B intersect.
	 * NOTE:
		* Currently does not detect intersections between collinear segments.
	**/
	static bool LinesIntersect(vector2 aStart, vector2 aEnd, vector2 bStart, vector2 bEnd)
	{
		// Adapted from answer by @Gavin at StackOverflow (https://stackoverflow.com/a/1968345).
		vector2 s1, s2;
		s1.x = aEnd.x - aStart.x;
		s1.y = aEnd.y - aStart.y;
		s2.x = bEnd.x - bStart.x;
		s2.y = bEnd.y - bStart.y;

		double denominator = -s2.x * s1.y + s1.x * s2.y;

		if (denominator == 0.0) return false;

		float s, t;
		s = (-s1.y * (aStart.x - bStart.x) + s1.x * (aStart.y - bStart.y)) / denominator;
		t = (s2.x * (aStart.y - bStart.y) - s2.y * (aStart.x - bStart.x)) / denominator;

		return s > 0 && s < 1 && t > 0 && t < 1;
	}

	/**
	 * Returns the intersection point between lines A and B, or a vector with
	 * coordinates at infinity if no intersection is found.
	 * NOTE:
		* Collinear segments are considered non-intersecting.
	**/
	static vector2 IntersectionOf(vector2 aStart, vector2 aEnd, vector2 bStart, vector2 bEnd)
	{
		// Adapted from answer by @Gavin at StackOverflow (https://stackoverflow.com/a/1968345).
		vector2 s1, s2;
		s1.x = aEnd.x - aStart.x;
		s1.y = aEnd.y - aStart.y;
		s2.x = bEnd.x - bStart.x;
		s2.y = bEnd.y - bStart.y;

		vector2 result = (double.Infinity, double.Infinity);

		double denominator = -s2.x * s1.y + s1.x * s2.y;

		if (denominator == 0.0) return result;

		double s, t;
		s = (-s1.y * (aStart.x - bStart.x) + s1.x * (aStart.y - bStart.y)) / denominator;
		t = (s2.x * (aStart.y - bStart.y) - s2.y * (aStart.x - bStart.x)) / denominator;

		if (s > 0 && s < 1 && t > 0 && t < 1)
		{
			result.x = aStart.x + (t * s1.x);
			result.y = aStart.y + (t * s1.y);
		}

		return result;
	}

	static bool IsClockwise(array<BoxedVector2> vertices)
	{
		if (vertices.Size() < 3)
		{
			ThrowAbortException("Cannot determine winding order of less than three edges.");
		}

		vector2 lowest = vertices[0].m_Value;
		int index = 0;

		// Find lowest vertex.
		for (int i = 1; i < vertices.Size(); i++)
		{
			vector2 point = vertices[i].m_Value;
			if (point.y < lowest.y || (point.y == lowest.y && point.x > lowest.x))
			{
				lowest = point;
				index = i;
			}
		}

		vector3 a = Vec2Util.XY_(vertices[MathI.PosMod(index - 1, vertices.Size())].Sub(lowest));
		vector3 b = Vec2Util.XY_(vertices[(index + 1) % vertices.Size()].Sub(lowest));
		vector3 result = a cross b;
		return result.z < 0.0;
	}

	static double GetTriangleArea(vector2 a, vector2 b, vector2 c)
	{
		return abs((a.x * b.y - a.y * b.x) + (b.x * c.y - b.y * c.x) + (c.x * a.y - c.y * a.x)) * 0.5;
	}

	static double GetPolygonArea(array<BoxedVector2> vertices)
	{
		if (vertices.Size() < 3)
		{
			ThrowAbortException("Cannot determine area of less than three edges.");
		}

		double area = 0.0;

		int count = vertices.Size();
		for (int i = 0; i < vertices.Size(); ++i)
		{
			vector2 m_V1 = vertices[i].m_Value;
			vector2 m_V2 = vertices[(i + 1) % count].m_Value;

			area += m_V1.x * m_V2.y - m_V1.y * m_V2.x;
		}

		return abs(area) * 0.5;
	}

	static void Triangulate(Triangulatable t)
	{
		DTSweepContext ctx = new("DTSweepContext");

		ctx.PrepareTriangulation(t);
		DTSweep.Triangulate(ctx);
	}
}

class BoxedVector2
{
	vector2 m_Value;

	static BoxedVector2 Create(vector2 v)
	{
		BoxedVector2 bV = new("BoxedVector2");
		bV.m_Value = v;

		return bV;
	}

	static BoxedVector2 FromVertex(Vertex v)
	{
		return BoxedVector2.Create(v.p);
	}

	double X() const { return m_Value.x; }
	double Y() const { return m_Value.y; }

	vector2 Add(vector2 v) const { return (m_Value.x + v.x, m_Value.y + v.y); }
	BoxedVector2 AddBoxed(BoxedVector2 bV) const { return BoxedVector2.Create(Add(bV.m_Value)); }

	vector2 Sub(vector2 v) const { return (m_Value.x - v.x, m_Value.y - v.y); }
	BoxedVector2 SubBoxed(BoxedVector2 bV) const { return BoxedVector2.Create(Sub(bV.m_Value)); }

	vector2 Mul(vector2 v) const { return (m_Value.x * v.x, m_Value.y * v.y); }
	BoxedVector2 MulBoxed(BoxedVector2 bV) const { return BoxedVector2.Create(Mul(bV.m_Value)); }

	vector2 Div(vector2 v) { return (m_Value.x / v.x, m_Value.y / v.y); }
	BoxedVector2 DivBoxed(BoxedVector2 bV) const { return BoxedVector2.Create(Div(bV.m_Value)); }

	double Length() const { return m_Value.Length(); }

	vector2 Unit() const { return m_Value.Unit(); }
	BoxedVector2 UnitBoxed() const { return BoxedVector2.Create(m_Value.Unit()); }

	double DotProduct(vector2 other) const { return m_Value dot other; }
	double DotProductBoxed(BoxedVector2 other) const { return m_Value dot other.m_Value; }
}

class Edge
{
	vector2 m_V1;
	vector2 m_V2;

	static Edge Create(vector2 v1, vector2 v2)
	{
		Edge e = new("Edge");
		e.m_V1 = v1;
		e.m_V2 = v2;
		return e;
	}

	static Edge FromLine(Line l)
	{
		return Edge.Create(l.v1.p, l.v2.p);
	}

	static void LinesToEdges(array<Line> lines, out array<Edge> edges)
	{
		for (int i = 0; i < lines.Size(); ++i)
		{
			edges.Push(Edge.FromLine(lines[i]));
		}
	}
}