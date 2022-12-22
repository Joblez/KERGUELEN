// TODO: Document modifiables.

enum EModifierType
{
	MD_Additive,
	MD_Multiplicative
}

class ModifierType
{
	static string AsString(EModifierType type)
	{
		switch (type)
		{
			case MD_Additive: return "MD_Additive";
			case MD_Multiplicative: return "MD_Multiplicative";
			default: ThrowAbortException("Invalid EModifierType.");
		}
	}
}

class FloatModifier
{
	name m_Name;
	ModifiableFloat m_Target;
	private EModifierType m_Type;
	private float m_Value;

	EModifierType GetType() const
	{
		return m_Type;
	}

	string ToString() const
	{
		return string.Format(
			"Name: %s\nType: %s\nValue: %f", m_Name, ModifierType.AsString(m_Type), m_Value);
	}

	void SetType(EModifierType newType)
	{
		m_Type = newType;
		if (m_Target) m_Target.MarkDirty();
	}

	float GetValue() const
	{
		return m_Value;
	}

	void SetValue(float newValue)
	{
		m_Value = newValue;
		if (m_Target) m_Target.MarkDirty();
	}
}

class ModifiableFloat
{
	private float m_BaseValue;
	private float m_FinalValue;
	private bool m_IsDirty;

	private array<FloatModifier> m_Modifiers;

	float GetBaseValue() const
	{
		return m_BaseValue;
	}

	string ToString(int precision = 6) const
	{
		string result =
			"Base value: "..ToStr.Float(m_BaseValue, precision)
		.."\nFinal value: "..ToStr.Float(m_BaseValue, precision);

		if (m_Modifiers.Size() > 0)
		{
			result.AppendFormat("\nModifiers:");

			for (int i = 0; i < m_Modifiers.Size(); ++i)
			{
				result.AppendFormat("\t%s", m_Modifiers[i].m_Name);
			}
		}

		return result;
	}

	float GetValue()
	{
		if (m_IsDirty) ApplyModifiers();
		return m_FinalValue;
	}

	void SetBaseValue(float newValue)
	{
		m_BaseValue = newValue;
		m_IsDirty = true;
	}

	void MarkDirty()
	{
		m_IsDirty = true;
	}

	void AddModifier(FloatModifier modifier)
	{
		modifier.m_Target = self;
		m_Modifiers.Push(modifier);
		m_IsDirty = true;
	}

	void RemoveModifier(FloatModifier modifier)
	{
		uint index = m_Modifiers.Find(modifier);

		if (index != m_Modifiers.Size()) m_Modifiers.Delete(index);
	}

