class M2CHUD : BaseWeaponHUD
{
	M2C m_M2C;

	ui InterpolatedDouble m_RoundsOffset;
	private vector2 m_OriginalHUDTranslation;
	private double m_OriginalHUDRotation;
	private vector2 m_OriginalHUDScale;

	override void Setup()
	{
		m_M2C = M2C(m_Context);
	}

	override void UISetup()
	{
		Super.UISetup();

		m_RoundsOffset = new("InterpolatedDouble");
		m_RoundsOffset.m_Target = m_M2C.owner.CountInv(m_M2C.AmmoType1);
		m_RoundsOffset.Update();
		m_RoundsOffset.m_SmoothTime = 0.07;
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

		int textureWidth, textureHeight;
		TextureID roundTexture = TexMan.CheckForTexture("FNRNRDY");
		[textureWidth, textureHeight] = TexMan.GetSize(roundTexture);

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

		m_RoundsOffset.m_Target = rounds * textureHeight / 2;
		m_RoundsOffset.Update();
		
		// Never thought I'd come across good ol' off-by-one in screen coordinates...
		double leftRowOffset = (textureHeight * rounds % 2 == 0 ? 1.0 : 2.0) - 1;
		vector2 roundScale = hudTransform.GetLocalScale();
		
		// So much work to get around what this one little CVar does...
		roundScale.y *= GetAspectScaleY();

		// No clue why it works this way.
		vector2 invertedScale = (1.0 / roundScale.x, 1.0 / roundScale.y);

		for (int i = 1; i <= leftRow; ++i)
		{
			vector2 roundVector =
				(roundsOrigin.x,
				(roundsOrigin.y - textureHeight * i)
					+ m_RoundsOffset.GetValue() + leftRowOffset);
					

			roundVector = hudTransform.TransformVector(roundVector);

			StatusBar.DrawTextureRotated(
				roundTexture,
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
				(roundsOrigin.y - textureHeight * i)
					+ m_RoundsOffset.GetValue() + textureHeight * 0.5);

			roundVector = hudTransform.TransformVector(roundVector);

			StatusBar.DrawTextureRotated(
				roundTexture,
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