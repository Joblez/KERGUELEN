/** Represents a two-dimensional transform that can be placed into a transform hierarchy. **/
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

	/** Returns the given vector transformed by this transform. **/
	vector2 TransformVector(vector2 v) const
	{
		Matrix3x3 mat;
		mat.CopyFrom(m_GlobalTransformMatrix);

		double x = v.x * mat.m_Values[0][0] + v.y * mat.m_Values[1][0] + mat.m_Values[2][0];
		double y = v.x * mat.m_Values[0][1] + v.y * mat.m_Values[1][1] + mat.m_Values[2][1];

		return (x, y);
	}

	/** Returns a string representation of this transform. **/
	string ToString() const
	{
		string result =
			"Translation: "..ToStr.Vec2(m_Translation)
		.."\nRotation: "..ToStr.Double(m_Rotation)
		.."\nScale: "..ToStr.Vec2(m_Scale)
		.."\nGlobal matrix:\n";

		// Move matrix string a bit to the right.
		string matrixString = "    "..m_GlobalTransformMatrix.ToString();
		matrixString.Replace("\n", "\n    ");

		return result..matrixString;
	}

	/** Returns the local translation of this transform. **/
	vector2 GetLocalTranslation() const
	{
		return m_Translation;
	}

	/** Returns the local rotation of this transform. **/
	double GetLocalRotation() const
	{
		return m_Rotation;
	}

	/** Returns the local scale of this transform. **/
	vector2 GetLocalScale() const
	{
		return m_Scale;
	}

	/** Returns the global translation of this transform. **/
	vector2 GetGlobalTranslation() const
	{
		return (m_GlobalTransformMatrix.m_Values[2][0], m_GlobalTransformMatrix.m_Values[2][1]);
	}

	/** Returns the global rotation of this transform. **/
	double GetGlobalRotation() const
	{
		return vectorangle((m_GlobalTransformMatrix.m_Values[0][0], m_GlobalTransformMatrix.m_Values[1][0]).Unit());
	}

	/** Returns the global scale of this transform. **/
	vector2 GetGlobalScale() const
	{
		double cr = cos(GetGlobalRotation());

		return ((m_GlobalTransformMatrix.m_Values[0][0] / cr, m_GlobalTransformMatrix.m_Values[1][1] / cr));
	}

	/** Parents this transform to the given transform. **/
	void ParentTo(Transform2D parent)
	{
		parent.AddChild(self);
	}

	/** Parents the given transform to this transform. **/
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

	/** Sets this transform's local translation. **/
	void SetTranslation(vector2 translation)
	{
		m_Translation = translation;
		UpdateGlobalTransform();
	}

	/** Sets this transform's local rotation. **/
	void SetRotation(double rotation)
	{
		m_Rotation = Math.PosMod(rotation, 360.0);
		UpdateGlobalTransform();
	}

	/** Sets this transform's local scale. **/
	void SetScale(vector2 scale)
	{
		m_Scale = scale;
		UpdateGlobalTransform();
	}

	/** Translates this transform by the given offset. **/
	void Translate(vector2 offset)
	{
		m_Translation += offset;
		UpdateGlobalTransform();
	}

	/** Rotates this transform by the given degrees. **/
	void Rotate(double degrees)
	{
		m_Rotation = Math.PosMod(m_Rotation + degrees, 360.0);
		UpdateGlobalTransform();
	}

	/** Scales this transform by the given factor. **/
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