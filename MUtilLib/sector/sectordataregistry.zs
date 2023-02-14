/** Holds computed data from select sectors. **/
class SectorDataRegistry : EventHandler
{
	private array<SectorTriangulation> m_Triangulations;

	// override void WorldLoaded(WorldEvent e)
	// {
	// 	// GetInstance().TryTriangulateAllSectors();
	// }

	/** Returns a SectorTriangulation for a given sector. **/
	static SectorTriangulation GetTriangulation(Sector sec)
	{
		SectorDataRegistry instance = GetInstance();

		SectorTriangulation result = null;
		foreach (triangulation : instance.m_Triangulations)
		{
			if (triangulation.GetSector() == sec) result = triangulation;
		}

		if (!result)
		{
			result = SectorTriangulation.TriangulateSector(sec);
		}

		if (result)
		{
			instance.m_Triangulations.Push(result);
		}
		else
		{
			Console.Printf("Sector %i could not be triangulated, possibly due to ill-formed geometry.", sec.Index());
		}
		return result;
	}

	private void TryTriangulateAllSectors()
	{
		let instance = GetInstance();

		// Sectors already triangulated.
		if (instance.m_Triangulations.Size() > 0) return;

		array<DelaunayTriangle> levelTriangulation;

		LevelUtil.TriangulateLevel(levelTriangulation);

		// Assign triangles to sectors.
		Map<int, SectorTriangulation> sectorTriangulations;

		for (int i = levelTriangulation.Size() - 1; i >= 0; --i)
		{
			DelaunayTriangle triangle = levelTriangulation[i];

			vector2 centroid = triangle.Centroid().ToVector2();
			Sector sec = level.PointInSector(centroid);

			// Remove triangles outside level.
			double z = sec.floorplane.ZatPoint(centroid) + TriangulationUtil.EPSILON;
				
			if (!sec || !level.IsPointInLevel((centroid, z))) continue;

			SectorTriangulation secTriangulation;
			if (!sectorTriangulations.CheckKey(sec.Index()))
			{
				secTriangulation = SectorTriangulation.Create(sec);
				sectorTriangulations.Insert(sec.Index(), secTriangulation);
				secTriangulation.AddTriangle(triangle);
			}
			else
			{
				secTriangulation = sectorTriangulations.Get(sec.Index());
				secTriangulation.AddTriangle(triangle);
			}
		}

		MapIterator<int, SectorTriangulation> iter;
		iter.Init(sectorTriangulations);

		while (iter.Next())
		{
			SectorTriangulation triangulation = iter.GetValue();
			triangulation.RecalculateArea();
			triangulation.RecalculateDistribution();
			instance.m_Triangulations.Push(triangulation);
		}
	}

	private static SectorDataRegistry GetInstance()
	{
		return SectorDataRegistry(EventHandler.Find("SectorDataRegistry"));
	}
}