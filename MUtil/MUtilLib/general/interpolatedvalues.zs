/**
 * Represents a float that interpolates to a target value over time.
**/
// class InterpolatedFloat
// {
// 	/** The end value of this InterpolatedFloat. **/
// 	float m_Target;

// 	/**
// 	 * The period of time over which this InterpolatedFloat will interpolate
// 	 * towards its target.
// 	**/
// 	float m_SmoothTime;

// 	private float m_Current;
// 	private float m_CurrentSpeed;

// 	/** Returns the current value of this InterpolatedFloat. **/
// 	float GetValue() const { return m_Current; }

// 	/**
// 	 * Returns a string representation of this InterpolatedFloat.
// 	 *
// 	 * Parameters:
// 	 * - precision: The amount of decimal places to truncate the resulting numbers to.
// 	**/
// 	string ToString(int precision = 6) const
// 	{
// 		return "Current: "..ToStr.Float(m_Current, precision)
// 			.."\nTarget: "..ToStr.Float(m_Target, precision);
// 	}

// 	/**
// 	 * Advances the interpolation of this InterpolatedFloat by the given time delta.
// 	 *
// 	 * NOTE:
// 	 * 	For many use cases this will likely be called every tic, which is why the default
// 	 * 	value of delta is 1 / 35.
// 	**/
// 	void Update(float delta = 1.f / 35.f) // TODO: Figure out why the compiler doesn't like this method.
// 	{
// 		m_Current = Mathf.SmoothDamp(
// 			m_Current,
// 			m_Target,
// 			m_CurrentSpeed,
// 			m_SmoothTime,
// 			float.Infinity,
// 			delta);
// 	}

// 	/**
// 	 * Forces the value of this InterpolatedFloat to be set to the given value immediately.
// 	 *
// 	 * NOTE: This is an advanced use case.
// 	**/
// 	void ForceSet(float value)
// 	{
// 		m_Target = value;
// 		m_Current = value;
// 		m_CurrentSpeed = 0.0;
// 	}

// 	/** Resets the end value of this InterpolatedFloat to zero. **/
// 	void Reset() { m_Target = 0.0; }

// 	/** Resets the value of this InterpolatedFloat immediately. **/
// 	void HardReset() { ForceSet(0.0); }
// }

/**
 * Represents a double that interpolates to a target value over time.
**/
class InterpolatedDouble
{
	/** The end value of this InterpolatedDouble. **/
	double m_Target;

	/**
	 * The period of time over which this InterpolatedDouble will interpolate
	 * towards its target.
	**/
	double m_SmoothTime;

	private double m_Current;
	private double m_CurrentSpeed;

	/** Returns the current value of this InterpolatedDouble. **/
	double GetValue() const { return m_Current; }

	/**
	 * Returns a string representation of this InterpolatedDouble.
	 *
	 * Parameters:
	 * - precision: The amount of decimal places to truncate the resulting numbers to.
	**/
	string ToString(int precision = 6) const
	{
		return "Current: "..ToStr.Double(m_Current, precision)
			.."\nTarget: "..ToStr.Double(m_Target, precision);
	}

	/**
	 * Advances the interpolation of this InterpolatedDouble by the given time delta.
	 *
	 * NOTE:
	 * 	For many use cases this will likely be called every tic, which is why the default
	 * 	value of delta is 1 / 35.
	**/
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

	/**
	 * Forces the value of this InterpolatedDouble to be set to the given value immediately.
	 *
	 * NOTE: This is an advanced use case.
	**/
	void ForceSet(double value)
	{
		m_Target = value;
		m_Current = value;
		m_CurrentSpeed = 0.0;
	}

	/** Resets the end value of this InterpolatedDouble to zero. **/
	void Reset() { m_Target = 0.0; }

	/** Resets the value of this InterpolatedDouble immediately. **/
	void HardReset() { ForceSet(0.0); }
}

/**
 * Represents a two-component vector that interpolates to a target value over time.
**/
class InterpolatedVector2
{
	/** The end value of this InterpolatedVector2. **/
	vector2 m_Target;

