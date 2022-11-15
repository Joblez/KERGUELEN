class WorldAgentHandler : EventHandler
{
	private Agent m_WorldAgent;

	override void WorldLoaded(WorldEvent e)
	{
		m_WorldAgent = Agent(Actor.Spawn("Agent"));
	}

	static Agent GetWorldAgent()
	{
		return GetInstance().m_WorldAgent;
	}

	private static WorldAgentHandler GetInstance()
	{
		return WorldAgentHandler(EventHandler.Find("WorldAgentHandler"));
	}
}