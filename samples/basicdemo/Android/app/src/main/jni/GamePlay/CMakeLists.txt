cmake_minimum_required(VERSION 3.4.1)

add_compile_options(-D__ANDROID__)

include_directories(${GAMEPLAY_DEPS_ROOT}/include)

set(GAMEPLAY_OBJS
    ${GAMEPLAY_ROOT}/src/Platform.cpp
    ${GAMEPLAY_ROOT}/src/Ray.cpp
    ${GAMEPLAY_ROOT}/src/ScreenDisplayer.cpp
    ${GAMEPLAY_ROOT}/src/RenderTarget.cpp
    ${GAMEPLAY_ROOT}/src/Technique.cpp
    ${GAMEPLAY_ROOT}/src/Rectangle.cpp
    ${GAMEPLAY_ROOT}/src/TileSet.cpp
    ${GAMEPLAY_ROOT}/src/Texture.cpp
    ${GAMEPLAY_ROOT}/src/Curve.cpp
    ${GAMEPLAY_ROOT}/src/Scene.cpp
    ${GAMEPLAY_ROOT}/src/Joint.cpp
    ${GAMEPLAY_ROOT}/src/RenderState.cpp
    ${GAMEPLAY_ROOT}/src/AnimationClip.cpp
    ${GAMEPLAY_ROOT}/src/Ref.cpp
    ${GAMEPLAY_ROOT}/src/Terrain.cpp
    ${GAMEPLAY_ROOT}/src/Properties.cpp
    ${GAMEPLAY_ROOT}/src/VertexAttributeBinding.cpp
    ${GAMEPLAY_ROOT}/src/BoundingBox.cpp
    ${GAMEPLAY_ROOT}/src/AnimationValue.cpp
    ${GAMEPLAY_ROOT}/src/Vector3.cpp
    ${GAMEPLAY_ROOT}/src/Camera.cpp
    ${GAMEPLAY_ROOT}/src/Model.cpp
    ${GAMEPLAY_ROOT}/src/TerrainPatch.cpp
    ${GAMEPLAY_ROOT}/src/Material.cpp
    ${GAMEPLAY_ROOT}/src/Quaternion.cpp
    ${GAMEPLAY_ROOT}/src/SpriteBatch.cpp
    ${GAMEPLAY_ROOT}/src/Frustum.cpp
    ${GAMEPLAY_ROOT}/src/AnimationTarget.cpp
    ${GAMEPLAY_ROOT}/src/Effect.cpp
    ${GAMEPLAY_ROOT}/src/Logger.cpp
    ${GAMEPLAY_ROOT}/src/Light.cpp
    ${GAMEPLAY_ROOT}/src/MaterialParameter.cpp
    ${GAMEPLAY_ROOT}/src/Animation.cpp
    ${GAMEPLAY_ROOT}/src/AnimationController.cpp
    ${GAMEPLAY_ROOT}/src/VertexFormat.cpp
    ${GAMEPLAY_ROOT}/src/Transform.cpp
    ${GAMEPLAY_ROOT}/src/Vector2.cpp
    ${GAMEPLAY_ROOT}/src/Vector4.cpp
    ${GAMEPLAY_ROOT}/src/MathUtil.cpp
    ${GAMEPLAY_ROOT}/src/FrameBuffer.cpp
    ${GAMEPLAY_ROOT}/src/Sprite.cpp
    ${GAMEPLAY_ROOT}/src/Node.cpp
    ${GAMEPLAY_ROOT}/src/ParticleEmitter.cpp
    ${GAMEPLAY_ROOT}/src/Drawable.cpp
    ${GAMEPLAY_ROOT}/src/HeightField.cpp
    ${GAMEPLAY_ROOT}/src/BoundingSphere.cpp
    ${GAMEPLAY_ROOT}/src/DebugNew.cpp
    ${GAMEPLAY_ROOT}/src/MeshBatch.cpp
    ${GAMEPLAY_ROOT}/src/DepthStencilTarget.cpp
    ${GAMEPLAY_ROOT}/src/Plane.cpp
    ${GAMEPLAY_ROOT}/src/Image.cpp
    ${GAMEPLAY_ROOT}/src/MeshSkin.cpp
    ${GAMEPLAY_ROOT}/src/Bundle.cpp
    ${GAMEPLAY_ROOT}/src/Pass.cpp
    ${GAMEPLAY_ROOT}/src/ThemeStyle.cpp
    ${GAMEPLAY_ROOT}/src/SceneLoader.cpp
    ${GAMEPLAY_ROOT}/src/MeshPart.cpp
    ${GAMEPLAY_ROOT}/src/Theme.cpp
    ${GAMEPLAY_ROOT}/src/Game.cpp
    ${GAMEPLAY_ROOT}/src/Mesh.cpp
    ${GAMEPLAY_ROOT}/src/FileSystem.cpp
    ${GAMEPLAY_ROOT}/src/Text.cpp
    ${GAMEPLAY_ROOT}/src/Font.cpp
    ${GAMEPLAY_ROOT}/src/Matrix.cpp
)

add_library(gameplay-deps
            STATIC
            IMPORTED)
set_target_properties( # Specifies the target library.
                       gameplay-deps

                       # Specifies the parameter you want to define.
                       PROPERTIES IMPORTED_LOCATION

                       # Provides the path to the library you want to import.
                       ${GAMEPLAY_DEPS_ROOT}/lib/android/${ANDROID_ABI}/libgameplay-deps.a )

add_library( # Sets the name of the library
             GamePlay

             # Sets the library as a static library.
             STATIC

             # Provides a relative path to your source file(s).
             # Associated headers in the same location as their source
             # file are automatically included.
             ${GAMEPLAY_OBJS})
target_link_libraries(GamePlay
                        gameplay-deps)