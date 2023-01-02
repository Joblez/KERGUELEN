class KergStatusBar : BaseStatusBar
{
	const HUD_WIDTH = 1280;
	const HUD_HEIGHT = 720;

	const WEAPON_HUD_ORIGIN_X = -330;
	const WEAPON_HUD_ORIGIN_Y = -200;

	const TEXT_SCALE = 6.0;
	const BASE_PADDING = 8;

	const UPPERCASE_ALPHANUMERIC_TOP_OFFSET = 2;

	const DIVIDER_GIRTH = 8;

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
		BeginHUD(forcescaled: true);

		// Draw health.

		int hp = CPlayer.mo.Health;

		int healthTextXOrigin = m_Font.mFont.StringWidth("Health") * 0.5 * TEXT_SCALE + BASE_PADDING * 3;

		int healthYOrigin = -220;
		int healthAmountYOffset = m_Font.mFont.GetHeight() * TEXT_SCALE + BASE_PADDING;

		DrawString(m_Font, "Health", (healthTextXOrigin, healthYOrigin), DI_TEXT_ALIGN_CENTER, scale: (TEXT_SCALE, TEXT_SCALE));
		DrawString(m_Font, FormatNumber(hp), (healthTextXOrigin, healthYOrigin + healthAmountYOffset), DI_TEXT_ALIGN_CENTER, scale: (TEXT_SCALE, TEXT_SCALE));

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

	void DrawAmmoHUD(int amount)
	{
		if (amount < 0) return;

		vector2 ammoHUDOrigin = (WEAPON_HUD_ORIGIN_X, WEAPON_HUD_ORIGIN_Y - m_Font.mFont.GetHeight() * TEXT_SCALE - BASE_PADDING);

		DrawString(m_Font, FormatNumber(amount, 1), ammoHUDOrigin, DI_TEXT_ALIGN_CENTER, scale: (TEXT_SCALE, TEXT_SCALE));
	}

	void DrawReserveHUD(int amount)
	{
		if (amount < 0) return;

		int dividerHeight = 86;

		vector2 reserveHUDOrigin = (WEAPON_HUD_ORIGIN_X, WEAPON_HUD_ORIGIN_Y + 40);

		DrawImage(
			"BPAKA0",
			(reserveHUDOrigin.x - BASE_PADDING * 4 - DIVIDER_GIRTH - 8, reserveHUDOrigin.y + UPPERCASE_ALPHANUMERIC_TOP_OFFSET * TEXT_SCALE * 0.5),
			DI_ITEM_RIGHT_TOP,
			scale: (2.0, 2.0));

		Fill(
			DIVIDER_FILL_COLOR,
			reserveHUDOrigin.x - DIVIDER_GIRTH * 0.5,
			reserveHUDOrigin.y,
			DIVIDER_GIRTH,
			dividerHeight);
		
		DrawString(
			m_Font,
			FormatNumber(amount, 1),
			(reserveHUDOrigin.x + BASE_PADDING * 4 + DIVIDER_GIRTH, reserveHUDOrigin.y),
			DI_TEXT_ALIGN_LEFT,
			scale: (TEXT_SCALE, TEXT_SCALE));
	}
}