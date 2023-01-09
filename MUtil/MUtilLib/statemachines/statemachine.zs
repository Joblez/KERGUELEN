// TODO: Document resuming transitions.
/**
 * A one-way connection between two child states of a particular state.
 *
 * Transitions define a target state, or "to" state, an optional origin state, or
 * "from" state, and an optional target state, or "to" state. A transition is triggered
 * when the containing state receives an event that matches the transition's event ID,
 * if it has one, and if the type of the containing state's active child matches the
 * transition's origin state, if it has one. However, transitions must at least have
 * either a trigger event or an origin state.
 *
 * When a transition is successfully performed, the active child of the containing
 * state is exited, and the target state defined by the transition is entered. The
 * target state becomes the contaning state's new active child.
 *
 * As mentioned previously, transitions may choose not to define an origin state.
 * These transitions are known as unbound transitions, and may be performed
 * regardless of which child of the containing state is active. Only one unbound
 * transition for any given event ID may be contained within a state.
 *
 * Additionally, transitions that define origin states may instead choose not to
 * define a trigger event. These are known as live transitions. States containing live
 * transitions will attempt to perform them every time their CallUpdate() method is
 * called. Only one live transition for any given child of a certain state may be
 * contained within said state.
 *
 * Transitions may define a condition to be fulfilled before the transition may
 * be performed. Transitions that are not performed due to their condition not
 * being fulfilled will not cause the event that triggered them to be consumed.
 * Transition conditions are given access to the data object of the machine that
 * owns the containing state, such that they may use this data in the condition
 * logic.
 *
 * Transitions may define custom behavior to be executed upon being performed
 * successfully. This behavior is executed after the containing state's active
 * child is changed, but before the new active child is entered. Transition
 * behaviors are given access to the state that performed the transition, such
 * that they may modify state data or propagate additional events.
 *
 * Ordinarily, the target state's active child is reset to default when a transition
 * is successfully performed. However, transitions may choose to allow the target
 * state to bypass this reset and keep the active hierarchy of its descendants intact.
 * These are known as branch-resuming transitions.
**/
class SMTransition
{
	private name m_EventId;
	private bool m_EventIdSet;

	private bool m_ResumesBranch;
	private bool m_ResumesBranchSet;

	private class<SMState> m_From;
	private bool m_FromSet;

	private class<SMState> m_To;
	private bool m_ToSet;

	/**
	 * Condition to check when attempting to perform this transition. This
	 * method is called from the containing state and should not be used directly.
	 *
	 * The state attempting to perform the transition passes its owning machine's
	 * data object to this method.
	 *
	 * Should return true if the transition should occur, and false otherwise.
	**/
	virtual bool CanPerform(Object data) const
	{
		return true;
	}

	/**
	 * Behavior to execute when this transition is performed. This method is
	 * called from the containing state and should not be used directly.
	 * Transition behaviors are performed after the containing state's active
	 * child has changed.
	 *
	 * The state performing this transition passes itself to this method.
	 *
	 * NOTE:
		* Great care should be taken when propagating events from transition behaviors.
		* The trajectory of any given event moving across the hierarchy may prove
		* difficult to grasp as machines grow in complexity, and transitions are not
		* inherntly aware of the structure of the hierarchy. If in doubt, consider
		* deriving a new transition class for each specific transition that needs custom
		* logic in a given hierarchy.
	**/
	virtual void OnTransitionPerformed(SMState inState) const { }

	/**
	 * Returns the transition's event ID.
	**/
	name GetEventId() const
	{
		return m_EventId;
	}

	/**
	 *	Returns the class of the transition's origin state.
	**/
	class<SMState> GetFrom() const
	{
		return m_From;
	}

	/**
	 * Returns the class of the transition's target state.
	**/
	class<SMState> GetTo() const
	{
		return m_To;
	}

	/**
	 * Returns true if this transition would make the branch resume its prior
	 * state, or false if it would make the branch reset.
	**/
	bool DoesResumeBranch() const
	{
		return m_ResumesBranch;
	}

