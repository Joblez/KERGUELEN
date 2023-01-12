/** Represents a matrix with two rows and two columns. **/
struct Matrix2x2
{
	/** The values contained in this matrix. **/
	double[2][2] m_Values;

	/** Returns a string representation of this matrix. **/
	string ToString(int precision = 6) const
	{
		return string.Format(
				"⌈%10."..Int(precision).."f %10."..Int(precision)..
			"f⌉\n⌊%10."..Int(precision).."f %10."..Int(precision).."f⌋",
			precision, m_Values[0][0], precision, m_Values[0][1],
			precision, m_Values[1][0], precision, m_Values[1][1]);
	}

	/**
	 * Reassigns all the values of this matrix to form an identity matrix, like so:
	 * ⌈1.0, 0.0⌉
	 * ⌊0.0, 1.0⌋
	**/
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

	/** Copies the values from the given matrix into this matrix. **/
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

	/**
	 * Adds the given matrix to this matrix and assigns the result to the matrix given
	 * in the result argument.
	**/
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

	/**
	 * Subtracts the given matrix from this matrix and assigns the result to the matrix given
	 * in the result argument.
	**/
	void Sub(Matrix2x2 other, out Matrix2x2 result)
	{
		for (int i = 0; i < 2; ++i)
		{
			for (int j = 0; j < 2; ++j)
			{
				result.m_Values[i][j] = m_Values[i][j] - other.m_Values[i][j];
			}
		}
	}

	/**
	 * Multiplies the given matrix by this matrix and assigns the result to the matrix given
	 * in the result argument.
	**/
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

/** Represents a matrix with three rows and three columns. **/
struct Matrix3x3
{
	/** The values contained in this matrix. **/
	double[3][3] m_Values;

	/** Returns a string representation of this matrix. **/
	string ToString(int precision = 6) const
	{
		return string.Format(
				"⌈%10."..Int(precision).."f %10."..Int(precision).."f %10."..Int(precision)..
			"f⌉\n|%10."..Int(precision).."f %10."..Int(precision).."f %10."..Int(precision)..
			"f|\n⌊%10."..Int(precision).."f %10."..Int(precision).."f %10."..Int(precision).."f⌋",
			precision, m_Values[0][0], precision, m_Values[0][1], precision, m_Values[0][2],
			precision, m_Values[1][0], precision, m_Values[1][1], precision, m_Values[1][2],
			precision, m_Values[2][0], precision, m_Values[2][1], precision, m_Values[2][2]);
	}

	/**
	 * Reassigns all the values of this matrix to form an identity matrix, like so:
	 * ⌈1.0, 0.0, 0.0⌉
	 * |0.0, 1.0, 0.0|
	 * ⌊0.0, 0.0, 1.0⌋
	**/
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

	/** Copies the values from the given matrix into this matrix. **/
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

	/**
	 * Adds the given matrix to this matrix and assigns the result to the matrix given
	 * in the result argument.
	**/
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

	/**
	 * Subtracts the given matrix from this matrix and assigns the result to the matrix given
	 * in the result argument.
	**/
	void Sub(Matrix3x3 other, out Matrix3x3 result)
	{
		for (int i = 0; i < 3; ++i)
		{
			for (int j = 0; j < 3; ++j)
			{
				result.m_Values[i][j] = m_Values[i][j] - other.m_Values[i][j];
			}
		}
	}

	/**
	 * Multiplies the given matrix by this matrix and assigns the result to the matrix given
	 * in the result argument.
	**/
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

/** Represents a matrix with four rows and four columns. **/
struct Matrix4x4
{
	/** The values contained in this matrix. **/
	double[4][4] m_Values;

	/** Returns a string representation of this matrix. **/
	string ToString(int precision = 6) const
	{
		return string.Format(
				"⌈%10."..Int(precision).."f %10."..Int(precision).."f %10."..Int(precision).."f %10."..Int(precision)..
			"f⌉\n|%10."..Int(precision).."f %10."..Int(precision).."f %10."..Int(precision).."f %10."..Int(precision)..
			"f|\n|%10."..Int(precision).."f %10."..Int(precision).."f %10."..Int(precision).."f %10."..Int(precision)..
			"f|\n⌊%10."..Int(precision).."f %10."..Int(precision).."f %10."..Int(precision).."f⌋",
			precision, m_Values[0][0], precision, m_Values[0][1], precision, m_Values[0][2], precision, m_Values[0][3],
			precision, m_Values[1][0], precision, m_Values[1][1], precision, m_Values[1][2], precision, m_Values[1][3],
			precision, m_Values[2][0], precision, m_Values[2][1], precision, m_Values[2][2], precision, m_Values[2][3],
			precision, m_Values[3][0], precision, m_Values[3][1], precision, m_Values[3][2], precision, m_Values[3][3]);
	}

	/**
	 * Reassigns all the values of this matrix to form an identity matrix, like so:
	 * ⌈1.0, 0.0, 0.0, 0.0⌉
	 * |0.0, 1.0, 0.0, 0.0|
	 * |0.0, 0.0, 1.0, 0.0|
	 * ⌊0.0, 0.0, 0.0, 1.0⌋
	**/
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

	/** Copies the values from the given matrix into this matrix. **/
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

	/**
	 * Adds the given matrix to this matrix and assigns the result to the matrix given
	 * in the result argument.
	**/
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

	/**
	 * Subtracts the given matrix from this matrix and assigns the result to the matrix given
	 * in the result argument.
	**/
	void Sub(Matrix4x4 other, out Matrix4x4 result)
	{
		for (int i = 0; i < 4; ++i)
		{
			for (int j = 0; j < 4; ++j)
			{
				result.m_Values[i][j] = m_Values[i][j] - other.m_Values[i][j];
			}
		}
	}

	/**
	 * Multiplies the given matrix by this matrix and assigns the result to the matrix given
	 * in the result argument.
	**/
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