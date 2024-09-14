float randomValue(vec3 coordinates) {
  // Generates a pseudo-random value based on input coordinates
  return fract(sin(dot(coordinates, vec3(12.9898, 4.1414, 1.0))) * 43758.5453);
}

float smoothNoise(vec3 coordinates) {
  // Generates interpolated noise based on input coordinates
  vec3 integerPart = floor(coordinates);    // Integer part of the coordinates
  vec3 fractionalPart = fract(coordinates); // Fractional part of the coordinates
  fractionalPart = fractionalPart * fractionalPart * (3.0 - 2.0 * fractionalPart); // Smooth interpolation

  // Generate random values for neighboring points
  float randOrigin = randomValue(integerPart);
  float randOffsetX = randomValue(integerPart + vec3(1.0, 0.0, 0.0));
  float randOffsetY = randomValue(integerPart + vec3(0.0, 1.0, 0.0));
  float randOffsetXY = randomValue(integerPart + vec3(1.0, 1.0, 1.0));

  // Perform bilinear interpolation between random values
  float interpolatedX = mix(randOrigin, randOffsetX, fractionalPart.x);
  float interpolatedY = mix(randOffsetY, randOffsetXY, fractionalPart.x);
  float result = mix(interpolatedX, interpolatedY, fractionalPart.y);

  return result * result;  // Square the result for a smoother transition
}

float fractalBrownianMotion(vec3 coordinates, float roughness) {

  float persistence = exp2(-roughness);  // Controls the amplitude falloff
  float frequency = 2.0;                 // Initial frequency
  float amplitude = 2.0;                 // Initial amplitude
  float totalNoise = 0.0;                // Accumulated noise

  vec3 timeOffset = vec3(uTime * 0.2) + 0.2;   // Time-based offset for fluidity
  float audioEffect = 0.008 + 0.008 * sin(uAudioFrequency);  // Modulate noise by audio frequency

  // Loop through multiple noise layers (octaves)
  for (int octave = 0; octave < NUM_OCTAVES; octave++) {
    totalNoise += amplitude * smoothNoise(frequency * coordinates + timeOffset * audioEffect);  // Add scaled noise with audio effect
    frequency *= 8.0;  // Double the frequency for next octave
    amplitude *= persistence;  // Decrease amplitude for next octave
  }

  return totalNoise;
}
