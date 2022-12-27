/**
 * Contains convenience methods for getting string representations of several types
**/
class ToStr
{
	/** Returns a string representing the value of the given boolean. **/
	static string Bool(bool value) { return value ? "true" : "false"; }

	/**
	 * Returns a string representing the value of the given integer.
	 * Effectively shorthand for string.Format("%i", value).
	**/
	static string Int(int value) { return string.Format("%i", value); }

	/**
	 * Returns a string representing the value of the given unsigned integer.
	 * Effectively shorthand for string.Format("%u", value).
	**/
	static string Uint(int value) { return string.Format("%u", value); }

	/** Returns a string representing the color values of the given color, formatted as RGBA. **/
	static string Color(color value) { return string.Format("R: %u, G: %u, B: %u, A: %u", value.r, value.g, value.b, value.a); }

	// Yuck...

	/**
	 * Returns a string representing the value of the given float.
	 *
	 * Parameters:
	 * - value: The value to represent as a string.
	 * - precision: The amount of decimal spaces to truncate the number to.
	**/
	static string Float(float value, int precision = 6) { return string.Format("."..Int(precision).."f", value); }

	/**
	 * Returns a string representing the value of the given double.
	 *
	 * Parameters:
	 * - value: The value to represent as a string.
	 * - precision: The amount of decimal spaces to truncate the number to.
	**/
	static string Double(double value, int precision = 6) { return string.Format("."..Int(precision).."f", value); }

	/**
	 * Returns a string representing the value of the given two-component vector, in XY order.
	 *
	 * Parameters:
	 * - value: The value to represent as a string.
	 * - precision: The amount of decimal spaces to truncate the number to.
	 * - padding: The amount of leading spaces to place behind each number.
	**/
	static string Vec2(vector2 value, int precision = 6, int padding = 0)
	{
		return string.Format(
			"[%"..Int(padding).."."..Int(precision).."f, %"
				..Int(padding).."."..Int(precision).."f]",
			value.x, value.y);
	}

	/**
	 * Returns a string representing the value of the given three-component vector, in XYZ order.
	 *
	 * Parameters:
	 * - value: The value to represent as a string.
	 * - precision: The amount of decimal spaces to truncate the number to.
	 * - padding: The amount of leading spaces to place behind each number.
	**/
	static string Vec3(vector3 value, int precision = 6, int padding = 0)
	{
		return string.Format(
			"[%"..Int(padding).."."..Int(precision).."f, %"
				..Int(padding).."."..Int(precision).."f, %"
				..Int(padding).."."..Int(precision).."f]",
			value.x, value.y, value.z);
	}

	/**
	 * Returns a string representing the value of the given four-component vector, in XYZW order.
	 *
	 * Parameters:
	 * - value: The value to represent as a string.
	 * - precision: The amount of decimal spaces to truncate the number to.
	 * - padding: The amount of leading spaces to place behind each number.
	**/
	static string Vec4(vector4 value, int precision = 6, int padding = 0)
	{
		return string.Format(
			"[%"..Int(padding).."."..Int(precision).."f, %"
				..Int(padding).."."..Int(precision).."f, %"
				..Int(padding).."."..Int(precision).."f, %"
				..Int(padding).."."..Int(precision).."f]",
			value.x, value.y, value.z, value.w);
	}
}