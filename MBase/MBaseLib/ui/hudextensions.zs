// TODO: Document HUDExtension.
class HUDExtension abstract
{
	enum ELifecycleStage
	{
		UNINITIALIZED,
		PENDING_ACTIVATION,
		ACTIVE,
		PENDING_REMOVAL
	}

	protected Object m_Context;
	protected ELifecycleStage m_LifecycleStage;
	protected SMHUDMachine m_StateMachine;

	protected ui bool m_IsUISetUp;

	virtual void OnActivate()
	{
		m_StateMachine.SendEvent('ActivationComplete');
	}

	virtual void OnDeactivate()
	{
		m_StateMachine.SendEvent('DeactivationComplete');
	}

	virtual void Setup() { }

	virtual void Tick() { }

	virtual ui void UISetup() { }
	
	virtual ui void PreDraw(RenderEvent event)
	{
		m_StateMachine.PreDraw(event);
	}
	virtual ui void Draw(RenderEvent event)
	{
		m_StateMachine.Draw(event);
	}
	virtual ui void PostDraw(RenderEvent event)
	{
		m_StateMachine.PostDraw(event);
	}

	protected virtual SMHUDMachine CreateHUDStateMachine()
	{
		return new("SMHUDMachine");
	}

	ELifecycleStage GetLifecycleStage() const
	{
		return m_LifecycleStage;
	}

	Object GetContext() const
	{
		return m_Context;
	}

	string GetLifecycleStageName() const
	{
		switch (m_LifecycleStage)
		{
			case UNINITIALIZED:
				return "Uninitialized";
			case PENDING_ACTIVATION:
				return "PendingActivation";
			case ACTIVE:
				return "Active";
			case PENDING_REMOVAL:
				return "PendingRemoval";
			default:
				return "";
		}
	}

	void Init(Object context)
	{
		m_Context = context;

		m_StateMachine = CreateHUDStateMachine();
		m_StateMachine.m_Data = self;
		m_StateMachine.CallBuild();

		Setup();
		QueueActivate();
	}

	void CallTick()
	{
		if (m_LifecycleStage != ACTIVE) return;

		Tick();
		m_StateMachine.Update();
	}

	void QueueActivate()
	{
		SendEventToSM('QueueActivate');
		m_LifecycleStage = PENDING_ACTIVATION;
	}

	void Activate()
	{
		if (m_LifecycleStage != PENDING_ACTIVATION)
		{
			ThrowAbortException("Attempted to activate HUD extension at lifecycle stage %s." , GetLifecycleStageName());
		}
		m_LifecycleStage = ACTIVE;
		m_StateMachine.Start();
	}

	void Remove()
	{
		m_LifecycleStage = PENDING_REMOVAL;
		m_StateMachine.Shutdown();
	}

	void SendEventToSM(name eventId)
	{
		m_StateMachine.SendEvent(eventId);
	}

	ui void CallDraw(RenderEvent event)
	{
		if (m_LifecycleStage != ACTIVE) return;

		// A little sloppy, but it can't be helped.
		if (!m_IsUISetUp)
		{
			UISetup();
			m_IsUISetUp = true;
		}

		PreDraw(event);
		Draw(event);
		PostDraw(event);
	}
}

class SMHUDState : SMState abstract
{
	virtual ui void PreDraw(RenderEvent event) { }
	virtual ui void Draw(RenderEvent event) { }
	virtual ui void PostDraw(RenderEvent event) { }

	HUDExtension GetHUDExtension() const
	{
		return HUDExtension(GetData());
	}

	PlayerInfo GetPlayerInfo() const
	{
		return players[consoleplayer];
	}

	ui void CallPreDraw(RenderEvent event)
	{
		if (GetActiveChild() is "SMHUDState")
		{
			SMHUDState(GetActiveChild()).CallPreDraw(event);
		}
		PreDraw(event);
	}

	ui void CallDraw(RenderEvent event)
	{
		if (GetActiveChild() is "SMHUDState")
		{
			SMHUDState(GetActiveChild()).CallDraw(event);
		}
		Draw(event);
	}

	ui void CallPostDraw(RenderEvent event)
	{
		if (GetActiveChild() is "SMHUDState")
		{
			SMHUDState(GetActiveChild()).CallPostDraw(event);
		}
		PostDraw(event);
	}
}

class SMHUDActivating : SMHUDState
{
	override void EnterState()
	{
		GetHUDExtension().OnActivate();
	}
}

class SMHUDActive : SMHUDState
{
}

class SMHUDDeactivating : SMHUDState
{
	override void EnterState()
	{
		GetHUDExtension().OnDeactivate();
	}
}

class SMHUDRemoved : SMHUDState
{
	override void EnterState()
	{
		GetHUDExtension().Remove();
	}
}

class SMHUDMachine : SMMachine
{
	override void Build()
	{
		AddChild(new("SMHUDRemoved"));
		AddChild(new("SMHUDActivating"));
		AddChild(new("SMHUDActive"));
		AddChild(new("SMHUDDeactivating"));

		AddTransition(new("SMTransition")
			.From("SMHUDRemoved")
			.To("SMHUDActivating")
			.On('QueueActivate')
		);
		AddTransition(new("SMTransition")
			.From("SMHUDActivating")
			.To("SMHUDActive")
			.On('ActivationComplete')
		);
		AddTransition(new("SMTransition")
			.From("SMHUDActive")
			.To("SMHUDDeactivating")
			.On('Deactivate')
		);
		AddTransition(new("SMTransition")
			.From("SMHUDDeactivating")
			.To("SMHUDRemoved")
			.On('DeactivationComplete')
		);
	}

	SMHUDActivating GetHUDActivatingState() const
	{
		return SMHUDActivating(GetChild("SMHUDActivating"));
	}

	SMHUDActive GetHUDActiveState() const
	{
		return SMHUDActive(GetChild("SMHUDActive"));
	}

	SMHUDDeactivating GetHUDDeactivatingState() const
	{
		return SMHUDDeactivating(GetChild("SMHUDDeactivating"));
	}

	ui void PreDraw(RenderEvent event)
	{
		SMHUDState activeChild = SMHUDState(GetActiveChild());
		if (activeChild) activeChild.CallPreDraw(event);
	}

	ui void Draw(RenderEvent event)
	{
		SMHUDState activeChild = SMHUDState(GetActiveChild());
		if (activeChild) activeChild.CallDraw(event);
	}

	ui void PostDraw(RenderEvent event)
	{
		SMHUDState activeChild = SMHUDState(GetActiveChild());
		if (activeChild) activeChild.CallPostDraw(event);
	}
}