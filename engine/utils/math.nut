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

function convertRange(value, from1, to1, from2 = 0.0, to2 = 1.0, clamp = true)
{
	local size1 = to1 - from1;
	local size2 = to2 - from2;
	local result = (((value - from1) / size1) * size2) + from2;
	if (clamp) result = ::clamp(from2, to2);
	return result;
}

function pointInRect(point, rect)
{
	return (
		between(point.x, rect.x, rect.x + rect.w) &&
		between(point.y, rect.y, rect.y + rect.h)
	);
}

function interpolate(from, to, stepf)
{
	if ((typeof(from) == "array") && (typeof(to) == "array")) {
		local ret = [];
		for (local n = 0; n < from.len(); n++) ret.push(interpolate(from[n], to[n], stepf));
		return ret;
	}
	stepf = clamp(stepf, 0.0, 1.0);
	return (to - from) * stepf + from;
}

/**
 * Returns an integer value between min and max, excluding max.
 */
function rand_between(min, max)
{
	return min + (rand() % (max - min));
}

/**
 * Returns a float value between 0.0 and 1.0
 */
function rand_float()
{
	return rand() / RAND_MAX.tofloat();
}