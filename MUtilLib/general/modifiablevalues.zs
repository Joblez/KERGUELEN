/**
 * The types of modification a modifier can apply to a modifiable value.
 *
 * Modifiers are applied in insertion order. However, all additive modifiers are applied
 * to modifiable values first, then multiplicative ones.
 **/
enum EModifierType
{
	MD_Additive,
	MD_Multiplicative
}

// Only here to not put the ToString for ModifierTypes in one specific modifier class.
class ModifierType
{
	/** Returns the symbol (name) for an EModifierType value as a string. **/
	static string ToString(EModifierType type)
	{
		switch (type)
		{
			case MD_Additive: return "Additive";
			case MD_Multiplicative: return "Multiplicative";
			default:
				ThrowAbortException("Invalid EModifierType.");
				return ""; // Only here so the compiler stops complaining.
		}
	}
}

/** Represents a value that alters the value of a ModifiableFloat. **/
class FloatModifier
{
	/** The ModifiableFloat this modifier is applied to. **/
	ModifiableFloat m_Target;

	private EModifierType m_Type;
	private float m_Value;

	/** Returns the EModifierType of this modifier. **/
	EModifierType GetType() const { return m_Type; }

	/** Returns this modifier's value. **/
	float GetValue() const { return m_Value; }

	/** Returns a string representation of this modifier. **/
	string ToString() const { return string.Format("Type: %s, Value: %f", ModifierType.ToString(m_Type), m_Value); }

	/** Sets the EModifierType of this modifier. **/
	void SetType(EModifierType newType)
	{
		m_Type = newType;
		if (m_Target) m_Target.MarkDirty();
	}

	/** Sets the value of this modifier. **/
	void SetValue(float newValue)
	{
		m_Value = newValue;
		if (m_Target) m_Target.MarkDirty();
	}
}

/** Represents a float that can be altered by modifiers. **/
class ModifiableFloat
{
	private float m_BaseValue;
	private float m_FinalValue;
	private bool m_IsDirty;

	private array<FloatModifier> m_Modifiers;

	/** Returns the base value of this ModifiableFloat. **/
	float GetBaseValue() const { return m_BaseValue; }

	/**
	 * Returns a string representation of this ModifiableFloat.
	 *
	 * Parameters:
	 * - precision: The amount of decimal places to truncate the resulting numbers to.
	**/
	string ToString(int precision = 6) const
	{
		string result =
			"Base value: "..ToStr.Float(m_BaseValue, precision)
		.."\nFinal value: "..ToStr.Float(m_BaseValue, precision);

		if (m_Modifiers.Size() > 0)
		{
			result.AppendFormat("\nModifiers:\n");

			for (int i = 0; i < m_Modifiers.Size(); ++i)
			{
				result.AppendFormat(ToStr.Int(i + 1)..":    "..m_Modifiers[i].ToString().."\n");
			}
		}

		return result;
	}

	/**
	 * Returns the modified value of this ModifiableFloat.
	 *
	 * All changes to ModifiableFloat's state or that of any of its applied modifiers
	 * will be reflected in the value returned by this method.
	**/
	float GetValue()
	{
		if (m_IsDirty) ApplyModifiers();
		return m_FinalValue;
	}

	/** Sets the base value of this ModifiableFloat. **/
	void SetBaseValue(float newValue)
	{
		m_BaseValue = newValue;
		m_IsDirty = true;
	}

	/**
	 * Indicates that the final value for this ModifiableFloat needs to be recalculated.
	 *
	 * NOTE:
	 * 	This is used by modifiers to notify their applied ModifiableFloat whenever their
	 * 	state changes. Normally there should be no need to call this method manually.
	**/
	void MarkDirty()
	{
		m_IsDirty = true;
	}

	/** Applies the given FloatModifier to this ModifiableFloat. **/
	void AddModifier(FloatModifier modifier)
	{
		modifier.m_Target = self;
		m_Modifiers.Push(modifier);
		m_IsDirty = true;
	}

