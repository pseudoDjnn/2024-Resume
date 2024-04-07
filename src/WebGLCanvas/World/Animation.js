import * as THREE from 'three'
import WebGLCanvas from '../WebGLCanvas'
import Audio from './Audio'

import animationVertexShader from '../../shaders/animation/vertexAnimation.glsl'
import animationFragmentShader from '../../shaders/animation/fragmentAnimation.glsl'

export default class Animation {
  constructor() {

    this.webglCanvas = new WebGLCanvas()
    this.scene = this.webglCanvas.scene
    this.time = this.webglCanvas.time
    this.audio = new Audio()

    // console.log('this is for the animation')

    this.geometry = new THREE.IcosahedronGeometry(3, 2)
    this.geometry.setIndex(null)
    this.geometry.deleteAttribute('normal')

    this.count = this.geometry.attributes.position.count
    this.randoms = new Float32Array(this.count, 2)

    for (let x = 0; x < this.count; x++) {
      this.randoms[x] = Math.hypot(this.count * Math.abs(Math.sin(Math.random() * 10000.0)) * -1 - 1)
    }

    this.geometry.setAttribute('aRandom', new THREE.BufferAttribute(this.randoms, 2))

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
        uAudioFrequency: new THREE.Uniform(0),
        uFrequency: new THREE.Uniform(new THREE.Vector2(13, 8)),
        uResolution: new THREE.Uniform(new THREE.Vector2(this.width * this.pixelRatio, this.height * this.pixelRatio)),
        uShadowRepetitions: new THREE.Uniform(13),
        uLightRepetitions: new THREE.Uniform(55),
        uTimeAnimation: new THREE.Uniform(0),
        uTime: new THREE.Uniform(0),
        //
        uWaveElevation: new THREE.Uniform(0.5),
        uWaveFrequency: new THREE.Uniform(new THREE.Vector2(8, 2.5)),
        uWaveSpeed: new THREE.Uniform(0.21),
      },
      depthWrite: false,
      blending: THREE.AdditiveBlending,
    })

    this.mesh = new THREE.Mesh(this.geometry, this.material)
    this.mesh.scale.set(13, 13, 13)
    this.mesh.position.set(0, 0, 0)
    this.mesh.rotation.set(21, 0, -55)
    this.scene.add(this.mesh)
  }

  update() {

    // this.mesh.rotation.x = Math.sin(this.time.elapsed * 0.0003)
    // this.mesh.rotation.y = -Math.PI * 2
    // this.mesh.rotation.z = Math.cos(this.time.elapsed * 0.00003)

    this.material.uniforms.uTimeAnimation.value = Math.cos(this.time.elapsed - 0.5) * 0.00055
    this.material.uniforms.uTime.value = (this.time.elapsed - 0.5) * 0.00002
    this.material.uniforms.uAudioFrequency.value = this.audio.analyser.getAverageFrequency()

  }

}