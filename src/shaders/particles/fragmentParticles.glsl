varying vec3 vColor;

void main() {
  // Disc
  // float particleRounding = distance(gl_PointCoord, vec2(0.5));
  // particleRounding = step(0.5, particleRounding);
  // particleRounding = 1.0 - particleRounding;

  // float particleRounding = distance(gl_PointCoord, vec2(0.5));
  // particleRounding *= 2.0;
  // particleRounding = 1.0 - particleRounding;

  float particleRounding = distance(gl_PointCoord, vec2(0.5));
  particleRounding = 1.0 - particleRounding;
  particleRounding = pow(particleRounding, 3.0);

  // Mixed color
  vec3 color = mix(vec3(0.0), vColor, particleRounding);

  gl_FragColor = vec4(color, 1.0);
    #include <colorspace_fragment>
}