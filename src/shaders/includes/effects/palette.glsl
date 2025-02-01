vec3 palette(float tone) {
    // Define a modern, evolving color scheme
  vec3 a = vec3(0.8, 0.5, 0.89); // Light purple
  vec3 b = vec3(0.5, 0.55, 0.2); // Muted greenish tone
  vec3 c = vec3(0.3, 0.3, 0.35); // Darker neutral gray
  vec3 d = vec3(0.1, 0.15, 0.2); // Deep grounding color

    // Adjust dullFactor to be more dynamic with tone
  float dullFactor = smoothstep(0.2, 0.8, abs(sin(tone * 3.14 + uTime * 0.1)));

    // Improved interpolation for better blending
  float interpo = smoothstep(0.0, 1.0, fract(tone + uTime * 0.2));

    // Enhanced fractal noise variation
  float fbm = fractalBrownianMotion(c * sin(d + tone * 2.0), interpo);

    // Blend colors dynamically with tone and fbm
  vec3 result = mix(a, b + tone * 0.3, fbm) * (1.0 - dullFactor) + c * dullFactor;

    // Add subtle luminance variations
  result *= 0.9 + 0.1 * sin(tone * 6.283 + uTime * 0.3);

  return result;
}
