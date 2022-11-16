
// { S&W Model 19 }

const BCYN = 6;

Class RevoCylinder : Ammo
{
	Default
	{
		Inventory.Amount BCYN;
		Inventory.MaxAmount BCYN;
		Ammo.BackpackAmount 0;
		Ammo.BackpackMaxAmount BCYN;
	}
}

class Revolver : BaseWeapon
{
	bool m_SingleAction; //Checks if you're firing in Single action.
	vector2 m_Spread; //Weapon Spread.
	bool m_IsLoading; //checks if you are reloading.

	Default
	{
		Weapon.Kickback 20;
		Weapon.SlotNumber 2;
		Weapon.AmmoUse 0;
		Weapon.AmmoGive1 0;
		Weapon.AmmoGive2 6;
		Weapon.AmmoType1 "RevoCylinder";
		Weapon.AmmoType2 "Ammo357";
		Weapon.UpSound("sw/raise");

		BaseWeapon.HUDExtensionType "RevolverRoundsHUD";

		Inventory.PickupMessage "[2].357 Magnum Revolver";

		Tag "Model 15";
	}

	override void Travelled()
	{
		if (m_SingleAction) owner.Player.SetPSprite(PSP_WEAPON, ResolveState("AltReady"));
	}

	States
	{
	Spawn:
		PICK A -1;
		Stop;

	ZF:
		TNT1 A 1 A_VRecoil(0.9,1,4);
		TNT1 A 1 A_VRecoil(0.95,1,4);
		TNT1 A 1 A_VRecoil(1.0,1,4);
		stop;
	Fire:
		TNT1 A 0 A_JumpIf((invoker.m_IsLoading), "ReloadEnd"); // If reloading.
		TNT1 A 0 A_JumpIf(invoker.m_SingleAction, "Shoot");
	DoubleAction:
		TNT1 A 0 {
			A_StartSound("sw/cock2", 9);
			HUDExtensionRegistry.SendEventToExtension('CylinderRotated', invoker.GetHUDExtensionID());
		}
		SWDA A 1;
		SWDA B 1;
		SWDA C 1;
	Shoot:
		TNT1 A 0 A_JumpIfInventory("RevoCylinder", 1, 1);
		Goto Empty;

		SWDA E 0 Bright {
			A_AlertMonsters();
			A_TakeInventory("RevoCylinder", 1);
			A_StartSound("sw/fire", CHAN_AUTO);
			A_GunFlash("ZF",GFF_NOEXTCHANGE);
			A_FireBullets(invoker.m_Spread.x, invoker.m_Spread.y, -1, 20, "BulletPuff");
			A_FRecoil(1);
			A_ShotgunSmoke(3, 3);
		}
		TNT1 A 0 { invoker.m_SingleAction = false; }
		Goto PostShot;

	PostShot:
		SWAF A 1 Bright;
		SWAF B 2 Bright;
		SWAF C 1;
		SWAF D 1;
		SWAF E 1;
		SWAF F 1;
		SWAF G 1;
	PostPostShot:
		SWAF I 1;
		TNT1 A 0 A_ReFire("PostPostShot");
		Goto Ready;

	AltFire:
		TNT1 A 0 A_JumpIf(invoker.m_SingleAction, "AltReady");
		SWSA ABCD 1;
		TNT1 A 0 A_StartSound("sw/cock", 10,0,0.5);
		SWSA E 1;
		SWSA F 1 { HUDExtensionRegistry.SendEventToExtension('CylinderRotated', invoker.GetHUDExtensionID()); }
		SWSA GHIJKLMN 1;
		TNT1 A 0 { invoker.m_SingleAction = true; }
		Goto AltReady;

	AltReady:
		TNT1 A 0 { invoker.m_Spread = (1, 1); }
		SWSA N 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;

	Ready:
		TNT1 A 0 { invoker.m_Spread = (3, 3); }
		SWAI A 1 A_WeaponReady(WRF_ALLOWRELOAD);
		Loop;

	Empty:
		SWAI A 2 {
			A_StartSound("weapons/empty", CHAN_AUTO,0,0.5);
			invoker.m_SingleAction = false;
		}
		Goto Ready;

	Reload:
		TNT1 A 0 {
			if (CheckInventory(invoker.AmmoType1, BCYN) || !CheckInventory(invoker.AmmoType2, 1))
			{
				// Wish I could just conditional operator this...
				if (invoker.m_SingleAction)
				{
					return ResolveState("AltReady");
				}
				else
				{
					return ResolveState("Ready");
				}
			}
			return ResolveState(null);
		}
		SWEJ ABC 1;
		SWEJ DE 2;
		TNT1 A 0 A_StartSound("sw/open", CHAN_AUTO,0,0.5);
		SWEJ FG 1;
		SWEJ HI 1;
		SWEJ J 1;
		SWEJ K 1 {
			A_TakeInventory("RevoCylinder", BCYN);
			HUDExtensionRegistry.SendEventToExtension('CylinderEmptied', invoker.GetHUDExtensionID());
			A_StartSound("sw/eject", CHAN_AUTO, 0, 0.5);
		}
		SWEJ L 1;
		SWEJ M 3;
		TNT1 A 0 {
			invoker.m_IsLoading = true;
			for (int i = 0; i < 6; ++i)
			{
				A_CasingRevolver(random(-4,4), random(-30,-34));
			}
		}
		SWEJ N 1;
		SWEJ O 3;
		SWEJ PQ 1;
		SWEJ R 1;
		SWEJ ST 1;
		SWEJ UV 2;
	Load:
		SWLD ABC 1 A_WeaponReady(WRF_NOSWITCH);
		SWLD DE 1 A_WeaponReady(WRF_NOSWITCH);
		TNT1 A 0 {
			A_StartSound("sw/load", CHAN_AUTO,0,0.5);

			int ammoAmount = min(
				FindInventory(invoker.AmmoType1).maxAmount - CountInv(invoker.AmmoType1),
				CountInv(invoker.AmmoType2));

			if (ammoAmount <= 0) return ResolveState("Ready");

			GiveInventory(invoker.AmmoType1, 1);
			TakeInventory(invoker.AmmoType2, 1);

			return ResolveState(null);
		}
		SWLD FG 2 A_WeaponReady(WRF_NOSWITCH);
		TNT1 A 0 { HUDExtensionRegistry.SendEventToExtension('CylinderRotated', invoker.GetHUDExtensionID()); }
		SWLD HIJ 1 A_WeaponReady(WRF_NOSWITCH);
		TNT1 A 0 {
			if (CheckInventory(invoker.AmmoType1, BCYN) || !CheckInventory(invoker.AmmoType2, 1))
			{
				return ResolveState ("ReloadEnd");
			}

			return ResolveState("Load");
		}
	ReloadEnd:
	Close:
		SWCL ABCDE 1;
		SWCL A 0 A_StartSound("sw/close", CHAN_AUTO,0,0.5);
		TNT1 A 0 {
			HUDExtensionRegistry.SendEventToExtension('ReloadComplete', invoker.GetHUDExtensionID());
			invoker.m_IsLoading = false;
		}
		SWCL FGH 3;
		SWCL IJKLMN 2;
		TNT1 A 0 { invoker.m_SingleAction = false; }
		Goto Ready;

	Select:
		TNT1 A 0 {
			SetPlayerProperty(0, 1, 2);
			invoker.RegisterWeaponHUD();
			invoker.m_SingleAction = false;
		}
		TNT1 A 1;
		SWCL J 1 A_SetBaseOffset(-65, 81);
		SWCL J 1 A_SetBaseOffset(-35, 55);
		SWCL J 1 A_SetBaseOffset(-28, 39);
		SWCL J 1 A_SetBaseOffset(-12, 38);
		SWCL K 1 A_SetBaseOffset(3, 34);
		SWCL K 1 A_SetBaseOffset(3, 34);
		SWCL LMN 1;
		SWAF A 0 A_SetBaseOffset(0, WEAPONTOP);
		SWAI A 1 A_Raise(16);
		Goto Ready;

	Deselect:
		TNT1 A 0 { invoker.UnregisterWeaponHUD(); }
		SWCL M 1 A_SetBaseOffset(3, 34);
		SWCL K 1 A_SetBaseOffset(-12, 38);
		SWCL J 1 A_SetBaseOffset(-28, 39);
		SWCL J 1 A_SetBaseOffset(-35, 55);
		SWCL J 1 A_SetBaseOffset(-65, 81);
		TNT1 A 0 A_SetBaseOffset(0, WEAPONBOTTOM);
		TNT1 A 4;
		SWAI A 1 A_Lower(16);
		Loop;
	}
}

