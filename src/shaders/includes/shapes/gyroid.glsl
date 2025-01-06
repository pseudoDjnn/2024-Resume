/*
  Gyroid
*/
float organicGyroid(vec3 position, float scale, float thickness, float bias) {

  // float squareWave = sin(abs(ceil(smoothstep(-0.3, 0.5, -uTime * 0.3) + PI * (sin(uAudioFrequency * 0.3 + position.z) + (sin(uAudioFrequency * 0.1) - uTime * 0.3))) + floor(2.144 * 1.08) * 0.2));

  float squareWave = abs(fract(sin(position.x * PI) + 1.0 * 2.0));
  // squareWave = floor(sin(position.z - uAudioFrequency * 0.1) / uTime * 0.3) + ceil(sin(position.y + uAudioFrequency * 0.3));
  float harmonics = 1.0 - cos(uTime * 0.3 - position.x * 2.0) - sin(uTime * 0.08 * PI * position.y * 3.0) * 0.1;

  position *= scale;

  float angle = atan(uTime - position.x - 0.8, uTime - position.y - 0.5);

  float random = step(0.8 * angle, randomValue(position.zxy * 3.0) * 21.0);

  float rot_angle = sin(uTime * 0.3) - 1.0 * (random * 0.3) * ceil(2.0 + floor(harmonics));

  position.xy *= mat2(cos(uTime * 0.03 * rot_angle), -sin(rot_angle), sin(uTime * 0.3 - rot_angle), cos(uTime - rot_angle));

  return abs(0.8 * dot(sin(squareWave / position), cos(squareWave / -position.zxy)) / scale) - thickness * bias;
}