	// TODO: Document call chain setup syntax.

	SMTransition From(class<SMState> _from)
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

	SMTransition To(class<SMState> _to)
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

	SMTransition On(name eventId)
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

	SMTransition ResumesBranch(bool resumes = true)
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

/**
 * A single unit of logic in a hierarchical finite state machine.
 *
 * States may contain any number of child states, also referred to as branches,
 * and consider only one of these children to be active at any given time.
 * A state that coontains children will define a default child. Typically this is
 * the first child added to the state. 
 *
 * States may define behavior to be executed upon the state initially becoming
 * active, behavior to be executed on demand, and behavior to be executed upon
 * becoming inactive. These are known as entry, update, and exit behaviors
 * respectively. Entry and update behaviors are executed top-to-bottom: the
 * outermost states execute first, while the innermost states execute last.
 * Exit behaviors, however, are executed bottom-to-top.
 *
 * States may also define transitions between children, which change the active
 * child of the state.
 *
 * States may propagate events up and down the hierarchy of active states.
 * Events are defined as simple names. Upon receiving an event, A state may
 * choose to respond by executing custom behavior or performing a transition.
 * Said state may also consume the received event. An event is consumed when
 * the receiving state performs a transition in response, or when the state
 * responds with custom behavior that explicitly declares the event consumed.
 * A state that does not consume a received event via custom behavior may still
 * consume the event by performing a transition. Events that are consumed do
 * not propagate any further.
**/
class SMState
{
	/** This state's parent state. **/
	protected SMState m_Parent;

	/** This state's owning machine. **/
	protected SMMachine m_Machine;

	private class<SMState> m_ActiveChildClass;
	private class<SMState> m_DefaultChildClass;

	private SMState m_ActiveChild;

	private array<SMState> m_Children;
	private array<SMTransition> m_Transitions;

	/** Sets this state's active child back to the default state. **/
	protected void Reset()
	{
		SMState activeChild = m_ActiveChild;
		SMState defaultChild;
		if (m_DefaultChildClass != null) defaultChild = GetChild(m_DefaultChildClass);
		if (defaultChild)
		{
			m_ActiveChildClass = m_DefaultChildClass;
			if (activeChild) activeChild.ExitState();
			m_ActiveChild = defaultChild;
			m_ActiveChild.EnterState();
		}
	}

	/**
	 * The state's entry behavior.
	 *
	 * NOTE:
	 *		Callers should avoid calling this method directly, consider using
	 *		CallEnter() instead.
	**/
	protected virtual void EnterState() { }

	/**
	 * The state's update behavior.
	 *
	 * NOTE:
	 *		Callers should avoid calling this method directly, consider using
	 *		CallUpdate() instead.
	**/
	protected virtual void UpdateState() { }

	/**
	 * The state's exit behavior.
	 *
	 * NOTE:
	 *		Callers should avoid calling this method directly, consider using
	 *		CallExit() instead.
	**/
	protected virtual void ExitState() { }

	/**
	 * Behavior to execute when responding to an event.
	 * Should return true if the event should be consumed, and false otherwise.
	**/
	protected virtual bool TryHandleEvent(name eventId)
	{
		return false;
	}

	/**
	 * Returns the parent state.
	**/
	SMState GetParent() const
	{
		return m_Parent;
	}

	/**
	 * Returns the machine containing this state.
	**/
	SMMachine GetMachine() const
	{
		return m_Machine;
	}

	/**
	 * Returns the child of the given class.
	 * Returns null if no child of the given class is found, or if the given
	 * class is null.
	**/
	SMState GetChild(class<SMState> childClass) const
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

