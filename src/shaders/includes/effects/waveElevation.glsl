float waveElevation(vec3 position) {
  // Elevation
  float elevation = sin(position.x * uWaveFrequency.x + uTimeAnimation * uWaveSpeed) * cos(position.z * uWaveFrequency.y + uTimeAnimation * uWaveSpeed) * uWaveElevation;

  for (float i = 1.0; i <= 4.0; i++) {
    elevation -= abs(perlinClassic3D(vec3(position.xz * 3.0 * i, uTimeAnimation)) * 0.13 * i);

    return elevation;
  }
}