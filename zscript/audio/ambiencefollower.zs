class AmbienceFollower
{
	vector3 m_Position;
	SectorTriangle m_Triangle;

	static AmbienceFollower Create(SectorTriangle triangle)
	{
		AmbienceFollower follower = new("AmbienceFollower");

		follower.m_Triangle = triangle;

		vector2 point = triangle.GetCentroid();
		follower.m_Position = (point, triangle.GetSector().LowestFloorAt(point));

		return follower;
	}
}