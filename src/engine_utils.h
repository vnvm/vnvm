//#define ClampInt(x, m, M) if (x < (m)) x = m; else if (x > (M)) x = M;

#define ClampMin(x, m) if (x < (m)) x = m;
#define ClampMax(x, M) if (x > (M)) x = M;
#define ClampMinMax(x, m, M) ClampMin(x, m) else ClampMax(x, M)