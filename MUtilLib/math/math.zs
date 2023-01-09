/** Contains several math functions for doubles. **/
class Math
{
	/** Returns 1.0 if the given number is positive, or -1.0 if it is negative. **/
	static double Sign(double num)
	{
		return num >= 0.0 ? 1.0 : -1.0;
	}

	/**
	 * Linearly interpolates between the given start and end values by the given step
	 * value, where a step of 0.5 would yield the midpoint between the start and end
	 * values.
	**/
	static double Lerp(double start, double end, double step)
	{
		return start + (end - start) * step;
	}

	/**
	 * Returns a value that would lie at a position between the given bStart and bEnd values
	 * that corresponds to the position of the given value between the aStart and aEnd values.
	 * For instance, when aStart = 0.0, aEnd = 1.0, bStart = 2.0, and bEnd = 4.0, a value of
	 * 0.5 would yield 3.0.
	**/
	static double Remap(double value, double aStart, double aEnd, double bStart, double bEnd)
	{
		return bStart + (value - aStart) * (bEnd - bStart) / (aEnd - aStart);
	}

	/** Modulo operation that wraps negative remainders back into the positive range. **/
	static double PosMod(double a, double b)
	{
		b = abs(b);

		if (b == 0.0) ThrowAbortException("\"a mod 0\" is undefined.");

		double remainder = a % b;
		return remainder < 0 ? remainder + b : remainder;
	}

	/** Returns a value wrapped to the range described by the given start and end values. **/
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

	/** Returns the given value in radians. **/
	static double DegToRad(double degrees)
	{
		return degrees * (M_PI / 180.0);
	}

	/** Returns the given value in degrees. **/
	static double RadToDeg(double radians)
	{
		return (180.0 / M_PI) * radians;
	}

	/**
	 * Smoothly shifts the given current value to the given target value via a process
	 * resembling a spring-damper function.
	 * 
	 * NOTE:
	 *		Most use cases will want to pass the return value back into the current
	 *		argument every time the method is called.
	 *
	 * Parameters;
	 * - current: the current value.
	 * - target: the value that the current value will move towards.
	 * - currentSpeed: the rate of movement as of the last time the method was called.
	 *		Most use cases will want to use a separate speed variable for every value
	 *		that is to be shifted.
	 * - smoothTime: the approximate time it should take for the current value to reach
	 *		the target value.
	 * - maxSpeed: the maximum speed at which the current value will move.
	 * - delta: the time difference between the given current value and the resulting
	 *		current value.
	**/
	static double SmoothDamp(
		double current,
		double target,
		out double currentSpeed,
		double smoothTime,
		double maxSpeed,
		double delta)
	{
		if (delta == 0.0) return current; // Avoid division by zero.

		if (smoothTime == 0.0) // Instant.
		{
			currentSpeed = target - current;
			return target;
		}
		
		smoothTime = max(0.000001, smoothTime);
		double omega = 2.0 / smoothTime;
		double x = omega * delta;
		double exponent = 1 / (1 + x + (0.48 * x * x) + (0.235 * x * x * x));
		double difference = current - target;
		double originalTo = target;

		double maxDifference = maxSpeed * smoothTime;
		difference = clamp(difference, -maxDifference, maxDifference);
		target = current - difference;
		double temp = (currentSpeed + (omega * difference)) * delta;
		currentSpeed = (currentSpeed - (omega * temp)) * exponent;
		double result = target + ((difference + temp) * exponent);

		if (originalTo - current > 0.0 == result > originalTo)
		{
			result = originalTo;
			currentSpeed = (result - originalTo) / delta;
		}

		return result;
	}
}

/** Contains several math functions for floats. **/
class MathF
{
	/** Returns 1.0 if the given number is positive, or -1.0 if it is negative. **/
	static float Sign(float num)
	{
		return num >= 0.0 ? 1.0 : -1.0;
	}

	/**
	 * Linearly interpolates between the given start and end values by the given step
	 * value, where a step of 0.5 would yield the midpoint between the start and end
	 * values.
	**/
	static float Lerp(float start, float end, float step)
	{
		return start + (end - start) * step;
	}

	/**
	 * Returns a value that would lie at a position between the given bStart and bEnd values
	 * that corresponds to the position of the given value between the aStart and aEnd values.
	 * For instance, when aStart = 0.0, aEnd = 1.0, bStart = 2.0, and bEnd = 4.0, a value of
	 * 0.5 would yield 3.0.
	**/
	static float Remap(float value, float aStart, float aEnd, float bStart, float bEnd)
	{
		return bStart + (value - aStart) * (bEnd - bStart) / (aEnd - aStart);
	}

