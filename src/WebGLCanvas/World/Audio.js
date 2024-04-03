import * as THREE from 'three'
import WebGLCanvas from '../WebGLCanvas';
// import EventEmitter from "../Utils/EventEmitter";

export default class Audio {
  constructor() {
    // super()

    this.webglCanvas = new WebGLCanvas()
    this.scene = this.webglCanvas.scene

    // console.log("this is for the Audio class")

    // Setup
    this.listener = new THREE.AudioListener()
    // console.log(this.listener)
    this.scene.add(this.listener)

    this.sound = new THREE.Audio(this.listener)
    // console.log(this.sound)

    this.audioLoader = new THREE.AudioLoader()
    this.audioLoader.load('/sound/The Resolution.mp3', (bufnr) => {
      this.sound.setBuffer(bufnr)
      window.addEventListener('click', () => {
        this.sound.play()
      })
    })
  }
}