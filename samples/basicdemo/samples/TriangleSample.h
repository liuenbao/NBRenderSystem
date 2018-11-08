#ifndef TRIANGLESAMPLE_H_
#define TRIANGLESAMPLE_H_

#include "gameplay.h"
#include "Sample.h"

using namespace gameplay;

/**
 * Sample creating and draw a single triangle.
 */
class TriangleSample : public Sample
{
public:
    TriangleSample();

    void touchEvent(Touch::TouchEvent evt, int x, int y, unsigned int contactIndex);

protected:

    void initialize();

    void finalize();

    void update(float elapsedTime);

    void render(float elapsedTime);

private:

    bool drawScene(Node* node);
    void initializeDirectionalTechnique(const char* technique, Light* light);
    void setUnlitMaterialTexture(Model* model, const char* texturePath, bool mipmap = true);
    
private:
    
//    Font* _font;
    
    Scene* _scene;

    Node* _modelNode;
    Model* _model;
    
    Node* _directionalLightNode;
    Model* _directionalLightQuadModel;
    
    Material* _lighting;
    
    float _spinDirection;
//    Matrix _worldViewProjectionMatrix;
};

#endif
