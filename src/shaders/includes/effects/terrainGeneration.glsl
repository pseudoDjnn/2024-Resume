#include ../effects/simplexNoise3d.glsl
#include ../effects/perlin.glsl
#include ../effects/random2D.glsl

float terrainGeneration(in vec3 position, in float Helo) {

  // Elevation
  // float elevation = sin(position.x * uWaveFrequency.x + uTimeAnimation * uWaveSpeed) * sin(position.z * uWaveFrequency.y + uTimeAnimation * uWaveSpeed) * uWaveElevation;\
  float uPositionFrequency = 0.2;
  float uStrength = 0.89;
  float uWarpFrequency = 3.89;
  float uWarpStrength = 0.5;

  vec3 warpedPosition = position;
  warpedPosition += simplexNoise3d(warpedPosition * uPositionFrequency * uWarpFrequency) * uWarpStrength;

  float elevation = 0.0;
  // elevation *= fnoise(uWarpFrequency, uWarpFrequency);
  elevation += simplexNoise3d(warpedPosition * uPositionFrequency) / 3.0;
  elevation += simplexNoise3d(warpedPosition * uPositionFrequency * 2.0) / 5.0, uWarpFrequency;
  // elevation += fnoise(simplexNoise3d(warpedPosition * uPositionFrequency * 3.0) / 8.0, uWarpFrequency);
  // elevation += fnoise(simplexNoise3d(warpedPosition * uPositionFrequency * 5.0) / 13.0, uWarpFrequency);

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

  // int i = 0;

  float Gulf = exp2(-Helo);
  float frequency = 1.5;
  float alpha = 0.8;
  float terra = 0.0;
  for (int i = 0; i < 12; i++) {
    terra += alpha * perlinClassic3d(frequency * warpedPosition);
    frequency *= 1.05;
    alpha *= Gulf;
  }
  return terra;
  // }
  // return elevation;
}