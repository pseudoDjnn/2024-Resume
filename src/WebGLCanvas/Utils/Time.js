import EventEmitter from "./EventEmitter";

export default class Time extends EventEmitter {
  constructor() {
    super()


    // Setup
    this.start = Date.now()
    this.current = this.start
    this.elapsed = 0
    this.delta = 16
    this.fpsLimit = null

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

    if (this.fpsLimit && this.elapsed < 1000 / this.fpsLimit) {
      requestAnimationFrame(() => this.tick());
      return;
    }

    this.trigger('tick')

    window.requestAnimationFrame(() => {
      this.tick()
    })
  }
}