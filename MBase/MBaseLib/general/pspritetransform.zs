class PSpriteTransform
{
	Vector2Modifier m_Translation;
	Vector2Modifier m_Scale;

	protected bool m_Initialized;

	void Init(name translationName = 'None', name scaleName = 'None')
	{
		if (m_Initialized) return;

		if (translationName == 'None')
		{
			string trName = GetClassName();
			trName = trName.."Translation";
			translationName = trName;
		}

		if (scaleName == 'None')
		{
			string scName = GetClassName();
			scName = scName.."Scale";
			scaleName = scName;
		}

		m_Translation = new("Vector2Modifier");
		m_Translation.m_Name = translationName;
		m_Translation.SetType(MD_Additive);
		m_Translation.SetValue((0, 0));

		m_Scale = new("Vector2Modifier");
		m_Scale.m_Name = scaleName;
		m_Scale.SetType(MD_Additive);
		m_Scale.SetValue((0, 0));

		m_Initialized = true;
	}

	void AddTransform(out ModifiableVector2 originTranslation, out ModifiableVector2 originScale)
	{
		originTranslation.AddModifier(m_Translation);
		originScale.AddModifier(m_Scale);
	}

	void RemoveTransform(out ModifiableVector2 originTranslation, out ModifiableVector2 originScale)
	{
		originTranslation.RemoveModifier(m_Translation);
		originScale.RemoveModifier(m_Scale);
	}
}

class InterpolatedPSpriteTransform : PSpriteTransform
{
	protected InterpolatedVector2 m_InterpolatedTranslation;
	protected InterpolatedVector2 m_InterpolatedScale;

	// Constructors would come in real handy here...
	void InterpolatedInit(double smoothTime, name translationName = 'None', name scaleName = 'None')
	{
		if (m_Initialized) return;

		Init(translationName, scaleName);

		m_Initialized = false;

		m_InterpolatedTranslation = new("InterpolatedVector2");
		m_InterpolatedTranslation.m_SmoothTime = smoothTime;
		m_InterpolatedScale = new("InterpolatedVector2");
		m_InterpolatedScale.m_SmoothTime = smoothTime;

		m_Initialized = true;
	}

	virtual void Update()
	{
		if (!m_Initialized) return;

		m_InterpolatedTranslation.Update();
		m_InterpolatedScale.Update();

		m_Translation.SetValue(m_InterpolatedTranslation.GetValue());
		m_Scale.SetValue(m_InterpolatedScale.GetValue());
	}

	void SetSmoothTime(double smoothTime)
	{
		m_InterpolatedTranslation.m_SmoothTime = smoothTime;
		m_InterpolatedScale.m_SmoothTime = smoothTime;
	}

	void SetTargetTranslation(vector2 target)
	{
		m_InterpolatedTranslation.m_Target = target;
	}

	void SetTargetScale(vector2 target)
	{
		m_InterpolatedScale.m_Target = target;
	}
	
	void Reset()
	{
		m_InterpolatedTranslation.Reset();
		m_InterpolatedScale.Reset();
	}

	void HardReset()
	{
		m_InterpolatedTranslation.HardReset();
		m_InterpolatedScale.HardReset();
	}
}