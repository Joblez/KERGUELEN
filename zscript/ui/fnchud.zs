class FNCHUD : BaseWeaponHUD
{
	FNC m_FNC;

	ui InterpolatedDouble m_RoundsOffset;
	private vector2 m_OriginalHUDTranslation;
	private double m_OriginalHUDRotation;
	private vector2 m_OriginalHUDScale;

	override void Setup()
	{
		m_FNC = FNC(m_Context);
	}

	override void UISetup()
	{
		Super.UISetup();

		m_RoundsOffset = new("InterpolatedDouble");
		m_RoundsOffset.m_Target = m_FNC.owner.CountInv(m_FNC.AmmoType1);
		m_RoundsOffset.Update();
		m_RoundsOffset.m_SmoothTime = 0.06;
	}

	override void PreDraw(RenderEvent event)
	{
		Super.PreDraw(event);

		m_OriginalHUDTranslation = hudTransform.GetLocalTranslation();
		m_OriginalHUDRotation = hudTransform.GetLocalRotation();
		m_OriginalHUDScale = hudTransform.GetLocalScale();

		hudTransform.SetTranslation(ScreenUtil.NormalizedPositionToView((0.957, 0.7)));
		hudTransform.SetRotation(90.0);
		hudTransform.SetScale(ScreenUtil.ScaleRelativeToBaselineRes(1.0, 1.0, 1280, 720));
	}

	override void Draw(RenderEvent event)
	{
		if (automapactive) return;

		int rounds = m_FNC.owner.CountInv(m_FNC.AmmoType1);

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
		
		int leftRowOffset = int(textureHeight) * rounds % 2 == 0 ? 1 : 2;
		
		vector2 roundScale = hudTransform.GetLocalScale();

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
				StatusBarCore.DI_ITEM_LEFT_TOP | StatusBar.DI_MIRROR,
				hudTransform.GetLocalRotation(),
				1.0,
				scale: invertedScale,
				col: 0xFFFFFFFF);
		}

		for (int i = 1; i <= rightRow; ++i)
		{
			vector2 roundvector =
				(roundsOrigin.x + 4,
				(roundsOrigin.y - textureHeight * i)
					+ m_RoundsOffset.GetValue() + textureHeight / 2);

			roundVector = hudTransform.TransformVector(roundVector);

			StatusBar.DrawTextureRotated(
				roundTexture,
				roundVector,
				StatusBarCore.DI_ITEM_LEFT_TOP | StatusBar.DI_MIRROR,
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