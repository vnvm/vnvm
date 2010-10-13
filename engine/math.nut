function clamp(v, m, M)
{
	if (v < m) return m;
	if (v > M) return M
	return v;
}

function between(v, m, M)
{
	return (v >= m) && (v < M);
}

function interpolate(from, to, stepf)
{
	stepf = clamp(stepf, 0.0, 1.0);
	return (to - from) * stepf + from;
}

