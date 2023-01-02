// TODO: Document HUDExtension.

// Note: HUDExtensions represent HUD drawing behavior with state, you retrieve them from
// your status bar's Draw() method and call CallDraw() to draw them. You can also tick their
// state machines with their CallTick() method.
class HUDExtension abstract
{
	protected Object m_Context;
	protected SMHUDMachine m_StateMachine;

	protected ui bool m_IsUISetUp;

	// TODO: Add ToString().

	virtual void Setup() { }

	virtual void Tick() { }

	virtual ui void UISetup() { }
	
	protected virtual SMHUDMachine CreateHUDStateMachine()
	{
		return new("SMHUDMachine");
	}

	protected virtual ui void PreDraw(int state, double ticFrac)
	{
		m_StateMachine.PreDraw(state, ticFrac);
	}
	protected virtual ui void Draw(int state, double ticFrac)
	{
		m_StateMachine.Draw(state, ticFrac);
	}
	protected virtual ui void PostDraw(int state, double ticFrac)
	{
		m_StateMachine.PostDraw(state, ticFrac);
	}

	Object GetContext() const
	{
		return m_Context;
	}

	void Init(Object context)
	{
		m_Context = context;

		m_StateMachine = CreateHUDStateMachine();
		m_StateMachine.m_Data = self;
		m_StateMachine.CallBuild();

		Setup();
		m_StateMachine.Start();
		SendEventToSM('Activate');
	}

	void CallTick()
	{
		Tick();
		m_StateMachine.Update();
	}

	void SendEventToSM(name eventId)
	{
		m_StateMachine.SendEvent(eventId);
	}

	ui void CallUISetup()
	{
		if (m_IsUISetUp) return;

		UISetup();
		m_IsUISetUp = true;
	}

	ui void CallDraw(int state, double ticFrac)
	{
		// A little sloppy, but it can't be helped.
		CallUISetup();

		PreDraw(state, ticFrac);
		Draw(state, ticFrac);
		PostDraw(state, ticFrac);
	}
}

class SMHUDState : SMState abstract
{
	virtual ui void PreDraw(int state, double ticFrac) { }
	virtual ui void Draw(int state, double ticFrac) { }
	virtual ui void PostDraw(int state, double ticFrac) { }

	HUDExtension GetHUDExtension() const
	{
		return HUDExtension(GetData());
	}

	PlayerInfo GetPlayerInfo() const
	{
		return players[consoleplayer];
	}

	ui void CallPreDraw(int state, double ticFrac)
	{
		if (GetActiveChild() is "SMHUDState")
		{
			SMHUDState(GetActiveChild()).CallPreDraw(state, ticFrac);
		}
		PreDraw(state, ticFrac);
	}

	ui void CallDraw(int state, double ticFrac)
	{
		if (GetActiveChild() is "SMHUDState")
		{
			SMHUDState(GetActiveChild()).CallDraw(state, ticFrac);
		}
		Draw(state, ticFrac);
	}

	ui void CallPostDraw(int state, double ticFrac)
	{
		if (GetActiveChild() is "SMHUDState")
		{
			SMHUDState(GetActiveChild()).CallPostDraw(state, ticFrac);
		}
		PostDraw(state, ticFrac);
	}
}

class SMHUDMachine : SMMachine
{
	ui void PreDraw(int state, double ticFrac)
	{
		SMHUDState activeChild = SMHUDState(GetActiveChild());
		if (activeChild) activeChild.CallPreDraw(state, ticFrac);
	}

	ui void Draw(int state, double ticFrac)
	{
		SMHUDState activeChild = SMHUDState(GetActiveChild());
		if (activeChild) activeChild.CallDraw(state, ticFrac);
	}

	ui void PostDraw(int state, double ticFrac)
	{
		SMHUDState activeChild = SMHUDState(GetActiveChild());
		if (activeChild) activeChild.CallPostDraw(state, ticFrac);
	}
}