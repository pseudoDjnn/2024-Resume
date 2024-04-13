#include ../effects/simplexNoise3d.glsl

float terrainGeneration(in vec3 position, in float Helo) {

  // Elevation
  // float elevation = sin(position.x * uWaveFrequency.x + uTimeAnimation * uWaveSpeed) * sin(position.z * uWaveFrequency.y + uTimeAnimation * uWaveSpeed) * uWaveElevation;\
  float uPositionFrequency = 0.2;
  float uStrength = 2.0;
  float uWarpFrequency = 5.0;
  float uWarpStrength = 0.5;

  vec3 warpedPosition = position;
  warpedPosition += simplexNoise3d(warpedPosition * uPositionFrequency * uWarpFrequency) * uWarpStrength;

  float elevation = 0.0;
  elevation += simplexNoise3d(warpedPosition * uPositionFrequency * uAudioFrequency * 0.1) / 3.0;
  elevation += simplexNoise3d(warpedPosition * uPositionFrequency * 2.0) / 5.0;
  elevation += simplexNoise3d(warpedPosition * uPositionFrequency * 3.0) / 8.0;

  float elevationSign = sin(elevation);
  elevation = pow(abs(elevation), 2.0) * elevationSign;
  elevation *= uStrength;
  // elevation += uAudioFrequency * 0.2;

  // for (float i = 0.0; i < uWarpFrequency; i++) {
    // elevation += simplexNoise3d(position);

    // elevation -= abs(perlinClassic3D(vec3(position.xz * 0.03 * i, uAudioFrequency * 0.002)) * 0.013 / i);

    // float fractional = pow(2.0, float(i));
    // float alpha = pow(fractional, -H);
    // elevation += alpha * simplexNoise3d(fractional * position);

  float Gulf = exp2(-Helo);
  float foxtrot = 1.0;
  float alpha = 1.0;
  float terra = 0.0;
  for (float i = 0.0; i < uWarpFrequency; i++) {
    terra += alpha * simplexNoise3d(foxtrot * position);
    foxtrot *= 2.0;
    alpha *= Gulf;
  }
  return terra;
  // }
  // return elevation;
}