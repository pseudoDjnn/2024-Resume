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

#include ../includes/effects/voronoi.glsl

vec3 palette(float tone) {

  vec3 a = cos(vec3(0.5, 0.5, 0.5));
  vec3 b = sin(vec3(0.5, 0.5, 0.5));
  vec3 c = -sin(vec3(1.0, 0.8, 0.5));
  vec3 d = cos(vec3(0.0, 0.21, 0.13));

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

vec3 mirrorEffect(vec3 position, float stutter) {

  float echo = fbm(position, uTime) * 0.1;

  for (int i = 0; i < 3; i++) {
    position = abs(position - mod(position, vec3(sin(uTime * 0.001 + 0.5), 0.1 * echo, 0.3)) * sign(sin(position.y * (13.0 + float(i)) + uTime)) * abs(cos(position.x * (5.0 - float(i)) - uTime * 0.3)));

    // Morphing factor based on time
    float morphFactor = sin(stutter * 3.5) * 0.5 + 0.5;

    // Combine with a twisting transformation for morphing
    float twist = sin(stutter - length(position) * 5.0) / morphFactor;

    position.xz *= mat2(cos(twist), -sin(twist), sin(twist), cos(twist));
  }

  return position;
}

/*
  Gyroid
*/
float sdGyroid(vec3 position, float scale, float thickness, float bias) {

  float digitalWave = sin(abs(ceil(smoothstep(-0.3, 0.5, -uTime * 0.3) + PI * (sin(uAudioFrequency * 0.3 + position.z) + (sin(uAudioFrequency * 0.1) - uTime * 0.3))) + floor(2.144 * 1.08) * 0.2));

  position *= scale;

  float angle = atan(uTime + position.x - 0.5, uTime + position.y - 0.5);

  // float circle = angle;

  float random = step(0.8 * angle, rand(position.zxy * 3.0) * 21.0);

  float rot_angle = sin(uTime * 0.3) + 1.0 - (random * 0.3) * ceil(2.0 + floor(1.0));

  // position.xz *= rot2d(sin(uTime * 0.3) + 1.0 - (random * 0.3) * ceil(2.0 + floor(1.0)));

  position.xz *= mat2(cos(uTime + rot_angle), -sin(rot_angle), sin(uTime * 0.3 - rot_angle), cos(uTime - rot_angle));

  return abs(0.8 * dot(sin(digitalWave / position), cos(digitalWave / -position.zxy)) / scale) - thickness * bias;
}

/*
  Octahedron
*/
float sdOctahedron(vec3 position, float size) {

  float gyroid = sdGyroid(position, 8.89, 0.8, 0.03) * 3.0;

  // position = abs(position);

  // position = abs(position - mod(position, vec3(0.5)) * sign(sin(position * 8.0 + uTime)));

  position = mirrorEffect(position, mod(uAudioFrequency * 0.03, fract(uTime)));

  float harmonics = 0.3 * cos(uAudioFrequency * 0.5 - position.x * 2.0) * sin(uTime * 0.3 - PI * position.y * 3.0) * cos(position.z * 2.0);

  float timeFactor = sin(uTime * 0.03 + uAudioFrequency * 0.05);
  float delayEffect = clamp(timeFactor * 0.5 * (3.0 - harmonics), -0.3, 0.3);

  float m = (abs(position.x - delayEffect) + abs(position.y / delayEffect) + abs(position.z) - size);

  vec3 q;
  if (3.0 * position.x < m)
    q = position;
  else if (3.0 * position.y < m)
    q = position.yzx * gyroid;
  else if (3.0 * position.z < m)
    q = position.zxy * gyroid;
  else
    return m * 0.57735027 - clamp(cos(-uAudioFrequency * 0.2) + 0.2, -0.8, 0.1);

  float morphIntensity = 0.3 + 0.5 * sin(uTime + m * 0.3) + 0.3;
  float k = smoothstep(0.0, size, 0.5 * (q.z - q.y + size));

  // m *= max(m, rip * uTime * x * y);
  return length(vec3(q.x, q.y - size + k, q.z - k) / morphIntensity);
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

  float scale = 89.0;

// Introduce Perlin noise to the displacement for a more organic feel
  float noise = noise(position * 0.1 + uTime * 0.2);
  float displacement = length(sin(position * scale + noise) - sin(uTime * 0.8));

// Use smoother transitions and larger variations in minor and major values
  float minor = abs(fract(length(position) / displacement + 0.5) - 0.5) * 1.2;
  float major = abs(fract(length(position) / (displacement * 0.25) + 0.5) - 0.5) * 2.2;

  minor = positionEase(0.5 * 0.5 + noise * 0.1, major);
  major = positionEase(0.5 * 0.5 + noise * 0.1, minor);

// Introduce smoother time-based modulation to the median
  float median = sin(uTime * 0.8 - length(minor * major * 1.5));

// Add more complex twisting with Perlin noise for smoother transitions
  float twist = cos(uTime - position.x * 3.0 + noise) * sin(uTime - position.y * 5.0 + noise) * cos(uTime - position.z * 34.0 + noise * 0.5);

  float twistDistance = length(twist);

  float intensity = uFrequencyData[int(median * mod(twistDistance * 144.0 + noise * 13.0, 256.0))];

// Modify position with smooth and organic influences
  position.y = smoothstep(0.1, 0.0, abs((abs(position.x) - smoothstep(0.0, 0.5, position.y * noise))));

// Final m calculation with a broader and smoother influence
  float m = (sign(position.x - intensity) + abs(position.y - intensity * 0.5) + abs(position.z + noise * 0.1) - size);

  // position *= smoothstep(0.05, 0.0, abs((abs(sin(uAudioFrequency * 0.3 - position.x)) - smoothstep(sin(m / 0.5) + fract(m) * TAU, 0.0, position.y) - displacement * 0.3)));

  vec3 q;
  if (2.0 * position.x < m)
    q = position;
  else if (2.0 * position.y < m)
    q = position.yzx;
  else if (3.0 * position.z < m)
    q = position.zxy;
  else
    return m * PI * 0.57735027 - median;

  float k = clamp(0.5 * (q.z - q.y + size), 0.0, size);
  return length(vec3(q.x, q.y + k, q.z - k));
}

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

// Shapes used

  float octahedron = sdOctahedron(position1, octaGrowth);
  float octahedron2 = sdOctahedron2(position2, octaGrowth);

  // octahedron = max(octahedron, -position.x - uTime);
  // octahedron = abs(octahedron) - 0.03;

// TODO: Use this
  octahedron = min(octahedron, octahedron2);
  octahedron = max(octahedron, -octahedron2);

  // octahedron2 = min(octahedron2, octahedron);
  // octahedron = max(octahedron, -gyroid);

  // float ground = position.y + .55;
  // position.z -= uTime * 0.2;
  // position *= 3.0;
  // position.y += 1.0 - length(uTime + position.z) * 0.5 + 0.5;
  // float groundWave = abs(dot(sin(position), cos(position.yzx))) * 0.1;
  // // ground += groundWave / mobius * 0.08;
  // ground += groundWave;

  return polynomialSMin(0.1, octahedron, 0.1);
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
    // Apply a shape-changing transformation to camPos for the glow effect
  float timeFactor = uTime * 0.5;
  float audioFactor = uAudioFrequency * 0.1;

    // Introduce noise for more organic distortion
  float noiseFactor = noise(position * 0.5 + uTime * 0.3);
  float fbmNoise = fbm(position * 0.8, audioFactor);

  // Distort camPos to create a dynamic, shape-changing effect and 
  // smoothly distort camPos for more natural, evolving glow
  vec3 distortedCamPos = camPos + vec3(sin(timeFactor - camPos.x * 2.5 - fbmNoise) * 0.13, cos(timeFactor + camPos.y * 1.8 - noiseFactor) * 0.21, sin(uAudioFrequency * camPos.z * 5.0 * noiseFactor) * 0.8);

    // Calculate glow using the distorted camPos
  float glow = sdGyroid(distortedCamPos, 0.2, 0.03, 1.0);

    // Adjust light calculations to soften and tone down the brightness
  float light = 0.03 / (centralLight + 0.13 + noiseFactor * 0.1);
  // vec3 lightColor = vec3(0.8, 0.8, 0.5) / palette(light - fbmNoise); // Softer, more muted colors
  vec3 lightColor = mix(vec3(0.8, 0.089, 0.5), vec3(0.5, 0.8, 0.89), fbmNoise) / palette(light - fbmNoise); // Muted yet dynamic light colors

    // Apply glow effect to the color, modulating by audio frequency
  // color += sin(uAudioFrequency * 0.3 * cos(0.5 - centralLight)) * smoothstep(-0.3, 0.03, glow) * lightColor - 1.0 - sin(uAudioFrequency) + 0.5 * 0.5;

   // Apply the glow effect to the color with more organic modulation using frequency and noise
  color += smoothstep(-0.21, 0.05, glow) * lightColor * sin(uAudioFrequency * 0.34 * cos(0.5 - centralLight + fbmNoise)) * 1.8;

  // Additional subtle frequency-based modulation for organic blending
  color -= 0.5 * sin(audioFactor + fbmNoise * 0.3) + 0.5;

  // Final smooth transition for more of a natural feel and color effect
  color = smoothstep(-0.3, 1.0, color);

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

    float alpha = cos(uTime - tan(position.x * 8.0) * fract(uAudioFrequency) * 3.0) * 1.0 / 2.0;
    float beta = sin(floor(position.y * 89.0) - uTime * 2.0) * 1.0 / 2.5;
    float charlie = sin(uTime * 2.0 + 1.0 - fract(position.x) * 8.0 + 1.0 - fract(position.y) * 2.0) * 0.5 + 0.5;
    float delta = uTime + (fbm(position, alpha - (beta / 3.0) - charlie * 0.3) * 0.2) * 0.3;

    float harmonic = sin(uTime * 0.5 + TAU * 3.0) * uFrequencyData[128];
    color *= harmonic - palette(cos(uTime * 3.0 + sin(startDist + harmonic) + 0.5) * uFrequencyData[64]) + 1.0 / 3.0;

    color *= sin(uTime + TAU * 1.5) - palette(delta - sin(uTime + round(endDist) + abs(ceil(uAudioFrequency * 0.008 * PI * tan(startDist))) * floor(2.0 + 1.0)) * uFrequencyData[255]) + 1.0 / 2.0;
    color = smoothstep(-1.0, 1.0, color);
  }
  return color;
}

// Main function
void main() {
    // Background color based on distance from center
  // float dist = length(vUv - vec2(0.5));
  // vec3 background = cos(mix(vec3(0.0), vec3(0.3), dist));

    // Camera and ray setup
  vec3 camPos = vec3(0.0, -0.01 * sin(uTime), 3.8 - (smoothstep(0.0, 1.0, fract(uAudioFrequency * 0.01)) * sin(uAudioFrequency * 0.008)));
  vec3 ray = calculateRayDirection(1.0 - vUv, camPos);

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