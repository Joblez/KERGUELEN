class ToStr
{
	static string Bool(bool value) { return value ? "true" : "false"; }
	static string Int(int value) { return string.Format("%i", value); }
	static string Uint(int value) { return string.Format("%u", value); }
	static string Color(color value) { return string.Format("R: %u, G: %u, B: %u, A: %u", value.r, value.g, value.b, value.a); }
	static string Float(float value, int precision = 6) { return string.Format(".*f", precision, value); }
	static string Double(double value, int precision = 6) { return string.Format(".*f", precision, value); }

	static string Vec2(vector2 value, int precision = 6, int padding = 0)
	{
		return string.Format("[%*.*f, %*.*f]",
			padding, precision, value.x,
			padding, precision, value.y);
	}

	static string Vec3(vector3 value, int precision = 6, int padding = 0)
	{
		return string.Format("[%*.*f, %*.*f, %*.*f]",
			padding, precision, value.x,
			padding, precision, value.y,
			padding, precision, value.z);
	}

	static string Vec4(vector4 value, int precision = 6, int padding = 0)
	{
		return string.Format("[%*.*f, %*.*f, %*.*f, %*.*f]",
			padding, precision, value.x,
			padding, precision, value.y,
			padding, precision, value.z,
			padding, precision, value.w);
	}
}