	/** Removes the given FloatModifier from this ModifiableFloat. **/
	void RemoveModifier(FloatModifier modifier)
	{
		uint index = m_Modifiers.Find(modifier);

		if (index != m_Modifiers.Size()) m_Modifiers.Delete(index);
	}

	private void ApplyModifiers()
	{
		m_FinalValue = m_BaseValue;
		for (int i = 0; i < m_Modifiers.Size(); ++i)
		{
			if (m_Modifiers[i].GetType() == MD_Additive)
			{
				m_FinalValue += m_Modifiers[i].GetValue();
			}
			else
			{
				m_FinalValue *= m_Modifiers[i].GetValue();
			}
		}
		m_IsDirty = false;
	}
}

/** Represents a value that alters the value of a ModifiableDouble. **/
class DoubleModifier
{
	/** The ModifiableDouble this modifier is applied to. **/
	ModifiableDouble m_Target;
	
	private EModifierType m_Type;
	private double m_Value;

	/** Returns the EModifierType of this modifier. **/
	EModifierType GetType() const { return m_Type; }

	/** Returns this modifier's value. **/
	double GetValue() const { return m_Value; }

	/** Returns a string representation of this modifier. **/
	string ToString() const
	{
		return string.Format("Type: %s, Value: %f", ModifierType.ToString(m_Type), m_Value);
	}

	/** Sets the EModifierType of this modifier. **/
	void SetType(EModifierType newType)
	{
		m_Type = newType;
		if (m_Target) m_Target.MarkDirty();
	}

	/** Sets the value of this modifier. **/
	void SetValue(double newValue)
	{
		m_Value = newValue;
		if (m_Target) m_Target.MarkDirty();
	}
}

/** Represents a double that can be altered by modifiers. **/
class ModifiableDouble
{
	private double m_BaseValue;
	private double m_FinalValue;
	private bool m_IsDirty;

	private array<DoubleModifier> m_Modifiers;

	/** Returns the base value of this ModifiableDouble. **/
	double GetBaseValue() const { return m_BaseValue; }

	/**
	 * Returns a string representation of this ModifiableDouble.
	 *
	 * Parameters:
	 * - precision: The amount of decimal places to truncate the resulting numbers to.
	**/
	string ToString(int precision = 6) const
	{
		string result =
			"Base value: "..ToStr.Double(m_BaseValue, precision)
		.."\nFinal value: "..ToStr.Double(m_BaseValue, precision);

		if (m_Modifiers.Size() > 0)
		{
			result.AppendFormat("\nModifiers:\n");

			for (int i = 0; i < m_Modifiers.Size(); ++i)
			{
				result.AppendFormat(ToStr.Int(i + 1)..":    "..m_Modifiers[i].ToString().."\n");
			}
		}

		return result;
	}

	/**
	 * Returns the modified value of this ModifiableDouble.
	 *
	 * All changes to ModifiableDouble's state or that of any of its applied modifiers
	 * will be reflected in the value returned by this method.
	**/
	double GetValue()
	{
		if (m_IsDirty) ApplyModifiers();
		return m_FinalValue;
	}

	/** Sets the base value of this ModifiableDouble. **/
	void SetBaseValue(double newValue)
	{
		m_BaseValue = newValue;
		m_IsDirty = true;
	}

	/**
	 * Indicates that the final value for this ModifiableDouble needs to be recalculated.
	 *
	 * NOTE:
	 * 	This is used by modifiers to notify their applied ModifiableDouble whenever their
	 * 	state changes. Normally there should be no need to call this method manually.
	**/
	void MarkDirty()
	{
		m_IsDirty = true;
	}

	/** Applies the given DoubleModifier to this ModifiableDouble. **/
	void AddModifier(DoubleModifier modifier)
	{
		modifier.m_Target = self;
		m_Modifiers.Push(modifier);
		m_IsDirty = true;
	}

	/** Removes the given DoubleModifier from this ModifiableDouble. **/
	void RemoveModifier(DoubleModifier modifier)
	{
		uint index = m_Modifiers.Find(modifier);

		if (index != m_Modifiers.Size()) m_Modifiers.Delete(index);
	}

