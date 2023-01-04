class SectorDataRegistry : EventHandler
{
	private array<SectorTriangulation> m_Triangulations;

	/** Returns a SectorTriangulation for a given sector. **/
	static SectorTriangulation GetTriangulation(Sector sec)
	{
		SectorDataRegistry instance = GetInstance();

		SectorTriangulation triangulation;
		for (int i = 0; i < instance.m_Triangulations.Size(); ++i)
		{
			triangulation = instance.m_Triangulations[i];
			if (triangulation.GetSector() == sec) return triangulation;
		}

		triangulation = SectorTriangulation.Create(sec);
		instance.m_Triangulations.Push(triangulation);
		return triangulation;
	}

	private static SectorDataRegistry GetInstance()
	{
		return SectorDataRegistry(EventHandler.Find("SectorDataRegistry"));
	}
}