	/** Modulo operation that wraps negative remainders back into the positive range. **/
	static float PosMod(float a, float b)
	{
		b = abs(b);

		if (b == 0.0) ThrowAbortException("\"a mod 0\" is undefined.");

		float remainder = a % b;
		return remainder < 0.0 ? remainder + b : remainder;
	}

	/** Returns a value wrapped to the range described by the given start and end values. **/
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

	/** Returns the given value in radians. **/
	static float DegToRad(float degrees)
	{
		return degrees * (M_PI / 180.0);
	}

	/** Returns the given value in degrees. **/
	static float RadToDeg(float radians)
	{
		return (180.0 / M_PI) * radians;
	}

	/**
	 * Smoothly shifts the given current value to the given target value via a process
	 * resembling a spring-damper function.
	 * 
	 * NOTE:
	 *		Most use cases will want to pass the return value back into the current
	 *		argument every time the method is called.
	 *
	 * Parameters;
	 * - current: the current value.
	 * - target: the value that the current value will move towards.
	 * - currentSpeed: the rate of movement as of the last time the method was called.
	 *		Most use cases will want to use a separate speed variable for every value
	 *		that is to be shifted.
	 * - smoothTime: the approximate time it should take for the current value to reach
	 *		the target value.
	 * - maxSpeed: the maximum speed at which the current value will move.
	 * - delta: the time difference between the given current value and the resulting
	 *		current value.
	**/
	static float SmoothDamp(
		float current,
		float target,
		out float currentSpeed,
		float smoothTime,
		float maxSpeed,
		float delta)
	{
		if (delta == 0.0) return current; // Avoid division by zero.

		if (smoothTime == 0.0) // Instant.
		{
			currentSpeed = target - current;
			return target;
		}
	
		float omega = 2.0 / smoothTime;
		float x = omega * delta;
		float exponent = 1 / (1 + x + (0.48 * x * x) + (0.235 * x * x * x));
		float difference = current - target;
		float originalTo = target;

		float maxDifference = maxSpeed * smoothTime;
		difference = clamp(difference, -maxDifference, maxDifference);
		target = current - difference;
		float temp = (currentSpeed + (omega * difference)) * delta;
		currentSpeed = (currentSpeed - (omega * temp)) * exponent;
		float result = target + ((difference + temp) * exponent);

		if (originalTo - current > 0.0 == result > originalTo)
		{
			result = originalTo;
			currentSpeed = (result - originalTo) / delta;
		}

		return result;
	}
}

/** Contains several math functions for integers. **/
class MathI
{
	/** Returns 1 if the given number is positive, or -1 if it is negative. **/
	static int Sign(int num)
	{
		return num >= 0 ? 1 : -1;
	}

	/**
	 * Linearly interpolates between the given start and end values by the given step
	 * value, where a step of 0.5 would yield the midpoint between the start and end
	 * values.
	**/
	static int Lerp(int start, int end, double step)
	{
		return start + (end - start) * step;
	}

	/**
	 * Returns a value that would lie at a position between the given bStart and bEnd values
	 * that corresponds to the position of the given value between the aStart and aEnd values.
	 * For instance, when aStart = 0, aEnd = 2, bStart = 2, and bEnd = 4, a value of
	 * 1 would yield 3.
	**/
	static int Remap(int value, int aStart, int aEnd, int bStart, int bEnd)
	{
		return bStart + (value - aStart) * (bEnd - bStart) / (aEnd - aStart);
	}

	/** Modulo operation that wraps negative remainders back into the positive range. **/
	static int PosMod(int a, int b)
	{
		b = abs(b);

		if (b == 0) ThrowAbortException("\"a mod 0\" is undefined.");

		int remainder = a % b;
		return remainder < 0 ? remainder + b : remainder;
	}

	/** Returns a value wrapped to the range described by the given start and end values. **/
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

/** Contains several math functions for two-component vectors. **/
class MathVec2
{
	/** Clamps the given vector's magnitude between the given minimum and maximum values. **/
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

	/** Returns the distance between the given vectors. **/
	static double DistanceBetween(vector2 a, vector2 b)
	{
		return sqrt((b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y));
	}

	/** Returns the squared distance between the given vectors. **/
	static double SquareDistanceBetween(vector2 a, vector2 b)
	{
		return (b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y);
	}

	/** Returns a vector rotated by the degrees in the given angle. **/
	static vector2 Rotate(vector2 vector, double angle)
	{
		return Actor.RotateVector(vector, angle);
		// return (vector.x * cos(angle) - vector.y * sin(angle), vector.x * sin(angle) + vector.y * cos(angle));
	}

	/** Returns a vector rotated around the given pivot by the degrees in the given angle. **/
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

