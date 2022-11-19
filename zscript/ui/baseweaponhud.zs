class BaseWeaponHUD : HUDExtension
{
	protected int m_OriginalRelTop;
	protected int m_OriginalHorizontalResolution;
	protected int m_OriginalVerticalResolution;

	override void PreDraw(RenderEvent event)
	{
		if (automapactive) return;

		m_OriginalRelTop = StatusBar.RelTop;
		m_OriginalHorizontalResolution = StatusBar.HorizontalResolution;
		m_OriginalVerticalResolution = StatusBar.VerticalResolution;

		StatusBar.SetSize(0, 1280, 720);
		StatusBar.BeginHUD(forcescaled: false);

		Super.PreDraw(event);
	}

	override void PostDraw(RenderEvent event)
	{
		if (automapactive) return;

		StatusBar.SetSize(m_OriginalRelTop, m_OriginalHorizontalResolution, m_OriginalVerticalResolution);

		StatusBar.BeginHUD(forcescaled: false);
		StatusBar.BeginStatusBar();

		Super.PostDraw(event);
	}
}