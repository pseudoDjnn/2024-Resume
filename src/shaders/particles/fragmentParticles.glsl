varying vec3 vColor;

void main() {

  vec2 uv = gl_PointCoord;
  float distanceToCenter = length(uv - 0.5);
  float alpha = 0.05 / distanceToCenter - 0.1;

  gl_FragColor = vec4(vColor, alpha / 5.0) * 3.0;
  // gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}