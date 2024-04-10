// #include ../effects/simplexNoise3d.glsl
#include ../effects/simplexNoise3d.glsl

float waveElevation(vec3 position) {
  // Elevation
  // float elevation = sin(position.x * uWaveFrequency.x + uTimeAnimation * uWaveSpeed) * sin(position.z * uWaveFrequency.y + uTimeAnimation * uWaveSpeed) * uWaveElevation;\
  float uPositionFrequency = 0.2;
  float uStrength = 2.0;
  float uWarpFrequency = 5.0;
  float uWarpStrength = 0.5;

  vec3 warpedPosition = position;
  warpedPosition += simplexNoise3d(warpedPosition * uPositionFrequency * uWarpFrequency) * uWarpStrength;

  float elevation = 0.0;
  elevation += simplexNoise3d(warpedPosition * uPositionFrequency * uAudioFrequency * 0.1) / 2.0;
  elevation += simplexNoise3d(warpedPosition * uPositionFrequency * 2.0) / 5.0;
  elevation += simplexNoise3d(warpedPosition * uPositionFrequency * 5.0) / 8.0;

  float elevationSign = sign(elevation);
  elevation = pow(abs(elevation), 2.0) * elevationSign;
  elevation *= uStrength;
  // elevation += uAudioFrequency * 0.2;

  for (float i = 1.0; i <= 3.0; i++) {
    // elevation += simplexNoise3d(position);

    // elevation -= abs(perlinClassic3D(vec3(position.xz * 0.03 * i, uAudioFrequency * 0.002)) * 0.013 / i);

    return elevation;
  }
}