class FNCHUD : BaseWeaponHUD
{
	FNC m_FNC;

	ui Transform2D m_CanvasTransform;
	ui InterpolatedDouble m_BottomOffset;

	override void Setup()
	{
		m_FNC = FNC(m_Context);
	}

	override void UISetup()
	{
		m_CanvasTransform = Transform2D.Create();
		m_BottomOffset = new("InterpolatedDouble");
		m_BottomOffset.m_Target = m_FNC.owner.CountInv(m_FNC.AmmoType1);
		m_BottomOffset.Update();
		m_BottomOffset.m_SmoothTime = 0.08;
	}

	override void Draw(RenderEvent event)
	{
		if (automapactive) return;

		vector2 bottomCoords = ScreenUtil.NormalizedPositionToView((0.89, 0.235));
		int rounds = m_FNC.owner.CountInv(m_FNC.AmmoType1);

		int textureWidth, textureHeight;
		TextureID roundTexture = TexMan.CheckForTexture("FNRNRDY");
		[textureWidth, textureHeight] = TexMan.GetSize(roundTexture);

		vector2 roundScale = (2.0, 2.0);

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


		m_BottomOffset.m_Target = rounds * textureHeight * roundScale.y / 2;
		m_BottomOffset.Update();

		StatusBar.SetClipRect(
			int(bottomCoords.x),
			int(bottomCoords.y),
			int(textureWidth * roundScale.x) + 8,
			int(textureHeight * roundScale.y) * (rounds + 1));
		
		int leftRowOffset = int(textureHeight * roundScale.y) * rounds % 2 == 0 ? 1 : 2;

		for (int i = 1; i <= leftRow; ++i)
		{
			StatusBar.DrawTexture(
				roundTexture,
				(bottomCoords.x,
					(bottomCoords.y - textureHeight * roundScale.y * i)
					+ m_BottomOffset.GetValue() + leftRowOffset),
				StatusBarCore.DI_ITEM_LEFT_TOP,
				1.0,
				scale: roundScale,
				col: 0xFFFFFFFF);
		}

		for (int i = 1; i <= rightRow; ++i)
		{
			StatusBar.DrawTexture(
				roundTexture,
				(bottomCoords.x + 4,
					(bottomCoords.y - textureHeight * roundScale.y * i)
					+ m_BottomOffset.GetValue() + textureHeight * roundScale.y / 2),
				StatusBarCore.DI_ITEM_LEFT_TOP,
				1.0,
				scale: roundScale,
				col: 0xFFFFFFFF);
		}

		StatusBar.ClearClipRect();
	}
}