	/**
	 * The period of time over which this InterpolatedVector2 will interpolate
	 * towards its target.
	**/
	double m_SmoothTime;

	private vector2 m_Current;
	private vector2 m_CurrentSpeed;

	/** Returns the current value of this InterpolatedVector2. **/
	vector2 GetValue() const { return m_Current; }

	/** Returns the X-component of the current value of this InterpolatedVector2. **/
	double GetX() const { return m_Current.x; }

	/** Returns the Y-component of the current value of this InterpolatedVector2. **/
	double GetY() const { return m_Current.y; }

	/**
	 * Returns a string representation of this InterpolatedVector2.
	 *
	 * Parameters:
	 * - precision: The amount of decimal places to truncate the resulting numbers to.
	**/
	string ToString(int precision = 6) const
	{
		return "Current: "..ToStr.Vec2(m_Current, precision)
			.."\nTarget: "..ToStr.Vec2(m_Target, precision);
	}

	/**
	 * Advances the interpolation of this InterpolatedVector2 by the given time delta.
	 *
	 * NOTE:
	 * 	For many use cases this will likely be called every tic, which is why the default
	 * 	value of delta is 1 / 35.
	**/
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

	/**
	 * Forces the value of this InterpolatedVector2 to be set to the given value immediately.
	 *
	 * NOTE: This is an advanced use case.
	**/
	void ForceSet(vector2 value)
	{
		m_Target = value;
		m_Current = value;
		m_CurrentSpeed = Vec2Util.Zero();
	}

	/** Resets the end value of this InterpolatedVector2 to zero. **/
	void Reset()
	{
		m_Target = (0, 0);
	}

	/** Resets the value of this InterpolatedVector2 immediately. **/
	void HardReset()
	{
		m_Target = (0, 0);
		m_Current = (0, 0);
	}
}

/**
 * Represents a three-component vector that interpolates to a target value over time.
**/
class InterpolatedVector3
{
	/** The end value of this InterpolatedVector3. **/
	vector3 m_Target;

	/**
	 * The period of time over which this InterpolatedVector3 will interpolate
	 * towards its target.
	**/
	double m_SmoothTime;

	private vector3 m_Current;
	private vector3 m_CurrentSpeed;

	/** Returns the current value of this InterpolatedVector3. **/
	vector3 GetValue() const { return m_Current; }

	/** Returns the X-component of the current value of this InterpolatedVector3. **/
	double GetX() const { return m_Current.x; }

	/** Returns the Y-component of the current value of this InterpolatedVector3. **/
	double GetY() const { return m_Current.y; }

	/** Returns the Z-component of the current value of this InterpolatedVector3. **/
	double GetZ() const { return m_Current.z; }

	/**
	 * Returns a string representation of this InterpolatedVector3.
	 *
	 * Parameters:
	 * - precision: The amount of decimal places to truncate the resulting numbers to.
	**/
	string ToString(int precision = 6) const
	{
		return "Current: "..ToStr.Vec3(m_Current, precision)
			.."\nTarget: "..ToStr.Vec3(m_Target, precision);
	}

	/**
	 * Advances the interpolation of this InterpolatedVector3 by the given time delta.
	 *
	 * NOTE:
	 * 	For many use cases this will likely be called every tic, which is why the default
	 * 	value of delta is 1 / 35.
	**/
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

	/**
	 * Forces the value of this InterpolatedVector3 to be set to the given value immediately.
	 *
	 * NOTE: This is an advanced use case.
	**/
	void ForceSet(vector3 value)
	{
		m_Target = value;
		m_Current = value;
		m_CurrentSpeed = Vec3Util.Zero();
	}

	/** Resets the end value of this InterpolatedVector3 to zero. **/
	void Reset()
	{
		m_Target = (0, 0, 0);
	}

	/** Resets the value of this InterpolatedVector3 immediately. **/
	void HardReset()
	{
		m_Target = (0, 0, 0);
		m_Current = (0, 0, 0);
	}
}