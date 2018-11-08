#include "TriangleSample.h"
#include "SamplesGame.h"

//#if defined(ADD_SAMPLE)
//    ADD_SAMPLE("Graphics", "Triangle", TriangleSample, 1);
//#endif

///**
// * Creates a triangle mesh with vertex colors.
// */
//static Mesh* createTriangleMesh()
//{
//    // Calculate the vertices of the equilateral triangle.
//    float a = 0.5f;     // length of the side
//    Vector2 p1(0.0f,       a / sqrtf(3.0f));
//    Vector2 p2(-a / 2.0f, -a / (2.0f * sqrtf(3.0f)));
//    Vector2 p3( a / 2.0f, -a / (2.0f * sqrtf(3.0f)));
//
//    // Create 3 vertices. Each vertex has position (x, y, z) and color (red, green, blue)
//    float vertices[] =
//    {
//        p1.x, p1.y, 0.0f,     1.0f, 0.0f, 0.0f,
//        p2.x, p2.y, 0.0f,     0.0f, 1.0f, 0.0f,
//        p3.x, p3.y, 0.0f,     0.0f, 0.0f, 1.0f,
//    };
//    unsigned int vertexCount = 3;
//    VertexFormat::Element elements[] =
//    {
//        VertexFormat::Element(VertexFormat::POSITION, 3),
//        VertexFormat::Element(VertexFormat::COLOR, 3)
//    };
//    Mesh* mesh = Mesh::createMesh(VertexFormat(elements, 2), vertexCount, false);
//    if (mesh == NULL)
//    {
//        GP_ERROR("Failed to create mesh.");
//        return NULL;
//    }
//    mesh->setPrimitiveType(Mesh::TRIANGLES);
//    mesh->setVertexData(vertices, 0, vertexCount);
//    return mesh;
//}

TriangleSample::TriangleSample()
    :
//_font(NULL),
_model(NULL),
_spinDirection(-1.0f),
_scene(NULL)
{
    
}

void TriangleSample::initialize()
{
//    // Create the font for drawing the framerate.
//    _font = Font::create("res/ui/arial.gpb");

//    // Create an orthographic projection matrix.
//    float width = getWidth() / (float)getHeight();
//    float height = 1.0f;
//    Matrix::createOrthographic(width, height, -1.0f, 1.0f, &_worldViewProjectionMatrix);
    
//    // Create a material from the built-in "colored-unlit" vertex and fragment shaders.
//    // This sample doesn't use lighting so the unlit shader is used.
//    // This sample uses vertex color so VERTEX_COLOR is defined. Look at the shader source files to see the supported defines.
//    _model->setMaterial("res/shaders/colored.vert", "res/shaders/colored.frag", "VERTEX_COLOR");
//
//    // Create the triangle mesh.
//    Mesh* mesh = createTriangleMesh();
    
    _scene = Scene::create("world");
    
    Camera* camera = Camera::createPerspective(15.0f, getAspectRatio(), 0.1, 10.0f);
    
    Node* cameraNode = _scene->addNode("camera");
    cameraNode->translate(0.0f, 0.0f, 5.0f);
    cameraNode->setCamera(camera);
    _scene->setActiveCamera(camera);
    // must after setActiveCamera
    SAFE_RELEASE(camera);
    
    Mesh* mesh = Mesh::createQuad(-0.2, -0.2, 0.4, 0.4);
    // Create a model for the triangle mesh. A model is an instance of a Mesh that can be drawn with a specified material.
    _model = Model::create(mesh);
    SAFE_RELEASE(mesh);
    
    _modelNode = _scene->addNode("triangle");
     setUnlitMaterialTexture(_model, "res/png/grass.png");
    _modelNode->setDrawable(_model);
    
    cameraNode->rotateX(0);
    cameraNode->getWorldMatrix();
    
//    // Load the scene
//    _scene = Scene::load("res/common/lightBrickWall.gpb");
//    _scene->getActiveCamera()->setAspectRatio(getAspectRatio());
    
//    // Get the wall model node
//    _modelNode = _scene->findNode("wall");
//    _model = dynamic_cast<Model*>(_modelNode->getDrawable());
    
    // Create a directional light and a reference icon for the light
    Light* directionalLight = Light::createDirectional(1.0f, 1.0f, 1.0f);
    _directionalLightNode = Node::create("directionalLight");
    _directionalLightNode->setLight(directionalLight);
    
    // Create and initialize lights and materials for lights
    _lighting = Material::create("res/common/light.material");
    initializeDirectionalTechnique("directional", directionalLight);
    
    SAFE_RELEASE(directionalLight);
    Mesh* directionalLightQuadMesh = Mesh::createQuad(-0.2f, -0.2f, 0.4f, 0.4f);
    _directionalLightQuadModel = Model::create(directionalLightQuadMesh);
    SAFE_RELEASE(directionalLightQuadMesh);
    setUnlitMaterialTexture(_directionalLightQuadModel, "res/png/light-directional.png");
    _directionalLightNode->setDrawable(_directionalLightQuadModel);
    _directionalLightNode->setTranslation(0.0f, 0.0f, 7.0f);
    _scene->addNode(_directionalLightNode);
    
    _lighting->setTechnique("directional");
    _model->setMaterial(_lighting);
}

