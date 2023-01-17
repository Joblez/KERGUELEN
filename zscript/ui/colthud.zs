class ColtHUD : BaseWeaponHUD
{
	Colt m_Colt;

	ui InterpolatedDouble m_RoundsOffset;

	TextureID m_RoundTexture;
	vector2 m_TextureSize;

	private ui double m_PreviousTime;

	private vector2 m_OriginalHUDTranslation;

	private int m_PreviousRounds;

	override void Setup()
	{
		m_Colt = Colt(m_Context);

		m_RoundTexture = TexMan.CheckForTexture("PSTRNRDY");
		int textureWidth, textureHeight;
		[textureWidth, textureHeight] = TexMan.GetSize(m_RoundTexture);
		m_TextureSize = (textureWidth, textureHeight);
	}

	override void UISetup()
	{
		Super.UISetup();

		m_RoundsOffset = new("InterpolatedDouble");
		m_RoundsOffset.m_SmoothTime = 0.03;
	}

	override void PreDraw(int state, double ticFrac)
	{
		Super.PreDraw(state, ticFrac);

		m_RoundsOffset.m_SmoothTime = m_PreviousRounds < m_Colt.GetAmmo() ? 0.0 : 0.03;

		m_OriginalHUDTranslation = m_HUDTransform.GetLocalTranslation();

		m_HUDTransform.SetTranslation((KergStatusBar.WEAPON_HUD_ORIGIN_X + 40, KergStatusBar.WEAPON_HUD_ORIGIN_Y - 18));
	}

	override void Draw(int state, double ticFrac)
	{
		if (automapactive) return;

		vector2 roundsOrigin = Vec2Util.Zero();
		vector2 roundScale = m_HUDTransform.GetLocalScale();
		vector2 invertedScale = (1.0 / roundScale.x, 1.0 / roundScale.y);

		int rounds = m_Colt.GetAmmo();

		m_RoundsOffset.m_Target = rounds * m_TextureSize.y;
		m_RoundsOffset.Update((level.time + ticFrac - m_PreviousTime) / TICRATE);

		double maxOffset = CMAG * m_TextureSize.y;

		for (int i = 1; i <= rounds; ++i)
		{
			vector2 roundVector =
				(roundsOrigin.x + m_TextureSize.y * i - m_RoundsOffset.GetValue(),
				roundsOrigin.y);

			roundVector = m_HUDTransform.TransformVector(roundVector);

			StatusBar.DrawTextureRotated(
				m_RoundTexture,
				roundVector,
				StatusBarCore.DI_ITEM_CENTER,
				m_HUDTransform.GetLocalRotation() - 90.0,
				1.0,
				scale: invertedScale,
				col: 0xFFFFFFFF);
		}
	}

	override void PostDraw(int state, double ticFrac)
	{
		Super.PostDraw(state, ticFrac);

		m_PreviousRounds = m_Colt.GetAmmo();
		m_PreviousTime = level.time + ticFrac;

		m_HUDTransform.SetTranslation(m_OriginalHUDTranslation);
	}
}