import * as THREE from 'three'
import WebGLCanvas from '../WebGLCanvas'
import Camera from '../Camera'
import Audio from './Audio'

import animationVertexShader from '../../shaders/animation/vertexAnimation.glsl'
import animationFragmentShader from '../../shaders/animation/fragmentAnimation.glsl'

export default class Animation {
  constructor() {

    this.webglCanvas = new WebGLCanvas()
    this.scene = this.webglCanvas.scene
    this.sizes = this.webglCanvas.sizes
    this.time = this.webglCanvas.time
    this.camera - new Camera()
    this.audio = new Audio()

    // console.log('this is for the animation')

    this.geometry = new THREE.PlaneGeometry(8, 8, 1, 1)
    // this.geometry.setIndex(null)
    // this.geometry.deleteAttribute('uv')
    this.geometry.deleteAttribute('normal')

    this.uniforms = {
      uAudioFrequency: new THREE.Uniform(0),
      uFrequencyData: new THREE.Uniform(0),
      uMouse: new THREE.Uniform(new THREE.Vector2(0, 0)),
      uResolution: new THREE.Uniform(new THREE.Vector4(this.width * this.pixelRatio, this.height * this.pixelRatio)),
      uTimeAnimation: new THREE.Uniform(0),
      uTime: new THREE.Uniform(0),
    }

    this.material = new THREE.ShaderMaterial({
      // wireframe: true,
      vertexShader: animationVertexShader,
      fragmentShader: animationFragmentShader,
      transparent: true,
      side: THREE.DoubleSide,
      uniforms: this.uniforms,
      depthWrite: false,
      blending: THREE.AdditiveBlending,
    })

    this.mesh = new THREE.Mesh(this.geometry, this.material)
    // this.mesh.rotation.x = -0.0001
    // this.mesh.scale.set(5, 5, 5)
    // this.mesh.position.set(-3, 0, 0)
    // this.mesh.rotation.set(0, 0, 0)
    this.scene.add(this.mesh)

    this.mouseEvents()
  }

  mouseEvents() {
    this.mouse = new THREE.Vector2()
    document.addEventListener('mousemove', (event) => {
      this.mouse.x = (event.clientX / this.sizes.width) - 0.5
      this.mouse.y = (-event.clientY / this.sizes.height) + 0.5
    })
  }

  update() {

    // this.mesh.rotation.x = Math.sin(this.time.elapsed - 0.5) * 0.0001
    // this.mesh.rotation.y = Math.sin(this.time.delta - 0.5) * 0.00002
    // this.mesh.rotation.z = Math.cos(this.time.elapsed * 0.0001)

    this.material.uniforms.uTimeAnimation.value = this.time.elapsed * 0.00001
    this.material.uniforms.uTime.value = this.time.elapsed * 0.0008
    this.material.uniforms.uAudioFrequency.value = this.audio.analyser.getAverageFrequency()
    this.material.uniforms.uFrequencyData.value = this.audio.analyser.getFrequencyData()

    if (this.mouse) {
      this.material.uniforms.uMouse.value = this.mouse
      // console.log(this.mouse)
    }
  }
}