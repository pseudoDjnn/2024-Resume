import * as THREE from 'three'
import WebGLCanvas from '../WebGLCanvas'

import animationVertexShader from '../../shaders/animation/vertexAnimation.glsl'
import animationFragmentShader from '../../shaders/animation/fragmentAnimation.glsl'

export default class Animation {
  constructor() {

    this.webglCanvas = new WebGLCanvas()
    this.scene = this.webglCanvas.scene
    this.time = this.webglCanvas.time


    // console.log('this is for the animation')

    this.geometry = new THREE.IcosahedronGeometry(5, 3)
    this.geometry.setIndex(null)
    this.geometry.deleteAttribute('normal')

    this.count = this.geometry.attributes.position.count
    this.randoms = new Float32Array(this.count)

    for (let i = 0; i < this.count; i++) {
      this.randoms[i] = Math.floor(this.count * Math.random() * -2 - 1)
    }

    this.geometry.setAttribute('aRandom', new THREE.BufferAttribute(this.randoms, 3))

    this.materialAnimationParamters = {}
    this.materialAnimationParamters.color = '#70c1ff'
    this.materialAnimationParamters.shadowColor = '#ff794d'
    this.materialAnimationParamters.lightColor = '#e5ffe0'

    this.material = new THREE.ShaderMaterial({
      // wireframe: true,
      vertexShader: animationVertexShader,
      fragmentShader: animationFragmentShader,
      transparent: true,
      side: THREE.DoubleSide,
      uniforms: {
        //
        uColor: new THREE.Uniform(new THREE.Color(this.materialAnimationParamters.color)),
        uColorOffset: new THREE.Uniform(0.925),
        uColorMultiplier: new THREE.Uniform(1),
        uShadeColor: new THREE.Uniform(),
        uShadowColor: new THREE.Uniform(new THREE.Color(this.materialAnimationParamters.shadowColor)),
        uLightColor: new THREE.Uniform(new THREE.Color(this.materialAnimationParamters.lightColor)),
        //
        uFrequency: new THREE.Uniform(new THREE.Vector2(13, 8)),
        uResolution: new THREE.Uniform(new THREE.Vector2(this.width * this.pixelRatio, this.height * this.pixelRatio)),
        uShadowRepetitions: new THREE.Uniform(21),
        uLightRepetitions: new THREE.Uniform(144),
        uTimeAnimation: new THREE.Uniform(0),
        uTime: new THREE.Uniform(0),
        //
        uWaveElevation: new THREE.Uniform(0.8),
        uWaveFrequency: new THREE.Uniform(new THREE.Vector2(13, 3.5)),
        uWaveSpeed: new THREE.Uniform(0.89),
      },
      depthWrite: false,
      blending: THREE.AdditiveBlending,
    })

    this.mesh = new THREE.Mesh(this.geometry, this.material)
    this.mesh.position.set(3, -8, 5)
    this.mesh.rotation.set(89, 89, 13)
    this.scene.add(this.mesh)
  }

  update() {
    this.material.uniforms.uTimeAnimation.value = Math.sin(this.time.elapsed - 0.5) * 0.00013
    this.material.uniforms.uTime.value = (this.time.elapsed - 0.5) * 0.00013
  }

}