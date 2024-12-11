vec3 palette(float tone) {

  // Increase intensity for each component to create a more vibrant color effect
  vec3 a = 1.0 - cos(vec3(1.2, 1.2, 1.2)); // Higher values to make colors more intense
  vec3 b = 1.0 - sin(vec3(1.2, 1.2, 1.2));
  vec3 c = -sin(vec3(0.8, 1.2, 1.0));
  vec3 d = 1.0 - cos(vec3(0.8, 0.5, 0.8));

  // Dulling factor to reduce vibrancy
  float dullFactor = abs(sin(uTime * 0.01 * atan(uTime, uAudioFrequency)));
  // float dullFactor = 0.08;

  // Apply dulling factor to tone and time-based color calculation
  // return (a + b * -cos(uTime / 5.28318 * (c + tone + d))) * dullFactor;
  return mix(vec3(0.3, 0.8, fract(uTime * 0.5)), a + b * cos(c + tone + uTime * 0.3) * 0.3, dullFactor) * d;

}
