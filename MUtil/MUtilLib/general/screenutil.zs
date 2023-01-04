// TODO: Document ScreenUtil.
class ScreenUtil
{
	const ASPECT_SCALE_X = 1.2;
	const ASPECT_SCALE_Y = 5.0 / 6.0;

	static vector2 NormalizedPositionToView(vector2 pos)
	{
		// Wrap values, but ensure 1.0 doesn't wrap to 0.
		if (abs(pos.x) > 1.0) pos.x %= 1;
		if (abs(pos.y) > 1.0) pos.y %= 1;

		int viewX, viewY, viewW, viewH;
		[viewX, viewY, viewW, viewH] = Screen.GetViewWindow();

		viewH = AdjustForHUDAspectScaleVertical(viewH);

		return (pos.x * viewW + viewX, pos.y * viewH + viewY);
	}

	static double GetAspectRatio()
	{
		int viewX, viewY, viewW, viewH;
		[viewX, viewY, viewW, viewH] = Screen.GetViewWindow();

		if (viewH == 0) return 0.0;

		viewH = AdjustForHUDAspectScaleVertical(viewH);

		return 1.0 * viewW / viewH;
	}

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

	static vector2 ScaleRelativeToBaselineRes(
		double x,
		double y,
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
			vector2 result = (x * smaller, y * smaller);
			if (adjustForHUDAspectScale) result.x = AdjustForHUDAspectScaleHorizontal(result.x);
			return result;
		}

		return (x * xFactor, y * yFactor);
	}

	static vector2 ScaleToViewport(double x, double y)
	{
		int viewX, viewY, viewW, viewH;
		[viewX, viewY, viewW, viewH] = Screen.GetViewWindow();

		int screenW = Screen.GetWidth();
		int screenH = Screen.GetHeight();

		x *= 1.0 * viewW / screenW;
		y *= 1.0 * viewH / screenH;

		return (x, y);
	}

	private static double AdjustForHUDAspectScaleHorizontal(double horizontal)
	{
		bool m_HUDAspectScale = CVar.GetCVar("hud_aspectscale").GetBool();

		return m_HUDAspectScale ? horizontal * ASPECT_SCALE_X : horizontal;
	}

	private static double AdjustForHUDAspectScaleVertical(double vertical)
	{
		bool m_HUDAspectScale = CVar.GetCVar("hud_aspectscale").GetBool();

		return m_HUDAspectScale ? vertical * ASPECT_SCALE_Y : vertical;
	}
}