	// TODO: Update GetTransition documentation.
	/**
	 * Returns the transition corresponding to the given event ID and origin state.
	 * If 'None' is provided as an event ID, this method will return the live transition
	 * corresponding to the given origin state. If no origin state is provided, this
	 * method will return the unbound transition corresponding to the given event ID.
	 *
	 * Returns null if no transition with the given ID or origin state is found, or if
	 * the given event ID is 'None' and the given origin state is null.
	**/
	SMTransition GetTransition(name eventId, class<SMState> from) const
	{
		if (eventId == 'None' && from == null) return null;

		for (uint i = 0u; i < m_Transitions.Size(); ++i)
		{
			SMTransition transition = m_Transitions[i];

			// This should catch live or unbound transitions too.
			if (transition.GetEventId() == eventId && transition.GetFrom() == from)
			{
				return transition;
			}
		}

		Console.Printf("State %s does not contain a transition for the %s event "
			.."originating from the %s state.", GetClassName(), eventId, from.GetClassName());
		return null;
	}

	/**
	 * Returns the unbound transition corresponding to the given event ID,
	 * or null if none is found.
	**/
	SMTransition GetUnboundTransition(name eventId) const
	{
		return GetTransition(eventId, null);
	}

	/**
	 * Returns the live transition corresponding to the given origin state,
	 * or null if none is found.
	**/
	SMTransition GetLiveTransition(class<SMState> from) const
	{
		return GetTransition('None', from);
	}

	/**
	 * Returns the active child.
	**/
	SMState GetActiveChild() const
	{
		return m_ActiveChild;
	}

	/**
	 * Returns the class of the active child.
	**/
	class<SMState> GetActiveChildClass() const
	{
		return m_ActiveChildClass;
	}

	/**
	 * Returns the object that this state's containing machine operates upon.
	 * Returns null if this state is not contained within a state machine.
	**/
	Object GetData() const
	{
		if (!m_Machine) return null;
		return m_Machine.m_Data;
	}

	/**
	 * Adds the given child the the array of children.
	 *
	 * Returns itself upon success, so calls to this method can be chained to
	 * other method calls on the same state.
	 * Returns null upon failure.
	**/
	SMState AddChild(SMState newState)
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

		// New state may have descendants, update those as well.
		newState.UpdateHierarchyReferences();

		UpdateDefaultAndActiveStates();
		return self;
	}

