enum EButtonEventType
{
	BTEVENT_None,
	BTEVENT_Pressed,
	BTEVENT_Released
}

// TODO: (Maybe?) Document ButtonEventQueue.
class ButtonEventQueue : Thinker
{
	private PlayerPawn m_EventSource;
	private array<int> m_Events;
	private array<int> m_EventTypes;

	private bool m_Initialized;

	private bool m_IsListening;

	ButtonEventQueue Init(PlayerPawn source)
	{
		if (m_Initialized)
		{
			Console.Printf("Button event queue has already been initialized.");
			return self;
		}

		m_EventSource = source;
		m_Initialized = true;
		return self;
	}

	override void Tick()
	{
		if (!m_Initialized || !m_IsListening) return;

		ListenForButtonEvents();
	}

	void StartListening()
	{
		m_IsListening = true;
	}

	void StopListening()
	{
		m_IsListening = false;
	}

	bool IsListening() const
	{
		return m_IsListening;
	}

	int, int TryConsumeEvent()
	{
		if (m_Events.Size() == 0) return 0, 0;

		int event = m_Events[0];
		int eventType = m_EventTypes[0];
		m_Events.Delete(0);
		m_EventTypes.Delete(0);

		return event, eventType;
	}

	static name GetAsString(int event, int type)
	{
		string eventText;
		switch (event)
		{
			case BT_ATTACK:			eventText = eventText.."ATTACK"; break;
			case BT_USE:			eventText = eventText.."USE"; break;
			case BT_JUMP:			eventText = eventText.."JUMP"; break;
			case BT_CROUCH:			eventText = eventText.."CROUCH"; break;
			case BT_TURN180:		eventText = eventText.."TURN180"; break;
			case BT_ALTATTACK:		eventText = eventText.."ALTATTACK"; break;
			case BT_RELOAD:			eventText = eventText.."RELOAD"; break;
			case BT_ZOOM:			eventText = eventText.."ZOOM"; break;
			case BT_SPEED:			eventText = eventText.."SPEED"; break;
			case BT_STRAFE:			eventText = eventText.."STRAFE"; break;
			case BT_MOVERIGHT:		eventText = eventText.."MOVERIGHT"; break;
			case BT_MOVELEFT:		eventText = eventText.."MOVELEFT"; break;
			case BT_BACK:			eventText = eventText.."BACK"; break;
			case BT_FORWARD:		eventText = eventText.."FORWARD"; break;
			case BT_RIGHT:			eventText = eventText.."RIGHT"; break;
			case BT_LEFT:			eventText = eventText.."LEFT"; break;
			case BT_LOOKUP:			eventText = eventText.."LOOKUP"; break;
			case BT_LOOKDOWN:		eventText = eventText.."LOOKDOWN"; break;
			case BT_MOVEUP:			eventText = eventText.."MOVEUP"; break;
			case BT_MOVEDOWN:		eventText = eventText.."MOVEDOWN"; break;
			case BT_SHOWSCORES:		eventText = eventText.."SHOWSCORES"; break;
			case BT_USER1:			eventText = eventText.."USER1"; break;
			case BT_USER2:			eventText = eventText.."USER2"; break;
			case BT_USER3:			eventText = eventText.."USER3"; break;
			case BT_USER4:			eventText = eventText.."USER4"; break;
			case BT_RUN:			eventText = eventText.."RUN"; break;

			default:				eventText = eventText.."None"; break;
		}

		eventText = eventText..", ";

		switch (type)
		{
			case BTEVENT_Pressed:		eventText = eventText.."Pressed"; break;
			case BTEVENT_Released:		eventText = eventText.."Released"; break;
			default:					eventText = eventText.."None"; break;
		}

		return eventText;
	}

	private void ListenForButtonEvents()
	{
		int newButtons = m_EventSource.GetPlayerInput(MODINPUT_BUTTONS);
		int oldButtons = m_EventSource.GetPlayerInput(MODINPUT_OLDBUTTONS);

		uint diff = uint(newButtons ^ oldButtons);
		for (int pos = 0; pos != 32 ; ++pos)
		{
			// Bits set to 1 are the buttons that changed
			if (diff & (1 << pos))
			{
				if (newButtons & (1 << pos))
				{
					QueueEvent(1 << pos, BTEVENT_Pressed);
				}
				else
				{
					QueueEvent(1 << pos, BTEVENT_Released);
				}
			}
		}
	}

	private void QueueEvent(int event, int eventType)
	{
		m_Events.Push(event);
		m_EventTypes.Push(eventType);
	}
}