vec3 palette(float tone) {
  // Define a neutral and modern base palette
  vec3 a = vec3(0.8, 0.5, 0.89); // Light gray with a hint of blue for a modern feel
  vec3 b = vec3(0.5, 0.55, 0.2); // Muted cool tones for contrast
  vec3 c = vec3(0.3, 0.3, 0.35); // Darker gray for depth
  vec3 d = vec3(0.1, 0.15, 0.2); // Dark tones for grounding

  // Dulling factor to subtly blend colors
  float dullFactor = smoothstep(0.2, 0.8, abs(sin(uTime * 0.1)));

  // Interpolation for smooth transitions
  float interpo = smoothstep(0.0, 1.0, fract(tone + uTime * 0.2));

  // Fractal-based noise for organic blending
  float fbm = fractalBrownianMotion(c * d, interpo);

  // Combine colors with subtle dynamics
  return mix(a, b + tone * 0.3, fbm) * (1.0 - dullFactor) + c * dullFactor;
}
