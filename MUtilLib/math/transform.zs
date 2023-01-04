class Transform2D
{
	private double m_Rotation;
	private vector2 m_Translation;
	private vector2 m_Scale;

	private Matrix3x3 m_GlobalTransformMatrix;

	private Transform2D m_Parent;
	private array<Transform2D> m_Children;

	static Transform2D Create()
	{
		Transform2D tr = new("Transform2D");
		tr.m_GlobalTransformMatrix.MakeIdentity();
		tr.m_Scale = (1, 1);
		return tr;
	}

	Shape2DTransform ToShape2DTransform() const
	{
		Matrix3x3 mat;
		mat.CopyFrom(m_GlobalTransformMatrix);

		Shape2DTransform tr = new("Shape2DTransform");
		tr.From2D(
			mat.m_Values[0][0], mat.m_Values[0][1],
			mat.m_Values[1][0], mat.m_Values[1][1],
			mat.m_Values[2][0], mat.m_Values[2][1]);

		return tr;
	}

	vector2 TransformVector(vector2 v) const
	{
		Matrix3x3 mat;
		mat.CopyFrom(m_GlobalTransformMatrix);

		// Console.Printf("%f %f %f", mat.m_Values[0][0], mat.m_Values[0][1], mat.m_Values[0][2]);
		// Console.Printf("%f %f %f", mat.m_Values[1][0], mat.m_Values[1][1], mat.m_Values[1][2]);
		// Console.Printf("%f %f %f", mat.m_Values[2][0], mat.m_Values[2][1], mat.m_Values[2][2]);

		double x = v.x * mat.m_Values[0][0] + v.y * mat.m_Values[1][0] + mat.m_Values[2][0];
		double y = v.x * mat.m_Values[0][1] + v.y * mat.m_Values[1][1] + mat.m_Values[2][1];

		return (x, y);
	}

	string ToString() const
	{
		string result =
			"Translation: "..ToStr.Vec2(m_Translation)
		.."\nRotation: "..ToStr.Double(m_Rotation)
		.."\nScale: "..ToStr.Vec2(m_Scale)
		.."\nGlobal matrix:\n";

		// Move matrix string a bit to the right.
		string matrixString = "\t"..m_GlobalTransformMatrix.ToString();
		matrixString.Replace("\n", "\n\t");

		return result..matrixString;
	}

	vector2 GetLocalTranslation() const
	{
		return m_Translation;
	}

	double GetLocalRotation() const
	{
		return m_Rotation;
	}

	vector2 GetLocalScale() const
	{
		return m_Scale;
	}

	vector2 GetGlobalTranslation() const
	{
		return (m_GlobalTransformMatrix[2][0], m_GlobalTransformMatrix[2][1]);
	}

	double GetGlobalRotation() const
	{
		return vectorangle((m_GlobalTransformMatrix[0][0], m_GlobalTransformMatrix[1][0]).Unit());
	}

	vector2 GetGlobalScale() const
	{
		double cr = cos(GetGlobalRotation());

		return ((m_GlobalTransformMatrix[0][0] / cr, m_GlobalTransformMatrix[1][1] / cr));
	}

	// double GetGlobalScale() const
	// {
	// 	return m_Scale * m_Parent ? m_Parent.GetGlobalScale() : 1.0;
	// }

	double GetSumOfRotations() const
	{
		double combinedAngle = m_Rotation;
		if (m_Parent) combinedAngle += m_Parent.GetSumOfRotations();
		return combinedAngle;
	}

	void ParentTo(Transform2D parent)
	{
		parent.AddChild(self);
	}

	void AddChild(Transform2D child)
	{
		if (child.m_Parent)
		{
			int childIndex = child.m_Parent.m_Children.Find(child);
			child.m_Parent.m_Children.Delete(childIndex);
		}
		child.m_Parent = self;
		m_Children.Push(child);
		child.UpdateGlobalTransform();
	}

	void SetTranslation(vector2 translation)
	{
		m_Translation = translation;
		UpdateGlobalTransform();
	}

	void SetRotation(double rotation)
	{
		m_Rotation = Math.PosMod(rotation, 360.0);
		UpdateGlobalTransform();
	}

	void SetScale(vector2 scale)
	{
		m_Scale = scale;
		UpdateGlobalTransform();
	}

	void Translate(vector2 offset)
	{
		m_Translation += offset;
		UpdateGlobalTransform();
	}

	void Rotate(double degrees)
	{
		m_Rotation = Math.PosMod(m_Rotation + degrees, 360.0);
		UpdateGlobalTransform();
	}

	void Scale(vector2 factor)
	{
		m_Scale += factor;
		UpdateGlobalTransform();
	}

	private void UpdateGlobalTransform()
	{
		Matrix3x3 temp;

		if (m_Parent)
		{
			temp.CopyFrom(m_Parent.m_GlobalTransformMatrix);
		}
		else
		{
			temp.MakeIdentity();
		}

		Matrix3x3 comp;
		Matrix3x3 result;

		comp.MakeIdentity();

		comp.m_Values[0][0] = m_Scale.x;
		comp.m_Values[1][1] = m_Scale.y;
		temp.Mul(comp, result);
		temp.CopyFrom(result);

		comp.MakeIdentity();

		if (m_Rotation != 0.0)
		{
			double cosine = cos(m_Rotation);
			double sine = sin(m_Rotation);
			comp.m_Values[0][0] = cosine;
			comp.m_Values[0][1] = sine;
			comp.m_Values[1][0] = -sine;
			comp.m_Values[1][1] = cosine;
			temp.Mul(comp, result);
			temp.CopyFrom(result);
			comp.MakeIdentity();
		}

		comp.m_Values[2][0] = m_Translation.x;
		comp.m_Values[2][1] = m_Translation.y;
		temp.Mul(comp, result);

		m_GlobalTransformMatrix.CopyFrom(result);

		if (m_Children.Size() > 0)
		{
			for (int i = 0; i < m_Children.Size(); ++i)
			{
				m_Children[i].UpdateGlobalTransform();
			}
		}
	}
}