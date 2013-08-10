# set the scene size
WIDTH = window.innerWidth
HEIGHT = window.innerHeight

# set some camera attributes
VIEW_ANGLE = 45
ASPECT = WIDTH / HEIGHT
NEAR = 1
FAR = 1500

ORIGIN = new THREE.Vector3

clock = new THREE.Clock

# get the DOM element to attach to
# - assume we've got jQuery to hand
$container = $('#container')

# create a WebGL renderer, camera
# and a scene
renderer = new THREE.WebGLRenderer {antialias: true}
renderer.autoClear = off
camera = new THREE.PerspectiveCamera(  VIEW_ANGLE,
                                ASPECT,
                                NEAR,
                                FAR  )
scene = new THREE.Scene

# start the renderer
renderer.setSize(WIDTH, HEIGHT)

# attach the render-supplied DOM element
$container.append(renderer.domElement)

# set up the sphere vars
ballRadius = 5
segments = 16
rings = 16

ballGeometry = new THREE.SphereGeometry(ballRadius, segments, rings)
ballsContainer = new THREE.Object3D
ballsContainer.position.set(-100, 100, 40)

camera.position.set(0, 0, 300)

# and the camera
scene.add(camera);

# urls of the images,
# one per half axis
urls = [
  'images/santa_maria/posx.jpg',
  'images/santa_maria/negx.jpg',
  'images/santa_maria/posy.jpg',
  'images/santa_maria/negy.jpg',
  'images/santa_maria/posz.jpg',
  'images/santa_maria/negz.jpg'
]

# wrap it up into the object that we need
cubemap = THREE.ImageUtils.loadTextureCube(urls)
cubemap.format = THREE.RGBFormat;

shader = THREE.ShaderLib[ "cube" ]
shader.uniforms[ "tCube" ].normal = cubemap

material = new THREE.ShaderMaterial {
    fragmentShader: shader.fragmentShader,
    vertexShader: shader.vertexShader,
    uniforms: shader.uniforms,
    depthWrite: false,
    side: THREE.BackSide
}

skybox = new THREE.Mesh( new THREE.CubeGeometry( 1000, 1000, 1000 ), material )
skybox.flipSided = true
scene.add(skybox)

ambient = new THREE.AmbientLight( 0xffffff )
scene.add(ambient)

pointLight = new THREE.PointLight( 0xffffff, 2 )
scene.add( pointLight )

reflectionMaterialRed = new THREE.MeshLambertMaterial {
    color: 0xff0000,
    envMap: cubemap
}

reflectionMaterialGreen = new THREE.MeshLambertMaterial {
    color: 0x00ff00,
    envMap: cubemap
}

reflectionMaterialBlue = new THREE.MeshLambertMaterial {
    color: 0x0000ff,
    envMap: cubemap
}

# create a new mesh with sphere geometry

for i in [0...80] by 1
    reflectionMaterial = [reflectionMaterialRed, reflectionMaterialGreen, reflectionMaterialBlue][Math.floor(Math.random() * 3)]
    ball = new THREE.Mesh(ballGeometry, reflectionMaterial)
    ball.position.x = i % 20 * ballRadius * 2
    ball.position.y = -Math.floor(i / 20) * ballRadius * 2
    
    # add the sphere to the scene
    ballsContainer.add(ball)

scene.add(ballsContainer)

cylinderGeometry = new THREE.CylinderGeometry( 5, 15, 40, 32 )
cylinderGeometry.applyMatrix( new THREE.Matrix4().makeRotationX( Math.PI / 2 ) )
cylinder = new THREE.Mesh(cylinderGeometry, reflectionMaterial)

cylinder.position.set(0, -80, 40)
scene.add(cylinder)

mousePosition = new THREE.Vector3(0, 0, 40)
ballDirection = null
ball = null

onMouseMove = (event) ->
    mousePosition.x = event.clientX - WIDTH / 2
    
onMouseClick = (event) ->
    scene.remove(ball)
    reflectionMaterial = [reflectionMaterialRed, reflectionMaterialGreen, reflectionMaterialBlue][Math.floor(Math.random() * 3)]
    ball = new THREE.Mesh(ballGeometry, reflectionMaterial)
    ballDirection = cylinder.rotation.y
    ball.position.set(25 * Math.sin(ballDirection),
                      25 * Math.cos(ballDirection) - 80, 40)
    scene.add(ball)

document.addEventListener( 'mousemove', onMouseMove, false )
document.addEventListener( 'mousedown', onMouseClick, false )

animate = ->
	window.requestAnimationFrame(animate)
	render()

render = ->
    delta = clock.getDelta()
    time = clock.getElapsedTime()
    ballsContainer.position.y -= delta
    cylinder.lookAt(mousePosition)
    
    if ballDirection
        ball.position.x += Math.sin(ballDirection) * delta * 100
        ball.position.y += Math.cos(ballDirection) * delta * 100
        
    renderer.render(scene, camera)

animate()