	private void ApplyModifiers()
	{
		m_FinalValue = m_BaseValue;
		for (int i = 0; i < m_Modifiers.Size(); ++i)
		{
			if (m_Modifiers[i].GetType() == MD_Additive)
			{
				m_FinalValue += m_Modifiers[i].GetValue();
			}
			else
			{
				m_FinalValue *= m_Modifiers[i].GetValue();
			}
		}
		m_IsDirty = false;
	}
}

/** Represents a value that alters the value of a ModifiableVector2. **/
class Vector2Modifier
{
	/** The ModifiableVector2 this modifier is applied to. **/
	ModifiableVector2 m_Target;

	private EModifierType m_Type;
	private vector2 m_Value;

	/** Returns the EModifierType of this modifier. **/
	EModifierType GetType() const { return m_Type; }

	/** Returns this modifier's value. **/
	vector2 GetValue() const { return m_Value; }

	/** Returns a string representation of this modifier. **/
	string ToString() const
	{
		return string.Format("Type: "..ModifierType.ToString(m_Type))..", Value: "..ToStr.Vec2(m_Value);
	}

	/** Sets the EModifierType of this modifier. **/
	void SetType(EModifierType newType)
	{
		m_Type = newType;
		if (m_Target) m_Target.MarkDirty();
	}

	/** Sets the value of this modifier. **/
	void SetValue(vector2 newValue)
	{
		m_Value = newValue;
		if (m_Target) m_Target.MarkDirty();
	}

	/** Sets the X-component of this modifier's value. **/
	void SetX(double newX)
	{
		m_Value.x = newX;
		if (m_Target) m_Target.MarkDirty();
	}

	/** Sets the Y-component of this modifier's value. **/
	void SetY(double newY)
	{
		m_Value.y = newY;
		if (m_Target) m_Target.MarkDirty();
	}
}

class ModifiableVector2
{
	private vector2 m_BaseValue;
	private vector2 m_FinalValue;
	private bool m_IsDirty;

	private array<Vector2Modifier> m_Modifiers;

	/** Returns the base value of this ModifiableVector2. **/
	vector2 GetBaseValue() const { return m_BaseValue; }

	/** Returns the X-component of this ModifiableVector2's base value. **/
	double GetBaseX() const { return m_BaseValue.x; }

	/** Returns the Y-component of this ModifiableVector2's base value. **/
	double GetBaseY() const { return m_BaseValue.y; }

	/**
	 * Returns a string representation of this ModifiableVector2.
	 *
	 * Parameters:
	 * - precision: The amount of decimal places to truncate the resulting numbers to.
	**/
	string ToString(int precision = 6) const
	{
		string result =
			"Base value: "..ToStr.Vec2(m_BaseValue, precision)
		.."\nFinal value: "..ToStr.Vec2(m_BaseValue, precision);

		if (m_Modifiers.Size() > 0)
		{
			result.AppendFormat("\nModifiers:\n");

			for (int i = 0; i < m_Modifiers.Size(); ++i)
			{
				result.AppendFormat(ToStr.Int(i + 1)..":    "..m_Modifiers[i].ToString().."\n");
			}
		}

		return result;
	}

	/**
	 * Returns the modified value of this ModifiableVector2.
	 *
	 * All changes to ModifiableVector2's state or that of any of its applied modifiers
	 * will be reflected in the value returned by this method.
	**/
	vector2 GetValue()
	{
		if (m_IsDirty) ApplyModifiers();
		return m_FinalValue;
	}

	/**
	 * Returns the X-component of the modified value of this ModifiableVector2.
	 * Shorthand for GetValue().x, as the ZScript parser does not accept this syntax.
	**/
	double GetX()
	{
		let vector = GetValue();
		return vector.x;
	}

	/**
	 * Returns the Y-component of the modified value of this ModifiableVector2.
	 * Shorthand for GetValue().y, as the ZScript parser does not accept this syntax.
	**/
	double GetY()
	{
		let vector = GetValue();
		return vector.y;
	}

	/** Sets the base value of this ModifiableVector2. **/
	void SetBaseValue(vector2 newValue)
	{
		m_BaseValue = newValue;
		m_IsDirty = true;
	}

