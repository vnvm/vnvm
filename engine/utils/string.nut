function array_join(array, separator = "")
{
	local ret = "";
	for (local n = 0; n < array.len(); n++) {
		if (n != 0) ret += separator;
		ret += array[n];
	}
	return ret;
}

function object_to_string(v)
{
	switch (type(v)) {
		case "instance":
			return typeof v;
		break;
		case "array":
			local vv = [];
			foreach (c in v) vv.push(object_to_string(c));
			return "[" + array_join(vv, ",") + "]";
		break;
		case "table":
			local vv = [];
			foreach (k, c in v) vv.push(object_to_string(k) + " = " + object_to_string(c));
			return "{" + array_join(vv, ",") + "}";
		break;
		case "string":
			return "\"" + v + "\"";
		break;
	}
	return v.tostring();
}

function base2dec(str, base)
{
	local v = 0;
	foreach (c in str) {
		local cv = 0;
		if (c >= '0' && c <= '9') cv = c - '0';
		else if (c >= 'a' && c <= 'z') cv = c - 'a' + 10;
		else if (c >= 'A' && c <= 'Z') cv = c - 'A' + 10;
		//printf("'%c' : %d\n", c, cv);
		if (cv < base) {
			v *= base;
			v += cv;
		}
	}
	return v;
}

function hex2dec(str)
{
	return base2dec(str, 16);
}

function substr(str, start = 0, len = null)
{
	local strlen = str.len();
	local end = 0;
	if (len == null) {
		end = strlen;
	} else if (len < 0) {
		end = len;
	} else {
		end = start + len;
	}
	start = clamp(start, 0, strlen);
	end = clamp(end, start, strlen);
	return str.slice(start, end);
}

function rgba(str)
{
	local v = [0.0, 0.0, 0.0, 1.0];
	local n = (str.len() == 3) ? 1 : 2;
	local scale = (pow(16, n) - 1).tofloat();
	for (local i = 0; i < 4; i++) {
		if (str.len() >= n * (i + 1)) {
			v[i] = hex2dec(substr(str, n * i, n)) / scale;
		}
	}
	return v;
}

function rgb(str)
{
	return rgba(str).slice(0, 3);
}