/**
 * Represents an n-dimensional curve baked as a set of points, where each column holds the
 * nth-dimension of the curve, and each row represents a single point in the curve.
 *
 * Curves are read from a lump named CURVESET.The curve set may contain any number of curves,
 * with each curve in the set requiring a unique name to be identified with.
 *
 * Curves make no assumptions about the time-precision of their contained bake. Callers
 * are expected to know the data they are working with. However, the class does provide a
 * GetLength() method that returns the total number of points in the curve. Using this,
 * callers may choose to sample the curve using normalized time values by muliplying these
 * by the total length of the curve, like so:
 *
 * // sampledValue will hold the value at the middle of the curve.
 * double sampledValue = curve.Sample(0.5 * curve.GetLength());
 *
 * All points on a curve must have the same number of dimensions. This will be enforced
 * by the parser.
 *
 * Below is an example of a curve as the parser expects it to be formatted. Whitespace
 * may generally be omitted if desired, save for line breaks.
 *
 * ExampleCurve
 * {
 *		0.000000, 0.000000
 *		1.366310, 1.334942
 *		2.657417, 2.463233
 *		3.848346, 3.288257
 *		4.914121, 3.713391
 *		5.829765, 3.640670
 *		6.570305, 3.070058
 *		7.110764, 2.130000
 *		7.426166, 0.954839
 * }
**/
class BakedCurve
{
	enum EInterpolationMode
	{
		IM_Linear,
		IM_Quadratic,
		IM_Quintic
	}

	private name m_Name;
	private array<CurveValues> m_CurveValues;

	/**
	 * Returns the value corresponding to the given time value at the given dimension.
	 * Each point in a curve represents one unit of time.
	 *
	 * NOTE:
	 *		Fractional time values may be interpolated using one of three interpolation
	 *		methods: linear, quadratic, or quintic. Quadratic mode averages out the
	 *		result using the surrounding two points, quintic does the same with four.
	 *		Modes other than linear will result in smoother samples, but will undershoot
	 *		the values of the points. Quintic will undershoot more drastically than
	 *		quadratic.
	 *
	 * Parameters:
	 * - time: the point in time to sample from the curve.
	 * - dim: the dimension of the curve to sample.
	 * - mode: the type of interpolation to use when sampling the curve.
	**/
	double Sample(double time, int dim = 0, EInterpolationMode mode = IM_Linear)
	{
		if (mode == IM_Quintic && GetLength() < 5)
		{
			// Not enough points for quintic interpolation, try quadratic.
			mode = IM_Quadratic;
		}

		if (mode == IM_Quadratic && GetLength() < 3)
		{
			// Not enough points for quadratic interpolation, fall back to linear.
			mode = IM_Linear;
		}
		
		switch (mode)
		{
			case IM_Quintic:
			{
				// Get point indices.
				int i2 = int(round(time));
				int i0 = i2 - 2;
				int i1 = i2 - 1;
				int i3 = i2 + 1;
				int i4 = i2 + 2;

				// Remap time.
				time = Math.Remap(time, i0, i4, 0.0, 1.0);

				// Wrap indices.
				i0 = Mathf.PosMod(i0, GetLength());
				i1 = Mathf.PosMod(i1, GetLength());
				i2 = Mathf.PosMod(i2, GetLength());
				i3 = Mathf.PosMod(i3, GetLength());
				i4 = Mathf.PosMod(i4, GetLength());

				// Reduce polynomial.
				double p0 = m_CurveValues[i0].m_Values[dim];
				double p1 = m_CurveValues[i1].m_Values[dim];
				double p2 = m_CurveValues[i2].m_Values[dim];
				double p3 = m_CurveValues[i3].m_Values[dim];
				double p4 = m_CurveValues[i4].m_Values[dim];

				double q0 = Math.Lerp(p0, p1, time);
				double q1 = Math.Lerp(p1, p2, time);
				double q2 = Math.Lerp(p2, p3, time);
				double q3 = Math.Lerp(p3, p4, time);

				double r0 = Math.Lerp(q0, q1, time);
				double r1 = Math.Lerp(q1, q2, time);
				double r2 = Math.Lerp(q2, q3, time);

				double s0 = Math.Lerp(r0, r1, time);
				double s1 = Math.Lerp(r1, r2, time);

				return Math.Lerp(s0, s1, time);
			}

			case IM_Quadratic:
			{
				// Get point indices.
				int i1 = int(round(time));
				int i0 = i1 - 1;
				int i2 = i1 + 1;

				// Remap time.
				time = Math.Remap(time, i0, i2, 0.0, 1.0);

				// Wrap indices.
				i0 = Mathf.PosMod(i0, GetLength());
				i1 = Mathf.PosMod(i1, GetLength());
				i2 = Mathf.PosMod(i2, GetLength());

				// Reduce polynomial.
				double p0 = m_CurveValues[i0].m_Values[dim];
				double p1 = m_CurveValues[i1].m_Values[dim];
				double p2 = m_CurveValues[i2].m_Values[dim];

				double q0 = Math.Lerp(p0, p1, time);
				double q1 = Math.Lerp(p1, p2, time);

				return Math.Lerp(q0, q1, time);
			}

			case IM_Linear:
			default:
				int point = int(time);
				double step = time - point;
				int next = (point + 1) % m_CurveValues.Size();
				return Math.Lerp(m_CurveValues[time].m_Values[dim], m_CurveValues[next].m_Values[dim], step);
		}
	}