	/** Sets the X-component of the base value of this ModifiableVector2. **/
	void SetBaseX(double newX)
	{
		m_BaseValue.x = newX;
		m_IsDirty = true;
	}

	/** Sets the Y-component of the base value of this ModifiableVector2. **/
	void SetBaseY(double newY)
	{
		m_BaseValue.y = newY;
		m_IsDirty = true;
	}

	/**
	 * Indicates that the final value for this ModifiableVector2 needs to be recalculated.
	 *
	 * NOTE:
	 * 	This is used by modifiers to notify their applied ModifiableVector2 whenever their
	 * 	state changes. Normally there should be no need to call this method manually.
	**/
	void MarkDirty()
	{
		m_IsDirty = true;
	}

	/** Applies the given Vector2Modifier to this ModifiableVector2. **/
	void AddModifier(Vector2Modifier modifier)
	{
		modifier.m_Target = self;
		m_Modifiers.Push(modifier);
		m_IsDirty = true;
	}

	/** Removes the given Vector2Modifier from this ModifiableVector2. **/
	void RemoveModifier(Vector2Modifier modifier)
	{
		uint index = m_Modifiers.Find(modifier);

		if (index != m_Modifiers.Size()) m_Modifiers.Delete(index);
	}

	private void ApplyModifiers()
	{
		m_FinalValue = m_BaseValue;
		for (int i = 0; i < m_Modifiers.Size(); ++i)
		{
			if (m_Modifiers[i].GetType() == MD_Additive)
			{
				m_FinalValue += m_Modifiers[i].GetValue();
			}
			else
			{
				let modifier = m_Modifiers[i].GetValue();
				m_FinalValue.x *= modifier.x;
				m_FinalValue.y *= modifier.y;
			}
		}
		m_IsDirty = false;
	}
}

/** Represents a value that alters the value of a ModifiableVector3. **/
class Vector3Modifier
{
	/** The ModifiableVector3 this modifier is applied to. **/
	ModifiableVector3 m_Target;

	private EModifierType m_Type;
	private vector3 m_Value;

	/** Returns the EModifierType of this modifier. **/
	EModifierType GetType() const { return m_Type; }

	/** Returns this modifier's value. **/
	vector3 GetValue() const { return m_Value; }

	/** Returns a string representation of this modifier. **/
	string ToString() const
	{
		return string.Format("Type: "..ModifierType.ToString(m_Type))..", Value: "..ToStr.Vec3(m_Value);
	}

	/** Sets the EModifierType of this modifier. **/
	void SetType(EModifierType newType)
	{
		m_Type = newType;
		if (m_Target) m_Target.MarkDirty();
	}

	/** Sets the value of this modifier. **/
	void SetValue(vector3 newValue)
	{
		m_Value = newValue;
		if (m_Target) m_Target.MarkDirty();
	}

	/** Sets the X-component of this modifier's value. **/
	void SetX(double newX)
	{
		m_Value.x = newX;
		if (m_Target) m_Target.MarkDirty();
	}

	/** Sets the Y-component of this modifier's value. **/
	void SetY(double newY)
	{
		m_Value.y = newY;
		if (m_Target) m_Target.MarkDirty();
	}

	/** Sets the Z-component of this modifier's value. **/
	void SetZ(double newZ)
	{
		m_Value.z = newZ;
		if (m_Target) m_Target.MarkDirty();
	}
}

// TODO: Replace Vector3Modifier array with Map<name, Vector3Modifier>.
class ModifiableVector3
{
	private vector3 m_BaseValue;
	private vector3 m_FinalValue;
	private bool m_IsDirty;

	private array<Vector3Modifier> m_Modifiers;

	/** Returns the base value of this ModifiableVector3. **/
	vector3 GetBaseValue() const { return m_BaseValue; }

	/** Returns the X-component of this ModifiableVector3's base value. **/
	double GetBaseX() const { return m_BaseValue.x; }

	/** Returns the Y-component of this ModifiableVector3's base value. **/
	double GetBaseY() const { return m_BaseValue.y; }

	/** Returns the Z-component of this ModifiableVector3's base value. **/
	double GetBaseZ() const { return m_BaseValue.z; }

