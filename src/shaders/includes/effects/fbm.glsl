float rand(vec3 position) {
  return fract(sin(dot(position, vec3(12.9898, 4.1414, 1.0))) * 43758.5453);
}

float noise(vec3 position) {
  vec3 ip = floor(position);
  vec3 u = fract(position);
  u = u * u * (3.0 - 2.0 * u);

  float rand_ip = rand(ip);
  float rand_ip_x = rand(ip + vec3(1.0, 0.0, 0.0));
  float rand_ip_y = rand(ip + vec3(0.0, 1.0, 0.0));
  float rand_ip_xy = rand(ip + vec3(1.0, 1.0, 1.0));

  float res = mix(mix(rand_ip, rand_ip_x, u.x), mix(rand_ip_y, rand_ip_xy, u.x), u.y);
  return res * res;
}

float fbm(in vec3 position, in float H) {

  float G = exp2(-H);
  float f = 2.0;
  float a = 2.0;
  float t = 0.0;
  vec3 timeOffset = vec3(uTime * 1.0);

  for (int i = 0; i < NUM_OCTAVES; i++) {
    t += a * noise(f * position + timeOffset);
    f *= 2.0;
    a *= G;
  }
  return t;
}