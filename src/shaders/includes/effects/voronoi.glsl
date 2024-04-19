//	<https://www.shadertoy.com/view/Xd23Dh>
//	by inigo quilez <http://iquilezles.org/www/articles/voronoise/voronoise.htm>
//

vec3 hash3(vec3 p) {
  vec3 q = vec3(dot(p, vec3(127.1, 311.7, 1.0)), dot(p, vec3(269.5, 183.3, 1.0)), dot(p, vec3(419.2, 371.9, 1.0)));
  return fract(sin(q) * 43758.5453);
}

float voroNoise(in vec3 x, float u, float v) {
  vec3 p = floor(x);
  vec3 f = fract(x);

  float k = 1.0 + 63.0 * pow(1.0 - v, 4.0);

  float va = 0.0;
  float wt = 0.0;
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) {
      vec3 g = vec3(float(i), float(j), float(i - j));
      vec3 o = hash3(p + g) * vec3(u, u, 1.0);
      vec3 r = g - f + o.xyz;
      float d = dot(r, r);
      float ww = pow(1.0 - smoothstep(0.0, 1.414, sqrt(d)), k);
      va += o.z * ww;
      wt += ww;
    }

  return va / wt;
}