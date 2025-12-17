#include <SDL3/SDL.h>

typedef struct Matrix4x4 {
    float m11, m12, m13, m14;
    float m21, m22, m23, m24;
    float m31, m32, m33, m34;
    float m41, m42, m43, m44;
} Matrix4x4;

typedef struct Vector3 {
    float x, y, z;
} Vector3;

Vector3 Vector3_Normalize(Vector3 vec) {
    float magnitude =
        SDL_sqrtf((vec.x * vec.x) + (vec.y * vec.y) + (vec.z * vec.z));
    return (Vector3){vec.x / magnitude, vec.y / magnitude, vec.z / magnitude};
}

float Vector3_Dot(Vector3 vecA, Vector3 vecB) {
    return (vecA.x * vecB.x) + (vecA.y * vecB.y) + (vecA.z * vecB.z);
}

Vector3 Vector3_Cross(Vector3 vecA, Vector3 vecB) {
    return (Vector3){vecA.y * vecB.z - vecB.y * vecA.z,
                     -(vecA.x * vecB.z - vecB.x * vecA.z),
                     vecA.x * vecB.y - vecB.x * vecA.y};
}

Matrix4x4 Matrix4x4_Multiply(Matrix4x4 matrix1, Matrix4x4 matrix2) {
    Matrix4x4 result;

    result.m11 = ((matrix1.m11 * matrix2.m11) + (matrix1.m12 * matrix2.m21) +
                  (matrix1.m13 * matrix2.m31) + (matrix1.m14 * matrix2.m41));
    result.m12 = ((matrix1.m11 * matrix2.m12) + (matrix1.m12 * matrix2.m22) +
                  (matrix1.m13 * matrix2.m32) + (matrix1.m14 * matrix2.m42));
    result.m13 = ((matrix1.m11 * matrix2.m13) + (matrix1.m12 * matrix2.m23) +
                  (matrix1.m13 * matrix2.m33) + (matrix1.m14 * matrix2.m43));
    result.m14 = ((matrix1.m11 * matrix2.m14) + (matrix1.m12 * matrix2.m24) +
                  (matrix1.m13 * matrix2.m34) + (matrix1.m14 * matrix2.m44));
    result.m21 = ((matrix1.m21 * matrix2.m11) + (matrix1.m22 * matrix2.m21) +
                  (matrix1.m23 * matrix2.m31) + (matrix1.m24 * matrix2.m41));
    result.m22 = ((matrix1.m21 * matrix2.m12) + (matrix1.m22 * matrix2.m22) +
                  (matrix1.m23 * matrix2.m32) + (matrix1.m24 * matrix2.m42));
    result.m23 = ((matrix1.m21 * matrix2.m13) + (matrix1.m22 * matrix2.m23) +
                  (matrix1.m23 * matrix2.m33) + (matrix1.m24 * matrix2.m43));
    result.m24 = ((matrix1.m21 * matrix2.m14) + (matrix1.m22 * matrix2.m24) +
                  (matrix1.m23 * matrix2.m34) + (matrix1.m24 * matrix2.m44));
    result.m31 = ((matrix1.m31 * matrix2.m11) + (matrix1.m32 * matrix2.m21) +
                  (matrix1.m33 * matrix2.m31) + (matrix1.m34 * matrix2.m41));
    result.m32 = ((matrix1.m31 * matrix2.m12) + (matrix1.m32 * matrix2.m22) +
                  (matrix1.m33 * matrix2.m32) + (matrix1.m34 * matrix2.m42));
    result.m33 = ((matrix1.m31 * matrix2.m13) + (matrix1.m32 * matrix2.m23) +
                  (matrix1.m33 * matrix2.m33) + (matrix1.m34 * matrix2.m43));
    result.m34 = ((matrix1.m31 * matrix2.m14) + (matrix1.m32 * matrix2.m24) +
                  (matrix1.m33 * matrix2.m34) + (matrix1.m34 * matrix2.m44));
    result.m41 = ((matrix1.m41 * matrix2.m11) + (matrix1.m42 * matrix2.m21) +
                  (matrix1.m43 * matrix2.m31) + (matrix1.m44 * matrix2.m41));
    result.m42 = ((matrix1.m41 * matrix2.m12) + (matrix1.m42 * matrix2.m22) +
                  (matrix1.m43 * matrix2.m32) + (matrix1.m44 * matrix2.m42));
    result.m43 = ((matrix1.m41 * matrix2.m13) + (matrix1.m42 * matrix2.m23) +
                  (matrix1.m43 * matrix2.m33) + (matrix1.m44 * matrix2.m43));
    result.m44 = ((matrix1.m41 * matrix2.m14) + (matrix1.m42 * matrix2.m24) +
                  (matrix1.m43 * matrix2.m34) + (matrix1.m44 * matrix2.m44));

    return result;
}

