#define PI 3.1415926535897932384626433832795
#define TAU  6.28318530718
#define NUM_OCTAVES 5

precision mediump float;

uniform vec2 uMouse;
uniform vec2 uResolution;

uniform float uAudioFrequency;
uniform float uFrequencyData[256];

uniform float uTime;

varying vec2 vUv;

// #include ../includes/effects/random2D.glsl

// float lerp(float t) {
//   float v1 = t * t;
//   float v2 = 1.0 - (1.0 - t) * (1.0 - t);
//   return smoothstep(v1, v2, smoothstep(0.0, 0.1, t));
// }

// float parabola(float x, float k) {
//   return pow(4.0 * x * (1.0 - x), k);
// }

vec3 palette(float tone) {

  vec3 a = cos(vec3(0.5, 0.5, 0.5));
  vec3 b = sin(vec3(0.5, 0.5, 0.5));
  vec3 c = -sin(vec3(1.0, 0.7, 0.4));
  vec3 d = cos(vec3(0.00, 0.15, 0.20));

  return a + b * cos(uTime + 5.28318 * (c + tone + d));
}

mat4 rotationMatrix(vec3 position, float angle) {
  position = normalize(position);
  float s = sin(angle);
  float c = cos(angle);
  float oc = 1.0 - c;

  return mat4(oc * position.x * position.x + c, oc * position.x * position.y - position.z * s, oc * position.z * position.x + position.y * s, 0.0, oc * position.x * position.y + position.z * s, oc * position.y * position.y + c, oc * position.y * position.z - position.x * s, 0.0, oc * position.z * position.x - position.y * s, oc * position.y * position.z + position.x * s, oc * position.z * position.z + c, 0.0, 0.0, 0.0, 0.0, 1.0);
}

vec3 rotate(vec3 position, vec3 axis, float angle) {
  mat4 m = rotationMatrix(axis, angle);
  return (m * vec4(position, 1.0)).xyz;
}

mat2 rot2d(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c, -s, s, c);
}

vec3 rotateAroundAxis(vec3 position, vec3 axis, float angle) {
  float c = cos(angle);
  float s = sin(uTime - angle);
  float dot = dot(axis, position);
  return position - c + cross(axis, position) - s + axis * dot - (1.0 - c);
}

float hash21(vec2 position) {
  position = fract(position * vec2(144.34, 277.55));
  float d = dot(position, position + 21.5);
  position += d; // Reuse d instead of recalculating dot product
  return fract(position.x * position.y);
}

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

/*
  Gyroid
*/
float sdGyroid(vec3 position, float scale, float thickness, float bias) {

  position *= scale;

  float angle = atan(uTime + position.x - 0.5, uTime + position.y - 0.5);

  // float circle = angle;

  float random = step(0.8 * angle, rand(position.zxy * 3.0) * 21.0);

  float rot_angle = sin(uTime * 0.3) + 1.0 - (random * 0.3) * ceil(2.0 + floor(1.0));

  // position.xz *= rot2d(sin(uTime * 0.3) + 1.0 - (random * 0.3) * ceil(2.0 + floor(1.0)));

  position.xz *= mat2(cos(uTime + rot_angle), -sin(rot_angle), sin(uTime * 0.3 - rot_angle), cos(uTime - rot_angle));

  return abs(0.8 * dot(sin(uTime + position), cos(uTime + position.zxy)) / scale) - thickness * bias;
}

