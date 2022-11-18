
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
		Weapon.AmmoGive2 BCYN;
		Weapon.AmmoType1 "RevoCylinder";
		Weapon.AmmoType2 "Ammo357";
		Weapon.UpSound("sw/raise");

		BaseWeapon.HUDExtensionType "RevolverHUD";

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
			invoker.GetHUDExtension().SendEventToSM('CylinderRotated');
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
			invoker.GetHUDExtension().SendEventToSM('RoundFired');
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
		TNT1 A 0 A_JumpIf((invoker.m_IsLoading), "ReloadEnd"); // If reloading.
		TNT1 A 0 A_JumpIf(invoker.m_SingleAction, "AltReady");
		SWSA ABCD 1;
		TNT1 A 0 A_StartSound("sw/cock", 10,0,0.5);
		SWSA E 1;
		SWSA F 1 { invoker.GetHUDExtension().SendEventToSM('CylinderRotated'); }
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
		SWEJ JKL 1;
		SWEJ M 3;
		TNT1 A 0 {
			invoker.m_IsLoading = true;
			RevolverHUD hud = RevolverHUD(invoker.GetHUDExtension());

			for (int i = 0; i < BCYN - hud.m_EmptyRounds; ++i)
			{
				A_CasingRevolver(random(-4,4), random(-30,-34));
			}

			A_TakeInventory("RevoCylinder", BCYN);
			invoker.GetHUDExtension().SendEventToSM('CylinderEmptied');
			A_StartSound("sw/eject", CHAN_AUTO, 0, 0.5);
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

			invoker.GetHUDExtension().SendEventToSM('RoundInserted');
			return ResolveState(null);
		}
		SWLD FG 2 A_WeaponReady(WRF_NOSWITCH);
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
		SWCL AB 1;
		SWCL C 1 {
			invoker.GetHUDExtension().SendEventToSM('CylinderClosed');
		}
		SWCL DE 1;
		SWCL A 0 A_StartSound("sw/close", CHAN_AUTO,0,0.5);
		SWCL FGH 3;
		SWCL IJKLMN 2;
		TNT1 A 0 {
			invoker.GetHUDExtension().SendEventToSM('SmoothTimeReset');
			invoker.m_SingleAction = false;
			invoker.m_IsLoading = false;
		}
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

// Not very proud of how hacky some of this is...
class RevolverHUD : HUDExtension
{
	enum ERoundState
	{
		RS_Ready,
		RS_Spent,
		RS_Empty
	}

	const ROTATION_CORRECTION = 90.0;
	const ROTATION_SMOOTH_TIME = 0.07;

	Revolver m_Revolver;
	ERoundState[BCYN] m_Rounds;
	int m_CurrentRound;
	int m_EmptyRounds;

	InterpolatedCylinderRotation m_CylinderRotation;

	override SMHUDMachine CreateHUDStateMachine()
	{
		return new("SMHUDRevolverRoundsMachine");
	}

	override void Setup()
	{
		m_CylinderRotation = new("InterpolatedCylinderRotation");
		m_CylinderRotation.m_SmoothTime = ROTATION_SMOOTH_TIME;
		m_Revolver = Revolver(m_Context);
	}

	override void Tick()
	{
		m_CylinderRotation.Update();
	}
}

class SMHUDRevolverState : SMHUDState
{
	protected RevolverHUD m_RoundsHUD;

	protected int m_OriginalRelTop;
	protected int m_OriginalHorizontalResolution;
	protected int m_OriginalVerticalResolution;

	override void EnterState()
	{
		if (!m_RoundsHUD) m_RoundsHUD = RevolverHUD(GetData());
	}

	override void UpdateState()
	{
		Revolver rev = m_RoundsHUD.m_Revolver;

		// In case players use IDFA or IDKFA.
		if (rev.owner.CountInv(rev.AmmoType1) == BCYN)
		{
			for (int i = 0; i < BCYN; ++i)
			{
				m_RoundsHUD.m_Rounds[i] = RevolverHUD.RS_Ready;
			}
			m_RoundsHUD.m_EmptyRounds = 0;
		}
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

		StatusBar.SetSize(0, 1280, 720);
		StatusBar.BeginHUD(forcescaled: false);
	}

	override void Draw(RenderEvent event)
	{
		if (automapactive) return;

		InterpolatedCylinderRotation rotation = m_RoundsHUD.m_CylinderRotation;

		for (int i = 0; i < BCYN; ++i)
		{
			int roundIndex = MathI.PosMod(m_RoundsHUD.m_CurrentRound + i, BCYN);

			if (m_RoundsHUD.m_Rounds[roundIndex] == RevolverHUD.RS_Empty) continue;

			vector2 polarCoords = (
				40, (360.0 - double(roundIndex) * 60.0) + rotation.GetValue() - RevolverHUD.ROTATION_CORRECTION);

			vector2 offset = MathVec2.PolarToCartesian(polarCoords);
			offset = ScreenUtil.ScaleRelativeToBaselineRes(offset.x, offset.y, 1280, 720);

			if (m_RoundsHUD.m_Rounds[roundIndex] == RevolverHUD.RS_Ready)
			{
				DrawReadyRound(ScreenUtil.NormalizedPositionToView((0.89, 0.625)) + offset);
			}
			else
			{
				DrawSpentRound(ScreenUtil.NormalizedPositionToView((0.89, 0.625)) + offset);
			}
		}
	}

