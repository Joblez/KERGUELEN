class HUDExtensionRegistry : EventHandler
{
	private int m_CurrentID;
	private array<HUDExtensionEntry> m_Entries;

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.IsManual
		|| e.Player < 0
		|| !(players[e.Player].mo)
		|| e.Player != consolePlayer)
		{
			return;
		}

		array<string> stringArgEvent;
		e.Name.Split(stringArgEvent, ":");

		// Can't switch on strings :(
		if (stringArgEvent[0] == "SendHUDEvent")
		{
			name eventId = stringArgEvent[1];

			for (uint i = 0; i < m_Entries.Size(); ++i)
			{
				if (m_Entries[i].m_Registrant == e.Player)
				{
					m_Entries[i].SendEvent(eventId);
				}
			}
		}
		else if (stringArgEvent[0] == "SendEventToExtension")
		{
			name eventId = stringArgEvent[1];
			int extensionId = e.Args[0];

			for (uint i = 0; i < m_Entries.Size(); ++i)
			{
				if (m_Entries[i].m_Registrant == e.Player && m_Entries[i].m_ID == extensionId)
				{
					m_Entries[i].SendEvent(eventId);
				}
			}
		}
	}

	override void RenderUnderlay(RenderEvent e)
	{
		for (uint i = 0; i < m_Entries.Size(); ++i)
		{
			if (m_Entries[i].m_Registrant != consolePlayer) continue;

			HUDExtension extension = m_Entries[i].m_Extension;
			if (extension.GetLifecycleStage() == HUDExtension.ACTIVE)
			{
				extension.CallDraw(e);
			}
		}
	}

	override void WorldTick()
	{
		// Iterate backwards in case entries need to be removed.
		for (uint i = m_Entries.Size(); i > 0; --i)
		{
			uint index = i - 1;
			if (m_Entries[index].m_Registrant == consolePlayer)
			{
				HUDExtension extension = m_Entries[index].m_Extension;
				switch (extension.GetLifecycleStage())
				{
					case HUDExtension.PENDING_ACTIVATION:
						extension.Activate();
						break;

					case HUDExtension.ACTIVE:
						extension.CallTick();
						break;

					case HUDExtension.PENDING_REMOVAL:
						m_Entries.Delete(index);
						break;

					default:
						break;
				}
			}
		}
	}

	static int AddExtension(Object context, class<HUDExtension> type)
	{
		return GetInstance().AddExtensionEntry(context, consolePlayer, type);
	}

	static void SendHUDEvent(name eventId)
	{
		EventHandler.SendNetworkEvent("SendHUDEvent:"..eventId);
	}

	static void SendEventToExtension(name eventId, int extensionId)
	{
		EventHandler.SendNetworkEvent("SendEventToExtension:"..eventId, extensionId);
	}

	static void RemoveExtension(int id)
	{
		GetInstance().TryStartRemovingExtension(id);
	}

	protected int AddExtensionEntry(Object context, int registrant, class<HUDExtension> type)
	{
		m_CurrentID++;
		let entry = CreateEntry(m_CurrentID, context, registrant, type);
		m_Entries.Push(entry);

		return entry.m_ID;
	}

	protected void TryStartRemovingExtension(int id)
	{
		for (uint i = m_Entries.Size(); i > 0; --i)
		{
			uint index = i - 1;
			if (m_Entries[index].m_ID == id)
			{
				m_Entries[index].SendEvent('Deactivate');
			}
		}
	}

	private static HUDExtensionRegistry GetInstance()
	{
		return HUDExtensionRegistry(EventHandler.Find("HUDExtensionRegistry"));
	}

	private static HUDExtensionEntry CreateEntry(int id, Object context, int registrant, class<HUDExtension> type)
	{
		let entry = new("HUDExtensionEntry");
		let extension = HUDExtension(new(type));
		extension.Init(context);

		entry.m_ID = id;
		entry.m_Registrant = registrant;
		entry.m_Extension = extension;

		return entry;
	}
}

class HUDExtensionEntry
{
	int m_ID;
	int m_Registrant;
	HUDExtension m_Extension;

	void SendEvent(name eventId)
	{
		m_Extension.SendEventToSM(eventId);
	}
}