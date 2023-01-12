/**
 * An event handler that spawns and holds a reference to a single Agent instance
 * that can be retrieved and used instead of spawning new Agents.
 *
 * NOTE:
 *		Several other utility classes make use of the world Agent. Exercise
 *		caution when stripping this from the library.
**/
class WorldAgentHandler : EventHandler
{
	private Agent m_WorldAgent;

	override void WorldLoaded(WorldEvent e)
	{
		m_WorldAgent = Agent(Actor.Spawn("Agent"));
	}

	/**
	 * Returns a reference to this handler's Agent.
	**/
	static Agent GetWorldAgent()
	{
		return GetInstance().m_WorldAgent;
	}

	private static WorldAgentHandler GetInstance()
	{
		return WorldAgentHandler(EventHandler.Find("WorldAgentHandler"));
	}
}