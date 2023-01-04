class CurveValues
{
	array<double> m_Values;
}

// TODO: Document BakedCurve.
// NOTE: BakedCurves are effectively LUTs describing an approximation of a function of time with a precision of 1 / TICRATE.
/*
-- CURVESET.txt --

ExampleCurve
{
	0.000000
	1.366310
	2.657417
}

ExampleCurve2
{
	0.000000, 0.000000
	1.366310, 1.334942
	2.657417, 2.463233
	3.848346, 3.288257
	4.914121, 3.713391
	5.829765, 3.640670
	6.570305, 3.070058
	7.110764, 2.130000
	7.426166, 0.954839
}
*/
class BakedCurve
{
	private name m_Name;
	private array<CurveValues> m_CurveValues;

	double Sample(double time, int index = 0)
	{
		int point = int(time);
		double step = time - point;
		int next = (point + 1) % m_CurveValues.Size();
		return Math.Lerp(m_CurveValues[time].m_Values[index], m_CurveValues[next].m_Values[index], step);
	}

	int GetLength() const
	{
		return m_CurveValues.Size();
	}

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
			ThrowAbortException("Anim curve not found.");
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

			let values = new("CurveValues");
			for (int i = 0; i < valuesAsText.Size(); ++i)
			{
				values.m_Values.Push(valuesAsText[i].ToDouble());
			}

			curve.m_CurveValues.Push(values);
			++currentLine;
		}

		return curve;
	}
}