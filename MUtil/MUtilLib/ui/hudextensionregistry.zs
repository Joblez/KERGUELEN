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

	static void AddExtension(HUDExtension extension)
	{
		GetInstance().AddExtensionEntry(consolePlayer, extension);
	}

	static void SendHUDEvent(name eventId)
	{
		EventHandler.SendNetworkEvent("SendHUDEvent:"..eventId);
	}

	static void RemoveExtension(HUDExtension extension)
	{
		GetInstance().TryStartRemovingExtension(extension);
	}

	protected void AddExtensionEntry(int registrant, HUDExtension extension)
	{
		extension.QueueActivate();
		let entry = CreateEntry(registrant, extension);
		m_Entries.Push(entry);
	}

	protected void TryStartRemovingExtension(HUDExtension extension)
	{
		for (uint i = m_Entries.Size(); i > 0; --i)
		{
			uint index = i - 1;
			if (m_Entries[index].m_Extension == extension)
			{
				m_Entries[index].SendEvent('Deactivate');
			}
		}
	}

	private static HUDExtensionRegistry GetInstance()
	{
		return HUDExtensionRegistry(EventHandler.Find("HUDExtensionRegistry"));
	}

	private static HUDExtensionEntry CreateEntry(int registrant, HUDExtension extension)
	{
		let entry = new("HUDExtensionEntry");
		entry.m_Registrant = registrant;
		entry.m_Extension = extension;

		return entry;
	}
}

class HUDExtensionEntry
{
	int m_Registrant;
	HUDExtension m_Extension;

	void SendEvent(name eventId)
	{
		m_Extension.SendEventToSM(eventId);
	}
}