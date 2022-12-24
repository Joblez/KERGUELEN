class M2CHUD : BaseWeaponHUD
{
	M2C m_M2C;

	InterpolatedDouble m_RoundsOffset;

	private TextureID m_RoundTexture;
	private vector2 m_TextureSize;

	private vector2 m_OriginalHUDTranslation;
	private double m_OriginalHUDRotation;
	private vector2 m_OriginalHUDScale;

	override void Setup()
	{
		m_M2C = M2C(m_Context);

		m_RoundsOffset = new("InterpolatedDouble");
		m_RoundsOffset.m_Target = m_M2C.owner.CountInv(m_M2C.AmmoType1);
		m_RoundsOffset.Update();
		m_RoundsOffset.m_SmoothTime = 0.05;

		m_RoundTexture = TexMan.CheckForTexture("FNRNRDY");
		int textureWidth, textureHeight;
		[textureWidth, textureHeight] = TexMan.GetSize(m_RoundTexture);
		m_TextureSize = (textureWidth, textureHeight);
	}

	override void Tick()
	{
		int rounds = m_M2C.owner.CountInv(m_M2C.AmmoType1);
		m_RoundsOffset.m_Target = rounds * m_TextureSize.y / 2;
		m_RoundsOffset.Update();
	}

	override void PreDraw(RenderEvent event)
	{
		Super.PreDraw(event);

		m_OriginalHUDTranslation = hudTransform.GetLocalTranslation();
		m_OriginalHUDRotation = hudTransform.GetLocalRotation();
		m_OriginalHUDScale = hudTransform.GetLocalScale();

		hudTransform.SetTranslation(ScreenUtil.NormalizedPositionToView((0.97, 0.97)));
		hudTransform.SetRotation(90.0);
		hudTransform.SetScale(ScreenUtil.ScaleRelativeToBaselineRes(1.0, 1.0, HUD_WIDTH, HUD_HEIGHT, adjustForHUDAspectScale: false));
	}

	override void Draw(RenderEvent event)
	{
		if (automapactive) return;

		int rounds = m_M2C.owner.CountInv(m_M2C.AmmoType1);

		vector2 roundsOrigin = Vec2Util.Zero();

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
		vector2 roundScale = hudTransform.GetLocalScale();
		
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
					

			roundVector = hudTransform.TransformVector(roundVector);

			StatusBar.DrawTextureRotated(
				m_RoundTexture,
				roundVector,
				StatusBarCore.DI_ITEM_CENTER | StatusBar.DI_MIRROR,
				hudTransform.GetLocalRotation(),
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

			roundVector = hudTransform.TransformVector(roundVector);

			StatusBar.DrawTextureRotated(
				m_RoundTexture,
				roundVector,
				StatusBarCore.DI_ITEM_CENTER | StatusBar.DI_MIRROR,
				hudTransform.GetLocalRotation(),
				1.0,
				scale: invertedScale,
				col: 0xFFFFFFFF);
		}
	}

	override void PostDraw(RenderEvent event)
	{
		Super.PostDraw(event);

		hudTransform.SetTranslation(m_OriginalHUDTranslation);
		hudTransform.SetRotation(m_OriginalHUDRotation);
		hudTransform.SetScale(m_OriginalHUDScale);
	}
}