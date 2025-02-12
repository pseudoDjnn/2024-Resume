#include ../helpers/smoothMin.glsl

vec3 morphingShape(vec3 position, float stutter, float time) {

  float dist = sqrt(dot(position, position));

  float organicNoise = fractalBrownianMotion(position - uTime * 0.2, 5.0);

  float lowFreq = 0.0;
  float midFreq = 0.0;
  float highFreq = 0.0;

  for (int i = 0; i < 257; i++) {
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

  // float squareWave = abs(fract(sin(uTime - position.z * PI) + 1.0 * 2.0) + organicNoise);

  vec3 rotatedPosition = rotationMatrix * (position - morphedPosition);

  float frequencyScale = uFrequencyData[0] * 256.0;

  float rampedTime = pow(uTime * 0.2, 1.0);

  vec3 segmentation = vec3(ceil(position.x), ceil(position.y), ceil(position.z));

  vec3 newPosition = rotateZ(rotationAngle + cos(uTime) * 0.5) *
    rotateX(rotationAngle + sin(uTime) * 0.3) *
    rotateY(rotationAngle + cos(uTime * 0.8) * 0.5) * position;

  vec3 objectRotationX = rotateX(frequencyScale * 0.0005) * sin(rampedTime - segmentation);
  vec3 objectRotationY = rotateY(frequencyScale * 0.0003) * cos(rampedTime - segmentation);
  vec3 objectRotationZ = rotateZ(frequencyScale * 0.0001) * sin(rampedTime - segmentation);

  // objectRotation.y += 
  // float squareWaveOrganic = abs(fract(sin(uTime * frequencyScale * position.y * PI * 0.8) * 1.8));
  vec3 squareWave = vec3(step(0.3, fract(sin(uFrequencyData[144] - uTime * 3.0 + position.x) * organicNoise)), step(0.3, fract(sin(uFrequencyData[144] - uTime * 2.5 + position.y) * organicNoise)), step(0.3, fract(sin(uFrequencyData[144] - uTime * 2.8 + position.z) * organicNoise)));

  float octahedronSDF = (abs(objectRotationZ.x) + abs(objectRotationZ.y) + abs(objectRotationZ.z) * 0.8); // Octahedron shape

  float starScale = sin(uAudioFrequency * cos(uTime - 0.8));
  float starSDF = abs(sin(uTime * position.x * starScale) + cos(uTime / position.y * starScale) * 0.5) * length(position.xy);

  float clampedSin = clamp(sin(uTime - 0.8), 0.5, 0.8 / float(squareWave));
  float sphereSDF = length(position) * clampedSin;

  float gyroidScale = clamp(uTime, 0.0, 21.0);

  float gyroidSDF = abs(sin(uTime * TAU - objectRotationX.x * gyroidScale) * cos(objectRotationY.y * gyroidScale) + sin(position.y * gyroidScale) * cos(uTime * TAU - position.z * gyroidScale) + sin(uTime * TAU - objectRotationZ.z * gyroidScale) * cos(position.x * gyroidScale));

  float cubeSDF = max(abs(position.x), max(abs(position.y), abs(position.z) * 0.3 - smoothstep(0.0, 1.0, gyroidSDF) * 0.8)); // Cube shape

  float timeMorph = rampedTime + (smoothstep(0.0, 1.0, sin(uTime)) - rampedTime) * organicNoise; // Time-driven smooth morph
  float timeMorph2 = smoothstep(0.0, 1.0, 0.3 - sin(uTime)) * 0.1; // Time-driven smooth morph

  float blendedShape = polynomialSMin(sphereSDF + (starSDF * 0.05), cubeSDF, timeMorph); // Sphere <-> Cube
  float finalShape = min(blendedShape, octahedronSDF); // Blending Octahedron

  return rotatedPosition * finalShape;
}