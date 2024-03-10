import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import GUI from 'lil-gui'
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'



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
 * Textures and loaders
 */
const gltfLoader = new GLTFLoader()
const textureLoader = new THREE.TextureLoader()
const particleTexture = textureLoader.load('/textures/gradients/5.jpg')
particleTexture.colorSpace = THREE.SRGBColorSpace
particleTexture.magFilter = THREE.NearestFilter



/**
 * Reel to reel model
 */
let reel2Reel = null

gltfLoader.load('/models/scene.gltf',
    (gltf) => {
        gltf.scene.position.x = 4
        gltf.scene.position.y = -2
        gltf.scene.position.z = -1.7

        gltf.scene.rotation.y = -1

        gltf.scene.scale.set(8, 8, 4)
        scene.add(gltf.scene)
    })


/**
 * Particle parameters
 */
const parameters = {
    count: 10000,
    size: 0.001,
    color: '#ffeded'
}

let geometry = null
let positions = null
let points = null
let fibbonacci = null
let colors = null

const generateParticles = () => {

    geometry = new THREE.BufferGeometry()
    positions = new Float32Array(parameters.count * 3)
    colors = new Float32Array(parameters.count * 3)


    const material = new THREE.PointsMaterial({
        color: parameters.color,
        size: parameters.size,
        sizeAttenuation: true,
        transparent: true,
        alphaMap: particleTexture,
        depthWrite: false,
        blending: THREE.AdditiveBlending,
        vertexColors: true
    })

    points = new THREE.Points(geometry, material)
    points.position.x = -21.8
    points.position.y = -8

    // Test fibbonacci sequence instead of using Math.random()
    fibbonacci = (i, count = {}) => {
        const i3 = i * 5
        if (i in count) return count[i];
        if (i <= 2) return 1;

        count[i] = fibbonacci(i - 1, count) + fibbonacci(i - 2, count)
        positions[i3] = (Math.random() - 0.5) * -55
        positions[i3 + 1] = (Math.random() - 0.5) * 13
        positions[i3 + 2] = (Math.random() - 0.5) * 55
        colors[i] = Math.random()

        return count[i3 * 3]
    }
    fibbonacci(5000)

    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))
    geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3))

    scene.fog = new THREE.Fog(0xcccccc, 8, 13)
    scene.add(points)
}

generateParticles()


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
const camera = new THREE.PerspectiveCamera(135, sizes.width / sizes.height, 0.1, 100)
camera.position.z = 2.5
scene.add(camera)

// Controls
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true


/**
 * Lights
 */
const ambientLight = new THREE.AmbientLight(0xffeded, 1)
scene.add(ambientLight)


/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
    canvas: canvas,
    antialias: true,
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

    // Temporary gltf movement
    if (gltfLoader) {
        // gltfLoader.rotation.x = 2
    }

    // Update particles (keeping this simple for now)
    if (points) {
        points.rotation.x = Math.cos(-elapsedTime * 0.00021) * 17
        points.rotation.y = -Math.sin((deltaTime - 0.5) * 3) * 0.55
        points.rotation.z = Math.sin(elapsedTime * 0.00089) * 3
    }

    // Update controls
    controls.update()

    // Render
    renderer.render(scene, camera)

    // Call tick again on the next frame
    window.requestAnimationFrame(tick)
}

tick()