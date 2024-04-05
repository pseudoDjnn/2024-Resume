float waveElevation(vec3 position) {
  // Elevation
  float elevation = sin(position.x * uWaveFrequency.x + uTimeAnimation * uWaveSpeed) * sin(position.y * uWaveFrequency.y + uTimeAnimation * uWaveSpeed) * uWaveElevation;

  for (float i = 1.0; i <= 4.0; i++) {
    elevation -= abs(cnoise(vec3(position.xz * 3.0 * i, uTimeAnimation * 0.5)) * 0.21 / i);

    return elevation;
  }
}