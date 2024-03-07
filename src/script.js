import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import GUI from 'lil-gui'

/**
 * Base
 */
// Debug
const gui = new GUI()

// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()

/**
 * Textures
 */
const textureLoader = new THREE.TextureLoader()
// const gradientTexture = textureLoader.load('textures/gradients/5.jpg')
// gradientTexture.magFilter = THREE.NearestFilter

/**
 * Particles test idea
 */
const parameters = {
    count: 10000,
    size: 0.001,
}

let geometry = null
let positions = null
let points = null
// let fibbonacci = null

// Array to iterate over for particles
const iterableParticles = []

const generateParticles = () => {
    geometry = new THREE.BufferGeometry()
    positions = new Float32Array(parameters.count * 3)
    // Test fibbonacci sequence instead of using Math.random()
    const fibbonacci = (i, count = {}) => {
        const i3 = i * 3
        if (i in count) return count[i];
        if (i <= 2) return 1;

        count[i] = fibbonacci(i - 1, count) + fibbonacci(i - 2, count)
        positions[i3] = (Math.random() - 0.5) * 3
        positions[i3 + 1] = (Math.random() - 0.5) * 3
        positions[i3 + 2] = (Math.random() - 0.5) * 3

        return count[i3]
    }


    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))

    const material = new THREE.PointsMaterial({
        color: '#ffeded',
        size: parameters.size,
        sizeAttenuation: true,
        depthWrite: false,
        blending: THREE.AdditiveBlending
    })
    points = new THREE.Points(geometry, material)

    fibbonacci(5000)
    // iterableParticles.push({
    //     mesh: material,
    //     body: positions
    // })

    scene.add(points)
}
generateParticles()

const directionalLight = new THREE.DirectionalLight('#ffeded', 3)
directionalLight.position.set(1, 1, 0)
scene.add(directionalLight)



/**
 * Sizes
*/
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight
}

window.addEventListener('resize', () => {
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

/**
 * Camera
 */
// Base camera
const camera = new THREE.PerspectiveCamera(35, sizes.width / sizes.height, 0.1, 100)
camera.position.z = 3
scene.add(camera)

// Controls
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
    canvas: canvas,
    alpha: true
})
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

/**
 * Animate
 */
const clock = new THREE.Clock()

let previousTime = 0

const tick = () => {
    const elapsedTime = clock.getElapsedTime()
    const deltaTime = elapsedTime - previousTime
    previousTime = elapsedTime

    //Animate particles (keep it simple for now)
    // generateParticles(deltaTime - 0.5 / points) * 5
    // points.update(deltaTime)
    for (const object of iterableParticles) {
        // object.
        // particles.rotation.y = elapsedTime * 0.12
    }


    // Update controls
    controls.update()

    // Render
    renderer.render(scene, camera)

    // Call tick again on the next frame
    window.requestAnimationFrame(tick)
}

tick()