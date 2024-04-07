float waveElevation(vec3 position) {
  // Elevation
  float elevation = fract(sin(position.x * uWaveFrequency.x + uTime * uWaveSpeed) * 0.01) * fract(sin(position.y * uWaveFrequency.y + uTime * uWaveSpeed) * 0.01) * uWaveElevation;

  for (float i = 1.0; i <= 4.0; i++) {
    elevation *= abs(perlinClassic3D(vec3(position.xz * 3.0 * i, uTimeAnimation * 0.2)) * 0.13 / i);

    return elevation;
  }
}