// Not very proud of how hacky some of this is...
class RevolverHUD : BaseWeaponHUD
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
		return new("SMHUDRevolverMachine");
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

	override void Draw(RenderEvent event)
	{
		if (automapactive) return;

		InterpolatedCylinderRotation rotation = m_RoundsHUD.m_CylinderRotation;

		for (int i = 0; i < BCYN; ++i)
		{
			int roundIndex = MathI.PosMod(m_RoundsHUD.m_CurrentRound + i, BCYN);

			if (m_RoundsHUD.m_Rounds[roundIndex] == RevolverHUD.RS_Empty) continue;

			vector2 polarCoords = (
				20, (360.0 - double(roundIndex) * 60.0) + rotation.GetValue() - RevolverHUD.ROTATION_CORRECTION);

			vector2 offset = MathVec2.PolarToCartesian(polarCoords);
			offset = ScreenUtil.ScaleRelativeToBaselineRes(offset.x, offset.y, BaseWeaponHUD.HUD_WIDTH, BaseWeaponHUD.HUD_HEIGHT);

			if (m_RoundsHUD.m_Rounds[roundIndex] == RevolverHUD.RS_Ready)
			{
				DrawReadyRound(ScreenUtil.NormalizedPositionToView((0.9, 0.94)) + offset);
			}
			else
			{
				DrawSpentRound(ScreenUtil.NormalizedPositionToView((0.9, 0.94)) + offset);
			}
		}
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
			1.0,
			scale: ScreenUtil.ScaleRelativeToBaselineRes(1.0, 1.0, BaseWeaponHUD.HUD_WIDTH, BaseWeaponHUD.HUD_HEIGHT),
			col: 0xFFCCCCCC);
	}
	
	protected ui void DrawSpentRound(vector2 coords)
	{
		StatusBar.DrawImage(
			"RVRNSPNT",
			coords,
			StatusBarCore.DI_ITEM_CENTER,
			1.0,
			scale: ScreenUtil.ScaleRelativeToBaselineRes(1.0, 1.0, BaseWeaponHUD.HUD_WIDTH, BaseWeaponHUD.HUD_HEIGHT),
			col: 0xFF999999);
	}
}

class SMHUDRevolverMachine : SMHUDMachine
{
	override void Build()
	{
		Super.Build();

		GetHUDActiveState()
			.AddChild(new("SMHUDRevolverState"))
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