	override void PostDraw(RenderEvent event)
	{
		if (automapactive) return;

		StatusBar.SetSize(m_OriginalRelTop, m_OriginalHorizontalResolution, m_OriginalVerticalResolution);

		StatusBar.BeginHUD(forcescaled: false);
		StatusBar.BeginStatusBar();
	}

	override bool TryHandleEvent(name eventId)
	{
		switch (eventId)
		{
			// Tying the rotation target to the round index causes wrap-around issues,
			// so they have to be modified independently.

			case 'RoundInserted':
				int insertIndex = MathI.PosMod(m_RoundsHUD.m_CurrentRound + 1, BCYN);
				m_RoundsHUD.m_Rounds[insertIndex] = RevolverHUD.RS_Ready;
				m_RoundsHUD.m_EmptyRounds--;
				Revolver rev = m_RoundsHUD.m_Revolver;
				if (rev.owner.CountInv(rev.AmmoType1) < BCYN)
				{
					m_RoundsHUD.m_CurrentRound = MathI.PosMod(m_RoundsHUD.m_CurrentRound - 1, BCYN);
					m_RoundsHUD.m_CylinderRotation.m_Target -= 60.0;
				}
				return true;
			
			case 'RoundFired':
				m_RoundsHUD.m_Rounds[m_RoundsHUD.m_CurrentRound] = RevolverHUD.RS_Spent;
				return true;

			case 'CylinderEmptied':
				for (int i = 0; i < BCYN; ++i)
				{
					m_RoundsHUD.m_Rounds[i] = RevolverHUD.RS_Empty;
				}
				m_RoundsHUD.m_EmptyRounds = BCYN;
				return true;

			case 'CylinderRotated':
				m_RoundsHUD.m_CurrentRound = MathI.PosMod(m_RoundsHUD.m_CurrentRound + 1, BCYN);
				m_RoundsHUD.m_CylinderRotation.m_Target += 60.0;
				return true;
			
			case 'CylinderClosed':
				m_RoundsHUD.m_CurrentRound = MathI.PosMod(m_RoundsHUD.m_CurrentRound + 1, BCYN);
				m_RoundsHUD.m_CylinderRotation.m_Target += 60.0;
				m_RoundsHUD.m_CylinderRotation.m_SmoothTime = 0.1;
				return true;

			case 'SmoothTimeReset':
				m_RoundsHUD.m_CylinderRotation.m_SmoothTime = RevolverHUD.ROTATION_SMOOTH_TIME;
				return true;

			default:
				return false;
		}
	}

	Revolver GetRevolver() const
	{
		return m_RoundsHUD.m_Revolver;
	}

	protected ui void DrawReadyRound(vector2 coords)
	{
		StatusBar.DrawImage(
			"RVRNRDY",
			coords,
			StatusBarCore.DI_ITEM_CENTER,
			0.5,
			scale: ScreenUtil.ScaleRelativeToBaselineRes(2.0, 2.0, 1280, 720),
			col: 0xFFFFFFFF);
	}
	
	protected ui void DrawSpentRound(vector2 coords)
	{
		StatusBar.DrawImage(
			"RVRNSPNT",
			coords,
			StatusBarCore.DI_ITEM_CENTER,
			0.35,
			scale: ScreenUtil.ScaleRelativeToBaselineRes(2.0, 2.0, 1280, 720),
			col: 0xFFBBBBBB);
	}
}

class SMHUDRevolverRoundsMachine : SMHUDMachine
{
	override void Build()
	{
		Super.Build();

		GetHUDActiveState()
			.AddChild(new("SMHUDRevolverRoundsState"))
		;
	}
}

class InterpolatedCylinderRotation
{
	double m_Target;
	double m_SmoothTime;

	private double m_Current;
	private double m_CurrentSpeed;

	double GetValue() const
	{
		return m_Current;
	}

	void Update()
	{
		m_Current = Math.SmoothDamp(
			m_Current,
			m_Target,
			m_CurrentSpeed,
			m_SmoothTime,
			double.Infinity,
			1.0 / 35.0);

		// Allow values to reach 360.0 so current can wrap cleanly.
		if (m_Current > 360.0)
		{
			m_Target -= 360.0;
			m_Current -= 360.0;
		}
		else if (m_Current < -360.0)
		{
			m_Target += 360.0;
			m_Current += 360.0;
		}
	}
}