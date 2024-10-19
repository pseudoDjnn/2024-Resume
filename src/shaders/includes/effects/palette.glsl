vec3 palette(float tone) {

  // Increase intensity for each component to create a more vibrant color effect
  vec3 a = cos(vec3(1.2, 1.2, 1.2)); // Higher values to make colors more intense
  vec3 b = sin(vec3(1.2, 1.2, 1.2));
  vec3 c = -sin(vec3(1.5, 1.2, 1.0));
  vec3 d = cos(vec3(0.5, 0.6, 0.7));

  // Dulling factor to reduce vibrancy
  float dullFactor = abs(sin(uTime * 0.01 * fract(uAudioFrequency)));
  // float dullFactor = 0.08;

  // Apply dulling factor to tone and time-based color calculation
  return (a + b * -cos(uTime / 5.28318 * (c + tone + d))) * dullFactor;
}