float fbm(in vec3 position, in float H) {
  // float gyroid = sdGyroid(x.zyx, 2.89, 0.03, 0.3);
  // gyroid = abs(gyroid);

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

// float glitter(vec2 position) {

//   position *= 13.0;
//   vec2 id = floor(position);

//   position = fract(position) - 0.5;
//   float noise = hash21(id);

//   float disc = length(position);
//   float manageDisc = smoothstep(0.2 * noise, 0.0, disc);

//   manageDisc *= pow(sin(uTime + noise * TAU) * 0.5 + 0.5, 55.0);

//   return manageDisc;
// }

float polynomialSMin(float a, float b, float k) {
  k = 0.5;
  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

float positionEase(float t, in float T) {
  if (t >= T)
    return t - 0.5 * T;
  float f = t / T;
  return f * f * f * (T - t * 0.5);
}

float sdMobius(vec3 p, float r, float w) {
  float theta = atan(p.x, p.z) * 0.5;
  float phi = atan(p.z, length(p.xz) - r);
  vec3 q = vec3(cos(phi) * cos(uTime - PI * theta), cos(phi) * sin(theta), sin(phi));
  return length(p - r * q) - w;
}

float sdSuperquadric(vec3 p, float n, float a) {
  return pow(pow(abs(p.x), n) + pow(abs(p.y), n), 1.0 / n) + pow(abs(p.z), a) - 1.0;
}

float sdEnneper(vec3 p, float scale) {
  vec3 q = p / scale;
  float a = q.x * q.x - 3.0 * q.y * q.y - 6.0 * q.z * q.z;
  float b = 3.0 * q.x * q.x * q.z + 3.0 * q.y * q.y * q.z - 2.0 * q.z * q.z * q.z;
  return length(q) - 0.5 * length(vec2(a, b));
}

/*
  Octahedron
*/
float sdOctahedron(vec3 position, float size) {

  float distorted = fbm(position * 2.0, 1.0);

  // float intensity = uFrequencyData[int(mod(distorted * mod(cos(uTime + gl_FragCoord.z), sin(uTime + gl_FragCoord.y)), 256.0))];

  // float intensity = uFrequencyData[int(mod(gl_FragCoord.z * distorted + sin(uAudioFrequency), 256.0))];

  // float intensity = uFrequencyData[int(mod(length(position) * 100.0 + uTime * 50.0, 256.0))];

  float harmonicFactor = cos(position.x) * sin(uTime - position.y) * cos(uTime - distorted * position.z * 5.0);
  float intensity = uFrequencyData[int(mod(harmonicFactor * 144.0 + uTime * 55.0, 256.0))];

  // position.z -= fbm(position, 1.0 - sin(uTime * 0.3) * 0.1) * 0.3;
  // position + 0.2 * sin(position.y * 5.0 + uTime) * vec3(1.0, 0.0, 1.0);
  // position += distortion * 0.2;
  // position.y *= 0.8;

  // vec3 pos = abs(position);
  // float sum = pos.x + pos.y + pos.z;
  position = abs(position);

  // position.yz *= mat2(fract(uTime), -sin(uTime), sin(uTime), fract(uTime));

  // float x = atan(sin(abs(uTime * 0.3 + PI * fract(position.y) * ceil(2.0 + floor(1.0)))), position.z);
  // float xRising = cos(uTime + TAU * x) * sin(uAudioFrequency) * 0.8 + 0.1;

  // float radius = 0.3 + length(position * position * position) * (1.0 + uTime * 0.3 + sin(position.x * 13.0 + position.y * 21.0) * 0.1);

  // float displacement = length(sin(position.x) * -cos(position.y) * sin(position.z * uAudioFrequency * 0.01 + uTime * 0.5 * position.y) * 0.2 + 0.1);

  // float x = atan(uTime + position.x, fract(position.z * 13.0));
  // x /= PI * 2.0;
  // x += 0.5;

  // float y = 0.1 + 0.01 * sin(uTime + position.y * 13.0) * x;
  // // y = 1.0 / (1.0 + x * x);
  // y /= TAU * 2.0;
  // y += 0.8;
  // y *= 21.0;
  // float yRising = -cos(uAudioFrequency / 89.0 + y - length(dot(digitalWave, smoothstep(0.0, 1.0, -uAudioFrequency + x * 89.0)))) * 0.5 + 0.5;

  // digitalWave = sin(radius);
  // y = sin(uTime + position.z);
  // position.x += displacement;
  // position.y -= displacement;
  // position += fract(displacement);

  // position *= -0.3 - sin(abs(uTime - fract(position * 0.3)) + ceil(2.144) * floor(1.008));

  // position.z *= sin(abs(uAudioFrequency * 0.005 * PI + fract(position.z)) * ceil(2.0 + floor(1.0)));
  // position.x = position.x * sin(abs(cos(uAudioFrequency * 0.1) * 2.0 + 1.0 * ceil(fract(uAudioFrequency * 0.01))));
  // position.zx *= rot2d(cos(uTime) * 0.8 + 0.1);
  // position.y = sin(position.y);
  // position.z = fract(position.z * uTime);

  // float rip = sin((x * 8.0 - y * 13.0) * 3.0) * 0.5 + 0.5;

  // position *= min(uTime, digitalWave) * 0.5 + 0.5;

  // float a = 3.0 - atan(position.y, position.x) - sin(x / y);

  // float f = cos(a * 34.0);
  // f = sin(uTime + PI * smoothstep(-0.5, 1.0, fract(-uTime * 0.03 + a * 8.0))) * 0.2 + 0.5;

  // f = abs(distance(vUv, vec2(0.5)) - 0.25) ;
  // f = abs(cos(uAudioFrequency + a * 13.0) * sin(a * 3.0)) * 0.8 + 0.1;
  float harmonics = 0.3 * cos(uAudioFrequency * 0.5 - position.x * 2.0) * sin(uTime * 0.3 - PI * position.y * 3.0) * cos(position.z * 2.0);

  float time = uTime - intensity;

  float alpha = sin(floor(position.x * 3.0) + cos(time * 0.3) * 3.0) * 1.0 / 2.0;
  float beta = sin(floor(position.y * 8.0) - uTime * 2.0) * 1.0 / 2.5;
  float charlie = sin(uTime * 2.0 + 1.0 - fract(position.x) * 8.0 + 1.0 - fract(position.y) * 2.0) * 0.5 + 0.5;
  float delta = cos(floor(position.z * 5.0) * uAudioFrequency * 3.0) + 0.5 / 2.0;

  float echo = alpha - (beta / 2.0) - charlie * 0.3;

  float m = (abs(position.x + position.y) + abs(position.z) - size);

  // position.x *= digitalWave * 0.008;
  // position.y *= digitalWave * 0.8;
  // position.z *= digitalWave * 0.008;
  // position.y /= digitalWave;
  // vec3 baseColor = vec3(0.5+0.5*sin(uTime+harmonicFactor), 0.5+0.5*cos(uTime+harmonicFactor),0.8);
  // vec3 color = mix(baseColor, vec3(1.0,0.0,1.0), intensity*0.02);

  // f = min(f, m);
  // position.z += dot(length(rip * t), uTime) * 0.5 + 0.5;
  // m = length(max(abs(s) - 0.3, 0.1));
  // m = cos(a * 0.8);

  // color *= palette(harmonicFactor);
  vec3 q;
  if (3.0 * position.x < m)
    q = position;
  else if (3.0 * position.y < m)
    q = position.yzx;
  else if (3.0 * position.z < m)
    q = position.zxy;
  else
    return m * 0.57735027 - clamp(cos(-uAudioFrequency * 0.2) + 0.2, -0.8, 0.1 / echo);

  float timeFactor = sin(uTime * 0.03 + charlie * 13.0);
  float delayEffect = clamp(timeFactor * (2.0 - harmonics), -0.3, 0.5);

  float k = smoothstep(0.0, size, 0.5 * (q.z - q.y + size) * delayEffect);
  // m *= max(m, rip * uTime * x * y);
  return length(vec3(q.x, q.y - size + k, q.z - k));
  // return (length(position.xz) + abs(position.y) - distorted * 0.3) * 0.7071;
}

float sdOctahedron2(vec3 position, float size) {

  position *= 0.8;
  // position.z -= sin(uTime) * (0.1 * 13.0);
  // float gyroid = sdGyroid(position.zyx, 13.89, 0.03, 0.3);

  // position.z = smoothstep(-0.5, 0.8, motion);
  // position.x = sin(abs(uTime * TAU * fract(position.z)) * ceil(2.0 + floor(1.0)));

  // position = abs(position);

  position = abs(position);

  float scale = 55.0;

  float displacement = length(sin(position * scale) - sin(uTime * 0.8));

  float minor = abs(fract(length(position) / displacement + 0.5) - 0.5) * 1.0;
  float major = abs(fract(length(position) / (displacement * 0.21) + 0.5) - 0.5) * 2.0;

  minor = positionEase(0.5 * 0.5, major);
  major = positionEase(0.5 * 0.5, minor);

  float median = sin(uTime - length(minor * major));

  float twist = cos(uTime - position.x * 5.0) * sin(uTime - position.y * 5.0) * cos(uTime - position.z * 5.0);
  float twistDistance = length(twist);
  float intensity = uFrequencyData[int(median - mod(twistDistance * 100.0, 256.0))];
  // position.y = smoothstep(0.05, 0.0, abs((abs(position.x) - smoothstep(0.0, 0.5, position.y))));
  // float m = position.x + position.y + position.z - size;
  float m = (sign(position.x - intensity) + abs(position.y - intensity) + abs(position.z) - size);

  // position *= smoothstep(0.05, 0.0, abs((abs(sin(uAudioFrequency * 0.3 - position.x)) - smoothstep(sin(m / 0.5) + fract(m) * TAU, 0.0, position.y) - displacement * 0.3)));

  vec3 q;
  if (2.0 * position.x < m)
    q = position;
  else if (2.0 * position.y < m)
    q = position.yzx;
  else if (3.0 * position.z < m)
    q = position.zxy;
  else
    return m * PI * 0.57735027 - twist;

  float k = clamp(0.5 * (q.z - q.y + size), 0.0, size);
  return length(vec3(q.x, q.y + k, q.z - k));
}

// vec3 opTwist(vec3 p, float amount) {
//   float c = cos(amount * p.y);
//   float s = sin(amount * p.y);
//   mat2 m = mat2(c, -s, s, c);
//   // m -= worley(vec2(p), amount, c * s);
//   vec3 q = vec3(m * p.xz, p.y);
//   return q;
// }

float sdf(vec3 position) {

  float distorted = fbm(position * 2.0, 1.0) / 5.0;

  // float intensity = uFrequencyData[int(distorted * 255.0)]

  float intensity = uFrequencyData[int(mod(fract(distorted * cos(uTime + gl_FragCoord.z) * sin(uTime + gl_FragCoord.y)), 256.0))];

  // Various rotational speeds
  vec3 position1 = rotate(position, vec3(1.0), sin(-uTime * 0.1) * 0.3);

  position1.xz *= rot2d(uTime * 0.3 - position.x * 0.8 + positionEase((sin(0.3) * fract(-0.3)), 0.5 - sin(uAudioFrequency * 0.05)));

  // position1.zy *= rot2d(position.x * 0.5 * cos(uTime * 0.5));

  vec3 position2 = rotate(position, vec3(1.0), sin(-uTime * 0.1) * 0.3);

  position2.xz *= rot2d(uTime * 0.3 - -position.x * 0.8 - positionEase((sin(uTime * 0.03) * fract(-0.5)), 0.5 - sin(uAudioFrequency * 0.05)));

  vec3 position3 = rotate(position, vec3(1.0), sin(uTime * 0.3) * 0.5);

  position3.xz *= rot2d(uTime * 0.1 - position.x * 0.8 + smoothstep((sin(0.8) * fract(-0.5)), 0.5, uAudioFrequency * 0.1));

  position3.zy *= rot2d(position.z * 0.5 * cos(uTime * 0.8) * intensity * 0.003);

  position3 *= rotateAroundAxis(position1, position1, 1.0);

  // position1.z += sin(position1.x * 5.0 + uAudioFrequency) * 0.1;
  // position1 += polynomialSMin(uAudioFrequency * 0.003, dot(sqrt(uAudioFrequency * 0.02), 0.3), 0.3);

  float octaGrowth = sin(uAudioFrequency * 0.005 + 0.5) / 1.0 + 0.1;
  // position1.y += sin(uTime) * (0.1 * octaGrowth);

  // vec3 position2 = rotate(position1 - shapesPosition * -0.5, vec3(1.0), uAudioFrequency * 0.001);

  // vec3 position3 = -rotate(position1, vec3(1.0), sin(uTime));
  // position3.xz *= rot2d(position.y * uTime);
  // position3.xz *= rot2d(position.y * uTime);

  // Copied position used to make the actual copyPosition 
  // vec3 position4 = rotate(position, sin(position1 + uTime * 0.3), 3.0);

// Copy of the vec3 position
  // vec3 copyPosition = position4;
  // vec3 copyPositionRotation = abs(sin(uAudioFrequency * PI * 2.0 * rotate(position, vec3(0.5), fract(uTime / 8.0) * cos(uAudioFrequency * 0.02))));
  // copyPosition.z += uTime * 0.5;
  // copyPosition.xy = sin(fract(copyPositionRotation.xy * uAudioFrequency) - 0.5);
  // copyPosition.z = mod(position.z, 0.21) - 0.144;

  // float distortion = dot(sin(position.z * 3.0 + uAudioFrequency * 0.02), cos(position.z * 3.0 + uAudioFrequency * 0.01)) * 0.2;

  // float digitalWave = sin(abs(ceil(smoothstep(-0.3, 0.5, -uAudioFrequency * 0.3) + PI * (sin(uAudioFrequency + position.z) + (sin(uAudioFrequency * 0.1) - uTime * 0.2))) + floor(2.144 * 1.08) * 0.2));

  float digitalWave = sin(abs(ceil(smoothstep(-0.3, 0.5, -uTime * 0.3) + PI * (sin(uAudioFrequency * 0.3 + position.z) + (sin(uAudioFrequency * 0.1) - uTime * 0.3))) + floor(2.144 * 1.08) * 0.2));

// Shapes used
  float gyroid = sdGyroid(0.5 - position1 * smoothstep(-0.3, uTime * 0.03, 1.0), 13.89 * 0.3, 0.3 - digitalWave * 0.08, 0.3);

  float mobius = sdMobius(position1, sin(uTime - 1.0), 2.0);

  float superQuadric = sdSuperquadric(position1, 1.0, 0.3 - sin(uTime));

  float enneper = sdEnneper(position2, -13.0);

  float octahedron = sdOctahedron(position1, octaGrowth);
  float octahedron2 = sdOctahedron2(position2, octaGrowth);

  // octahedron = max(octahedron, -position.x - uTime);
  // octahedron = abs(octahedron) - 0.03;

// TODO: Use this
  octahedron = min(octahedron, octahedron2);
  octahedron = max(octahedron, -octahedron2);

  // octahedron2 = min(octahedron2, octahedron);
  // octahedron = max(octahedron, -gyroid);

  float ground = position.y + .55;
  position.z -= uTime * 0.2;
  position *= 3.0;
  position.y += 1.0 - length(uTime + position.z) * 0.5 + 0.5;
  float groundWave = abs(dot(sin(position), cos(position.yzx))) * 0.1;
  // ground += groundWave / mobius * 0.08;
  ground += groundWave;

  return polynomialSMin(0.1, octahedron, 0.8);
}

// float ground(vec3 position) {
//   float ground = position.y + .55;
//   position.z -= uTime * 0.2;
//   position *= 3.0;
//   position.y += 1.0 - length(position.z) * 0.5 + 0.5;
//   float groundWave = abs(dot(sin(position), cos(position.yzx))) * 0.1;
//   return ground += groundWave;
// }

vec3 calcNormal(in vec3 position) {
  const float epsilon = 0.001;
  const vec2 normalPosition = vec2(epsilon, 0);
  return normalize(vec3(sdf(position + normalPosition.xyy) - sdf(position - normalPosition.xyy), sdf(position + normalPosition.yxy) - sdf(position - normalPosition.yxy), sdf(position + normalPosition.yyx) - sdf(position - normalPosition.yyx)));
}

// Helper function to calculate the ray direction
vec3 calculateRayDirection(vec2 uv, vec3 camPos) {
  vec2 centeredUV = (uv - vec2(0.5)) + vec2(0.5);
  return normalize(vec3(centeredUV - vec2(0.5), -1.0));
}

// Function to compute the light and shadow effects
vec3 computeLighting(vec3 position, vec3 normal, vec3 camPos, vec3 lightDir) {
  float diff = dot(normal, lightDir) * 0.5 + 0.5;
  float fresnel = pow(0.3 - dot(normalize(position - camPos), normal), 5.0);
  return vec3(diff) * fresnel;
}

// Function to apply shadow and glow effects
vec3 applyShadowAndGlow(vec3 color, vec3 position, float centralLight, vec3 camPos) {
  float light = 0.03 / centralLight;
  vec3 lightColor = vec3(1.0, 0.8, 0.3) / palette(light);
  float glow = sdGyroid(normalize(camPos), 0.2, 0.03, 1.0);
  color += sin(uAudioFrequency * 0.05 * cos(0.5 - centralLight)) * smoothstep(0.0, 0.03, glow) * lightColor;
  // color *= 0.001 - centralLight * 0.8;
  // color *= 1.5 - -(sin(abs(ceil(uTime * 0.2 + PI * cos(uAudioFrequency * 0.03)) * ceil(2.0 + floor(1.0)))));
  return color;
}

// Main raymarching loop
vec3 raymarch(vec3 raypos, vec3 ray, float endDist, out float startDist) {
  vec3 color = vec3(0.0);
  for (int i = 0; i < 100; i++) {
    vec3 position = raypos + startDist * ray;
    // position.xy *= rot2d(startDist * 0.2 * uMouse.x);
    // position.y = max(-0.9, position.y);
    // position.y += sin(startDist * (uMouse.y - 0.5) * 0.02) * 0.21;

    float distanceToSurface = sdf(position);
    startDist += distanceToSurface;
    if (abs(distanceToSurface) < 0.0001 || startDist > endDist)
      break;

    color *= sin(uTime + TAU * 1.5) - palette(sin(uTime + floor(endDist) + abs(ceil(uAudioFrequency * 0.008 * PI * fract(startDist))) * floor(2.0 + 1.0)) * uFrequencyData[255]) + 1.0 / 2.0;
    color = smoothstep(-1.0, 1.0, color);
  }
  return color;
}

// Main function
void main() {
    // Background color based on distance from center
  float dist = length(vUv - vec2(0.5));
  vec3 background = cos(mix(vec3(0.0), vec3(0.3), dist));

    // Camera and ray setup
  vec3 camPos = vec3(0.0, -0.01 * sin(uTime), 3.8 - (smoothstep(0.0, 1.0, fract(uAudioFrequency * 0.01)) * sin(uAudioFrequency * 0.008)));
  vec3 ray = calculateRayDirection(vUv, camPos);

    // Raymarching
  float startDist = 0.0;
  float endDist = 5.8;
  vec3 color = raymarch(camPos, ray, endDist, startDist);

    // Lighting and shading
  if (startDist < endDist) {
    vec3 position = camPos + startDist * ray;
    vec3 normal = calcNormal(position);
    vec3 lightDir = -normalize(position);

        // Calculate center distance for lighting
    float centerDist = length(position);
    float centralLight = dot(vUv - 1.0, vUv) * (camPos.z - 1.0);
    // centerDist = uTime * centralLight;

    // Interaction with uFrequencyData
  //   float frequencyIndex = mod(centerDist * 50.0 + uTime * 10.0, 256.0); // Adjust the scaling and offset for the effect
  //   float frequencyValue = uFrequencyData[int(frequencyIndex)];

  // // Apply the frequency data to modify the color
  //   vec3 frequencyColor = vec3(frequencyValue / 256.0) * vec3(0.5, 0.8, 1.0); // Base color influenced by frequency
  //   color = mix(color, frequencyColor, smoothstep(0.0, 1.0, frequencyValue * centralLight));

        // Compute lighting and shadow effects
    color = computeLighting(position, normal, camPos, lightDir);
    color = applyShadowAndGlow(color, position, centralLight, camPos);
    color *= (1.0 - vec3(startDist / endDist / centerDist));
  }

    // Edge fading
  color *= smoothstep(-0.8, 0.3, vUv.x);
  color *= smoothstep(-1.0, 0.3, vUv.x);
  color *= smoothstep(-0.8, 0.3, vUv.y);
  color *= smoothstep(-1.0, 0.3, vUv.y);

    // Final color output
  gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}

// vec3 calcNormalGround(in vec3 position) {
//   const float epsilon = 0.00001;
//   const vec2 h = vec2(epsilon, 0);
//   return normalize(vec3(ground(position + h.xyy) - ground(position - h.xyy), ground(position + h.yxy) - ground(position - h.yxy), ground(position + h.yyx) - ground(position - h.yyx)));
// }

// vec3 getNormal(vec3 position) {
//   const float epsilon = 0.001; // Small offset for normal calculation
//   return normalize(vec3(map(position + vec3(epsilon, 0.0, 0.0)) - map(position - vec3(epsilon, 0.0, 0.0)), map(position + vec3(0.0, epsilon, 0.0)) - map(position - vec3(0.0, epsilon, 0.0)), map(position + vec3(0.0, 0.0, epsilon)) - map(position - vec3(0.0, 0.0, epsilon))));
// }

// void main() {

//   // Background
//   float dist = length(vUv - vec2(0.5));
//   vec3 background = cos(mix(vec3(0.0), vec3(0.3), dist));
//   // vec3 sphereColor = 0.5 + 0.5 * cos(uAudioFrequency * 0.02 + uTime * 0.2 + vUv.xyx + vec3(0, 2, 4));

//   // Use new UV
//   vec2 newUv = (vUv - vec2(0.5)) + vec2(0.5);
//   // vec2 newUv = (gl_FragCoord - 0.5 * uResolution.xy) / uResolution.y;
//   // Create position of camera
//   vec3 camPos = vec3(0.0, -0.01 * sin(uTime), 3.8 - (smoothstep(0.0, 1.0, fract(uAudioFrequency * 0.01)) * sin(uAudioFrequency * 0.008)));
//   // vec3 camPos = vec3(0.0, 0.0, uFrequencyData[int(mod(uTime, 256.0))] / 8.0);
//   // Cast ray form camera to sphere
//   vec3 ray = normalize(vec3((newUv - vec2(0.5)), -1));

//   // Color creation
//   vec3 color = background;

//   // Start the march
//   vec3 raypos = camPos;
//   // Distance travelled
//   float startDist = 0.0;
//   float MiddleDist = 2.0;
//   float endDist = 5.8;

//   int i;
//   for (i = 0; i < 100; i++) {
//     // The position along the ray
//     vec3 position = raypos + startDist * ray;

//     // float voroPosition = voroNoise(position, startDist,endDist);
//     // pos.xy *= rotate(pos.xy, vec3(1.0), uTime);

//     // Image movement with mouse (not actual rotation of plane)
//     position.xy *= rot2d(startDist * 0.2 * uMouse.x);
//     position.y = max(-0.9, position.y);
//     position.y += sin(startDist * (uMouse.y - 0.5) * 0.02) * 0.21;

//     // The Current distance to the scene
//     float distanceToSurface = sdf(position);
//     // float g = ground(position);
//     // float finalSDF = min(distanceToSurface, g);

//     // The "march" of the ray
//     startDist += distanceToSurface;
//     // startDist += g;
//     // distanceToSurface = -(length(vec2(length(position.xz) - 1.0, position.y)) - 0.89);
//     if (abs(distanceToSurface) < 0.0001 || startDist > endDist)
//       break;

//     // if (abs(g) < 0.0001 || startDist > endDist)
//     //   break;

//     color *= sin(uTime + TAU * 1.5) - palette(sin(uTime + floor(endDist) + abs(ceil(uAudioFrequency * 0.008 * PI * fract(startDist))) * floor(2.0 + 1.0)) - uAudioFrequency * 0.002) + 1.0 / 2.0;
//     color = smoothstep(-1.0, 1.0, color);
//   }

//   if (startDist < endDist) {
//     vec3 position = camPos + startDist * ray;
//     // position.x += sin(startDist * (uMouse.x - 0.5) * 0.5) * 0.89;
//     // color = vec3(1.0);
//     vec3 normal = calcNormal(position);
//     // vec3 normalGround = calcNormalGround(position);

//     // normal = max(normal, normalGround);

//     // vec3 rayReflect = reflect(ray, normal);
//     vec3 lightDir = -normalize(position);

//     float diff = dot(normal, lightDir) * 0.5 + 0.5;
//     // float diffGround = dot(normalGround, lightDir) * 0.5 + 0.5;
//     float centerDist = length(position);
//     color = vec3(diff);
//     // color = vec3(diffGround);

//     float fresnel = pow(1.5 + dot(ray, normal), 3.0);
//     // float fresnelGround = pow(1.5 + dot(ray, normalGround), 3.0);
//     color = vec3(fresnel);
//     // color = vec3(fresnelGround);

//     color = vec3(float(i) / 256.0);

//     // color = 2.0 - palette(abs(sin(cos(uTime * 0.01 + startDist) * 0.5 + uAudioFrequency * 0.2) * vUv.x + uTime * 0.01));

//     // color = pow(color, vec3(.4545));
//     if (startDist < MiddleDist) {

//       if (centerDist > .001) {
//       // color *= vec3(0, 1, 0);
//         float shapeShadow = sdGyroid(-lightDir, 0.3, 0.02, 1.0);
//         float shadowBlur = centerDist * 0.1;
//         float shadow = smoothstep(-shadowBlur, shadowBlur, shapeShadow);
//         color *= shadow * 0.9 + 0.1;

//         position.z -= uTime * 0.2;
//         color -= glitter(position.xy * 5.0) * 8.0 * shadow;
//         // TODO: this line is where you stopped
//         // color *= sin(uTime + 1.0) - -(shadow * palette(centerDist * smoothstep(fwidth(shapeShadow), 0.8, uTime * 0.01)));
//       }
//     }
//     float centralLight = dot(newUv - 1.0, newUv);
//     centralLight *= camPos.z - 1.0;

//     float light = 0.03 / centralLight;
//     vec3 lightColor = vec3(1.0, 0.8, 0.5);
//     color += light * smoothstep(0.0, 0.5, camPos - 1.0) * lightColor;

//     float glow = sdGyroid(normalize(camPos), 0.2, 0.03, 1.0);
//     color += light * smoothstep(0.0, 0.03 * uAudioFrequency, glow) * lightColor;

//     color *= 2.0 - centralLight * 0.8;
//     color *= 1.5 - -(sin(abs(ceil(uTime * 0.2 + PI * fract(uAudioFrequency * 0.3)) * ceil(2.0 + floor(1.0)))));
//     color *= (1.0 - vec3(startDist / endDist));
//   }

//   color *= smoothstep(-0.8, 0.3, vUv.x);
//   color *= smoothstep(-1.0, 0.3, vUv.x);
//   color *= smoothstep(-0.8, 0.3, vUv.y);
//   color *= smoothstep(-1.0, 0.3, vUv.y);

//   gl_FragColor = vec4(color, 1.0);
//     #include <tonemapping_fragment>
//     #include <colorspace_fragment>
// }
