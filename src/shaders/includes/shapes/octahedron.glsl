/*
  Octahedron
*/
float sdOctahedron(vec3 position, float size) {

  position.z /= 0.3;
  position.x += smoothstep(0.0, 0.8, sin(uTime) * 0.2) / uAudioFrequency;
  position.y -= 0.02;

  // float time = uTime * 3.0 + 5000.0 + sin(uTime / 3.0) * 5.0;
  // float time = exp(-uTime * 0.1) - smoothstep(0.0, 1.0, 55.0) - sin(uTime * 0.5) * 8.0;
  // float time = exp(-uTime * 0.2) + cos(uTime * 0.3) * 5.0 - smoothstep(0.5, 1.5, 25.0);
  // float time = sin(uTime * 0.4) * smoothstep(0.0, 2.0, uTime * 0.1) - exp(-uTime * 0.05);
  // float time = log(uTime + 1.0) * 3.0 - tan(uTime * 0.2) + smoothstep(0.1, 1.0, 15.0);
  // float time = 1.0 / exp(uTime * 0.05) + mod(uTime, 10.0) * 2.0 - smoothstep(0.2, 0.8, 30.0);
  // float time = exp(-uTime * 0.15) * sin(uTime * 0.7) - smoothstep(0.0, 1.0, 45.0);
  // float time = pow(uTime * 0.1, 2.0) - mix(10.0, 5.0, sin(uTime * 0.3)) - smoothstep(0.0, 1.0, 65.0);
  // float time = exp(-uTime * 0.1) * abs(sin(uTime * 0.8)) - step(0.5, uTime * 0.05);
  float time = sin(uTime * 0.5) * exp(-uTime * 0.05) - smoothstep(0.2, 0.9, abs(cos(uTime * 0.3)));

  float organicNoise = fractalBrownianMotion(position * 0.3 - uTime * 0.1, 1.0 - size) * 0.5 + 0.5;

  float squareWave = abs(fract(sin((uTime - position.z * PI) * (uTime - position.y * PI)) + 1.0 * 2.0) * organicNoise);
  // squareWave = floor(cos(position.y - uTime * 0.2) * organicNoise / uTime * 0.5) + ceil(sin(position.y - cos(time * 0.8)) / time / organicNoise);

  // squareWave *= abs(squareWave * 2.0 - 1.0);
  // squareWave = 0.1 / sin(13.0 * squareWave + uTime + position.x * position.y);

  position = morphingShape(position, mod(uFrequencyData[255], squareWave), 0.5);

    // Apply a rotation around the Z-axis before taking the absolute value
  float angle = abs(fract(sin(organicNoise * 0.3)));
  mat2 rotZ = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
  position.xy = rotZ * position.xy;
  // position = abs(position);
  position = abs(position);
  // position.x *= organicNoise;

  float m = position.x + position.y + position.z - size;

  vec3 q;
  if (3.0 * position.x < m)
    q = position * smoothstep(0.0, 1.0, randomValue(position) / 0.8);
  else if (3.0 * position.y < m)
    q = position.yzx - fract(uFrequencyData[177]);
  else if (3.0 * position.z < m)
    q = position.zxy - sin(uTime) * angle;
  else
    return m * 0.57735027;

  float k = clamp(0.5 * (q.z - q.y + size), 0.0, size);

  return length(vec3(q.x, q.y - size + k, q.z - k));
}