	/**
	 * Smoothly shifts the given current value to the given target value via a process
	 * resembling a spring-damper function.
	 * 
	 * NOTE:
	 *		Most use cases will want to pass the return value back into the current
	 *		argument every time the method is called.
	 *
	 * Parameters;
	 * - current: the current value.
	 * - target: the value that the current value will move towards.
	 * - currentSpeed: the rate of movement as of the last time the method was called.
	 *		Most use cases will want to use a separate speed variable for every value
	 *		that is to be shifted.
	 * - smoothTime: the approximate time it should take for the current value to reach
	 *		the target value.
	 * - maxSpeed: the maximum speed at which the current value will move.
	 * - delta: the time difference between the given current value and the resulting
	 *		current value.
	**/
	static vector2 SmoothDamp(
		vector2 current,
		vector2 target,
		out vector2 currentSpeed,
		double smoothTime,
		double maxSpeed,
		double delta)
	{
		if (delta == 0.0) return current; // Avoid division by zero.

		if (smoothTime == 0.0) // Instant.
		{
			currentSpeed = target - current;
			return target;
		}

		double omega = 2.0 / smoothTime;
		double x = omega * delta;
		double exponent = 1.0 / (1.0 + x + (0.48 * x * x) + (0.235 * x * x * x));
		double xDifference = current.x - target.x;
		double yDifference = current.y - target.y;
		vector2 originalTo = target;

		double maxDifference = maxSpeed * smoothTime;
		double maxDifferenceSquared = maxDifference * maxDifference;

		double squareMagnitude = (xDifference * xDifference) + (yDifference * yDifference);

		if (squareMagnitude > maxDifferenceSquared)
		{
			double magnitude = sqrt(squareMagnitude);
			xDifference = xDifference / magnitude * maxDifference;
			yDifference = yDifference / magnitude * maxDifference;
		}

		target.x = current.x - xDifference;
		target.y = current.y - yDifference;

		double xTemp = (currentSpeed.x + (omega * xDifference)) * delta;
		double yTemp = (currentSpeed.y + (omega * yDifference)) * delta;
		currentSpeed.x = (currentSpeed.x - (omega * xTemp)) * exponent;
		currentSpeed.y = (currentSpeed.y - (omega * yTemp)) * exponent;

		double xResult = target.x + ((xDifference + xTemp) * exponent);
		double yResult = target.y + ((yDifference + yTemp) * exponent);

		double bXDifference = originalTo.x - current.x;
		double bYDifference = originalTo.y - current.y;
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

/** Contains several math functions for three-component vectors. **/
class MathVec3
{
	/** Clamps the given vector's magnitude between the given minimum and maximum values. **/
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

	/** Returns the distance between the given vectors. **/
	static double DistanceBetween(vector3 a, vector3 b)
	{
		return sqrt((b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y) + (b.z - a.z) * (b.z - a.z));
	}

	/** Returns the squared distance between the given vectors. **/
	static double SquareDistanceBetween(vector3 a, vector3 b)
	{
		return (b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y) + (b.z - a.z) * (b.z - a.z);
	}

	/** Returns a vector rotated by the degrees in the given angle along the given axis. **/
	static vector3 Rotate(vector3 vector, vector3 axis, double angle)
	{
		vector3 a = axis cross vector;
		vector3 b = axis cross a;
		return vector + sin(angle) * a + (1 - cos(angle)) * b;
	}

	/** Returns a vector rotated around the given pivot by the degrees in the given angle along the given axis. **/
	static vector3 RotateAround(vector3 vector, vector3 pivot, vector3 axis, double angle)
	{
		return pivot + Rotate(vector - pivot, axis, angle);
	}

	/**
	 * Returns the yaw and pitch angles corresponding to the given direction vector.
	 *
	 * NOTE: Z-axis-aligned vectors will yield a yaw of zero.
	**/
	static vector2 ToYawAndPitch(vector3 vector)
	{
		vector = vector.Unit();

		if (vector.xy == (0.0, 0.0)) return (0.0, 180.0 * vector.z);

		return (atan2(vector.y, vector.x), atan(vector.z / sqrt(vector.x * vector.x + vector.y * vector.y)));
	}

	/**
	 * Smoothly shifts the given current value to the given target value via a process
	 * resembling a spring-damper function.
	 * 
	 * NOTE:
	 *		Most use cases will want to pass the return value back into the current
	 *		argument every time the method is called.
	 *
	 * Parameters;
	 * - current: the current value.
	 * - target: the value that the current value will move towards.
	 * - currentSpeed: the rate of movement as of the last time the method was called.
	 *		Most use cases will want to use a separate speed variable for every value
	 *		that is to be shifted.
	 * - smoothTime: the approximate time it should take for the current value to reach
	 *		the target value.
	 * - maxSpeed: the maximum speed at which the current value will move.
	 * - delta: the time difference between the given current value and the resulting
	 *		current value.
	**/
	static vector3 SmoothDamp(
		vector3 current,
		vector3 target,
		out vector3 currentSpeed,
		double smoothTime,
		double maxSpeed,
		double delta)
	{
		if (delta == 0.0) return current; // Avoid division by zero.

		if (smoothTime == 0.0) // Instant.
		{
			currentSpeed = target - current;
			return target;
		}

		double omega = 2.0 / smoothTime;
		double x = omega * delta;
		double exponent = 1.0 / (1.0 + x + (0.48 * x * x) + (0.235 * x * x * x));
		double xDifference = current.x - target.x;
		double yDifference = current.y - target.y;
		double zDifference = current.z - target.z;
		vector3 originalTo = target;

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

		target.x = current.x - xDifference;
		target.y = current.y - yDifference;
		target.z = current.z - zDifference;
		double xTemp = (currentSpeed.x + (omega * xDifference)) * delta;
		double yTemp = (currentSpeed.y + (omega * yDifference)) * delta;
		double zTemp = (currentSpeed.z + (omega * zDifference)) * delta;
		currentSpeed.x = (currentSpeed.x - (omega * xTemp)) * exponent;
		currentSpeed.y = (currentSpeed.y - (omega * yTemp)) * exponent;
		currentSpeed.z = (currentSpeed.z - (omega * zTemp)) * exponent;

		double xResult = target.x + ((xDifference + xTemp) * exponent);
		double yResult = target.y + ((yDifference + yTemp) * exponent);
		double zResult = target.z + ((zDifference + zTemp) * exponent);

		double bXDifference = originalTo.x - current.x;
		double bYDifference = originalTo.y - current.y;
		double bZDifference = originalTo.z - current.z;
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

/** Contains several geometry-related utilities. **/
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
	 * Returns whether or not the given point is within the given bounding box, defined
	 * as bottom-left and top-right corners.
	**/
	static bool IsPointInBounds(vector2 point, vector2 bottomLeft, vector2 topRight)
	{
		return point.x > bottomLeft.x
			&& point.y > bottomLeft.y
			&& point.x < topRight.x
			&& point.y < topRight.y;
	}

	/**
	 * Returns whether or not the given rectangle is within the given bounding box, where
	 * both are defined as bottom-left and top-right corners.
	**/
	static bool IsBoxInBounds(vector2 bottomLeft, vector2 topRight, vector2 boundsBottomLeft, vector2 boundsTopRight)
	{
		return bottomLeft.x < topRight.x
			&& bottomLeft.y < topRight.y
			&& bottomLeft.x > boundsBottomLeft.x
			&& bottomLeft.y > boundsBottomLeft.y
			&& topRight.x < boundsTopRight.x
			&& topRight.y < boundsTopRight.y;
	}

	/**
	 * Returns whether or not the given point is within the given shape, where the shape
	 * is given as an array of edges (lines).
	 *
	 * NOTE:
	 *		The edges must form a simple polygon, or in other words, a closed shape with
	 *		no intersecting edges.
	**/
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
	 * Returns whether or not the line defined by the given aStart and aEnd points
	 * intersects with the line defined by the given bStart and bEnd points.
	 *
	 * NOTE:
	 * 		Currently does not detect intersections between collinear segments.
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
	 * Returns the intersection point between the line defined by the given aStart and aEnd points
	 * and the line defined by the given bStart and bEnd points, or a vector with coordinates at
	 * infinity if no intersection is found.
	 *
	 * NOTE:
	 *		Collinear segments are considered non-intersecting.
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

	/** Returns whether or not the given vertices are arranged in clockwise order. **/
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

	/** Returns the area of the given triangle. **/
	static double GetTriangleArea(vector2 a, vector2 b, vector2 c)
	{
		return abs((a.x * b.y - a.y * b.x) + (b.x * c.y - b.y * c.x) + (c.x * a.y - c.y * a.x)) * 0.5;
	}

	/** Returns the area of the given polygon. **/
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

	/** Performs a triangulation on the given triangulatable data set. **/
	static void Triangulate(Triangulatable t)
	{
		DTSweepContext ctx = new("DTSweepContext");

		ctx.PrepareTriangulation(t);
		DTSweep.Triangulate(ctx);
	}
}

/** Workaround for lack of verctor array support. **/
class BoxedVector2
{
	vector2 m_Value;

	static BoxedVector2 Create(vector2 v)
	{
		BoxedVector2 bV = new("BoxedVector2");
		bV.m_Value = v;

		return bV;
	}

	static BoxedVector2 currentVertex(Vertex v)
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

/**
 * Constitutes a line formed by two points. Alternative to the internal Line type
 * without the level data-related fields and methods.
**/
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