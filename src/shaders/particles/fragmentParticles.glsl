varying vec3 vColor;
varying vec2 vUv;

void main() {
  // Disc
  // float particleRounding = distance(gl_PointCoord, vec2(0.5));
  // particleRounding = step(0.5, particleRounding);
  // particleRounding = 1.0 - particleRounding;

  // float particleRounding = distance(gl_PointCoord, vec2(0.5));
  // particleRounding *= 2.0;
  // particleRounding = 1.0 - particleRounding;

  // float particleRounding = distance(gl_PointCoord, vec2(0.5));
  // particleRounding = 1.0 - particleRounding;
  // particleRounding = pow(particleRounding, 0.8  );

  // Mixed color
  // vec3 color = mix(vec3(0.0), vColor, particleRounding);

  vec2 vUv = gl_PointCoord;
  float distanceToCenter = length(vUv - 0.5);
  float alpha = 0.05 / distanceToCenter - 0.1;

  gl_FragColor = vec4(vColor, alpha);
    // #include <tonemapping_fragment>
    #include <colorspace_fragment>
}