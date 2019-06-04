//
//  GLESMath.h
//
//  Created by kesalin@gmail.com on 12-11-26.
//  Copyright (c) 2012. http://blog.csdn.net/kesalin/. All rights reserved.
//

#ifndef __GLESMATH_H__
#define __GLESMATH_H__

#import <OpenGLES/ES2/gl.h>
#include <math.h>

#ifndef M_PI
#define M_PI 3.1415926535897932384626433832795f
#endif

#define DEG2RAD( a ) (((a) * M_PI) / 180.0f)
#define RAD2DEG( a ) (((a) * 180.f) / M_PI)

// angle indexes
#define	PITCH				0		// up / down
#define	YAW					1		// left / right
#define	ROLL				2		// fall over

typedef unsigned char 		byte;

typedef struct
{
	GLfloat   m[3][3];
} KSMatrix3;


typedef struct
{
	GLfloat   m[4][4];
} KSMatrix4;

typedef struct KSVec3 {
    GLfloat x;
    GLfloat y;
    GLfloat z;
} KSVec3;

typedef struct KSVec4 {
    GLfloat x;
    GLfloat y;
    GLfloat z;
    GLfloat w;
} KSVec4;

typedef struct {
    GLfloat r;
    GLfloat g;
    GLfloat b;
    GLfloat a;
} KSColor;

#ifdef __cplusplus
extern "C" {
#endif

unsigned int ksNextPot(unsigned int n);
    
void ksCopyMatrix4(KSMatrix4 * target, const KSMatrix4 * src);

void ksMatrix4ToMatrix3(KSMatrix3 * target, const KSMatrix4 * src);

/**
 缩放变换
 @param result 矩阵(输入-输出)
 @param sx x缩放比例
 @param sy y缩放比例
 @param sz z缩放比例
 */
void ksScale(KSMatrix4 *result, GLfloat sx, GLfloat sy, GLfloat sz);

/**
 平移变换
 @param result 矩阵(输入-输出)
 @param tx x平移距离
 @param ty y平移距离
 @param tz z平移距离
 */
void ksTranslate(KSMatrix4 *result, GLfloat tx, GLfloat ty, GLfloat tz);

/**
 旋转变换
 x/y/z 旋转轴，当x=1.0时绕x轴旋转 当y=1.0时绕y轴旋转
 @param result 矩阵(输入-输出)
 @param angle 旋转角度
 @param x 0.0/1.0
 @param y 0.0/1.0
 @param z 0.0/1.0
 */
void ksRotate(KSMatrix4 *result, GLfloat angle, GLfloat x, GLfloat y, GLfloat z);

    
/**
 矩阵相乘
 result = srcA * srcB
 @param result 结果矩阵
 @param srcA 矩阵A
 @param srcB 矩阵B
 */
void ksMatrixMultiply(KSMatrix4 *result, const KSMatrix4 *srcA, const KSMatrix4 *srcB);

/**
 默认矩阵
 @param result 矩阵(输入-输出)
 */
void ksMatrixLoadIdentity(KSMatrix4 *result);
    
/**
 透视变换

 @param result 矩阵(输入-输出)
 @param fovy 视角
 @param aspect 视图长宽比
 @param nearZ 进平面距离
 @param farZ 远平面距离
 */
void ksPerspective(KSMatrix4 *result, float fovy, float aspect, float nearZ, float farZ);

//
/// multiply matrix specified by result with a perspective matrix and return new matrix in result
/// result Specifies the input matrix.  new matrix is returned in result.
/// left, right Coordinates for the left and right vertical clipping planes
/// bottom, top Coordinates for the bottom and top horizontal clipping planes
/// nearZ, farZ Distances to the near and far depth clipping planes.  These values are negative if plane is behind the viewer
//
void ksOrtho(KSMatrix4 *result, float left, float right, float bottom, float top, float nearZ, float farZ);

//
// multiply matrix specified by result with a perspective matrix and return new matrix in result
/// result Specifies the input matrix.  new matrix is returned in result.
/// left, right Coordinates for the left and right vertical clipping planes
/// bottom, top Coordinates for the bottom and top horizontal clipping planes
/// nearZ, farZ Distances to the near and far depth clipping planes.  Both distances must be positive.
//
void ksFrustum(KSMatrix4 *result, float left, float right, float bottom, float top, float nearZ, float farZ);

#ifdef __cplusplus
}
#endif

#endif // __GLESMATH_H__