	/**
	 * Returns a string representation of this ModifiableVector3.
	 *
	 * Parameters:
	 * - precision: The amount of decimal places to truncate the resulting numbers to.
	**/
	string ToString(int precision = 6) const
	{
		string result =
			"Base value: "..ToStr.Vec3(m_BaseValue, precision)
		.."\nFinal value: "..ToStr.Vec3(m_BaseValue, precision);

		if (m_Modifiers.Size() > 0)
		{
			result.AppendFormat("\nModifiers:\n");

			for (int i = 0; i < m_Modifiers.Size(); ++i)
			{
				result.AppendFormat(ToStr.Int(i + 1)..":    "..m_Modifiers[i].ToString().."\n");
			}
		}
		return result;
	}

	/**
	 * Returns the modified value of this ModifiableVector3.
	 *
	 * All changes to ModifiableVector3's state or that of any of its applied modifiers
	 * will be reflected in the value returned by this method.
	**/
	vector3 GetValue()
	{
		if (m_IsDirty) ApplyModifiers();
		return m_FinalValue;
	}

	/**
	 * Returns the X-component of the modified value of this ModifiableVector2.
	 * Shorthand for GetValue().x, as the ZScript parser does not accept this syntax.
	**/
	double GetX()
	{
		let vector = GetValue();
		return vector.x;
	}

	/**
	 * Returns the Y-component of the modified value of this ModifiableVector2.
	 * Shorthand for GetValue().y, as the ZScript parser does not accept this syntax.
	**/
	double GetY()
	{
		let vector = GetValue();
		return vector.y;
	}

	/**
	 * Returns the Z-component of the modified value of this ModifiableVector2.
	 * Shorthand for GetValue().z, as the ZScript parser does not accept this syntax.
	**/
	double GetZ()
	{
		let vector = GetValue();
		return vector.z;
	}

	/** Sets the base value of this ModifiableVector3. **/
	void SetBaseValue(vector3 newValue)
	{
		m_BaseValue = newValue;
		m_IsDirty = true;
	}

	/** Sets the X-component of the base value of this ModifiableVector3. **/
	void SetBaseX(double newX)
	{
		m_BaseValue.x = newX;
		m_IsDirty = true;
	}

	/** Sets the Y-component of the base value of this ModifiableVector3. **/
	void SetBaseY(double newY)
	{
		m_BaseValue.y = newY;
		m_IsDirty = true;
	}

	/** Sets the Z-component of the base value of this ModifiableVector3. **/
	void SetBaseZ(double newZ)
	{
		m_BaseValue.z = newZ;
		m_IsDirty = true;
	}

	/**
	 * Indicates that the final value for this ModifiableVector3 needs to be recalculated.
	 *
	 * NOTE:
	 * 	This is used by modifiers to notify their applied ModifiableVector3 whenever their
	 * 	state changes. Normally there should be no need to call this method manually.
	**/
	void MarkDirty()
	{
		m_IsDirty = true;
	}

	/** Applies the given Vector3Modifier to this ModifiableVector3. **/
	void AddModifier(Vector3Modifier modifier)
	{
		modifier.m_Target = self;
		m_Modifiers.Push(modifier);
		m_IsDirty = true;
	}

	/** Removes the given Vector3Modifier from this ModifiableVector3. **/
	void RemoveModifier(Vector3Modifier modifier)
	{
		uint index = m_Modifiers.Find(modifier);

		if (index != m_Modifiers.Size()) m_Modifiers.Delete(index);
	}

	private void ApplyModifiers()
	{
		m_FinalValue = m_BaseValue;
		for (int i = 0; i < m_Modifiers.Size(); ++i)
		{
			if (m_Modifiers[i].GetType() == MD_Additive)
			{
				m_FinalValue += m_Modifiers[i].GetValue();
			}
			else
			{
				let modifier = m_Modifiers[i].GetValue();
				m_FinalValue.x *= modifier.x;
				m_FinalValue.y *= modifier.y;
				m_FinalValue.z *= modifier.z;
			}
		}
		m_IsDirty = false;
	}
}