#if 1
float sdBoxFrame(vec3 p, vec3 b, float e) {
  p = abs(p) - b;
  vec3 q = abs(p + e) - e;

  return min(min(length(max(vec3(p.x, q.y, q.z), 0.0)) + min(max(p.x, max(q.y, q.z)), 0.0), length(max(vec3(q.x, p.y, q.z), 0.0)) + min(max(q.x, max(p.y, q.z)), 0.0)), length(max(vec3(q.x, q.y, p.z), 0.0)) + min(max(q.x, max(q.y, p.z)), 0.0));
}
#else
float dot2(in vec3 v) {
  return dot(v, v);
}
float sdBoxFrame(vec3 p, vec3 b, float e) {
  p = abs(p) - b;
  vec3 q = abs(p + e) - e;

  return sqrt(min(min(dot2(max(vec3(p.x, q.y, q.z), 0.0)), dot2(max(vec3(q.x, p.y, q.z), 0.0))), dot2(max(vec3(q.x, q.y, p.z), 0.0)))) + min(0.0, min(min(max(p.x, max(q.y, q.z)), max(p.y, max(q.z, q.x))), max(p.z, max(q.x, q.y))));
}
#endif

float map(in vec3 pos) {
  return sdBoxFrame(pos, vec3(0.5, 0.3, 0.5), 0.025);
}

// https://iquilezles.org/articles/normalsSDF
vec3 calcNormal(in vec3 pos) {
  vec2 e = vec2(1.0, -1.0) * 0.5773;
  const float eps = 0.0005;
  return normalize(e.xyy * map(pos + e.xyy * eps) +
    e.yyx * map(pos + e.yyx * eps) +
    e.yxy * map(pos + e.yxy * eps) +
    e.xxx * map(pos + e.xxx * eps));
}