	void RemoveModifierByName(name inName)
	{
		bool modifierFound = false;
		for (int i = m_Modifiers.Size() - 1; i >= 0; --i)
		{
			if (m_Modifiers[i].m_Name == inName)
			{
				m_Modifiers.Delete(i);
				m_IsDirty = true;
				modifierFound = true;
			}
		}

		if (!modifierFound)
		{
			Console.Printf("Modifiable does not contain a modifier named %s.", inName);
			// Console.PrintfEx(PRINT_HIGH, "Modifiable does not contain a modifier named %s.", inName);
		}
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

class DoubleModifier
{
	name m_Name;
	ModifiableDouble m_Target;
	private EModifierType m_Type;
	private double m_Value;

	EModifierType GetType() const
	{
		return m_Type;
	}

	double GetValue() const
	{
		return m_Value;
	}

	string ToString() const
	{
		return string.Format(
			"Name: %s\nType: %s\nValue: %f", m_Name, ModifierType.AsString(m_Type), m_Value);
	}

	void SetType(EModifierType newType)
	{
		m_Type = newType;
		if (m_Target) m_Target.MarkDirty();
	}

	void SetValue(double newValue)
	{
		m_Value = newValue;
		if (m_Target) m_Target.MarkDirty();
	}
}

class ModifiableDouble
{
	private double m_BaseValue;
	private double m_FinalValue;
	private bool m_IsDirty;

	private array<DoubleModifier> m_Modifiers;

	double GetBaseValue() const
	{
		return m_BaseValue;
	}

	double GetValue()
	{
		if (m_IsDirty) ApplyModifiers();
		return m_FinalValue;
	}

	string ToString(int precision = 6) const
	{
		string result =
			"Base value: "..ToStr.Double(m_BaseValue, precision)
		.."\nFinal value: "..ToStr.Double(m_BaseValue, precision);

		if (m_Modifiers.Size() > 0)
		{
			result.AppendFormat("\nModifiers:");

			for (int i = 0; i < m_Modifiers.Size(); ++i)
			{
				result.AppendFormat("\t%s", m_Modifiers[i].m_Name);
			}
		}

		return result;
	}

	void SetBaseValue(double newValue)
	{
		m_BaseValue = newValue;
		m_IsDirty = true;
	}

	void MarkDirty()
	{
		m_IsDirty = true;
	}

	void AddModifier(DoubleModifier modifier)
	{
		modifier.m_Target = self;
		m_Modifiers.Push(modifier);
		m_IsDirty = true;
	}

	void RemoveModifier(DoubleModifier modifier)
	{
		uint index = m_Modifiers.Find(modifier);

		if (index != m_Modifiers.Size()) m_Modifiers.Delete(index);
	}

	void RemoveModifierByName(name inName)
	{
		bool modifierFound = false;
		for (int i = m_Modifiers.Size() - 1; i >= 0; --i)
		{
			if (m_Modifiers[i].m_Name == inName)
			{
				m_Modifiers.Delete(i);
				m_IsDirty = true;
				modifierFound = true;
			}
		}

		if (!modifierFound)
		{
			Console.Printf("Modifiable does not contain a modifier named %s.", inName);
			// Console.PrintfEx(PRINT_HIGH, "Modifiable does not contain a modifier named %s.", inName);
		}
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

class Vector2Modifier
{
	name m_Name;
	ModifiableVector2 m_Target;
	private EModifierType m_Type;
	private vector2 m_Value;

	EModifierType GetType() const
	{
		return m_Type;
	}

	vector2 GetValue() const
	{
		return m_Value;
	}

	string ToString() const
	{
		return string.Format(
			"Name: %s\nType: %s\nValue: ", m_Name, ModifierType.AsString(m_Type))..ToStr.Vec2(m_Value);
	}

	void SetType(EModifierType newType)
	{
		m_Type = newType;
		if (m_Target) m_Target.MarkDirty();
	}

	void SetValue(vector2 newValue)
	{
		m_Value = newValue;
		if (m_Target) m_Target.MarkDirty();
	}

	void SetX(double newX)
	{
		m_Value.x = newX;
		if (m_Target) m_Target.MarkDirty();
	}

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

	vector2 GetBaseValue() const
	{
		return m_BaseValue;
	}

	double GetBaseX() const
	{
		return m_BaseValue.x;
	}

	double GetBaseY() const
	{
		return m_BaseValue.y;
	}

	string ToString(int precision = 6) const
	{
		string result =
			"Base value: "..ToStr.Vec2(m_BaseValue, precision)
		.."\nFinal value: "..ToStr.Vec2(m_BaseValue, precision);

		if (m_Modifiers.Size() > 0)
		{
			result.AppendFormat("\nModifiers:");

			for (int i = 0; i < m_Modifiers.Size(); ++i)
			{
				result.AppendFormat("\t%s", m_Modifiers[i].m_Name);
			}
		}

		return result;
	}

	vector2 GetValue()
	{
		if (m_IsDirty) ApplyModifiers();
		return m_FinalValue;
	}

	double GetX()
	{
		let vector = GetValue();
		return vector.x;
	}

	double GetY()
	{
		let vector = GetValue();
		return vector.y;
	}

	void SetBaseValue(vector2 newValue)
	{
		m_BaseValue = newValue;
		m_IsDirty = true;
	}

	void SetBaseX(double newX)
	{
		m_BaseValue.x = newX;
		m_IsDirty = true;
	}

	void SetBaseY(double newY)
	{
		m_BaseValue.y = newY;
		m_IsDirty = true;
	}

	void MarkDirty()
	{
		m_IsDirty = true;
	}

	void AddModifier(Vector2Modifier modifier)
	{
		modifier.m_Target = self;
		m_Modifiers.Push(modifier);
		m_IsDirty = true;
	}

	void RemoveModifier(Vector2Modifier modifier)
	{
		uint index = m_Modifiers.Find(modifier);

		if (index != m_Modifiers.Size()) m_Modifiers.Delete(index);
	}

	void RemoveModifierByName(name inName)
	{
		bool modifierFound = false;
		for (int i = m_Modifiers.Size() - 1; i >= 0; --i)
		{
			if (m_Modifiers[i].m_Name == inName)
			{
				m_Modifiers.Delete(i);
				m_IsDirty = true;
				modifierFound = true;
			}
		}

		if (!modifierFound)
		{
			Console.Printf("Modifiable does not contain a modifier named %s.", inName);
			// Console.PrintfEx(PRINT_HIGH, "Modifiable does not contain a modifier named %s.", inName);
		}
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

class Vector3Modifier
{
	name m_Name;
	ModifiableVector3 m_Target;
	private EModifierType m_Type;
	private vector3 m_Value;

	EModifierType GetType() const
	{
		return m_Type;
	}

	vector3 GetValue() const
	{
		return m_Value;
	}

	string ToString() const
	{
		return string.Format(
			"Name: %s\nType: %s\nValue: ", m_Name, ModifierType.AsString(m_Type))..ToStr.Vec3(m_Value);
	}

	void SetType(EModifierType newType)
	{
		m_Type = newType;
		if (m_Target) m_Target.MarkDirty();
	}

	void SetValue(vector3 newValue)
	{
		m_Value = newValue;
		if (m_Target) m_Target.MarkDirty();
	}

	void SetX(double newX)
	{
		m_Value.x = newX;
		if (m_Target) m_Target.MarkDirty();
	}

	void SetY(double newY)
	{
		m_Value.y = newY;
		if (m_Target) m_Target.MarkDirty();
	}

	void SetZ(double newZ)
	{
		m_Value.z = newZ;
		if (m_Target) m_Target.MarkDirty();
	}
}

class ModifiableVector3
{
	private vector3 m_BaseValue;
	private vector3 m_FinalValue;
	private bool m_IsDirty;

	private array<Vector3Modifier> m_Modifiers;

	vector3 GetBaseValue() const
	{
		return m_BaseValue;
	}

	double GetBaseX() const
	{
		return m_BaseValue.x;
	}

	double GetBaseY() const
	{
		return m_BaseValue.y;
	}

	double GetBaseZ() const
	{
		return m_BaseValue.z;
	}

	string ToString(int precision = 6) const
	{
		string result =
			"Base value: "..ToStr.Vec3(m_BaseValue, precision)
		.."\nFinal value: "..ToStr.Vec3(m_BaseValue, precision);

		if (m_Modifiers.Size() > 0)
		{
			result.AppendFormat("\nModifiers:");

			for (int i = 0; i < m_Modifiers.Size(); ++i)
			{
				result.AppendFormat("\t%s", m_Modifiers[i].m_Name);
			}
		}

		return result;
	}

	vector3 GetValue()
	{
		if (m_IsDirty) ApplyModifiers();
		return m_FinalValue;
	}

	double GetX()
	{
		let vector = GetValue();
		return vector.x;
	}

	double GetY()
	{
		let vector = GetValue();
		return vector.y;
	}

	double GetZ()
	{
		let vector = GetValue();
		return vector.z;
	}

	void SetBaseValue(vector3 newValue)
	{
		m_BaseValue = newValue;
		m_IsDirty = true;
	}

	void SetBaseX(double newX)
	{
		m_BaseValue.x = newX;
		m_IsDirty = true;
	}

	void SetBaseY(double newY)
	{
		m_BaseValue.y = newY;
		m_IsDirty = true;
	}

	void SetBaseZ(double newZ)
	{
		m_BaseValue.z = newZ;
		m_IsDirty = true;
	}

	void MarkDirty()
	{
		m_IsDirty = true;
	}

	void AddModifier(Vector3Modifier modifier)
	{
		modifier.m_Target = self;
		m_Modifiers.Push(modifier);
		m_IsDirty = true;
	}

	void RemoveModifier(Vector3Modifier modifier)
	{
		uint index = m_Modifiers.Find(modifier);

		if (index != m_Modifiers.Size()) m_Modifiers.Delete(index);
	}

	void RemoveModifierByName(name inName)
	{
		bool modifierFound = false;
		for (int i = m_Modifiers.Size() - 1; i >= 0; --i)
		{
			if (m_Modifiers[i].m_Name == inName)
			{
				m_Modifiers.Delete(i);
				m_IsDirty = true;
				modifierFound = true;
			}
		}

		if (!modifierFound)
		{
			Console.Printf("Modifiable does not contain a modifier named %s.", inName);
			// Console.PrintfEx(PRINT_HIGH, "Modifiable does not contain a modifier named %s.", inName);
		}
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