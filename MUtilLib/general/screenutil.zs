// TODO: Document ScreenUtil.
class ScreenUtil
{
	const ASPECT_SCALE_X = 1.2;
	const ASPECT_SCALE_Y = 5.0 / 6.0;

	/**
	 * Returns the viewport coordinates corresponding to the given normalized position
	 * vector.
	**/
	static vector2 NormalizedPositionToView(vector2 pos)
	{
		// Wrap values, but ensure 1.0 doesn't wrap to 0.
		if (abs(pos.x) > 1.0) pos.x %= 1.0;
		if (abs(pos.y) > 1.0) pos.y %= 1.0;

		int viewX, viewY, viewW, viewH;
		[viewX, viewY, viewW, viewH] = Screen.GetViewWindow();

		viewH = AdjustForHUDAspectScaleVertical(viewH);

		return (pos.x * viewW + viewX, pos.y * viewH + viewY);
	}

	/** Returns the width-to-height ratio of the viewport. **/
	static double GetAspectRatio()
	{
		int viewX, viewY, viewW, viewH;
		[viewX, viewY, viewW, viewH] = Screen.GetViewWindow();

		if (viewH == 0) return 0.0;

		viewH = AdjustForHUDAspectScaleVertical(viewH);

		return 1.0 * viewW / viewH;
	}

	/**
	 * Returns the given normalized position vector adjusted to account for the viewport's
	 * aspect ratio.
	**/
	static vector2 AdjustForAspectRatio(vector2 pos)
	{
		// Wrap values, but ensure 1.0 doesn't wrap to 0.
		if (abs(pos.x) > 1.0) pos.x %= 1;
		if (abs(pos.y) > 1.0) pos.y %= 1;

		int viewX, viewY, viewW, viewH;
		[viewX, viewY, viewW, viewH] = Screen.GetViewWindow();

		viewH = AdjustForHUDAspectScaleVertical(viewH);

		double aspectRatio = 1.0 * viewW / viewH;
		if (viewW > viewH) pos.x /= aspectRatio;
		else if (viewW < viewH) pos.y /= aspectRatio;

		return pos;
	}

	/**
	 * For the given top-left origin and the given width and height, returns a rectangle
	 * that has the given dimensions starting from the given origin, returned as top-left,
	 * top-right, bottom-left, and bottom-right corners in that order.
	 *
	 * Parameters:
	 * - origin: the top-left corner of the rectangle.
	 * - w: the width of the rectangle.
	 * - h: the height of the rectangle.
	 * - adjustForAspectRatio: whether or not the resulting rectangle should be adjusted
	 *		to take the aspect ratio of the viewport into account.
	**/
	static vector2, vector2, vector2, vector2 RectFromTopLeft(vector2 origin, double w, double h, bool adjustForAspectRatio = true)
	{
		if (adjustForAspectRatio)
		{
			int viewX, viewY, viewW, viewH;
			[viewX, viewY, viewW, viewH] = Screen.GetViewWindow();

			viewH = AdjustForHUDAspectScaleVertical(viewH);

			double aspectRatio = 1.0 * viewW / viewH;
			if (viewW > viewH) w /= aspectRatio;
			else if (viewW < viewH) h /= aspectRatio;
		}

		vector2 topLeft, topRight, bottomLeft, bottomRight;
		[topLeft, topRight, bottomLeft, bottomRight] = Vec2Util.RectFromTopLeft(origin, w, h);

		return topLeft, topRight, bottomLeft, bottomRight;
	}

	/**
	 * For the given center and the given width and height, returns a rectangle that has
	 * the given dimensions starting from the given origin, returned as top-left,
	 * top-right, bottom-left, and bottom-right corners in that order.
	 *
	 * Parameters:
	 * - center: the center of the rectangle.
	 * - w: the width of the rectangle.
	 * - h: the height of the rectangle.
	 * - adjustForAspectRatio: whether or not the resulting rectangle should be adjusted
	 *		to take the aspect ratio of the viewport into account.
	**/
	static vector2, vector2, vector2, vector2 RectFromCenter(vector2 center, double w, double h, bool adjustForAspectRatio = true)
	{
		if (adjustForAspectRatio)
		{
			int viewX, viewY, viewW, viewH;
			[viewX, viewY, viewW, viewH] = Screen.GetViewWindow();

			viewH = AdjustForHUDAspectScaleVertical(viewH);

			double aspectRatio = 1.0 * viewW / viewH;
			if (viewW > viewH) w /= aspectRatio;
			else if (viewW < viewH) h /= aspectRatio;
			adjustForAspectRatio = false;
		}

		vector2 origin = center - (w / 2, h / 2);
		vector2 topLeft, topRight, bottomLeft, bottomRight;
		[topLeft, topRight, bottomLeft, bottomRight] = RectFromTopLeft(origin, w, h, adjustForAspectRatio);
		return topLeft, topRight, bottomLeft, bottomRight;
	}

	/**
	 * Returns the given vector scaled relative to the given base width and height.
	 * For instance, for a size vector of (1.0, 1.0) and a given baseline resolution of
	 * 1920 * 1080, this method will return (0.5, 0.5) when the viewport resolution is
	 * 960 * 540.
	 *
	 * Parameters:
	 * - size: the vector to be scaled.
	 * - baseWidth: the width of the resolution to be used as a baseline.
	 * - baseHeight: the height of the resolution to be used as a baseline.
	 * - keepAspectRatio: whether or not the resulting vector should be shrinked to
	 *		retain the aspect ratio of the given size.
	 * - adjustForHUDAspectScale: whether or not the resulting vector should be adjusted
	 *		to account for the "HUD preserves aspect ratio" setting.
	**/
	static vector2 ScaleRelativeToBaselineRes(
		vector2 size,
		int baseWidth,
		int baseHeight,
		bool keepAspectRatio = true,
		bool adjustForHUDAspectScale = true)
	{
		int viewX, viewY, viewW, viewH;
		[viewX, viewY, viewW, viewH] = Screen.GetViewWindow();

		double xFactor = 1.0 * viewW / baseWidth;
		double yFactor = 1.0 * viewH / baseHeight;

		if (adjustForHUDAspectScale)
		{
			yFactor = AdjustForHUDAspectScaleVertical(yFactor);
		}

		if (keepAspectRatio)
		{
			double smaller = min(xFactor, yFactor);
			vector2 result = (size.x * smaller, size.y * smaller);
			if (adjustForHUDAspectScale) result.x = AdjustForHUDAspectScaleHorizontal(result.x);
			return result;
		}

		return (size.x * xFactor, size.y * yFactor);
	}

	/**
	 * Returns the given vector scaled to the size of the viewport relative to the size
	 * of the screen.
	**/
	static vector2 ScaleToViewport(vector2 size)
	{
		int viewX, viewY, viewW, viewH;
		[viewX, viewY, viewW, viewH] = Screen.GetViewWindow();

		int screenW = Screen.GetWidth();
		int screenH = Screen.GetHeight();

		size.x *= 1.0 * viewW / screenW;
		size.y *= 1.0 * viewH / screenH;

		return (size.x, size.y);
	}

	private static double AdjustForHUDAspectScaleHorizontal(double horizontal)
	{
		bool hudAspectScale = CVar.GetCVar('hud_aspectscale').GetBool();

		return hudAspectScale ? horizontal * ASPECT_SCALE_X : horizontal;
	}

	private static double AdjustForHUDAspectScaleVertical(double vertical)
	{
		bool hudAspectScale = CVar.GetCVar('hud_aspectscale').GetBool();

		return hudAspectScale ? vertical * ASPECT_SCALE_Y : vertical;
	}
}