/** Contains several utilities related to two-component vectors. **/
class Vec2Util
{
	//====================== Directions ======================//

	/** Returns a unit vector2 pointing to +X. **/
	static vector2 Forward()
	{
		return (1, 0);
	}

	/** Returns a unit vector2 pointing to -X. **/
	static vector2 Back()
	{
		return (-1, 0);
	}

	/** Returns a unit vector2 pointing to +Y. **/
	static vector2 Left()
	{
		return (0, 1);
	}
	
	/** Returns a unit vector2 pointing to -Y. **/
	static vector2 Right()
	{
		return (0, -1);
	}

	/** Returns a vector2 with all of its components set to zero. **/
	static vector2 Zero()
	{
		return (0, 0);
	}

	/** Returns a vector2 with all of its components set to double.Infinity. **/
	static vector2 Inf()
	{
		return (double.Infinity, double.Infinity);
	}

	//======================= Swizzles =======================//

	static vector2 XX(vector2 v) { return (v.x, v.x); }
	static vector2 XY(vector2 v) { return v; }

	static vector2 YY(vector2 v) { return (v.y, v.y); }
	static vector2 YX(vector2 v) { return (v.y, v.x); }

	static vector2 _X(vector2 v) { return (0.0, v.x); }
	static vector2 X_(vector2 v) { return (v.x, 0.0); }
	static vector2 _Y(vector2 v) { return (0.0, v.y); }
	static vector2 Y_(vector2 v) { return (v.y, 0.0); }

	static vector3 XXX(vector2 v) { return (v.x, v.x, v.x); }
	static vector3 XXY(vector2 v) { return (v.x, v.x, v.y); }
	static vector3 XYX(vector2 v) { return (v.x, v.y, v.x); }
	static vector3 YXX(vector2 v) { return (v.y, v.x, v.x); }
	static vector3 XYY(vector2 v) { return (v.x, v.y, v.y); }
	static vector3 YYX(vector2 v) { return (v.y, v.y, v.x); }
	static vector3 YXY(vector2 v) { return (v.y, v.x, v.y); }
	static vector3 YYY(vector2 v) { return (v.y, v.y, v.y); }

	static vector3 X__(vector2 v) { return (v.x, 0.0, 0.0); }
	static vector3 _X_(vector2 v) { return (0.0, v.x, 0.0); }
	static vector3 __X(vector2 v) { return (0.0, 0.0, v.x); }
	static vector3 Y__(vector2 v) { return (v.y, 0.0, 0.0); }
	static vector3 _Y_(vector2 v) { return (0.0, v.y, 0.0); }
	static vector3 __Y(vector2 v) { return (0.0, 0.0, v.y); }

	static vector3 X_X(vector2 v) { return (v.x, 0.0, v.x); }
	static vector3 XX_(vector2 v) { return (v.x, v.x, 0.0); }
	static vector3 _XX(vector2 v) { return (0.0, v.x, v.x); }
	static vector3 Y_Y(vector2 v) { return (v.y, 0.0, v.y); }
	static vector3 YY_(vector2 v) { return (v.y, v.y, 0.0); }
	static vector3 _YY(vector2 v) { return (0.0, v.y, v.y); }
	static vector3 X_Y(vector2 v) { return (v.x, 0.0, v.y); }
	static vector3 XY_(vector2 v) { return (v.x, v.y, 0.0); }
	static vector3 _XY(vector2 v) { return (0.0, v.x, v.y); }
	static vector3 Y_X(vector2 v) { return (v.y, 0.0, v.x); }
	static vector3 YX_(vector2 v) { return (v.y, v.x, 0.0); }
	static vector3 _YX(vector2 v) { return (0.0, v.y, v.y); }

	/** Returns a vector2 with random values from min X and Y to max X and Y. **/
	static vector2 Random(double minX, double maxX, double minY, double maxY)
	{
		return (FRandom(minX, maxX), FRandom(minY, maxY));
	}

	/**
	 * Convenience method for getting a direction vector from origin and target vectors.
	 *
	 * Equivalent to (target - origin).Unit().
	**/
	static vector2 Direction(vector2 origin, vector2 target)
	{
		return (target - origin).Unit();
	}

	/**
	 * Returns four vector2s corresponding to the four corners of a rectangle starting from
	 * the top-left corner with the given width and height.
	 *
	 * The values are returned as top-left, top-right, bottom-left, and bottom-right, in that order.
	 *
	 * Parameters:
	 * - origin: The top-left corner from which to derive the rectangle.
	 * - w: The width of the resulting rectangle.
	 * - h: The height of the resulting rectangle.
	**/
	static vector2, vector2, vector2, vector2 RectFromTopLeft(vector2 origin, double w, double h)
	{
		vector2 topLeft = origin;
		vector2 topRight = (topLeft.x + w, topLeft.y);
		vector2 bottomLeft = (topLeft.x, topLeft.y + h);
		vector2 bottomRight = (topLeft.x + w, topLeft.y + h);

		return topLeft, topRight, bottomLeft, bottomRight;
	}

