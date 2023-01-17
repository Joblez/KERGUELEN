class IthacaHUD : BaseWeaponHUD
{
	Ithaca m_Ithaca;

	ui InterpolatedDouble m_FirstRoundOffset;
	ui InterpolatedDouble m_RoundsOffset;

	TextureID m_RoundTexture;
	vector2 m_TextureSize;

	private ui double m_PreviousTime;

	private vector2 m_OriginalHUDTranslation;
	private vector2 m_OriginalHUDScale;

	private int m_PreviousRounds;

	override void Setup()
	{
		m_Ithaca = Ithaca(m_Context);

		m_RoundTexture = TexMan.CheckForTexture("FNRNRDY");
		int textureWidth, textureHeight;
		[textureWidth, textureHeight] = TexMan.GetSize(m_RoundTexture);
		m_TextureSize = (textureWidth, textureHeight);
	}

	override void UISetup()
	{
		Super.UISetup();

		m_FirstRoundOffset = new("InterpolatedDouble");
		m_FirstRoundOffset.m_SmoothTime = 0.05;
		m_RoundsOffset = new("InterpolatedDouble");
		m_RoundsOffset.m_SmoothTime = 0.05;
	}

	override void PreDraw(int state, double ticFrac)
	{
		Super.PreDraw(state, ticFrac);

		if ((!m_Ithaca.m_Chambered && m_Ithaca.GetAmmo() > 0))
		{
			m_RoundsOffset.m_SmoothTime = 0.05;
			m_FirstRoundOffset.m_SmoothTime = 0.0;
		}
		else
		{
			m_RoundsOffset.m_SmoothTime = 0.05;
			m_FirstRoundOffset.m_SmoothTime = 0.05;
		}


		m_OriginalHUDTranslation = m_HUDTransform.GetLocalTranslation();
		m_OriginalHUDScale = m_HUDTransform.GetLocalTranslation();

		m_HUDTransform.SetTranslation((KergStatusBar.WEAPON_HUD_ORIGIN_X + 16, KergStatusBar.WEAPON_HUD_ORIGIN_Y - 4));
		m_HUDTransform.SetScale((0.75, 0.75));
	}

	override void Draw(int state, double ticFrac)
	{
		if (automapactive) return;

		vector2 roundsOrigin = Vec2Util.Zero();
		vector2 roundScale = m_HUDTransform.GetLocalScale();
		vector2 invertedScale = (1.0 / roundScale.x, 1.0 / roundScale.y);

		int rounds = m_Ithaca.GetAmmo();

		int target = m_Ithaca.m_Chambered ? rounds - 1 : rounds;

		m_RoundsOffset.m_Target = target * m_TextureSize.x;
		m_RoundsOffset.Update((level.time + ticFrac - m_PreviousTime) / TICRATE);

		m_FirstRoundOffset.m_Target = m_Ithaca.m_Chambered ? m_TextureSize.y + 2 : 0.0;
		m_FirstRoundOffset.Update((level.time + ticFrac - m_PreviousTime) / TICRATE);

		if (rounds > 0)
		{
			vector2 roundVector =
				(roundsOrigin.x, roundsOrigin.y - m_FirstRoundOffset.GetValue());

			roundVector = m_HUDTransform.TransformVector(roundVector);

			StatusBar.DrawTextureRotated(
				m_RoundTexture,
				roundVector,
				StatusBarCore.DI_ITEM_CENTER,
				m_HUDTransform.GetLocalRotation(),
				1.0,
				scale: invertedScale,
				col: 0xFFFFFFFF);
		}

		for (int i = 1; i < rounds; ++i)
		{
			vector2 roundVector =
				(roundsOrigin.x + m_TextureSize.x * i - m_RoundsOffset.GetValue(),
				roundsOrigin.y);

			roundVector = m_HUDTransform.TransformVector(roundVector);

			StatusBar.DrawTextureRotated(
				m_RoundTexture,
				roundVector,
				StatusBarCore.DI_ITEM_CENTER,
				m_HUDTransform.GetLocalRotation(),
				1.0,
				scale: invertedScale,
				col: 0xFFFFFFFF);
		}
	}

	override void PostDraw(int state, double ticFrac)
	{
		Super.PostDraw(state, ticFrac);

		m_PreviousRounds = m_Ithaca.GetAmmo();
		m_PreviousTime = level.time + ticFrac;

		m_HUDTransform.SetTranslation(m_OriginalHUDTranslation);
		m_HUDTransform.SetScale(m_OriginalHUDScale);
	}
}