class RevolverRoundsHUD : HUDExtension
{
	const ROTATION_CORRECTION = 150.0;

	Revolver m_Revolver;
	InterpolatedDouble m_ChamberRotation;

	override SMHUDMachine CreateHUDStateMachine()
	{
		return new("SMHUDRevolverRoundsMachine");
	}

	override void Setup()
	{
		m_ChamberRotation = new("InterpolatedDouble");
		m_ChamberRotation.m_SmoothTime = 0.1;
		m_Revolver = Revolver(m_Context);
	}

	override void Tick()
	{
		m_ChamberRotation.Update();
		if (m_ChamberRotation.GetValue() ~== 360.0) m_ChamberRotation.HardReset();
	}
}

class SMHUDRevolverRoundsState : SMHUDState
{
	RevolverRoundsHUD m_RevolverRoundsHUD;

	protected int m_OriginalRelTop;
	protected int m_OriginalHorizontalResolution;
	protected int m_OriginalVerticalResolution;

	override void EnterState()
	{
		if (!m_RevolverRoundsHUD) m_RevolverRoundsHUD = RevolverRoundsHUD(GetData());
	}

	override void PreDraw(RenderEvent event)
	{
		if (automapactive) return;

		// Store these to clean up after drawing.
		m_OriginalRelTop = StatusBar.RelTop;
		m_OriginalHorizontalResolution = StatusBar.HorizontalResolution;
		m_OriginalVerticalResolution = StatusBar.VerticalResolution;

		int viewX, viewY, viewW, viewH;
			[viewX, viewY, viewW, viewH] = Screen.GetViewWindow();

		StatusBar.SetSize(0, viewW, viewH);
		StatusBar.BeginHUD(forcescaled: true);
	}