	/** Returns the amount of points in the curve. **/
	int GetLength() const
	{
		return m_CurveValues.Size();
	}

	/** Loads a curve with the given name from the CURVESET lump and returns it. **/
	static BakedCurve LoadCurve(name inName)
	{
		int lumpHandle = Wads.FindLump("CURVESET");
		if (lumpHandle == -1)
		{
			ThrowAbortException("CURVESET lump not found.");
		}

		string curvesAsText = Wads.ReadLump(lumpHandle);
		int defStart = curvesAsText.IndexOf(inName);

		if (defStart == -1)
		{
			ThrowAbortException("Curve not found.");
		}

		int defEnd = curvesAsText.IndexOf("}", defStart);
		string curveDef = curvesAsText.Mid(defStart, defEnd - defStart + 1);

		BakedCurve curve = FromDefinition(curveDef);
		return curve;
	}

	private static BakedCurve FromDefinition(string curveDef)
	{
		BakedCurve curve = new("BakedCurve");

		array<string> lines;
		curveDef.Split(lines, "\n", TOK_SKIPEMPTY);

		int currentLine = 0;
		curve.m_Name = lines[currentLine];
		currentLine += 2; // Skip open bracket.

		int previousValueCount = 0;

		while (currentLine < lines.Size() - 1) // Skip close bracket.
		{
			string line = lines[currentLine];
			if (lines[currentLine].IndexOf(",") == -1)
			{
				let value = new("CurveValues");
				value.m_Values.Push(line.ToDouble());
				curve.m_CurveValues.Push(value);
				++currentLine;
				continue;
			}

			array<string> valuesAsText;
			lines[currentLine].Split(valuesAsText, ",", TOK_SKIPEMPTY);

			if (valuesAsText.Size() == 0)
			{
				ThrowAbortException("Curve must be at least one-dimensional.");
			}

			let values = new("CurveValues");
			for (int i = 0; i < valuesAsText.Size(); ++i)
			{
				values.m_Values.Push(valuesAsText[i].ToDouble());
			}

			if (previousValueCount > 0 && values.m_Values.Size() != previousValueCount)
			{
				ThrowAbortException("All points on the curve must have the same "
					.."number of dimensions.");
			}

			previousValueCount = values.m_Values.Size();

			curve.m_CurveValues.Push(values);
			++currentLine;
		}

		if (curve.GetLength() < 2)
		{
			ThrowAbortException("Curve must have at least two points.");
		}

		return curve;
	}
}

/** Wrapper around an array of doubles. **/
class CurveValues
{
	array<double> m_Values;
}

