float polynomialSMin(float a, float b, float k) {
  k = 0.5;
  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

float positionEase(float t, in float T) {
  if (t >= T)
    return t - 0.5 * T;
  float f = t / T;
  return f * f * f * (T - t * 0.5);
}