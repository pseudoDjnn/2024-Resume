import EventEmitter from "./EventEmitter";
// import World from "../World/World";

export default class Time extends EventEmitter {
  constructor() {
    super()


    // Setup
    this.start = Date.now()
    this.current = this.start
    this.elapsed = 0
    this.delta = 16
    // this.world = new World()

    window.requestAnimationFrame(() => {
      this.tick()
    })

    // console.log('Time instantiated')
  }

  tick() {
    // console.log('tick')

    const currentTime = Date.now()
    this.delta = currentTime - this.current
    this.current = currentTime
    // console.log(this.delta)
    this.elapsed = this.current - this.start
    // console.log(this.elapsed)

    // Update material ( Particles )
    // this.particles.material.uniforms.uTime.value = (-currentTime - 0.5) * 0.034

    this.trigger('tick')

    window.requestAnimationFrame(() => {
      this.tick()
    })
  }
}