// TODO: Document HUDExtension.

// Note: HUDExtensions represent HUD drawing behavior with state, you retrieve them from
// your status bar's Draw() method and call CallDraw() to draw them. You can also tick their
// state machines with their CallTick() method.

/**
 * Represents a drawer for a custom HUD element, to be drawn on demand.
 *
 * HUDExtensions are meant to encapsulate HUD drawing logic that can hold its own state,
 * meant for play or data-scoped objects to define and update their own HUD state to later
 * be drawn by any associated UI-scoped objects. Although any drawing object may use them,
 * HUDExtensions are primarily designed to be drawn by custom status bars.
 *
 * A common use case would be for a weapon to define its own HUDExtension-derived class,
 * create an instance of it and update it every tick ,sending events to its state machine
 * as needed. Then a custom status bar would try to retrieve a pointer to the weapon's
 * HUDExtension and use its drawing methods to draw it to the screen.
**/
class HUDExtension abstract
{
	/**
	 * The object that this HUDExtension will read from.
	 * Most use cases will want to cast this to the object's derived type.
	**/
	protected Object m_Context;

	/** This HUDExtension's state machine. **/
	protected SMHUDMachine m_StateMachine;

	/** Workaround field to ensure UI setup is only performed once. **/
	protected transient ui bool m_IsUISetUp;

	/** Meant to perform any setup logic required. **/
	protected virtual void Setup() { }

	/**
	 * Meant to update the state of the HUDExtension.
	 *
	 * NOTE:
	 *		Not to be confused with updating the state machine's state.
	 *
	 *		This method should not be called directly. Consider calling
	 *		CallTick() instead.
	**/
	protected virtual void Tick() { }


	/**
	 * Meant to perform any UI-scoped setup logic required.
	 *
	 * NOTE:This method should not be called directly. Consider calling
	 *		CallUISetup() instead.
	**/
	protected virtual ui void UISetup() { }
	
	/** Meant to construct and return the state machine this HUDExtension will use. **/
	protected virtual SMHUDMachine CreateHUDStateMachine()
	{
		return new("SMHUDMachine");
	}

	/**
	 * Meant to contain logic to be performed before proper drawing occurs.
	 * Calls the PreDraw() method of this HUDExtension's state machine by default.
	**/
	protected virtual ui void PreDraw(int state, double ticFrac)
	{
		m_StateMachine.PreDraw(state, ticFrac);
	}

	/**
	 * Meant to contain this HUDExtension's drawing logic. Calls the Draw() method of
	 * this HUDExtension's state machine by default.
	**/
	protected virtual ui void Draw(int state, double ticFrac)
	{
		m_StateMachine.Draw(state, ticFrac);
	}

	/**
	 * Meant to contain logic to be performed after drawing. Calls the PostDraw() method
	 * of this HUDExtension's state machine by default.
	**/
	protected virtual ui void PostDraw(int state, double ticFrac)
	{
		m_StateMachine.PostDraw(state, ticFrac);
	}

	/** Returns this HUDExtension's context. **/
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


	/** Updates this HUDExtension. **/
	void CallTick()
	{
		Tick();
		m_StateMachine.Update();
	}

	/** Sends the given event ID to this HUDExtension's state machine. **/
	void SendEventToSM(name eventId)
	{
		m_StateMachine.SendEvent(eventId);
	}

	/** Performs UI-scoped setup. **/
	ui void CallUISetup()
	{
		if (m_IsUISetUp) return;

		UISetup();
		m_IsUISetUp = true;
	}

	/** Performs this HUDExtension's drawing logic. **/
	ui void CallDraw(int state, double ticFrac)
	{
		// A little sloppy, but it can't be helped.
		CallUISetup();

		PreDraw(state, ticFrac);
		Draw(state, ticFrac);
		PostDraw(state, ticFrac);
	}
}

/** Abstract class meant to derive HUDExtension-usable states from. **/
class SMHUDState : SMState abstract
{
	/**
	 * Meant to contain logic to be performed before proper drawing occurs.
	 *
	 * NOTE:
	 *		This method is meant to be called by the state's containing machine, and
	 *		should not be called directly.
	**/
	virtual ui void PreDraw(int state, double ticFrac) { }

	/**
	 * Meant to contain this SMHUDState's drawing logic.
	 *
	 * NOTE:
	 *		This method is meant to be called by the state's containing machine, and
	 *		should not be called directly.
	**/
	virtual ui void Draw(int state, double ticFrac) { }

	/**
	 * Meant to contain logic to be performed after drawing.
	 *
	 * NOTE:
	 *		This method is meant to be called by the state's containing machine, and
	 *		should not be called directly.
	**/
	virtual ui void PostDraw(int state, double ticFrac) { }

	/** Returns this SMHUDState's associated HUDExtension. **/
	HUDExtension GetHUDExtension() const
	{
		return HUDExtension(GetData());
	}

	/**
	 * Performs logic to be performed before proper drawing occurs. Also calls the
	 * PreDraw() method of its active child.
	 *
	 * NOTE:
	 *		This method is meant to be called by the state's containing machine, and
	 *		should not be called directly.
	**/
	ui void CallPreDraw(int state, double ticFrac)
	{
		if (GetActiveChild() is "SMHUDState")
		{
			SMHUDState(GetActiveChild()).CallPreDraw(state, ticFrac);
		}
		PreDraw(state, ticFrac);
	}

	/**
	 * Performs this SMHUDState's drawing logic. Also calls the Draw() method of its
	 * active child.
	 *
	 * NOTE:
	 *		This method is meant to be called by the state's containing machine, and
	 *		should not be called directly.
	**/
	ui void CallDraw(int state, double ticFrac)
	{
		if (GetActiveChild() is "SMHUDState")
		{
			SMHUDState(GetActiveChild()).CallDraw(state, ticFrac);
		}
		Draw(state, ticFrac);
	}

	/**
	 * Performs logic to be performed after drawing. Also calls the PreDraw() method
	 * of its active child.
	 *
	 * NOTE:
	 *		This method is meant to be called by the state's containing machine, and
	 *		should not be called directly.
	**/
	ui void CallPostDraw(int state, double ticFrac)
	{
		if (GetActiveChild() is "SMHUDState")
		{
			SMHUDState(GetActiveChild()).CallPostDraw(state, ticFrac);
		}
		PostDraw(state, ticFrac);
	}
}

/** State machine class meant to be used by HUDExtensions. **/
class SMHUDMachine : SMMachine
{
	/** See SMMachine.Build() **/
	override void Build()
	{
	}

	/** Calls the PreDraw() method of this SMHUDMachine's active branch. **/
	ui void PreDraw(int state, double ticFrac)
	{
		SMHUDState activeChild = SMHUDState(GetActiveChild());
		if (activeChild) activeChild.CallPreDraw(state, ticFrac);
	}

	/** Calls the Draw() method of this SMHUDMachine's active branch. **/
	ui void Draw(int state, double ticFrac)
	{
		SMHUDState activeChild = SMHUDState(GetActiveChild());
		if (activeChild) activeChild.CallDraw(state, ticFrac);
	}

	/** Calls the PostDraw() method of this SMHUDMachine's active branch. **/
	ui void PostDraw(int state, double ticFrac)
	{
		SMHUDState activeChild = SMHUDState(GetActiveChild());
		if (activeChild) activeChild.CallPostDraw(state, ticFrac);
	}
}