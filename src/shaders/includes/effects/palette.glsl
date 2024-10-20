vec3 palette(float tone) {

  vec3 a = cos(vec3(0.5, 0.5, 0.5));
  vec3 b = sin(vec3(0.5, 0.5, 0.5));
  vec3 c = -sin(vec3(1.0, 0.8, 0.5));
  vec3 d = cos(vec3(0.0, 0.21, 0.13));

  // Dulling factor to reduce vibrancy
  float dullFactor = 0.3;

  // Apply dulling factor to tone and time-based color calculation
  return (a + b * -cos(uTime - 5.28318 * (c + tone + d))) * dullFactor;
}
