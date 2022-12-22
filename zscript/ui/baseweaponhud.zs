class BaseWeaponHUD : HUDExtension abstract
{
	const HUD_WIDTH = 1280;
	const HUD_HEIGHT = 720;

	protected int m_OriginalRelTop;
	protected int m_OriginalHorizontalResolution;
	protected int m_OriginalVerticalResolution;

	protected ui Transform2D hudTransform;
	protected ui CVar hudAspectScale;

	ui double GetAspectScaleX()
	{
		return hudAspectScale.GetBool() ? ScreenUtil.ASPECT_SCALE_X : 1.0;
	}

	ui double GetAspectScaleY()
	{
		return hudAspectScale.GetBool() ? ScreenUtil.ASPECT_SCALE_Y : 1.0;
	}

	override void UISetup()
	{
		hudTransform = Transform2D.Create();
		hudAspectScale = CVar.GetCVar("hud_aspectscale");
	}

	override void PreDraw(RenderEvent event)
	{
		if (automapactive) return;

		m_OriginalRelTop = StatusBar.RelTop;
		m_OriginalHorizontalResolution = StatusBar.HorizontalResolution;
		m_OriginalVerticalResolution = StatusBar.VerticalResolution;

		StatusBar.BeginHUD(forcescaled: false);
		StatusBar.SetSize(0, HUD_WIDTH, HUD_HEIGHT);

		Super.PreDraw(event);
	}

	// None of the translucent styles work, the only way this can be used is using STYLE_TranslucentStencil
	// and filling in the sprite colors manually in separate draw calls, which would be ridiculous.
	// override void Draw(RenderEvent event)
	// {
	// 	Canvas hudCanvas = TexMan.GetCanvas("HUDCNVS1");

	// 	hudCanvas.ClearScreen();
	// 	DrawHUD(hudCanvas);
	// 	Screen.DrawTexture(TexMan.CheckForTexture("HUDCNVS1"), false, 200, 0, DTA_RenderStyle, STYLE_Translucent);
	// }

	override void PostDraw(RenderEvent event)
	{
		if (automapactive) return;

		StatusBar.SetSize(m_OriginalRelTop, m_OriginalHorizontalResolution, m_OriginalVerticalResolution);

		StatusBar.BeginHUD(forcescaled: true);
		StatusBar.BeginStatusBar();

		Super.PostDraw(event);
	}

	// abstract ui void DrawHUD(Canvas hudCanvas)
	// {
	// }
}