// AUTO-GENERATED

/*
┌──────────────────────────────────────────────────────────────────────────────┐
│ These are play-scoped versions of the state machine types found in           │
│ statemachines.zs. Please refer to the aforementioned file for documentation. │
└──────────────────────────────────────────────────────────────────────────────┘
*/

class SMTransitionPlay play
{
	private name m_EventId;
	private bool m_EventIdSet;
	private bool m_ResumesBranch;
	private bool m_ResumesBranchSet;
	private class<SMStatePlay> m_From;
	private bool m_FromSet;
	private class<SMStatePlay> m_To;
	private bool m_ToSet;
	virtual bool CanPerform(Object data) const
	{
		return true;
	}
	virtual void OnTransitionPerformed(SMStatePlay inState) const { }
	name GetEventId() const
	{
		return m_EventId;
	}
	class<SMStatePlay> GetFrom() const
	{
		return m_From;
	}
	class<SMStatePlay> GetTo() const
	{
		return m_To;
	}
	bool DoesResumeBranch() const
	{
		return m_ResumesBranch;
	}
	SMTransitionPlay From(class<SMStatePlay> _from)
	{
		if (m_FromSet)
		{
			Console.Printf("Origin state may only be set once.");
			return self;
		}
		m_From = _from;
		m_FromSet = true;
		return self;
	}
	SMTransitionPlay To(class<SMStatePlay> _to)
	{
		if (m_ToSet)
		{
			Console.Printf("Target state may only be set once.");
			return self;
		}
		m_To = _to;
		m_ToSet = true;
		return self;
	}
	SMTransitionPlay On(name eventId)
	{
		if (m_EventIdSet)
		{
			Console.Printf("Event ID may only be set once.");
			return self;
		}
		m_EventId = eventId;
		m_EventIdSet = true;
		return self;
	}
	SMTransitionPlay ResumesBranch(bool resumes = true)
	{
		if (m_EventIdSet)
		{
			Console.Printf("Branch resuming may only be set once.");
			return self;
		}
		m_ResumesBranch = resumes;
		m_ResumesBranchSet = true;
		return self;
	}
}
class SMStatePlay play
{
	protected SMStatePlay m_Parent;
	protected SMMachinePlay m_Machine;
	private class<SMStatePlay> m_ActiveChildClass;
	private class<SMStatePlay> m_DefaultChildClass;
	private SMStatePlay m_ActiveChild;
	private array<SMStatePlay> m_Children;
	private array<SMTransitionPlay> m_Transitions;
	protected void Reset()
	{
		SMStatePlay activeChild = m_ActiveChild;
		SMStatePlay defaultChild;
		if (m_DefaultChildClass != null) defaultChild = GetChild(m_DefaultChildClass);
		if (defaultChild)
		{
			m_ActiveChildClass = m_DefaultChildClass;
			if (activeChild) activeChild.ExitState();
			m_ActiveChild = defaultChild;
			m_ActiveChild.EnterState();
		}
	}
	protected virtual void EnterState() { }
	protected virtual void UpdateState() { }
	protected virtual void ExitState() { }
	protected virtual bool TryHandleEvent(name eventId)
	{
		return false;
	}
	SMStatePlay GetParent() const
	{
		return m_Parent;
	}
	SMMachinePlay GetMachine() const
	{
		return m_Machine;
	}
	SMStatePlay GetChild(class<SMStatePlay> childClass) const
	{
		if (childClass == null) return null;
		for (uint i = 0u; i < m_Children.Size(); ++i)
		{
			if (m_Children[i].GetClass() == childClass)
			{
				return m_Children[i];
			}
		}
		Console.Printf("State %s does not contain a child of type %s.",
			GetClassName(), childClass.GetClassName());
		return null;
	}
	SMTransitionPlay GetTransition(name eventId, class<SMStatePlay> from) const
	{
		if (eventId == 'None' && from == null) return null;
		for (uint i = 0u; i < m_Transitions.Size(); ++i)
		{
			SMTransitionPlay transition = m_Transitions[i];
			if (transition.GetEventId() == eventId && transition.GetFrom() == from)
			{
				return transition;
			}
		}
		Console.Printf("State %s does not contain a transition for the %s event "
			.."originating from the %s state.", GetClassName(), eventId, from.GetClassName());
		return null;
	}
	SMStatePlay GetActiveChild() const
	{
		return m_ActiveChild;
	}
	class<SMStatePlay> GetActiveChildClass() const
	{
		return m_ActiveChildClass;
	}
	Object GetData() const
	{
		if (!m_Machine) return null;
		return m_Machine.m_Data;
	}
	SMStatePlay AddChild(SMStatePlay newState)
	{
		for (uint i = 0u; i < m_Children.Size(); ++i)
		{
			if (m_Children[i].GetClass() == newState.GetClass())
			{
				Console.Printf("State %s already contains a child of type %s.",
					GetClassName(), newState.GetClassName());
				return null;
			}
		}
		m_Children.Push(newState);
		newState.m_Parent = self;
		newState.m_Machine = m_Machine;
		newState.UpdateHierarchyReferences();
		UpdateDefaultAndActiveStates();
		return self;
	}
	SMStatePlay RemoveChild(class<SMStatePlay> childClass)
	{
		if (childClass == m_DefaultChildClass && m_Children.Size() > 1u)
		{
			Console.Printf("Default child must be removed last.");
			return null;
		}
		for (uint i = 0u; i < m_Children.Size(); ++i)
		{
			if (m_Children[i].GetClass() == childClass)
			{
				if (childClass == m_ActiveChildClass)
				{
					if (childClass != m_DefaultChildClass)
					{
						PerformTransition(new("SMTransitionPlay")
							.From(m_ActiveChildClass).To(m_DefaultChildClass));
					}
					else
					{
						m_Children[i].CallExit();
					}
				}
				RemoveChildByIndex(i);
			}
		}
		Console.Printf("State %s does not contain a child of type %s.",
			GetClassName(), childClass.GetClassName());
		return null;
	}
	SMStatePlay AddTransition(SMTransitionPlay newTransition)
	{
		if (newTransition.GetEventID() == 'None' && newTransition.GetFrom() == null)
		{
			ThrowAbortException("Transitions may not be both live and unbound.");
		}
		for (uint i = 0u; i < m_Transitions.Size(); ++i)
		{
			SMTransitionPlay transition = m_Transitions[i];
			if (transition.GetEventID() == newTransition.GetEventID()
				&& transition.GetFrom() == newTransition.GetFrom())
			{
				if (transition.GetFrom() != null)
				{
					Console.Printf("State %s already contains a transition for the %s event originating from the %s state.",
						GetClassName(),transition.GetEventID(), transition.GetFrom().GetClassName());
				}
				else if (transition.GetEventID() == 'None')
				{
					Console.Printf("State %s already contains a live transition for the "
						.."originating from the %s state.", GetClassName(), transition.GetFrom());
				}
				else
				{
					Console.Printf("State %s already contains an unbound transition for the "
						.."%s event.", GetClassName(), transition.GetEventID());
				}
				return null;
			}
		}
		m_Transitions.Push(newTransition);
		return self;
	}
	SMStatePlay RemoveTransition(name eventId, class<SMStatePlay> from)
	{
		if (eventId == 'None' && from == null)
		{
			Console.Printf("Either a valid event ID or a valid origin state must be specified.");
			return null;
		}
		for (uint i = 0u; i < m_Transitions.Size(); ++i)
		{
			SMTransitionPlay transition = m_Transitions[i];
			if (transition.GetEventID() == eventId && transition.GetFrom() == from)
			{
				m_Transitions.Delete(i);
				return self;
			}
		}
		if (eventId == 'None')
		{
			Console.Printf("State %s does not contain a live transition "
				.."originating from the %s state.", GetClassName(), from.GetClassName());
		}
		else if (from != null)
		{
			Console.Printf("State %s does not contain an unbound "
				.."transition for the %s event.", GetClassName(), eventId);
		}
		else
		{
			Console.Printf("State %s does not contain a transition for the %s event originating from "
				.."the %s state.", GetClassName(), eventId, from.GetClassName());
		}
		return null;
	}
	SMStatePlay RemoveLiveTransition(class<SMStatePlay> from)
	{
		if (from == null)
		{
			Console.Printf("Origin state is null.");
			return null;
		}
		return RemoveTransition('None', from);
	}
	SMStatePlay RemoveUnboundTransition(name eventId)
	{
		if (eventId == 'None')
		{
			Console.Printf("Event ID is None.");
			return null;
		}
		return RemoveTransition(eventId, null);
	}
	protected SMStatePlay SetDefaultChild(class<SMStatePlay> newDefault)
	{
		if (!IsBuilding())
		{
			ThrowAbortException("Default child may not be explicitly set outside of the machine's Build method.");
		}
		m_DefaultChildClass = newDefault;
		return self;
	}
	protected void GetAllChildren(out array<SMStatePlay> stateArray)
	{
		if (!IsBuilding())
		{
			ThrowAbortException("Children must be accessed individually outside of the machine's Build method.");
		}
		stateArray.Copy(m_Children);
	}
	void FireEvent(name eventId)
	{
		if (TryConsumeEvent(eventId) || m_Parent == null) return;
		m_Parent.FireEvent(eventId);
	}
	void DrillEvent(name eventId)
	{
		if (TryConsumeEvent(eventId) || m_ActiveChild == null) return;
		m_ActiveChild.DrillEvent(eventId);
	}
	protected void SetActiveState(class<SMStatePlay> newActiveClass)
	{
		let newActive = GetChild(newActiveClass);
		if (!newActive) ThrowAbortException("Target state does not exist.");
		m_ActiveChildClass = newActiveClass;
		m_ActiveChild = newActive;
	}
	protected void UpdateHierarchyReferences()
	{
		for (uint i = 0u; i < m_Children.Size(); ++i)
		{
			SMStatePlay child = m_Children[i];
			child.m_Parent = self;
			child.m_Machine = m_Machine;
			m_Children[i].UpdateHierarchyReferences();
		}
	}
	protected void CallEnter()
	{
		EnterState();
		if (m_ActiveChild == null) return;
		m_ActiveChild.CallEnter();
	}
	protected void CallUpdate()
	{
		UpdateState();
		TryPerformTransition('None');		if (m_ActiveChild == null) return;
		m_ActiveChild.CallUpdate();
	}
	protected void CallExit()
	{
		if (m_ActiveChild != null) m_ActiveChild.CallExit();
		ExitState();
	}
	private bool TryConsumeEvent(name eventId)
	{
		if (TryHandleEvent(eventId) || TryPerformTransition(eventId)) return true;
		return false;
	}
	private bool TryPerformTransition(name eventId)
	{
		for (uint i = 0u; i < m_Transitions.Size(); ++i)
		{
			SMTransitionPlay transition = m_Transitions[i];
			if (transition.GetEventID() == eventId
				&& (transition.GetFrom() is m_ActiveChildClass || transition.GetFrom() == null)
				&& transition.CanPerform(GetData()))
			{
				PerformTransition(transition);
				return true;
			}
		}
		return false;
	}
	private void RemoveChildByIndex(uint index)
	{
		m_Children[index].RemoveAllChildren();
		m_Children.Delete(index);
		CleanTransitions();
		UpdateDefaultAndActiveStates();
	}
	private void RemoveAllChildren()
	{
		for (uint i = m_Children.Size(); i > 0; --i)
		{
			uint index = i = 1;
			RemoveChildByIndex(index);
		}
	}
	private void PerformTransition(SMTransitionPlay transition)
	{
		m_ActiveChild.CallExit();
		m_ActiveChildClass = transition.GetTo();
		m_ActiveChild = GetChild(m_ActiveChildClass);
		transition.OnTransitionPerformed(self);
		if (transition.DoesResumeBranch())
		{
			m_ActiveChild.EnterState();
		}
		else
		{
			m_ActiveChild.Reset();
			m_ActiveChild.CallEnter();
		}
	}
	private void UpdateDefaultAndActiveStates()
	{
		if (m_Children.Size() == 0u)
		{
			m_ActiveChildClass = null;
			m_DefaultChildClass = null;
		}
		if (m_Children.Size() == 1u)
		{
			m_ActiveChildClass = m_Children[0].GetClass();
			m_DefaultChildClass = m_ActiveChildClass;
		}
		m_ActiveChild = GetChild(m_ActiveChildClass);
	}
	private void CleanTransitions()
	{
		if (m_Children.Size() == 0)
		{
			m_Transitions.Clear();
			return;
		}
		array< class<SMStatePlay> > childrenClasses;
		for (uint i = 0; i < m_Children.Size(); ++i)
		{
			childrenClasses.Push(m_Children[i].GetClass());
		}
		uint classCount = childrenClasses.Size();
		for (int i = m_Transitions.Size() - 1; i >= 0 ; --i)
		{
			if (childrenClasses.Find(m_Transitions[i].GetFrom()) == classCount
				|| childrenClasses.Find(m_Transitions[i].GetTo()) == classCount)
			{
				m_Transitions.Delete(i);
			}
		}
	}
	private bool IsBuilding()
	{
		return m_Machine.IsBuilding();
	}
}
class SMMachinePlay : SMStatePlay abstract
{
	Object m_Data;
	private bool m_IsActive;
	private bool m_IsBuilding;
	bool IsBuilding() const
	{
		return m_IsBuilding;
	}
	protected abstract void Build();
	void CallBuild()
	{
		m_IsBuilding = true;
		m_Parent = null;
		m_Machine = self;
		Build();
		UpdateHierarchyReferences();
		m_IsBuilding = false;
	}
	void SendEvent(name eventId)
	{
		DrillEvent(eventId);
	}
	void Start()
	{
		CallEnter();
		m_IsActive = true;
	}
	void Update()
	{
		if (m_IsActive) CallUpdate();
	}
	void Shutdown()
	{
		m_IsActive = false;
		CallExit();
	}
	SMStatePlay GetState(string statePath)
	{
		uint pathLength = statePath.Length();
		if (pathLength == 0u) return self;
		array<string> pathNodes;
		if (statePath.IndexOf("/") < 0)
		{
			pathNodes.Push(statePath);
		}
		else
		{
			statePath.Split(pathNodes, "/", TOK_SKIPEMPTY);
		}
		return GetStateFromClasses(pathNodes);
	}
	SMStatePlay GetStateFromClasses(array<string> childClasses)
	{
		if (childClasses == null) ThrowAbortException("Array of child classes must not be null.");
		SMStatePlay outState = self;
		for (uint i = 0u; i < childClasses.Size(); ++i)
		{
			class<SMStatePlay> childClass = childClasses[i];
			if (childClass == null)
			{
				Console.Printf("Class name %s is invalid.", childClasses[i]);
				return null;
			}
			outState = outState.GetChild(childClass);
			if (outState == null)
			{
				Console.Printf("State not found.");
				return null;
			}
		}
		return outState;
	}
	void PrintActiveBranch()
	{
		string branch;
		SMStatePlay checkState = self;
		while (checkState != null)
		{
			branch = branch..checkState.GetClassName();
			checkState = checkState.GetActiveChild();
			if (checkState != null) branch = branch.." -> ";
		}
		Console.Printf("Active: %s", branch);
	}
}