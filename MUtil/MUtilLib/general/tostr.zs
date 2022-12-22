class ToStr
{
	static string Bool(bool value) { return value ? "true" : "false"; }
	static string Int(int value) { return string.Format("%i", value); }
	static string Uint(int value) { return string.Format("%u", value); }
	static string Color(color value) { return string.Format("R: %u, G: %u, B: %u, A: %u", value.r, value.g, value.b, value.a); }

	// Yuck...

	static string Float(float value, int precision = 6) { return string.Format("."..Int(precision).."f", value); }
	static string Double(double value, int precision = 6) { return string.Format("."..Int(precision).."f", value); }

	static string Vec2(vector2 value, int precision = 6, int padding = 0)
	{
		return string.Format(
			"[%"..Int(padding).."."..Int(precision).."f, %"
				..Int(padding).."."..Int(precision).."f]",
			value.x, value.y);
	}

	static string Vec3(vector3 value, int precision = 6, int padding = 0)
	{
		return string.Format(
			"[%"..Int(padding).."."..Int(precision).."f, %"
				..Int(padding).."."..Int(precision).."f, %"
				..Int(padding).."."..Int(precision).."f]",
			value.x, value.y, value.z);
	}

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