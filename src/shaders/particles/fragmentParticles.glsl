varying vec3 vColor;
// varying vec2 vUv;

void main() {

  float particleRounding = distance(gl_PointCoord, vec2(0.5));
  particleRounding = 1.0 - particleRounding;
  particleRounding = pow(particleRounding, 0.8);

  // Mixed color
  vec3 color = mix(vec3(0.0), vColor, particleRounding);

  vec2 vUv = gl_PointCoord;
  float distanceToCenter = length(vUv - 0.5);
  float alpha = 0.2 / distanceToCenter - 0.1;

  gl_FragColor = vec4(vColor * color, alpha / 5.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}