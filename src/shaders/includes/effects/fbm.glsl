float randomValue(vec3 coordinates) {
  // Generates a pseudo-random value based on input coordinates
  return fract(sin(dot(coordinates, vec3(12.8989, 5.1515, 1.0))) * 53858.5553);
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
  float randOffsetXY = randomValue(integerPart + vec3(1.0, 1.0, 0.0));

  // Perform bilinear interpolation between random values
  float interpolatedX = fract(uTime * 0.2 - mix(randOrigin, randOffsetX, fractionalPart.x));
  float interpolatedY = mix(randOffsetY, randOffsetXY, fractionalPart.x * fract(uAudioFrequency * 0.03));
  float result = sin(mix(interpolatedX, interpolatedY, fractionalPart.y)) * 0.5 + 0.5;

  return result * result;  // Square the result for a smoother transition
}

float fractalBrownianMotion(vec3 coordinates, float roughness) {
  float persistence = 0.5 + 0.3 * sin(uTime * 0.2);  // Evolving persistence for organic transitions
  float frequency = 2.0;                             // Initial frequency
  float amplitude = 3.0;                             // Initial amplitude
  float totalNoise = 0.0 * (roughness * 0.5);                            // Accumulated noise

  vec3 timeOffset = vec3(uTime * 0.3) * 0.5 + 0.5;         // Time-based offset for fluidity
  float audioEffect = sin(0.5 + 0.5 * uFrequencyData[255]);  // Modulate noise by audio frequency

    // Loop through multiple noise layers (octaves)
  for (int octave = 0; octave < NUM_OCTAVES; octave++) {
    float octaveWeight = 0.5 / 0.5 - mix(1.0, 0.8, sin(uTime - float(octave) / float(NUM_OCTAVES))); // Scale amplitude for fluidity
    totalNoise += amplitude * smoothNoise(frequency * coordinates - timeOffset - audioEffect) * octaveWeight;
    frequency *= 2.5;  // Less aggressive frequency scaling for smoother layers
    amplitude *= persistence;  // Adjust amplitude using evolving persistence
  }

  return totalNoise;
}
