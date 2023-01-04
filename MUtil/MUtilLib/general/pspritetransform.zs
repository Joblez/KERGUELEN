/**
 * Represents modifiable position, rotation, and scale values meant to be used with PSprites.
 * Used to group together modifiers that should then be applied to modifiable values which,
 * in turn, should be assigned to the corresponding fields on the PSprite.
 *
 * NOTE:
 *		The behavior of this class differs substantially from that of Transform2D.
 *		This is because PSprite's internal pivot makes applying proper transformations
 *		rather complex. Instead, this class's fields act as simple modifiers. Of particular
 *		note is that rotation and scale do not affect translation. As with proper transforms,
 *		however, translation and rotation are additive while scale is multiplicative.
**/
class PSpriteTransform
{
	/** The translation modifier to be applied. **/
	Vector2Modifier m_Translation;

	/** The rotation modifier to be applied. **/
	DoubleModifier m_Rotation;

	/** The scale modifier to be applied. **/
	Vector2Modifier m_Scale;

	static PSpriteTransform Create(
		vector2 translation = (0.0, 0.0),
		double rotation = 0.0,
		vector2 scale = (1.0, 1.0))
	{
		PSpriteTransform tr = new("PSpriteTransform");
		tr.Init(translation, rotation, scale);
		return tr;
	}

	protected virtual void Init(
		vector2 translation = (0.0, 0.0),
		double rotation = 0.0,
		vector2 scale = (1.0, 1.0))
	{
		m_Translation = new("Vector2Modifier");
		m_Translation.SetType(MD_Additive);
		m_Translation.SetValue(translation);

		m_Rotation = new("DoubleModifier");
		m_Rotation.SetType(MD_Additive);
		m_Rotation.SetValue(rotation);

		m_Scale = new("Vector2Modifier");
		m_Scale.SetType(MD_Multiplicative);
		m_Scale.SetValue(scale);
	}

	/** Returns a string representation of this PSpriteTransform. **/
	virtual string ToString() const
	{
		return string.Format(
			"T: %s"..ToStr.Vec2(m_Translation.GetValue())
		.."\nR: %s"..ToStr.Double(m_Rotation.GetValue())
		.."\nS: %s"..ToStr.Vec2(m_Scale.GetValue()));
	}

	/** Adds this PSpriteTransform's modifiers to the given modifiable origins. **/
	void AddTransform(out ModifiableVector2 originTranslation, out ModifiableDouble originRotation, out ModifiableVector2 originScale)
	{
		originTranslation.AddModifier(m_Translation);
		originRotation.AddModifier(m_Rotation);
		originScale.AddModifier(m_Scale);
	}

	/** Removes this PSpriteTransform's modifiers from the given modifiable origins. **/
	void RemoveTransform(out ModifiableVector2 originTranslation, out ModifiableDouble originRotation, out ModifiableVector2 originScale)
	{
		originTranslation.RemoveModifier(m_Translation);
		originRotation.RemoveModifier(m_Rotation);
		originScale.RemoveModifier(m_Scale);
	}
}

class InterpolatedPSpriteTransform : PSpriteTransform
{
	/** The interpolated translation to be assigned to the modifier. **/
	protected InterpolatedVector2 m_InterpolatedTranslation;

	/** The interpolated rotation to be assigned to the modifier. **/
	protected InterpolatedDouble m_InterpolatedRotation;

	/** The interpolated scale to be assigned to the modifier. **/
	protected InterpolatedVector2 m_InterpolatedScale;

	static InterpolatedPSpriteTransform Create(
		double smoothTime,
		vector2 translation = (0.0, 0.0),
		double rotation = 0.0,
		vector2 scale = (1.0, 1.0))
	{
		InterpolatedPSpriteTransform tr = new("InterpolatedPSpriteTransform");
		tr.InterpolatedInit(smoothTime, translation, rotation, scale);
		return tr;
	}

	void InterpolatedInit(
		double smoothTime,
		vector2 translation = (0.0, 0.0),
		double rotation = 0.0,
		vector2 scale = (1.0, 1.0))
	{
		Init(translation, rotation, scale);

		m_InterpolatedTranslation = new("InterpolatedVector2");
		m_InterpolatedTranslation.m_SmoothTime = smoothTime;
		m_InterpolatedRotation = new("InterpolatedDouble");
		m_InterpolatedRotation.m_SmoothTime = smoothTime;
		m_InterpolatedScale = new("InterpolatedVector2");
		m_InterpolatedScale.m_SmoothTime = smoothTime;
	}

	/** Returns a string representation of this InterpolatedPSpriteTransform. **/
	override string ToString() const
	{
		return string.Format(
			"T: %s"..ToStr.Vec2(m_InterpolatedTranslation.GetValue())
		.."\nR: %s"..ToStr.Double(m_InterpolatedRotation.GetValue())
		.."\nS: %s"..ToStr.Vec2(m_InterpolatedScale.GetValue()));
	}

	/** Advances the interpolation of this InterpolatedPSpriteTransform by the given time delta. **/
	virtual void Update(double delta = 1.0 / 35.0)
	{
		m_InterpolatedTranslation.Update(delta);
		m_InterpolatedRotation.Update(delta);
		m_InterpolatedScale.Update(delta);

		m_Translation.SetValue(m_InterpolatedTranslation.GetValue());
		m_Rotation.SetValue(m_InterpolatedRotation.GetValue());
		m_Scale.SetValue(m_InterpolatedScale.GetValue());
	}

	/** Sets this InterpolatedPSpriteTransform's smooth time. **/
	void SetSmoothTime(double smoothTime)
	{
		m_InterpolatedTranslation.m_SmoothTime = smoothTime;
		m_InterpolatedScale.m_SmoothTime = smoothTime;
	}

	/** Sets this InterpolatedPSpriteTransform's target translation. **/
	void SetTargetTranslation(vector2 target)
	{
		m_InterpolatedTranslation.m_Target = target;
	}

	/** Sets this InterpolatedPSpriteTransform's target rotation. **/
	void SetTargetRotation(double target)
	{
		m_InterpolatedRotation.m_Target = target;
	}

	/** Sets this InterpolatedPSpriteTransform's target scale. **/
	void SetTargetScale(vector2 target)
	{
		m_InterpolatedScale.m_Target = target;
	}

	/** Resets the value of this InterpolatedPSpriteTransform's fields. **/
	void Reset()
	{
		m_InterpolatedTranslation.Reset();
		m_InterpolatedRotation.Reset();
		m_InterpolatedScale.Reset();
	}

	/** Resets the value of this InterpolatedPSpriteTransform's fields immediately. **/
	void HardReset()
	{
		m_InterpolatedTranslation.HardReset();
		m_InterpolatedRotation.HardReset();
		m_InterpolatedScale.HardReset();
	}
}