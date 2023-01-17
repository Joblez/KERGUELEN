class M2CHUD : BaseWeaponHUD
{
	M2C m_M2C;

	ui InterpolatedDouble m_RoundsOffset;

	private int m_PreviousRounds;

	private TextureID m_RoundTexture;
	private vector2 m_TextureSize;

	private vector2 m_OriginalHUDTranslation;
	private double m_OriginalHUDRotation;
	private vector2 m_OriginalHUDScale;

	private ui double m_PreviousTime;

	override void Setup()
	{
		m_M2C = M2C(m_Context);

		m_RoundTexture = TexMan.CheckForTexture("FNRNRDY");
		int textureWidth, textureHeight;
		[textureWidth, textureHeight] = TexMan.GetSize(m_RoundTexture);
		m_TextureSize = (textureWidth, textureHeight);
	}

	override void UISetup()
	{
		Super.UISetup();

		m_RoundsOffset = new("InterpolatedDouble");
		m_RoundsOffset.m_SmoothTime = 0.025;
	}

	override void PreDraw(int state, double ticFrac)
	{
		Super.PreDraw(state, ticFrac);

		// One-size-fits-all solution...
		m_RoundsOffset.m_SmoothTime = m_PreviousRounds < m_M2C.GetAmmo() ? 0.0 : 0.025;

		m_OriginalHUDTranslation = m_HUDTransform.GetLocalTranslation();
		m_OriginalHUDRotation = m_HUDTransform.GetLocalRotation();
		m_OriginalHUDScale = m_HUDTransform.GetLocalScale();

		m_HUDTransform.SetTranslation((KergStatusBar.WEAPON_HUD_ORIGIN_X + 52, KergStatusBar.WEAPON_HUD_ORIGIN_Y - 4));
		m_HUDTransform.SetRotation(90.0);
		m_HUDTransform.SetScale((0.75, 0.75));
	}

	override void Draw(int state, double ticFrac)
	{
		if (automapactive) return;

		vector2 roundsOrigin = Vec2Util.Zero();

		int rounds = m_M2C.GetAmmo();

		int leftRow, rightRow;

		for (int i = 0; i < rounds; ++i)
		{
			if (i % 2 != 0)
			{
				leftRow++;
			}
			else
			{
				rightRow++;
			}
		}

		// Never thought I'd come across good ol' off-by-one in screen coordinates...
		double leftRowOffset = (m_TextureSize.y * rounds % 2 == 0 ? 1.0 : 2.0) - 1;
		vector2 roundScale = m_HUDTransform.GetLocalScale();
		
		m_RoundsOffset.m_Target = rounds * m_TextureSize.y / 2;

		m_RoundsOffset.Update((level.time + ticFrac - m_PreviousTime) / TICRATE);

		// So much work to get around what this one little CVar does...
		roundScale.y *= GetAspectScaleY();

		// No clue why it works this way.
		vector2 invertedScale = (1.0 / roundScale.x, 1.0 / roundScale.y);

		for (int i = 1; i <= leftRow; ++i)
		{
			vector2 roundVector =
				(roundsOrigin.x,
				(roundsOrigin.y - m_TextureSize.y * i)
					+ m_RoundsOffset.GetValue() + leftRowOffset);

			roundVector = m_HUDTransform.TransformVector(roundVector);

			StatusBar.DrawTextureRotated(
				m_RoundTexture,
				roundVector,
				StatusBarCore.DI_ITEM_CENTER | StatusBar.DI_MIRROR,
				m_HUDTransform.GetLocalRotation(),
				1.0,
				scale: invertedScale,
				col: 0xFFFFFFFF);
		}

		for (int i = 1; i <= rightRow; ++i)
		{
			vector2 roundvector =
				(roundsOrigin.x + 5 * GetAspectScaleY(),
				(roundsOrigin.y - m_TextureSize.y * i)
					+ m_RoundsOffset.GetValue() + m_TextureSize.y * 0.5);

			roundVector = m_HUDTransform.TransformVector(roundVector);

			StatusBar.DrawTextureRotated(
				m_RoundTexture,
				roundVector,
				StatusBarCore.DI_ITEM_CENTER | StatusBar.DI_MIRROR,
				m_HUDTransform.GetLocalRotation(),
				1.0,
				scale: invertedScale,
				col: 0xFFFFFFFF);
		}
	}

	override void PostDraw(int state, double ticFrac)
	{
		Super.PostDraw(state, ticFrac);

		m_PreviousRounds = m_M2C.GetAmmo();
		m_PreviousTime = level.time + ticFrac;

		m_HUDTransform.SetTranslation(m_OriginalHUDTranslation);
		m_HUDTransform.SetRotation(m_OriginalHUDRotation);
		m_HUDTransform.SetScale(m_OriginalHUDScale);
	}
}