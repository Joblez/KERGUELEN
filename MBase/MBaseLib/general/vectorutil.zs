struct Vector2Util
{
	static vector2 Forward()
	{
		return (1, 0);
	}
	static vector2 Back()
	{
		return (-1, 0);
	}
	static vector2 Left()
	{
		return (0, 1);
	}
	static vector2 Right()
	{
		return (0, -1);
	}
	static vector2 Zero()
	{
		return (0, 0);
	}

	static vector2, vector2, vector2, vector2 RectFromTopLeft(vector2 origin, double w, double h)
	{
		vector2 topLeft = origin;
		vector2 topRight = (topLeft.x + w, topLeft.y);
		vector2 bottomLeft = (topLeft.x, topLeft.y + h);
		vector2 bottomRight = (topLeft.x + w, topLeft.y + h);

		return topLeft, topRight, bottomLeft, bottomRight;
	}

	static vector2, vector2, vector2, vector2 RectFromCenter(vector2 center, double w, double h)
	{
		vector2 origin = center - (w / 2, h / 2);
		vector2 topLeft, topRight, bottomLeft, bottomRight;
		[topLeft, topRight, bottomLeft, bottomRight] = RectFromTopLeft(origin, w, h);
		return topLeft, topRight, bottomLeft, bottomRight;
	}
}

struct Vector3Util
{
	static vector3 Forward()
	{
		return (1, 0, 0);
	}
	static vector3 Back()
	{
		return (-1, 0, 0);
	}
	static vector3 Left()
	{
		return (0, 1, 0);
	}
	static vector3 Right()
	{
		return (0, -1, 0);
	}
	static vector3 Up()
	{
		return (0, 0, 1);
	}
	static vector3 Down()
	{
		return (0, 0, -1);
	}
	static vector3 Zero()
	{
		return (0, 0, 0);
	}

	static vector3 FromAngles(double yaw, double pitch, double length = 1)
	{
		return (length * cos(yaw), length * sin(yaw), length * -sin(pitch));
	}

	static vector3 Direction(vector3 origin, vector3 target, bool unit = true)
	{
		vector3 dir = target - origin;
		if (unit) dir = dir.Unit();
		return dir;
	}
}