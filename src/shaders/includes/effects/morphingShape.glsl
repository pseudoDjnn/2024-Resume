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

  vec3 segmentation = vec3(ceil(position.x), ceil(position.y), ceil(uTime - PI * position.z));

  // segmentation.y *= sin(uTime / cos(segmentation.x));
  // segmentation.x *= sin(frequencyScale * 0.001 * segmentation.y);
  // segmentation.y *= cos(frequencyScale * 0.001 * segmentation.x);

  vec3 objectRotation = rotateZ(frequencyScale * 0.0003) * sin(rampedTime - segmentation);
  // objectRotation.x -= round(position.y);
  // objectRotation.y += 
  // float squareWaveOrganic = abs(fract(sin(uTime * frequencyScale * position.y * PI * 0.8) * 1.8));
  vec3 squareWave = vec3(step(0.3, fract(sin(uTime * 3.0 + position.x) * organicNoise)), step(0.3, fract(sin(uTime * 2.5 + position.y) * organicNoise)), step(0.3, fract(sin(uTime * 2.8 + position.z) * organicNoise)));

  float starScale = sin(uAudioFrequency * cos(uTime - 0.8));
  float starSDF = abs(sin(uTime * position.x * starScale) + cos(uTime / position.y * starScale) * 0.5) * length(position.xy) - 0.2;

  float clampedSin = clamp(sin(uTime - 0.8), 0.5, 0.8);
  float sphereSDF = length(position) * clampedSin;

  float gyroidScale = clamp(uTime, 0.0, 21.0);

  float gyroidSDF = abs(sin(uTime * TAU - objectRotation.x * gyroidScale) * cos(squareWave.y * gyroidScale) + sin(position.y * gyroidScale) * cos(uTime * TAU - position.z * gyroidScale) + sin(uTime * TAU - objectRotation.z * gyroidScale) * cos(position.x * gyroidScale));

  float cubeSDF = max(abs(position.x), max(abs(position.y), abs(position.z) * 0.3 - smoothstep(0.0, 1.0, gyroidSDF) * 0.8)); // Cube shape

  float octahedronSDF = (abs(2.0 * position.x) + abs(2.0 * position.y) + abs(position.z * smoothstep(0.0, 2.0, squareWave.z))) * 0.8; // Octahedron shape

  float timeMorph = smoothstep(0.0, 0.8, sin(uTime)); // Time-driven smooth morph
  float timeMorph2 = smoothstep(0.0, 0.8, 0.5 - sin(uTime)) * 0.1; // Time-driven smooth morph

  float blendedShape = polynomialSMin(sphereSDF + (starSDF * 0.05), cubeSDF, timeMorph2); // Sphere <-> Cube
  float finalShape = mix(blendedShape, octahedronSDF * float(objectRotation * 0.2), timeMorph); // Blending Octahedron

  return rotatedPosition * finalShape;
}