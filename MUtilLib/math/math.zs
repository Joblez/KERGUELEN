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
	 * Returns the given value modified by the easing function specified in
	 * the easeFunction parameter.
	**/
	static double Ease(double value, EEasingFunction easeFunction)
	{
		switch (easeFunction)
		{
			case EASE_IN_SINE: return 1.0 - cos(value * Math.RadToDeg(M_PI_2));
			case EASE_OUT_SINE: return sin(value * Math.RadToDeg(M_PI_2));
			case EASE_INOUT_SINE: return -(cos(M_PI * value) - 1.0) * 0.5;

			case EASE_IN_QUAD: return value ** 2;
			case EASE_OUT_QUAD: return 1.0 - (1.0 - value) ** 2.0;
			case EASE_INOUT_QUAD: return value < 0.5 ? 2.0 * value ** 2.0 : 1.0 - ((-2.0 * value + 2.0) ** 2.0) * 0.5;

			case EASE_IN_CUBIC: return value ** 3;
			case EASE_OUT_CUBIC: return 1.0 - (1.0 - value) ** 3.0;
			case EASE_INOUT_CUBIC: return value < 0.5 ? 4.0 * value ** 3.0 : 1.0 - ((-2.0 * value + 2.0) ** 3.0) * 0.5;

			case EASE_IN_QUART: return value ** 4;
			case EASE_OUT_QUART: return 1.0 - (1.0 - value) ** 4.0;
			case EASE_INOUT_QUART: return value < 0.5 ? 8.0 * value ** 4.0 : 1.0 - ((-2.0 * value + 2.0) ** 4.0) * 0.5;

			case EASE_IN_QUINT: return value ** 5;
			case EASE_OUT_QUINT: return 1.0 - (1.0 - value) ** 5.0;
			case EASE_INOUT_QUINT: return value < 0.5 ? 16.0 * value ** 5.0 : 1.0 - ((-2.0 * value + 2.0) ** 5.0) * 0.5;

			case EASE_IN_EXPO: return value == 0.0 ? 0.0 : 2.0 ** (10.0 * value - 10.0);
			case EASE_OUT_EXPO: return value == 1.0 ? 1.0 : 1.0 - 2.0 ** (-10.0 * value);
			case EASE_INOUT_EXPO:
				if (value == 0.0) return 0.0;
				if (value == 1.0) return 1.0;
				return value < 0.5 ? (2.0 ** (20.0 * value - 10.0)) * 0.5 : (2.0 - (2.0 ** (-20.0 * value + 10.0))) * 0.5;
			
			case EASE_IN_CIRC: return 1.0 - sqrt(1.0 - value ** 2.0);
			case EASE_OUT_CIRC: return sqrt(1.0 - (value - 1.0) ** 2.0);
			case EASE_INOUT_CIRC:
				return value < 0.5
					? (1.0 -sqrt(1.0 - (2.0 * value) ** 2.0)) * 0.5
					: ((sqrt(1.0 - (-2.0 * value + 2.0) ** 2.0)) + 1.0) * 0.5;

			case EASE_IN_BACK: return 2.70158 * value ** 3.0 - 1.70158 * value ** 2.0;
			case EASE_OUT_BACK: return 1.0 + 2.70158 * ((value - 1.0) ** 3.0) + 1.70158 * ((value - 1.0) ** 2.0);
			case EASE_INOUT_BACK:
				double a = 1.70158 * 1.525;
				return value < 0.5
					? ((2.0 * value) ** 2.0) * ((a + 1.0) * 2.0 * value - a) * 0.5
					: (((2.0 * value - 2.0) ** 2.0) * ((a + 1.0) * (value * 2.0 - 2.0) + a) + 2.0) * 0.5;

			case EASE_IN_ELASTIC:
				if (value == 0.0) return 0.0;
				if (value == 1.0) return 1.0;
				return -(2.0 ** (10.0 * value - 10.0)) * sin((value * 10.0 - 10.75) * ((2.0 * M_PI) / 3.0));
			case EASE_OUT_ELASTIC:
				if (value == 0.0) return 0.0;
				if (value == 1.0) return 1.0;
				return (2.0 ** (-10.0 * value)) * sin((value * 10.0 - 0.75) * ((2.0 * M_PI) / 3.0)) + 1.0;
			case EASE_INOUT_ELASTIC:
				if (value == 0.0) return 0.0;
				if (value == 1.0) return 1.0;
				return value < 0.5
					? -((2.0 ** (20.0 * value - 10.0)) * sin((20.0 * value - 11.125) * ((2.0 * M_PI) / 4.5))) * 0.5
					: ((2.0 ** (-20.0 * value + 10.0)) * sin((20.0 * value - 11.125) * ((2.0 * M_PI) / 4.5))) * 0.5 + 1.0;
			
			case EASE_IN_BOUNCE: return 1.0 - Ease(1.0 - value, EASE_OUT_BOUNCE);
			case EASE_OUT_BOUNCE:
				if (value < 1.0 / 2.75) return 7.5625 * value ** 2.0;
				if (value < 2.0 / 2.75) return 7.5625 * ((value - 1.5 / 2.75) ** 2.0) + 0.75;
				if (value < 2.5 / 2.75) return 7.5625 * ((value - 2.25 / 2.75) ** 2.0) + 0.9375;
				return 7.5625 * ((value - 2.625 / 2.75) ** 2.0) + 0.984375;
			case EASE_INOUT_BOUNCE:
				return value < 0.5
					? (1.0 - Ease(1.0 - 2.0 * value, EASE_OUT_BOUNCE)) * 0.5
					: (1.0 + Ease(2.0 * value - 1.0, EASE_OUT_BOUNCE)) * 0.5;
			
			case LINEAR:
			default: return value;
		}
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
	 * Returns the given value modified by the easing function specified in
	 * the easeFunction parameter.
	**/
	static float Ease(float value, EEasingFunction easeFunction)
	{
		switch (easeFunction)
		{
			case EASE_IN_SINE: return 1.0 - cos(value * MathF.RadToDeg(M_PI_2));
			case EASE_OUT_SINE: return sin(value * MathF.RadToDeg(M_PI_2));
			case EASE_INOUT_SINE: return -(cos(M_PI * value) - 1.0) * 0.5;

			case EASE_IN_QUAD: return value ** 2;
			case EASE_OUT_QUAD: return 1.0 - (1.0 - value) ** 2.0;
			case EASE_INOUT_QUAD: return value < 0.5 ? 2.0 * value ** 2.0 : 1.0 - ((-2.0 * value + 2.0) ** 2.0) * 0.5;

			case EASE_IN_CUBIC: return value ** 3;
			case EASE_OUT_CUBIC: return 1.0 - (1.0 - value) ** 3.0;
			case EASE_INOUT_CUBIC: return value < 0.5 ? 4.0 * value ** 3.0 : 1.0 - ((-2.0 * value + 2.0) ** 3.0) * 0.5;

			case EASE_IN_QUART: return value ** 4;
			case EASE_OUT_QUART: return 1.0 - (1.0 - value) ** 4.0;
			case EASE_INOUT_QUART: return value < 0.5 ? 8.0 * value ** 4.0 : 1.0 - ((-2.0 * value + 2.0) ** 4.0) * 0.5;

			case EASE_IN_QUINT: return value ** 5;
			case EASE_OUT_QUINT: return 1.0 - (1.0 - value) ** 5.0;
			case EASE_INOUT_QUINT: return value < 0.5 ? 16.0 * value ** 5.0 : 1.0 - ((-2.0 * value + 2.0) ** 5.0) * 0.5;

			case EASE_IN_EXPO: return value == 0.0 ? 0.0 : 2.0 ** (10.0 * value - 10.0);
			case EASE_OUT_EXPO: return value == 1.0 ? 1.0 : 1.0 - 2.0 ** (-10.0 * value);
			case EASE_INOUT_EXPO:
				if (value == 0.0) return 0.0;
				if (value == 1.0) return 1.0;
				return value < 0.5 ? (2.0 ** (20.0 * value - 10.0)) * 0.5 : (2.0 - (2.0 ** (-20.0 * value + 10.0))) * 0.5;
			
			case EASE_IN_CIRC: return 1.0 - sqrt(1.0 - value ** 2.0);
			case EASE_OUT_CIRC: return sqrt(1.0 - (value - 1.0) ** 2.0);
			case EASE_INOUT_CIRC:
				return value < 0.5
					? (1.0 -sqrt(1.0 - (2.0 * value) ** 2.0)) * 0.5
					: ((sqrt(1.0 - (-2.0 * value + 2.0) ** 2.0)) + 1.0) * 0.5;

			case EASE_IN_BACK: return 2.70158 * value ** 3.0 - 1.70158 * value ** 2.0;
			case EASE_OUT_BACK: return 1.0 + 2.70158 * ((value - 1.0) ** 3.0) + 1.70158 * ((value - 1.0) ** 2.0);
			case EASE_INOUT_BACK:
				double a = 1.70158 * 1.525;
				return value < 0.5
					? ((2.0 * value) ** 2.0) * ((a + 1.0) * 2.0 * value - a) * 0.5
					: (((2.0 * value - 2.0) ** 2.0) * ((a + 1.0) * (value * 2.0 - 2.0) + a) + 2.0) * 0.5;

			case EASE_IN_ELASTIC:
				if (value == 0.0) return 0.0;
				if (value == 1.0) return 1.0;
				return -(2.0 ** (10.0 * value - 10.0)) * sin((value * 10.0 - 10.75) * ((2.0 * M_PI) / 3.0));
			case EASE_OUT_ELASTIC:
				if (value == 0.0) return 0.0;
				if (value == 1.0) return 1.0;
				return (2.0 ** (-10.0 * value)) * sin((value * 10.0 - 0.75) * ((2.0 * M_PI) / 3.0)) + 1.0;
			case EASE_INOUT_ELASTIC:
				if (value == 0.0) return 0.0;
				if (value == 1.0) return 1.0;
				return value < 0.5
					? -((2.0 ** (20.0 * value - 10.0)) * sin((20.0 * value - 11.125) * ((2.0 * M_PI) / 4.5))) * 0.5
					: ((2.0 ** (-20.0 * value + 10.0)) * sin((20.0 * value - 11.125) * ((2.0 * M_PI) / 4.5))) * 0.5 + 1.0;
			
			case EASE_IN_BOUNCE: return 1.0 - Ease(1.0 - value, EASE_OUT_BOUNCE);
			case EASE_OUT_BOUNCE:
				if (value < 1.0 / 2.75) return 7.5625 * value ** 2.0;
				if (value < 2.0 / 2.75) return 7.5625 * ((value - 1.5 / 2.75) ** 2.0) + 0.75;
				if (value < 2.5 / 2.75) return 7.5625 * ((value - 2.25 / 2.75) ** 2.0) + 0.9375;
				return 7.5625 * ((value - 2.625 / 2.75) ** 2.0) + 0.984375;
			case EASE_INOUT_BOUNCE:
				return value < 0.5
					? (1.0 - Ease(1.0 - 2.0 * value, EASE_OUT_BOUNCE)) * 0.5
					: (1.0 + Ease(2.0 * value - 1.0, EASE_OUT_BOUNCE)) * 0.5;
			
			default: return value;
		}
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

	
	/**
	 * Linearly interpolates between the given start and end values by the given step
	 * value, where a step of 0.5 would yield the midpoint between the start and end
	 * values.
	**/
	static vector2 Lerp(vector2 start, vector2 end, double step)
	{
		return (Math.Lerp(start.x, end.x, step), Math.Lerp(start.y, end.y, step));
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

	/** Returns the given polar (radius, angle) coordinates as Cartesian (x, y) coordinates. **/
	static vector2 CartesianToPolar(vector2 coords)
	{
		return (sqrt(coords.x * coords.x + coords.y * coords.y), atan(coords.y / coords.x));
	}

	/** Returns the given Cartesian (x, y) coordinates as polar (radius, angle) coordinates. **/
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

	/**
	 * Linearly interpolates between the given start and end values by the given step
	 * value, where a step of 0.5 would yield the midpoint between the start and end
	 * values.
	**/
	static vector3 Lerp(vector3 start, vector3 end, double step)
	{
		return (Math.Lerp(start.x, end.x, step), Math.Lerp(start.y, end.y, step), Math.Lerp(start.z, end.z, step));
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
	deprecated("4.9.0", "Use Level.SphericalCoords() instead")
	static vector2 ToYawAndPitch(vector3 vector)
	{
		return Vec3Util.YX(LevelLocals.SphericalCoords(Vec3Util.Zero(), vector.Unit(), absolute: true).xy);
	}

	/**
	 * Returns the Cartesian coordinates corresponding to spherical coordinates given as
	 * (yaw, pitch, radius).
	**/
	static vector3 SphericalToCartesian(vector3 coords)
	{
		return (coords.z * sin(coords.y) * cos(coords.x), coords.z * sin(coords.) * sin(coords.x), coords.z * cos(coords.y));
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
	const EPSILON = 0.0001;
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
	 * Returns whether or not the given point is on the line segment defined by the given
	 * start and end points.
	**/
	static bool IsPointOnLine(vector2 point, vector2 start, vector2 end)
	{
		if (point ~== start || point ~== end) return true;

		vector2 ab = end - start;
		vector2 ac = point - start;
		
		if (!((ab, 0.0) cross (ac, 0.0) ~== Vec3Util.Zero())) return false;

		double dbc = ab dot ac;
		double dbb = ab dot ab;

		return (0.0 < dbc && dbc < dbb);
	}

	/**
	 * Returns whether or not the given point is within the given shape, where the shape
	 * is given as an array of edges (lines).
	 *
	 * NOTE:
	 *		The edges must form a simple polygon, or in other words, a closed shape with
	 *		no intersecting edges.
	**/
	static bool IsPointInPolygon(vector2 point, array<Edge> shape, bool pointOnEdgeIsInside = true)
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

			if (pointOnEdgeIsInside && IsPointOnLine(point, line.m_V1, line.m_V2)) return true;

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
	**/
	static bool LinesIntersect(vector2 aStart, vector2 aEnd, vector2 bStart, vector2 bEnd)
	{
		// Adapted from answer by @Gareth Rees at StackOverflow (https://stackoverflow.com/a/565282).
		vector2 mp = (bStart.x - aStart.x, bStart.y - aStart.y);
		vector2 r = (aEnd.x - aStart.x, aEnd.y - aStart.y);
		vector2 s = (bEnd.x - bStart.x, bEnd.y - bStart.y);
 
		double mpxr = mp.x * r.y - mp.y * r.x;
		double mpxs = mp.x * s.y - mp.y * s.x;
		double rxs = r.x * s.y - r.y * s.x;
 
		if (mpxr == 0.0)
		{
			return ((bStart.x - aStart.x < 0.0) != (bStart.x - aEnd.x < 0.0))
				|| ((bStart.y - aStart.y < 0.0) != (bStart.y - aEnd.y < 0.0));
		}
 
		if (rxs == 0.0) return false;
 
		double rxsr = 1.0 / rxs;
		double t = mpxs * rxsr;
		double u = mpxr * rxsr;

		return (t >= 0.0) && (t <= 1.0) && (u >= 0.0) && (u <= 1.0);
	}

	/**
	 * Returns the distance between the given point and the line defined by the given p1
	 * and p2 points.
	**/
	static double DistanceToLine(vector2 point, vector2 p1, vector2 p2)
	{
		double lengthSquared = MathVec2.SquareDistanceBetween(p1, p2);
		if (lengthSquared == 0.0) return MathVec2.DistanceBetween(point, p1);

		double delta = clamp((point - p1) dot (p2 - p1) / lengthSquared, 0.0, 1.0);
		vector2 projection = p1 + delta * (p2 - p1);

		return MathVec2.DistanceBetween(point, projection);
	}

	/**
	 * Returns the intersection point between the line defined by the given aStart and
	 * aEnd points and the line defined by the given bStart and bEnd points, or a vector
	 * with coordinates at infinity if no intersection is found.
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

enum EEasingFunction
{
	LINEAR,
	EASE_IN_SINE,		EASE_OUT_SINE,		EASE_INOUT_SINE,
	EASE_IN_QUAD,		EASE_OUT_QUAD,		EASE_INOUT_QUAD,
	EASE_IN_CUBIC,		EASE_OUT_CUBIC,		EASE_INOUT_CUBIC,
	EASE_IN_QUART,		EASE_OUT_QUART,		EASE_INOUT_QUART,
	EASE_IN_QUINT,		EASE_OUT_QUINT,		EASE_INOUT_QUINT,
	EASE_IN_EXPO,		EASE_OUT_EXPO,		EASE_INOUT_EXPO,
	EASE_IN_CIRC,		EASE_OUT_CIRC,		EASE_INOUT_CIRC,
	EASE_IN_BACK,		EASE_OUT_BACK,		EASE_INOUT_BACK,
	EASE_IN_ELASTIC,	EASE_OUT_ELASTIC,	EASE_INOUT_ELASTIC,
	EASE_IN_BOUNCE,		EASE_OUT_BOUNCE,	EASE_INOUT_BOUNCE,
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

	bool Equals(Edge other, bool matchDirection = true) const
	{
		if (matchDirection) return (m_V1 ~== other.m_V1 && m_V2 ~== other.m_V2);

		return (m_V1 ~== other.m_V1 && m_V2 ~== other.m_V2) || (m_V2 ~== other.m_V1 && m_V1 ~== other.m_V2);
	}

	bool MatchesLine(Line l, bool matchDirection = false) const
	{
		if (matchDirection) return (l.v1.p ~== m_V1 && l.v2.p ~== m_V2);

		return (l.v1.p ~== m_V1 && l.v2.p ~== m_V2) || (l.v2.p ~== m_V1 && l.v1.p ~== m_V2);
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