	/**
	 * Returns four vector2s corresponding to the four corners of a rectangle starting from
	 * the given center point with the given width and height.
	 *
	 * The values are returned as top-left, top-right, bottom-left, and bottom-right, in that order.
	 *
	 * Parameters:
	 * - origin: The center point from which to derive the rectangle.
	 * - w: The width of the resulting rectangle.
	 * - h: The height of the resulting rectangle.
	**/
	static vector2, vector2, vector2, vector2 RectFromCenter(vector2 center, double w, double h)
	{
		vector2 origin = center - (w / 2, h / 2);
		vector2 topLeft, topRight, bottomLeft, bottomRight;
		[topLeft, topRight, bottomLeft, bottomRight] = RectFromTopLeft(origin, w, h);
		return topLeft, topRight, bottomLeft, bottomRight;
	}
}

/** Contains several utilities related to three-component vectors. **/
class Vec3Util
{
	//====================== Directions ======================//

	/** Returns a unit vector3 pointing to +X. **/
	static vector3 Forward()
	{
		return (1, 0, 0);
	}

	/** Returns a unit vector3 pointing to -X. **/
	static vector3 Back()
	{
		return (-1, 0, 0);
	}

	/** Returns a unit vector3 pointing to +Y. **/
	static vector3 Left()
	{
		return (0, 1, 0);
	}

	/** Returns a unit vector3 pointing to -Y. **/
	static vector3 Right()
	{
		return (0, -1, 0);
	}

	/** Returns a unit vector3 pointing to +Z. **/
	static vector3 Up()
	{
		return (0, 0, 1);
	}

	/** Returns a unit vector3 pointing to -Z. **/
	static vector3 Down()
	{
		return (0, 0, -1);
	}

	/** Returns a vector3 with all of its components set to zero. **/
	static vector3 Zero()
	{
		return (0, 0, 0);
	}

	/** Returns a vector3 with all of its components set to double.Infinity. **/
	static vector3 Inf()
	{
		return (double.Infinity, double.Infinity, double.Infinity);
	}

	//======================= Swizzles =======================//

	static vector2 XX(vector3 v) { return (v.x, v.x); }
	static vector2 XY(vector3 v) { return (v.x, v.y); }
	static vector2 XZ(vector3 v) { return (v.x, v.z); }

	static vector2 YX(vector3 v) { return (v.y, v.x); }
	static vector2 YY(vector3 v) { return (v.y, v.y); }
	static vector2 YZ(vector3 v) { return (v.y, v.z); }

	static vector2 ZX(vector3 v) { return (v.z, v.x); }
	static vector2 ZY(vector3 v) { return (v.z, v.y); }
	static vector2 ZZ(vector3 v) { return (v.z, v.z); }

	static vector2 X_(vector3 v) { return (v.x, 0.0); }
	static vector2 _X(vector3 v) { return (0.0, v.x); }
	static vector2 Y_(vector3 v) { return (v.y, 0.0); }
	static vector2 _Y(vector3 v) { return (0.0, v.y); }
	static vector2 Z_(vector3 v) { return (v.z, 0.0); }
	static vector2 _Z(vector3 v) { return (0.0, v.z); }

	static vector3 XXX(vector3 v) { return (v.x, v.x, v.x); }
	static vector3 XXY(vector3 v) { return (v.x, v.x, v.y); }
	static vector3 XXZ(vector3 v) { return (v.x, v.x, v.z); }
	static vector3 XYX(vector3 v) { return (v.x, v.y, v.x); }
	static vector3 XYY(vector3 v) { return (v.x, v.y, v.y); }
	static vector3 XYZ(vector3 v) { return v; }
	static vector3 XZX(vector3 v) { return (v.x, v.z, v.x); }
	static vector3 XZY(vector3 v) { return (v.x, v.z, v.y); }
	static vector3 XZZ(vector3 v) { return (v.x, v.z, v.z); }

	static vector3 YXX(vector3 v) { return (v.y, v.x, v.x); }
	static vector3 YXY(vector3 v) { return (v.y, v.x, v.y); }
	static vector3 YXZ(vector3 v) { return (v.y, v.x, v.z); }
	static vector3 YYX(vector3 v) { return (v.y, v.y, v.x); }
	static vector3 YYY(vector3 v) { return (v.y, v.y, v.y); }
	static vector3 YYZ(vector3 v) { return (v.y, v.y, v.z); }
	static vector3 YZX(vector3 v) { return (v.y, v.z, v.x); }
	static vector3 YZY(vector3 v) { return (v.y, v.z, v.y); }
	static vector3 YZZ(vector3 v) { return (v.y, v.z, v.z); }

