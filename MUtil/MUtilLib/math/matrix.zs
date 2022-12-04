struct Matrix2x2
{
	double[2][2] m_Values;

	void MakeIdentity()
	{
		for (int i = 0; i < 2; ++i)
		{
			for (int j = 0; j < 2; ++j)
			{
				m_Values[i][j] = i == j ? 1.0 : 0.0;
			}
		}
	}

	void CopyFrom(Matrix2x2 other)
	{
		for (int i = 0; i < 2; ++i)
		{
			for (int j = 0; j < 2; ++j)
			{
				m_Values[i][j] = other.m_Values[i][j];
			}
		}
	}

	void Add(Matrix2x2 other, out Matrix2x2 result)
	{
		for (int i = 0; i < 2; ++i)
		{
			for (int j = 0; j < 2; ++j)
			{
				result.m_Values[i][j] = m_Values[i][j] + other.m_Values[i][j];
			}
		}
	}

	void Sub(Matrix2x2 other, out Matrix2x2 result)
	{
		for (int i = 0; i < 2; ++i)
		{
			for (int j = 0; j < 2; ++j)
			{
				result.m_Values[i][j] = m_Values[i][j] + other.m_Values[i][j];
			}
		}
	}

	void Mul(Matrix2x2 other, out Matrix2x2 result)
	{
		for (int i = 0; i < 2; ++i)
		{
			for (int j = 0; j < 2; ++j)
			{
				double aggregate = 0;
				for (int k = 0; k < 2; ++k)
				{
					aggregate += m_Values[i][k] * other.m_Values[k][j];
				}
				result.m_Values[i][j] = aggregate;
			}
		}
	}
}

struct Matrix3x3
{
	double[3][3] m_Values;

	void MakeIdentity()
	{
		for (int i = 0; i < 3; ++i)
		{
			for (int j = 0; j < 3; ++j)
			{
				m_Values[i][j] = i == j ? 1.0 : 0.0;
			}
		}
	}

	void CopyFrom(Matrix3x3 other)
	{
		for (int i = 0; i < 3; ++i)
		{
			for (int j = 0; j < 3; ++j)
			{
				m_Values[i][j] = other.m_Values[i][j];
			}
		}
	}

	void Add(Matrix3x3 other, out Matrix3x3 result)
	{
		for (int i = 0; i < 3; ++i)
		{
			for (int j = 0; j < 3; ++j)
			{
				result.m_Values[i][j] = m_Values[i][j] + other.m_Values[i][j];
			}
		}
	}

	void Sub(Matrix3x3 other, out Matrix3x3 result)
	{
		for (int i = 0; i < 3; ++i)
		{
			for (int j = 0; j < 3; ++j)
			{
				result.m_Values[i][j] = m_Values[i][j] + other.m_Values[i][j];
			}
		}
	}

	void Mul(Matrix3x3 other, out Matrix3x3 result)
	{
		for (int i = 0; i < 3; ++i)
		{
			for (int j = 0; j < 3; ++j)
			{
				double aggregate = 0;
				for (int k = 0; k < 3; ++k)
				{
					aggregate += m_Values[i][k] * other.m_Values[k][j];
				}
				result.m_Values[i][j] = aggregate;
			}
		}
	}
}

struct Matrix4x4
{
	double[4][4] m_Values;

	void MakeIdentity()
	{
		for (int i = 0; i < 4; ++i)
		{
			for (int j = 0; j < 4; ++j)
			{
				m_Values[i][j] = i == j ? 1.0 : 0.0;
			}
		}
	}

	void CopyFrom(Matrix4x4 other)
	{
		for (int i = 0; i < 4; ++i)
		{
			for (int j = 0; j < 4; ++j)
			{
				m_Values[i][j] = other.m_Values[i][j];
			}
		}
	}

	void Add(Matrix4x4 other, out Matrix4x4 result)
	{
		for (int i = 0; i < 4; ++i)
		{
			for (int j = 0; j < 4; ++j)
			{
				result.m_Values[i][j] = m_Values[i][j] + other.m_Values[i][j];
			}
		}
	}

	void Sub(Matrix4x4 other, out Matrix4x4 result)
	{
		for (int i = 0; i < 4; ++i)
		{
			for (int j = 0; j < 4; ++j)
			{
				result.m_Values[i][j] = m_Values[i][j] + other.m_Values[i][j];
			}
		}
	}

	void Mul(Matrix4x4 other, out Matrix4x4 result)
	{
		for (int i = 0; i < 4; ++i)
		{
			for (int j = 0; j < 4; ++j)
			{
				double aggregate = 0;
				for (int k = 0; k < 4; ++k)
				{
					aggregate += m_Values[i][k] * other.m_Values[k][j];
				}
				result.m_Values[i][j] = aggregate;
			}
		}
	}
}