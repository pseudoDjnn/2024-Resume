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
const gradientTexture = textureLoader.load('textures/gradients/5.jpg')
gradientTexture.magFilter = THREE.NearestFilter

/**
 * Particles test idea
 */
const parameters = {
    count: 100000,
    size: 0.01,
}

let geometry = null
let positions = null
let points = null

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

    scene.add(points)
}
generateParticles()

const material = new THREE.MeshToonMaterial({
    gradientMap: gradientTexture

})

const mesh1 = new THREE.Mesh(
    new THREE.TorusGeometry(1, 0.4, 16, 40),
    material
)
mesh1.scale.x = -0.1
mesh1.position.z = -0.5
mesh1.scale.z = -0.2
scene.add(mesh1)

const directionalLight = new THREE.DirectionalLight('#ffeded', 3)
directionalLight.position.set(1, 1, 0)
scene.add(directionalLight)

// Array to iterate over for particles
const iterableParticles = [mesh1]


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

const tick = () => {
    const elapsedTime = clock.getElapsedTime()

    //Animate mesh (keep it simple for now)
    for (const mesh of iterableParticles) {
        mesh.rotation.x = elapsedTime * 0.1
        mesh.rotation.y = elapsedTime * 0.12
    }

    // Update controls
    controls.update()

    // Render
    renderer.render(scene, camera)

    // Call tick again on the next frame
    window.requestAnimationFrame(tick)
}

tick()