	/**
	 * Removes the child of the given class from the array of children, if one
	 * is found.
	 *
	 * Returns itself upon success, so calls to this method can be chained to
	 * other method calls on the same state.
	 * Returns null upon failure.
	**/
	SMState RemoveChild(class<SMState> childClass)
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
						// Active child will be removed, fall back to default.
						PerformTransition(new("SMTransition")
							.From(m_ActiveChildClass).To(m_DefaultChildClass));
					}
					else
					{
						// Default child will be removed, make it exit.
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

	// TODO: Update AddTransition documentation.
	/**
	 * Adds the given transition to the transition array, if there are no other
	 * transitions in the list with the same event ID corresponding to the same
	 * origin state, or if there are no unbound transitions with the same ID.
	 *
	 * Returns itself upon success, so calls to this method can be chained to
	 * other method calls on the same state.
	 * Returns null upon failure.
	**/
	SMState AddTransition(SMTransition newTransition)
	{
		if (newTransition.GetEventID() == 'None' && newTransition.GetFrom() == null)
		{
			ThrowAbortException("Transitions may not be both live and unbound.");
		}
		for (uint i = 0u; i < m_Transitions.Size(); ++i)
		{
			SMTransition transition = m_Transitions[i];

			// This should catch live or unbound transitions too.
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

	// TODO: Update RemoveTransition documentation.
	/**
	 * Removes the transition with the given event ID and origin state from the
	 * transition array, or the unbound transition with the given event ID,
	 * if one is found.
	 *
	 * Returns itself upon success, so calls to this method can be chained to
	 * other method calls on the same state.
	 * Returns null upon failure.
	**/
	SMState RemoveTransition(name eventId, class<SMState> from)
	{
		if (eventId == 'None' && from == null)
		{
			Console.Printf("Either a valid event ID or a valid origin state must be specified.");
			return null;
		}
		for (uint i = 0u; i < m_Transitions.Size(); ++i)
		{
			SMTransition transition = m_Transitions[i];

			// This should catch live or unbound transitions too
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

	/**
	 * Removes the live transition with the given origin state from this
	 * state's transitions.
	**/
	SMState RemoveLiveTransition(class<SMState> from)
	{
		if (from == null)
		{
			Console.Printf("Origin state is null.");
			return null;
		}
		return RemoveTransition('None', from);
	}

	/**
	 * Removes the unbound transition with the given trigger event from this
	 * state's transitions.
	**/
	SMState RemoveUnboundTransition(name eventId)
	{
		if (eventId == 'None')
		{
			Console.Printf("Event ID is None.");
			return null;
		}
		return RemoveTransition(eventId, null);
	}

	/**
	 * Sets the child that the state will transition to by default when the active
	 * child is removed.
	 *
	 * NOTE: This may only be called from within the owning machine's Build() method.
	**/
	protected SMState SetDefaultChild(class<SMState> newDefault)
	{
		if (!IsBuilding())
		{
			ThrowAbortException("Default child may not be explicitly set outside of the machine's Build method.");
		}

		m_DefaultChildClass = newDefault;
		return self;
	}

	/**
	 * Inserts all of the state's children into the given array.
	 *
	 * NOTE: This may only be called from within the owning machine's Build() method.
	**/
	protected void GetAllChildren(out array<SMState> stateArray)
	{
		if (!IsBuilding())
		{
			ThrowAbortException("Children must be accessed individually outside of the machine's Build method.");
		}

		stateArray.Copy(m_Children);
	}

	/**
	 * Attempts to consume the given event, and tries to forward the event to
	 * the parent if it cannot.
	 *
	 * Care should be taken to ensure calls to FireEvent() and DrillEvent() do
	 * not result in an infinite loop.
	**/
	void FireEvent(name eventId)
	{
		if (TryConsumeEvent(eventId) || m_Parent == null) return;

		m_Parent.FireEvent(eventId);
	}

	/**
	 * Attempts to consume the given event, and tries to forward the event to
	 * the active child if it cannot.
	 *
	 * Care should be taken to ensure calls to FireEvent() and DrillEvent() do
	 * not result in an infinite loop.
	**/
	void DrillEvent(name eventId)
	{
		if (TryConsumeEvent(eventId) || m_ActiveChild == null) return;

		m_ActiveChild.DrillEvent(eventId);
	}

	/**
	 * Forcibly assigns the given type to be this state's active child, without
	 * performing any transitions.
	 *
	 * NOTE: This is an advanced use case.
	**/
	protected void ForceActiveState(class<SMState> newActiveClass)
	{
		let newActive = GetChild(newActiveClass);
		if (!newActive) ThrowAbortException("Target state does not exist.");

		m_ActiveChildClass = newActiveClass;
		m_ActiveChild = newActive;
	}

	/**
	 * Recursively updates the containing machine and parent references of all
	 * of this state's descendants.
	**/
	protected void UpdateHierarchyReferences()
	{
		for (uint i = 0u; i < m_Children.Size(); ++i)
		{
			SMState child = m_Children[i];
			child.m_Parent = self;
			child.m_Machine = m_Machine;
			m_Children[i].UpdateHierarchyReferences();
		}
	}

	/**
	 * Wrapper around EnterState() to ensure that calls are forwarded to all
	 * active descendants in this state's hierarchy.
	 * States are entered top to bottom.
	**/
	protected void CallEnter()
	{
		EnterState();
		if (m_ActiveChild == null) return;

		m_ActiveChild.CallEnter();
	}

	/**
	 * Wrapper around UpdateState() to ensure that calls are forwarded to all
	 * active descendants in this state's hierarchy.
	 * States are updated top to bottom.
	**/
	protected void CallUpdate()
	{
		UpdateState();
		TryPerformTransition('None'); // Perform any live transitions.
		if (m_ActiveChild == null) return;

		m_ActiveChild.CallUpdate();
	}

	/**
	 * Wrapper around ExitState() to ensure that calls are forwarded to all
	 * active descendants in this state's hierarchy.
	 * States are exited bottom to top.
	**/
	protected void CallExit()
	{
		if (m_ActiveChild != null) m_ActiveChild.CallExit();

		ExitState();
	}

	private bool TryConsumeEvent(name eventId)
	{
		if (eventId == 'None')
		{
			Console.Printf("'None' is not a valid event ID.");
			return false;
		}

		if (TryHandleEvent(eventId) || TryPerformTransition(eventId)) return true;

		return false;
	}

	private bool TryPerformTransition(name eventId)
	{
		for (uint i = 0u; i < m_Transitions.Size(); ++i)
		{
			SMTransition transition = m_Transitions[i];
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

	private void PerformTransition(SMTransition transition)
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
		// No children, clear active and default
		if (m_Children.Size() == 0u)
		{
			m_ActiveChildClass = null;
			m_DefaultChildClass = null;
		}

		// Single child, make it both active and default
		if (m_Children.Size() == 1u)
		{
			m_ActiveChildClass = m_Children[0].GetClass();
			m_DefaultChildClass = m_ActiveChildClass;
		}

		m_ActiveChild = GetChild(m_ActiveChildClass);
	}

	private void CleanTransitions()
	{
		// No children, remove all transitions
		if (m_Children.Size() == 0)
		{
			m_Transitions.Clear();
			return;
		}

		array< class<SMState> > childrenClasses;
		for (uint i = 0; i < m_Children.Size(); ++i)
		{
			childrenClasses.Push(m_Children[i].GetClass());
		}

		uint classCount = childrenClasses.Size();

		// Array will very likely be modified, iterate backwards
		for (int i = m_Transitions.Size() - 1; i >= 0 ; --i)
		{
			// Delete any transitions that reference missing children
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

// TODO: Document SMMachine.
/**
 * A container for a finite hierarchy of states.
**/
class SMMachine : SMState abstract
{
	/**
	 * Data that this state machine operates upon.
	**/
	Object m_Data;

	private bool m_IsActive;
	private bool m_IsBuilding;

	bool IsBuilding() const
	{
		return m_IsBuilding;
	}

	// TODO: Add ToString().

	/**
	 * Defines the hierarchy of this state machine.
	 *
	 * This method should not be called directly. Use CallBuild() instead.
	 *
	 * It is intended that overrides of this method use the hierarchy management
	 * methods from SMState. Many of these methods return themselves, allowing
	 * them to be chained together to define the machine's hierarchy declaratively.
	 *
	 * Derived machine types may also make modifications to the base class's
	 * hierarchy by overriding this method and calling the super implementation
	 * prior to making their own changes.
	 *
	 * Here is an example of a hypothetical complex enemy AI machine:
	 *
	 *	override void Build()
	 *	{
	 *		AddChild(new("SMEnemyNeutral")
	 *			.AddChild(new("SMEnemyIdle")
	 *			)
	 *			.AddChild(new("SMEnemySuspicious")
	 *				.AddChild(new("SMEnemyMovingToDestination")
	 *				)
	 *				.AddChild(new("SMEnemyExaminingSuspiciousArea")
	 *				)
	 *				.AddTransition(new("SMTransition")
	 *					.On('ReachedDestination').From("SMEnemyMovingToDestination").To("SMEnemyExaminingSuspiciousArea")
	 *				)
	 *			)
	 *			.AddTransition(new("SMTransition")
	 *				.To("SMEnemySuspicious")
	 *				.On('DetectedActivity')
	 *				.From("SMEnemyIdle")
	 *			)
	 *			.AddTransition(new("SMTransition")
	 *				.From("SMEnemySuspicious")
	 *				.To("SMEnemyIdle")
	 *				.On('DispelledSuspicion')
	 *				.ResumesBranch()
	 *			)
	 *		);
	 *
	 *		AddChild(new("SMEnemyAlert"));
	 *
	 *		AddTransition(new("SMTransition")
	 *			.On('DetectedThreat').From("SMEnemyIdle").To("SMEnemyAlert")
	 *		);
	 *
	 *		AddChild(new("SMEnemyHostile")
	 *			.AddChild(new("SMEnemyChasing")
	 *			)
	 *			.AddChild(new("SMEnemyAttacking")
	 *			)
	 *			.AddTransition(new("SMEnemyChasingToAttacking")
	 *				.On('PlayerInLineOfSight').From("SMEnemyChasing").To("SMEnemyAttacking")
	 *			)
	 *			.AddTransition(new("SMEnemyAttackingToChasing")
	 *				.On('PlayerOutOfLineOfSight').From("SMEnemyAttacking").To("SMEnemyChasing")
	 *			)
	 *			.AddTransition(new("SMEnemyAttackingToChasing")
	 *				.On('PlayerOutOfAttackRange').From("SMEnemyAttacking").To("SMEnemyChasing")
	 *			)
	 *		);
	 *
	 *		AddTransition(new("SMTransition")
	 *			.On('DetectedPlayer').To(SMEnemyHostile")
	 *		);
	 *		AddTransition(new("SMTransition")
	 *			.On('LostPlayerTrail).From("SMEnemyHostile").To("SMEnemyAlert").ResumesBranch()
	 *		);
	 *	}
	 *
	 * And here is an example of modifying the previous build method in a
	 * derived machine class.
	 *
	 * override void Build()
	 * {
	 *	Super.Build();

	 *	SMState enemySuspiciousState = GetState("SMEnemyNeutral/SMEnemySuspicious");

	 *	enemySuspiciousState
	 *		.RemoveChild("SMEnemyExaminingSuspiciousArea"
	 *		)
	 *		.AddChild(new("SMEnemySettingUpDrone")
	 *		)
	 *		.AddTransition(new("SMTransition").Init(
	 *			'ReachedDestination', "SMEnemyMovingToDestination", "SMEnemySettingUpDrone"
	 *		));
	 * }
	**/
	protected abstract void Build();

	/**
	 * Wrapper around Build() to ensure that references are up to date across
	 * the entire hierarchy.
	**/
	void CallBuild()
	{
		m_IsBuilding = true;
		m_Parent = null;
		m_Machine = self;
		Build();

		// In case nested children are added from within the AddChild call
		// (where m_Machine would still be null).
		UpdateHierarchyReferences();
		m_IsBuilding = false;
	}

	/**
	 * Sends an event down the state hierarchy.
	**/
	void SendEvent(name eventId)
	{
		DrillEvent(eventId);
	}

	/**
	 * Calls the entry methods of the active states in the hierarchy and
	 * enables Update().
	**/
	void Start()
	{
		CallEnter();
		m_IsActive = true;
	}

	/**
	 * Calls the update methods of the active states in the hierarchy.
	 * Enabled by Start(), disabled by Shutdown().
	**/
	void Update()
	{
		if (m_IsActive) CallUpdate();
	}

	/**
	 * Calls the exit methods of the active states in the hierarchy and
	 * disables Update().
	**/
	void Shutdown()
	{
		m_IsActive = false;
		CallExit();
	}

	/**
	 * Looks for a specific state using the given path string.
	 * Path strings must be written as a sequence of class names divided by
	 * forward slashes ("/").
	 *
	 * Returns the state at the end of the path if found.
	 * Returns null if the state cannot be found.
	**/
	SMState GetState(string statePath)
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

	/**
	 * Looks down the hierarchy for a specific state using the given array of
	 * class names as a path.
	 *
	 * Returns the state at the end of the path if found.
	 * Returns itself if the path is empty.
	 * Returns null if the state cannot be found.
	 *
	 * Forces a crash if the given path is null.
	**/
	SMState GetStateFromClasses(array<string> childClasses)
	{
		if (childClasses == null) ThrowAbortException("Array of child classes must not be null.");

		SMState outState = self;
		for (uint i = 0u; i < childClasses.Size(); ++i)
		{
			class<SMState> childClass = childClasses[i];
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
		SMState checkState = self;
		while (checkState != null)
		{
			branch = branch..checkState.GetClassName();
			checkState = checkState.GetActiveChild();
			if (checkState != null) branch = branch.." -> ";
		}
		Console.Printf("Active: %s", branch);
	}
}