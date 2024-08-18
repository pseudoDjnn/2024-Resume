import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import WebGLCanvas from "./WebGLCanvas";

export default class Camera {
  constructor() {

    this.webglCanvas = new WebGLCanvas()
    this.sizes = this.webglCanvas.sizes
    this.scene = this.webglCanvas.scene
    this.canvas = this.webglCanvas.canvas

    this.setInstance()
    // this.setOrbitControl()
    this.setMouseMovement()
    // console.log('my camera', this)
  }

  setInstance() {
    this.frustumSize = 1
    this.aspect = this.sizes.width / this.sizes.height
    this.instance = new THREE.PerspectiveCamera(89, this.aspect, 0.01, 100)
    this.instance.position.set(0, 0, 4.3)
    // this.instance.lookAt(0, 0, 0)
    this.scene.add(this.instance)
  }

  // setOrbitControl() {
  //   this.controls = new OrbitControls(this.instance, this.canvas)
  //   this.controls.enableDamping = true
  //   this.controls.dampingFactor = 0.2
  // }

  setMouseMovement() {
    this.mouseX = 0
    this.mouseY = 0

    document.addEventListener('mousemove', (event) => {

      this.mouseXHalf = this.sizes.width / 2
      this.mouseYHalf = this.sizes.height / 2

      this.mouseX = (event.clientX - this.mouseXHalf) / 100
      this.mouseY = (event.clientY - this.mouseYHalf) / 100
    })
  }

  resize() {

    this.instance.aspect = this.sizes.width / this.sizes.height
    this.instance.updateProjectionMatrix()

    // console.log('this is resizing the camera')
  }

  update() {
    // this.controls.update()

    // this.instance.position.x += (this.mouseX - this.instance.position.x) * 0.000001
    // this.instance.position.y += (-this.mouseY - this.instance.position.y) * 0.000001

    this.instance.lookAt(this.scene.position)
  }
}