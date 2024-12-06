import * as THREE from 'three'
import WebGLCanvas from '../WebGLCanvas';


export default class Audio {
  constructor() {

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
    this.audioLoader.load('sound/1st Track06-16-24(2).mp3', (bufnr) => {
      this.sound.setBuffer(bufnr)
      window.addEventListener('click', () => {
        this.sound.setVolume(0.3)
        this.sound.play()
      })
    })

    this.analyser = new THREE.AudioAnalyser(this.sound, 512)

  }
}