class KergStatusBar : BaseStatusBar
{
	const HUD_WIDTH = 640;
	const HUD_HEIGHT = 360;

	const WEAPON_HUD_ORIGIN_X = -90;
	const WEAPON_HUD_ORIGIN_Y = -60;

	const TEXT_SCALE = 2.0;
	const BASE_PADDING = 4;

	const UPPERCASE_ALPHANUMERIC_TOP_OFFSET = 2;

	const DIVIDER_GIRTH = 2;

	const DIVIDER_FILL_COLOR = 0xFFB3AFAF;

	HUDFont m_Font;

	override void Init()
	{
		Super.Init();

		SetSize(0, HUD_WIDTH, HUD_HEIGHT);

		Font f = "ALTFONT";
		m_Font = HUDFont.Create(f, f.GetCharWidth("M") * 0.75, Mono_CellLeft);
	}

	override void Draw(int state, double TicFrac)
	{
		Super.Draw(state, TicFrac);

		if (state == HUD_None) return;

		BeginHUD(forcescaled: true);

		// Draw health.

		int hp = max(0, CPlayer.mo.Health);

		int healthTextXOrigin = m_Font.mFont.StringWidth("Health") * 0.5 * TEXT_SCALE + BASE_PADDING;

		int healthYOrigin = -80;
		int healthAmountYOffset = m_Font.mFont.GetHeight() * TEXT_SCALE + BASE_PADDING;

		DrawString(m_Font, "Health", (healthTextXOrigin, healthYOrigin), DI_TEXT_ALIGN_CENTER, scale: (TEXT_SCALE, TEXT_SCALE));
		DrawString(m_Font, FormatNumber(hp), (healthTextXOrigin, healthYOrigin + healthAmountYOffset), DI_TEXT_ALIGN_CENTER, scale: (TEXT_SCALE, TEXT_SCALE));

		//Draw Keys
		DrawKeyHUD();

		// Draw weapon HUD.

		BaseWeapon weap = BaseWeapon(CPlayer.ReadyWeapon);

		if (weap)
		{
			DrawReserveHUD(weap.GetReserveAmmo());

			HUDExtension extension = weap.GetHUDExtension();

			if (extension)
			{
				extension.CallDraw(state, TicFrac);
			}
			else
			{
				// Eventually this should be removed.
				DrawAmmoHUD(weap.GetAmmo());
			}
		}

	}

	void DrawKeyHUD()
	{
		{
		// Draw the keys. This does not use a special draw function like SBARINFO because the specifics will be different for each mod
		// so it's easier to copy or reimplement the following piece of code instead of trying to write a complicated all-encompassing solution.
		int keyXOrigin = -45;		
		int keyYOrigin = 10;

		Vector2 keypos = (keyXOrigin + BASE_PADDING, keyYOrigin + BASE_PADDING);		
		int rowc = 0;
		double roww = 0;
		for(let i = CPlayer.mo.Inv; i != null; i = i.Inv)
		{
			if (i is "Key" && i.Icon.IsValid())
			{
				DrawTexture(i.Icon, keypos, DI_SCREEN_RIGHT_TOP|DI_ITEM_LEFT_TOP);
				Vector2 size = TexMan.GetScaledSize(i.Icon);
				keypos.Y += size.Y + 2;
				roww = max(roww, size.X);
				if (++rowc == 3)
				{
					keypos.y += roww + 2;
					roww = 0;
					rowc = 0;
					}
				}
			}
		}
	}	

	void DrawAmmoHUD(int amount)
	{
		if (amount < 0) return;

		vector2 ammoHUDOrigin = (WEAPON_HUD_ORIGIN_X, WEAPON_HUD_ORIGIN_Y - m_Font.mFont.GetHeight() * TEXT_SCALE);

		DrawString(m_Font, FormatNumber(amount, 1), ammoHUDOrigin, DI_TEXT_ALIGN_CENTER, scale: (TEXT_SCALE, TEXT_SCALE));
	}

	void DrawReserveHUD(int amount)
	{
		if (amount < 0) return;

		int dividerHeight = m_Font.mFont.GetHeight() * TEXT_SCALE * 1.25 + 2;

		vector2 reserveHUDOrigin = (WEAPON_HUD_ORIGIN_X, WEAPON_HUD_ORIGIN_Y + 10);

		DrawImage(
			"BPAKA0",
			(reserveHUDOrigin.x - BASE_PADDING - DIVIDER_GIRTH - 2, reserveHUDOrigin.y),
			DI_ITEM_RIGHT_TOP,
			scale: (0.75, 0.75));

		Fill(
			DIVIDER_FILL_COLOR,
			reserveHUDOrigin.x - DIVIDER_GIRTH * 0.5,
			reserveHUDOrigin.y - 2,
			DIVIDER_GIRTH,
			dividerHeight);
		
		DrawString(
			m_Font,
			FormatNumber(amount, 1),
			(reserveHUDOrigin.x + BASE_PADDING + DIVIDER_GIRTH, reserveHUDOrigin.y),
			DI_TEXT_ALIGN_LEFT,
			scale: (TEXT_SCALE, TEXT_SCALE));
	}
		
}