void TriangleSample::initializeDirectionalTechnique(const char* technique, Light* light)
{
    _lighting->getTechnique(technique)->getParameter("u_ambientColor")->setValue(Vector3(light->getColor().x, light->getColor().y, light->getColor().z));
    _lighting->getTechnique(technique)->getParameter("u_directionalLightColor[0]")->setValue(Vector3(light->getColor().x, light->getColor().y, light->getColor().z));
    _lighting->getTechnique(technique)->getParameter("u_directionalLightDirection[0]")->bindValue(_directionalLightNode, &Node::getForwardVectorView);
}

void TriangleSample::setUnlitMaterialTexture(Model* model, const char* texturePath, bool mipmap)
{
    Material* material = model->setMaterial("res/shaders/textured.vert", "res/shaders/textured.frag", "DIRECTIONAL_LIGHT_COUNT 1");
    material->setParameterAutoBinding("u_worldViewProjectionMatrix", "WORLD_VIEW_PROJECTION_MATRIX");
    
    // Load the texture from file.
    Texture::Sampler* sampler = material->getParameter("u_diffuseTexture")->setValue(texturePath, mipmap);
    if (mipmap)
    {
        sampler->setFilterMode(Texture::LINEAR_MIPMAP_LINEAR, Texture::LINEAR);
    }
    else
    {
        sampler->setFilterMode(Texture::LINEAR, Texture::LINEAR);
    }
    sampler->setWrapMode(Texture::CLAMP, Texture::CLAMP);
    material->getStateBlock()->setCullFace(true);
    material->getStateBlock()->setDepthTest(true);
    material->getStateBlock()->setDepthWrite(true);
    material->getStateBlock()->setBlend(true);
    material->getStateBlock()->setBlendSrc(RenderState::BLEND_SRC_ALPHA);
    material->getStateBlock()->setBlendDst(RenderState::BLEND_ONE_MINUS_SRC_ALPHA);
}

void TriangleSample::finalize()
{
    // Model and font are reference counted and should be released before closing this sample.
    SAFE_RELEASE(_model);
    
//    SAFE_RELEASE(_font);
}

void TriangleSample::update(float elapsedTime)
{
//    // Update the rotation of the triangle. The speed is 180 degrees per second.
    
    _scene->update(elapsedTime);
    
//    _scene->findNode("camera")->getWorldMatrix().rotateY(MATH_PI * elapsedTime * 0.001f);
//    _scene->findNode("camera")->rotateX(elapsedTime * 0.0005f);
    _scene->findNode("triangle")->rotateY(elapsedTime * 0.001f);
}

void TriangleSample::render(float elapsedTime)
{
    // Clear the color and depth buffers
    clear(CLEAR_COLOR_DEPTH, Vector4::zero(), 1.0f, 0);
    
//    // Bind the view projection matrix to the model's parameter. This will transform the vertices when the model is drawn.
//    _model->getMaterial()->getParameter("u_worldViewProjectionMatrix")->setValue(_worldViewProjectionMatrix);
//    _model->draw();
//
//    drawFrameRate(_font, Vector4(0, 0.5f, 1, 1), 5, 1, getFrameRate());

    _model->draw();
    
    _directionalLightQuadModel->draw();
    
//    _scene->visit(this, &TriangleSample::drawScene);
}

bool TriangleSample::drawScene(Node* node) {
    if(node->getDrawable() == _model) {
        
    } else if (node->getDrawable() == _directionalLightQuadModel) {
        _directionalLightQuadModel->draw();
    }
    
    return true;
}

void TriangleSample::touchEvent(Touch::TouchEvent evt, int x, int y, unsigned int contactIndex)
{
    switch (evt)
    {
    case Touch::TOUCH_PRESS:
        if (x < 75 && y < 50)
        {
            // Toggle Vsync if the user touches the top left corner
            setVsync(!isVsync());
        }
        else
        {
            // Reverse the spin direction if the user touches the screen.
            _spinDirection *= -1.0f;
        }
        break;
    case Touch::TOUCH_RELEASE:
        break;
    case Touch::TOUCH_MOVE:
        break;
    };
}
