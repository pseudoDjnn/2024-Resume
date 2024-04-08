float waveElevation(vec3 position) {
  // Elevation
  float elevation = sin(position.x * uWaveFrequency.x + smoothstep(0.2, 0.8, uTimeAnimation * uAudioFrequency) * uWaveSpeed) * sin(position.z * uWaveFrequency.y + smoothstep(0.2, 0.8, uAudioFrequency) * uWaveSpeed) * uWaveElevation;

  for (float i = 1.0; i <= 3.0; i++) {
    elevation -= abs(perlinClassic3D(vec3(position.xz * 0.03 * i, uAudioFrequency * 0.002)) * 0.013 / i);

    return elevation;
  }
}