	static vector3 ZXX(vector3 v) { return (v.z, v.x, v.x); }
	static vector3 ZXY(vector3 v) { return (v.z, v.x, v.y); }
	static vector3 ZXZ(vector3 v) { return (v.z, v.x, v.z); }
	static vector3 ZYX(vector3 v) { return (v.z, v.y, v.x); }
	static vector3 ZYY(vector3 v) { return (v.z, v.y, v.y); }
	static vector3 ZYZ(vector3 v) { return (v.z, v.y, v.z); }
	static vector3 ZZX(vector3 v) { return (v.z, v.z, v.x); }
	static vector3 ZZY(vector3 v) { return (v.z, v.z, v.y); }
	static vector3 ZZZ(vector3 v) { return (v.z, v.z, v.z); }

	static vector3 X__(vector3 v) { return (v.x, 0.0, 0.0); }
	static vector3 _X_(vector3 v) { return (0.0, v.x, 0.0); }
	static vector3 __X(vector3 v) { return (0.0, 0.0, v.x); }
	static vector3 Y__(vector3 v) { return (v.y, 0.0, 0.0); }
	static vector3 _Y_(vector3 v) { return (0.0, v.y, 0.0); }
	static vector3 __Y(vector3 v) { return (0.0, 0.0, v.y); }
	static vector3 Z__(vector3 v) { return (v.z, 0.0, 0.0); }
	static vector3 _Z_(vector3 v) { return (0.0, v.z, 0.0); }
	static vector3 __Z(vector3 v) { return (0.0, 0.0, v.z); }

	static vector3 XX_(vector3 v) { return (v.x, v.x, 0.0); }
	static vector3 X_X(vector3 v) { return (v.x, 0.0, v.x); }
	static vector3 _XX(vector3 v) { return (0.0, v.x, v.x); }
	static vector3 XY_(vector3 v) { return (v.x, v.y, 0.0); }
	static vector3 X_Y(vector3 v) { return (v.x, 0.0, v.y); }
	static vector3 _XY(vector3 v) { return (0.0, v.x, v.y); }
	static vector3 XZ_(vector3 v) { return (v.x, v.z, 0.0); }
	static vector3 X_Z(vector3 v) { return (v.x, 0.0, v.z); }
	static vector3 _XZ(vector3 v) { return (0.0, v.x, v.z); }

	static vector3 YX_(vector3 v) { return (v.y, v.x, 0.0); }
	static vector3 Y_X(vector3 v) { return (v.y, 0.0, v.x); }
	static vector3 _YX(vector3 v) { return (0.0, v.y, v.x); }
	static vector3 YY_(vector3 v) { return (v.y, v.y, 0.0); }
	static vector3 Y_Y(vector3 v) { return (v.y, 0.0, v.y); }
	static vector3 _YY(vector3 v) { return (0.0, v.y, v.y); }
	static vector3 YZ_(vector3 v) { return (v.y, v.z, 0.0); }
	static vector3 Y_Z(vector3 v) { return (v.y, 0.0, v.z); }
	static vector3 _YZ(vector3 v) { return (0.0, v.y, v.z); }

	static vector3 ZX_(vector3 v) { return (v.z, v.x, 0.0); }
	static vector3 Z_X(vector3 v) { return (v.z, 0.0, v.x); }
	static vector3 _ZX(vector3 v) { return (0.0, v.z, v.x); }
	static vector3 ZY_(vector3 v) { return (v.z, v.y, 0.0); }
	static vector3 Z_Y(vector3 v) { return (v.z, 0.0, v.y); }
	static vector3 _ZY(vector3 v) { return (0.0, v.z, v.y); }
	static vector3 ZZ_(vector3 v) { return (v.z, v.z, 0.0); }
	static vector3 Z_Z(vector3 v) { return (v.z, 0.0, v.z); }
	static vector3 _ZZ(vector3 v) { return (0.0, v.z, v.z); }

	/** Returns a vector3 with random values from min X, Y, and Z to max X, Y, and Z. **/
	static vector3 Random(double minX, double maxX, double minY, double maxY, double minZ, double maxZ)
	{
		return (FRandom(minX, maxX), FRandom(minY, maxY), FRandom(minZ, maxZ));
	}

	/** Returns a direction vector from the given yaw and pitch angles. **/
	static vector3 FromAngles(double yaw, double pitch, double length = 1)
	{
		return (length * cos(yaw), length * sin(yaw), length * -sin(pitch));
	}

	/**
	 * Convenience method for getting a direction vector from origin and target vectors.
	 *
	 * Equivalent to (target - origin).Unit().
	**/
	static vector3 Direction(vector3 origin, vector3 target)
	{
		return (target - origin).Unit();
	}
}

class Vec4Util
{
	/** Returns a vector4 with random values from min X, Y, Z, and W to max X, Y, Z, and W. **/
	static vector4 Random(double minX, double maxX, double minY, double maxY, double minZ, double maxZ, double minW, double maxW)
	{
		return (FRandom(minX, maxX), FRandom(minY, maxY), FRandom(minZ, maxZ), FRandom(minW, maxW));
	}
}