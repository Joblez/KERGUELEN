/** Contains utilities for sectors. **/
class SectorUtil play
{
	/**
	 * Returns a vertex from one of the sector's lines with the given index,
	 * or null if no matching vertex can be found.
	**/
	static Vertex FindVertex(int index, Sector sec)
	{
		if (index < 0) ThrowAbortException("Cannot find vertex with negative index.");
		for (int i = 0; i < sec.lines.Size(); ++i)
		{
			Line l = sec.lines[i];
			if (l.v1.Index() == index) return l.v1;
			if (l.v2.Index() == index) return l.v2;
		}
		return null;
	}

	/** Returns a random point within the given sector's area. **/
	static vector2 GetRandomPoint(Sector sec)
	{
		return SectorDataRegistry.GetTriangulation(sec).GetRandomPoint();
	}
}