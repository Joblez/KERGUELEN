// TODO: Figure out why the compiler hates this one.
// class InterpolatedFloat
// {
// 	float m_Target;
// 	float m_SmoothTime;

// 	private float m_Current;
// 	private float m_CurrentSpeed;

// 	float GetValue() const
// 	{
// 		return m_Current;
// 	}

// 	string ToString(int precision = 6) const
// 	{
// 		return "Current: "..ToStr.Float(m_Current, precision)
// 			.."\nTarget: "..ToStr.Float(m_Target, precision);
// 	}

// 	void Update(double delta = 1.0 / 35.0)
// 	{
// 		m_Current = Mathf.SmoothDamp(
// 			m_Current,
// 			m_Target,
// 			m_CurrentSpeed,
// 			m_SmoothTime,
// 			float.Infinity,
// 			delta);
// 	}

// 	void Reset()
// 	{
// 		m_Target = 0;
// 	}

// 	void HardReset()
// 	{
// 		m_Target = 0;
// 		m_Current = 0;
// 	}
// }

class InterpolatedDouble
{
	double m_Target;
	double m_SmoothTime;

	private double m_Current;
	private double m_CurrentSpeed;

	double GetValue() const
	{
		return m_Current;
	}

	string ToString(int precision = 6) const
	{
		return "Current: "..ToStr.Double(m_Current, precision)
			.."\nTarget: "..ToStr.Double(m_Target, precision);
	}

	void Update(double delta = 1.0 / 35.0)
	{
		m_Current = Math.SmoothDamp(
			m_Current,
			m_Target,
			m_CurrentSpeed,
			m_SmoothTime,
			double.Infinity,
			delta);
	}

	void Reset()
	{
		m_Target = 0;
	}

	void HardReset()
	{
		m_Target = 0;
		m_Current = 0;
	}
}

class InterpolatedVector2
{
	vector2 m_Target;
	double m_SmoothTime;

	private vector2 m_Current;
	private vector2 m_CurrentSpeed;

	vector2 GetValue() const
	{
		return m_Current;
	}

	double GetX() const
	{
		return m_Current.x;
	}

	double GetY() const
	{
		return m_Current.y;
	}

	string ToString(int precision = 6) const
	{
		return "Current: "..ToStr.Vec2(m_Current, precision)
			.."\nTarget: "..ToStr.Vec2(m_Target, precision);
	}

	void Update(double delta = 1.0 / 35.0)
	{
		m_Current = MathVec2.SmoothDamp(
			m_Current,
			m_Target,
			m_CurrentSpeed,
			m_SmoothTime,
			double.Infinity,
			delta);
	}

	void Reset()
	{
		m_Target = (0, 0);
	}

	void HardReset()
	{
		m_Target = (0, 0);
		m_Current = (0, 0);
	}
}

class InterpolatedVector3
{
	vector3 m_Target;
	double m_SmoothTime;

	private vector3 m_Current;
	private vector3 m_CurrentSpeed;

	vector3 GetValue() const
	{
		return m_Current;
	}

	double GetX() const
	{
		return m_Current.x;
	}

	double GetY() const
	{
		return m_Current.y;
	}

	double GetZ() const
	{
		return m_Current.z;
	}

	string ToString(int precision = 6) const
	{
		return "Current: "..ToStr.Vec3(m_Current, precision)
			.."\nTarget: "..ToStr.Vec3(m_Target, precision);
	}

	void Update(double delta = 1.0 / 35.0)
	{
		m_Current = MathVec3.SmoothDamp(
			m_Current,
			m_Target,
			m_CurrentSpeed,
			m_SmoothTime,
			double.Infinity,
			delta);
	}

	void Reset()
	{
		m_Target = (0, 0, 0);
	}

	void HardReset()
	{
		m_Target = (0, 0, 0);
		m_Current = (0, 0, 0);
	}
}