class IshaporeHUD : BaseWeaponHUD
{
	Ishapore m_Ishapore;

	ui InterpolatedDouble m_RoundsOffset;

	TextureID m_RoundTexture;
	vector2 m_TextureSize;

	private ui double m_PreviousTime;

	private vector2 m_OriginalHUDTranslation;
	private vector2 m_OriginalHUDScale;

	override void Setup()
	{
		m_Ishapore = Ishapore(m_Context);

		m_RoundTexture = TexMan.CheckForTexture("ISHRNRDY");
		int textureWidth, textureHeight;
		[textureWidth, textureHeight] = TexMan.GetSize(m_RoundTexture);
		m_TextureSize = (textureWidth + 2, textureHeight);
	}

	override void UISetup()
	{
		Super.UISetup();

		m_RoundsOffset = new("InterpolatedDouble");
		m_RoundsOffset.m_SmoothTime = 0.05;
	}

	override void PreDraw(int state, double ticFrac)
	{
		Super.PreDraw(state, ticFrac);

		if ((!m_Ishapore.m_Chambered && !m_Ishapore.m_IsLoading && m_Ishapore.GetAmmo() > 0))
		{
			m_RoundsOffset.m_SmoothTime = 0.0;
		}
		else
		{
			m_RoundsOffset.m_SmoothTime = 0.05;
		}


		m_OriginalHUDTranslation = m_HUDTransform.GetLocalTranslation();
		m_OriginalHUDScale = m_HUDTransform.GetLocalTranslation();

		m_HUDTransform.SetTranslation((KergStatusBar.WEAPON_HUD_ORIGIN_X + 36, KergStatusBar.WEAPON_HUD_ORIGIN_Y - 4));
		m_HUDTransform.SetScale((0.75, 0.75));
	}

	override void Draw(int state, double ticFrac)
	{
		if (automapactive) return;

		vector2 roundsOrigin = Vec2Util.Zero();
		vector2 roundScale = m_HUDTransform.GetLocalScale();
		vector2 invertedScale = (1.0 / roundScale.x, 1.0 / roundScale.y);

		int rounds = m_Ishapore.GetAmmo();

		int target = !m_Ishapore.m_Chambered ? rounds + 1 : rounds;

		m_RoundsOffset.m_Target = target * m_TextureSize.y;
		m_RoundsOffset.Update((level.time + ticFrac - m_PreviousTime) / TICRATE);

		for (int i = 1; i <= rounds; ++i)
		{
			vector2 roundVector =
				(roundsOrigin.x + m_TextureSize.y * i - m_RoundsOffset.GetValue(),
				roundsOrigin.y);

			roundVector = m_HUDTransform.TransformVector(roundVector);

			StatusBar.DrawTextureRotated(
				m_RoundTexture,
				roundVector,
				StatusBarCore.DI_ITEM_CENTER | StatusBarCore.DI_MIRROR,
				m_HUDTransform.GetLocalRotation() + 90.0,
				1.0,
				scale: invertedScale,
				col: 0xFFFFFFFF);
		}
	}

	override void PostDraw(int state, double ticFrac)
	{
		Super.PostDraw(state, ticFrac);

		m_PreviousTime = level.time + ticFrac;

		m_HUDTransform.SetTranslation(m_OriginalHUDTranslation);
		m_HUDTransform.SetScale(m_OriginalHUDScale);
	}
}