	override void PostDraw(RenderEvent event)
	{
		if (automapactive) return;

		StatusBar.SetSize(m_OriginalRelTop, m_OriginalHorizontalResolution, m_OriginalVerticalResolution);

		StatusBar.BeginHUD(forcescaled: false);
		StatusBar.BeginStatusBar();
	}

	Revolver GetRevolver() const
	{
		return m_RevolverRoundsHUD.m_Revolver;
	}

	protected ui void DrawReadyRound(vector2 coords)
	{
		StatusBar.DrawImage(
			"RVRNRDY",
			coords,
			StatusBarCore.DI_ITEM_CENTER,
			0.6,
			scale: (2.0, 2.0),
			col: 0xFFFFFFFF);
	}
	
	protected ui void DrawSpentRound(vector2 coords)
	{
		StatusBar.DrawImage(
			"RVRNSPNT",
			coords,
			StatusBarCore.DI_ITEM_CENTER,
			0.6,
			scale: (2.0, 2.0),
			col: 0xFFAAAAAA);
	}
}

class SMHUDRevolverRoundsActive : SMHUDRevolverRoundsState
{
	override bool TryHandleEvent(name eventId)
	{
		switch (eventId)
		{
			case 'CylinderRotated':
				m_RevolverRoundsHUD.m_ChamberRotation.m_Target += 60.0;
				return true;

			default:
				return false;
		}
	}

	override void Draw(RenderEvent event)
	{
		if (automapactive) return;

		for (int i = 1; i <= 6; ++i)
		{
			vector2 polarCoords = (40,
				360.0 * (i / 6.0)
					- RevolverRoundsHUD.ROTATION_CORRECTION
					+ m_RevolverRoundsHUD.m_ChamberRotation.GetValue());

			vector2 polarOffset = MathVec2.PolarToCartesian(polarCoords);

			if (StatusBar.CheckInventory("RevoCylinder", i))
			{
				DrawReadyRound(ScreenUtil.NormalizedPositionToView((0.8, 0.65)) + polarOffset);
			}
			else
			{
				DrawSpentRound(ScreenUtil.NormalizedPositionToView((0.8, 0.65)) + polarOffset);
			}
		}
	}
}

class SMHUDRevolverRoundsReload : SMHUDRevolverRoundsState
{
	const ROTATION_CORRECTION = 150.0;
	override bool TryHandleEvent(name eventId)
	{
		switch (eventId)
		{
			case 'CylinderRotated':
				m_RevolverRoundsHUD.m_ChamberRotation.m_Target -= 60.0;
				return true;

			default:
				return false;
		}
	}

	override void EnterState()
	{
		Super.EnterState();
		m_RevolverRoundsHUD.m_ChamberRotation.HardReset();
	}

	override void Draw(RenderEvent event)
	{
		for (int i = 0 ; i < GetRevolver().owner.CountInv("RevoCylinder"); ++i)
		{
			vector2 polarCoords = (40,
				360.0 * (i / 6.0)
					- ROTATION_CORRECTION
					+ m_RevolverRoundsHUD.m_ChamberRotation.GetValue());

			vector2 polarOffset = MathVec2.PolarToCartesian(polarCoords);

			DrawReadyRound(ScreenUtil.NormalizedPositionToView((0.8, 0.65)) + polarOffset);
		}
	}
}

class SMHUDRevolverRoundsMachine : SMHUDMachine
{
	override void Build()
	{
		Super.Build();

		GetHUDActiveState()
			.AddChild(new("SMHUDRevolverRoundsActive"))
			.AddChild(new("SMHUDRevolverRoundsReload"))

			.AddTransition(new("SMTransition")
				.From("SMHUDRevolverRoundsActive")
				.To("SMHUDRevolverRoundsReload")
				.On('CylinderEmptied')
			)
			.AddTransition(new("SMTransition")
				.From("SMHUDRevolverRoundsReload")
				.To("SMHUDRevolverRoundsActive")
				.On('ReloadComplete')
			)
		;
	}
}