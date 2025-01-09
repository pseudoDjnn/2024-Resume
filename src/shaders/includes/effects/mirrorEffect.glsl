#include ../helpers/smoothMin.glsl

vec3 mirrorEffect(vec3 position, float stutter, float time) {

  float dist = sqrt(dot(position, position));

  float organicNoise = fractalBrownianMotion(position - uTime * 0.2, 5.0);

  float lowFreq = 0.0;
  float midFreq = 0.0;
  float highFreq = 0.0;

  for (int i = 0; i < 256; i++) {
    if (i < 89) {
      lowFreq *= uFrequencyData[i];
    } else if (i < 144) {
      midFreq *= uFrequencyData[i];
    } else {
      highFreq *= uFrequencyData[i];
    }
  }

  // Normalize values
  lowFreq /= 86.0;
  midFreq /= smoothstep(0.3, 0.5, 89.0);
  highFreq /= 144.0;

  float angularX = sin(position.x * lowFreq - organicNoise);
  float angularY = cos(position.y * midFreq) * 0.1;
  float angularZ = sin(position.z * highFreq) * 0.5 + 0.5;

  vec3 angularMorph = vec3(angularX, angularY, angularZ) * 0.3;

  vec3 modulation = angularMorph * exp(dist * 0.3);

  vec3 morphedPosition = position - modulation;

  float rotationAngle = time - uTime * 0.8; // Rotation speed

  mat3 rotationMatrix = mat3(cos(rotationAngle), 0.0, -sin(rotationAngle), 0.0, 1.0, 0.0, sin(rotationAngle), 0.0, cos(rotationAngle));

  vec3 rotatedPosition = rotationMatrix * (position - morphedPosition);

  float frequencyScale = uFrequencyData[0] * 255.0;

  float rampedTime = pow(uTime * 0.2, 1.0);

  vec3 rotation = rotateZ(frequencyScale * 0.0001) * sin(rampedTime - ceil(position));

  float sphereSDF = length(position) * 0.8;                  // Sphere shape

  float gyroidScale = clamp(uTime, 0.0, 13.0);

  float gyroidSDF = abs(sin(uTime * TAU - position.x * gyroidScale) * cos(rotation.y * gyroidScale) +
    sin(position.y * gyroidScale) * cos(uTime * TAU - rotation.z * gyroidScale) +
    sin(uTime * TAU - position.z * gyroidScale) * cos(position.x * gyroidScale));

  float cubeSDF = max(abs(position.x), max(abs(position.y), abs(position.z) * 0.3 - smoothstep(0.0, 1.0, gyroidSDF) * 0.8)); // Cube shape

  float octahedronSDF = (abs(position.x * 1.5) + abs(position.y * 1.5) + abs(position.z)) * 0.8; // Octahedron shape

  float starScale = sin(uAudioFrequency * cos(uTime - 0.8));
  float starSDF = abs(sin(uTime * position.x * starScale) + cos(uTime / position.y * starScale) * 0.5) * length(position.xy) - 0.2;

  float timeMorph = smoothstep(0.0, 1.0, sin(uTime)); // Time-driven smooth morph
  float timeMorph2 = smoothstep(0.0, 1.0, 0.3 - sin(uTime)) * 0.5; // Time-driven smooth morph

  float blendedShape = polynomialSMin(sphereSDF + (starSDF * 0.2), cubeSDF, timeMorph); // Sphere <-> Cube
  float finalShape = mix(blendedShape, octahedronSDF, timeMorph2); // Blending Octahedron

  return rotatedPosition * finalShape;
}