Matrix4x4 Matrix4x4_CreateRotationZ(float radians) {
    return (Matrix4x4){SDL_cosf(radians),
                       SDL_sinf(radians),
                       0,
                       0,
                       -SDL_sinf(radians),
                       SDL_cosf(radians),
                       0,
                       0,
                       0,
                       0,
                       1,
                       0,
                       0,
                       0,
                       0,
                       1};
}

Matrix4x4 Matrix4x4_CreateTranslation(float x, float y, float z) {
    return (Matrix4x4){1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, x, y, z, 1};
}

Matrix4x4 Matrix4x4_CreateOrthographicOffCenter(float left, float right,
                                                float bottom, float top,
                                                float zNearPlane,
                                                float zFarPlane) {
    return (Matrix4x4){2.0f / (right - left),
                       0,
                       0,
                       0,
                       0,
                       2.0f / (top - bottom),
                       0,
                       0,
                       0,
                       0,
                       1.0f / (zNearPlane - zFarPlane),
                       0,
                       (left + right) / (left - right),
                       (top + bottom) / (bottom - top),
                       zNearPlane / (zNearPlane - zFarPlane),
                       1};
}

Matrix4x4 Matrix4x4_CreatePerspectiveFieldOfView(float fieldOfView,
                                                 float aspectRatio,
                                                 float nearPlaneDistance,
                                                 float farPlaneDistance) {
    float num = 1.0f / ((float)SDL_tanf(fieldOfView * 0.5f));
    return (Matrix4x4){
        num / aspectRatio,
        0,
        0,
        0,
        0,
        num,
        0,
        0,
        0,
        0,
        farPlaneDistance / (nearPlaneDistance - farPlaneDistance),
        -1,
        0,
        0,
        (nearPlaneDistance * farPlaneDistance) /
            (nearPlaneDistance - farPlaneDistance),
        0};
}

Matrix4x4 Matrix4x4_CreateLookAt(Vector3 cameraPosition, Vector3 cameraTarget,
                                 Vector3 cameraUpVector) {
    Vector3 targetToPosition = {cameraPosition.x - cameraTarget.x,
                                cameraPosition.y - cameraTarget.y,
                                cameraPosition.z - cameraTarget.z};
    Vector3 vectorA = Vector3_Normalize(targetToPosition);
    Vector3 vectorB = Vector3_Normalize(Vector3_Cross(cameraUpVector, vectorA));
    Vector3 vectorC = Vector3_Cross(vectorA, vectorB);

    return (Matrix4x4){vectorB.x,
                       vectorC.x,
                       vectorA.x,
                       0,
                       vectorB.y,
                       vectorC.y,
                       vectorA.y,
                       0,
                       vectorB.z,
                       vectorC.z,
                       vectorA.z,
                       0,
                       -Vector3_Dot(vectorB, cameraPosition),
                       -Vector3_Dot(vectorC, cameraPosition),
                       -Vector3_Dot(vectorA, cameraPosition),
                       1};
}

SDL_GPUShader* LSE_CreateGPUShader(SDL_GPUDevice* device,
                                   SDL_GPUShaderCreateInfo* create_info,
                                   const char* entry_point) {
    create_info->entrypoint = entry_point;
    return SDL_CreateGPUShader(device, create_info);
}

SDL_GPURenderPass* LSE_BeginGPURenderPass(SDL_GPUCommandBuffer* cmd,
                                          SDL_GPUTexture* swap,
                                          SDL_GPUTexture* depth) {
    SDL_GPUColorTargetInfo color_info = {
        .texture = swap,
        .clear_color = {.r = .1, .g = .2, .b = .3, .a = 1.0},
        .load_op = SDL_GPU_LOADOP_CLEAR};

    SDL_GPUDepthStencilTargetInfo depth_info = {
        .texture = depth,
        .load_op = SDL_GPU_LOADOP_CLEAR,
        .clear_depth = 1.0,
        .store_op = SDL_GPU_STOREOP_DONT_CARE};

    return SDL_BeginGPURenderPass(cmd, &color_info, 1, &depth_info);
}

void LSE_PushTestMatrix(SDL_GPUCommandBuffer* cmd, float timestep) {
    Matrix4x4 proj = Matrix4x4_CreatePerspectiveFieldOfView(
        75.0f * SDL_PI_F / 180.0f, 900 / (float)600, 0.1, 100.0);
    Matrix4x4 view = Matrix4x4_CreateLookAt(
        (Vector3){2 + SDL_sinf(timestep) * 6, 8, 2 + SDL_cosf(timestep) * 6},
        (Vector3){2, 4, 2}, (Vector3){0, 1, 0});

    Matrix4x4 viewproj = Matrix4x4_Multiply(view, proj);

    SDL_PushGPUVertexUniformData(cmd, 0, &viewproj, (4 * 16));
}