class BaseWeaponHUD : HUDExtension abstract
{
	const HUD_WIDTH = 1280;
	const HUD_HEIGHT = 720;

	protected int m_OriginalRelTop;
	protected int m_OriginalHorizontalResolution;
	protected int m_OriginalVerticalResolution;

	protected ui Transform2D m_HUDTransform;
	protected ui transient CVar m_HUDAspectScale;

	ui double GetAspectScaleX() const
	{
		return m_HUDAspectScale.GetBool() ? ScreenUtil.ASPECT_SCALE_X : 1.0;
	}

	ui double GetAspectScaleY() const
	{
		return m_HUDAspectScale.GetBool() ? ScreenUtil.ASPECT_SCALE_Y : 1.0;
	}

	ui Transform2D GetHUDTransform() const
	{
		return m_HUDTransform;
	}

	override void UISetup()
	{
		m_HUDTransform = Transform2D.Create();
		m_HUDAspectScale = CVar.GetCVar("hud_aspectscale");
	}

	override void PreDraw(int state, double ticFrac)
	{
		if (automapactive) return;

		if (!m_HUDAspectScale) m_HUDAspectScale = CVar.GetCVar("hud_aspectscale");

		m_OriginalRelTop = StatusBar.RelTop;
		m_OriginalHorizontalResolution = StatusBar.HorizontalResolution;
		m_OriginalVerticalResolution = StatusBar.VerticalResolution;

		StatusBar.BeginHUD(forcescaled: true);
		StatusBar.SetSize(0, KergStatusBar.HUD_WIDTH, KergStatusBar.HUD_HEIGHT);

		Super.PreDraw(state, ticFrac);
	}

	override void PostDraw(int state, double ticFrac)
	{
		if (automapactive) return;

		StatusBar.SetSize(m_OriginalRelTop, m_OriginalHorizontalResolution, m_OriginalVerticalResolution);

		StatusBar.BeginHUD(forcescaled: true);
		StatusBar.BeginStatusBar();

		Super.PostDraw(state, ticFrac);
	}
}