class SectorDataRegistry : EventHandler
{
	const TRIANGULATION_TAG = 3560;

	private array<SectorTriangulation> m_Triangulations;

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

	override void WorldLoaded(WorldEvent e)
	{
		TriangulateTaggedSectors();

		for (int i = 0; i < m_Triangulations.Size(); ++i)
		{
			SectorTriangulation triangulation = m_Triangulations[i];
			Console.Printf("Sector: %i, Triangles: %i",
				triangulation.GetSector().Index(), triangulation.GetTriangleCount());
		}
	}

	void TriangulateTaggedSectors()
	{
		let iterator = Level.CreateSectorTagIterator(TRIANGULATION_TAG);
		int i;

		while ((i = iterator.Next()) >= 0)
		{
			Sector sec = Level.Sectors[i];

			let triangulation = SectorTriangulation.Create(sec);
			m_Triangulations.Push(triangulation);
			i = iterator.Next();
		}
	}

	private static SectorDataRegistry GetInstance()
	{
		return SectorDataRegistry(EventHandler.Find("SectorDataRegistry"));
	}
}