// TODO: [Long-term] Learn way more math.

struct Math
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

struct MathF
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

struct MathVec2
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

	static vector2 Rotate(vector2 vector, double angle)
	{
		return (vector.x * cos(angle) - vector.y * sin(angle), vector.x * sin(angle) + vector.y * cos(angle));
	}

	static vector2 RotateAround(vector2 vector, vector2 pivot, double angle)
	{
		return pivot + Rotate(vector - pivot, angle);
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

struct MathVec3
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
		vector2 result;
		result.x = 1 / (vector.x / -(vector.y == 0.0 ? double.Epsilon : vector.y));
		result.y = 1 / (sqrt((vector.x * vector.x) + (vector.y * vector.y)) / (vector.z == 0.0 ? double.Epsilon : vector.z));
		return result;
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