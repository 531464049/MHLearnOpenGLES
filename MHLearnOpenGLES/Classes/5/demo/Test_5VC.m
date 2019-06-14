//
//  Test_5VC.m
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/6/5.
//  Copyright © 2019 mh. All rights reserved.
//

#import "Test_5VC.h"
#import "MHVertexAttribArrayBuffer.h"
#import "sphere.h"

static const GLfloat  SceneEarthAxialTiltDeg = 23.5f;
static const GLfloat  SceneDaysPerMoonOrbit = 28.0f;
static const GLfloat  SceneMoonRadiusFractionOfEarth = 0.25;
static const GLfloat  SceneMoonDistanceFromEarth = 2.0;

@interface Test_5VC ()<GLKViewDelegate>

@property(nonatomic,strong)EAGLContext * context;
@property(nonatomic,strong)GLKBaseEffect * baseEffect;
@property(nonatomic,strong)GLKView * glkView;

@property(nonatomic,strong)MHVertexAttribArrayBuffer * positionBuffer;
@property(nonatomic,strong)MHVertexAttribArrayBuffer * normalBuffer;
@property(nonatomic,strong)MHVertexAttribArrayBuffer * coordBuffer;

@property(nonatomic,strong)GLKTextureInfo * earthTextureInfo;
@property(nonatomic,strong)GLKTextureInfo * moonTextureInfo;

@property(nonatomic,assign)GLKMatrixStackRef modelviewMatrixStack;
@property(nonatomic,assign)GLfloat earthRotationAngleDegress;
@property(nonatomic,assign)GLfloat moonRotationAngleDegress;

@end

@implementation Test_5VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContext_glkView];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    
    [self configureLight];
    
    GLfloat aspectRatio = self.view.bounds.size.width / self.view.bounds.size.height;
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(-1.0*aspectRatio, 1.0*aspectRatio, -1.0, 1.0, 1.0, 120.0);
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -5.0);
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    
    [self bufferData];
}
// 初始化EAGLContext  GLKView
- (void)setupContext_glkView
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    self.glkView = [[GLKView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) context:self.context];
    self.glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;//颜色缓冲区格式
    self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    self.glkView.delegate = self;
    [self.view addSubview:self.glkView];
    
    [EAGLContext setCurrentContext:self.context];
    glEnable(GL_DEPTH_TEST);
}
// 初始化光照
-(void)configureLight
{
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    self.baseEffect.light0.position = GLKVector4Make(1.0, 0.0, 0.8, 0.0);
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.2, 0.2, 0.2, 1.0);
}
-(void)bufferData
{
    self.modelviewMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    
    //顶点数据缓存
    self.positionBuffer = [[MHVertexAttribArrayBuffer alloc]
                           initWithAttribStride:3*sizeof(GLfloat)
                           numberofVertices:sizeof(sphereVerts) / (3*sizeof(GLfloat))
                           bytes:sphereVerts
                           usage:GL_STATIC_DRAW];
    
    self.normalBuffer = [[MHVertexAttribArrayBuffer alloc]
                         initWithAttribStride:3*sizeof(GLfloat)
                         numberofVertices:sizeof(sphereNormals) / (3*sizeof(GLfloat))
                         bytes:sphereNormals
                         usage:GL_STATIC_DRAW];
    
    self.coordBuffer = [[MHVertexAttribArrayBuffer alloc]
                        initWithAttribStride:3*sizeof(GLfloat)
                        numberofVertices:sizeof(sphereTexCoords) / (3*sizeof(GLfloat))
                        bytes:sphereTexCoords
                        usage:GL_STATIC_DRAW];
    
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES],
                              GLKTextureLoaderOriginBottomLeft, nil];
    //地球纹理
    CGImageRef earthImageRef = [UIImage imageNamed:@"Earth512x256.jpg"].CGImage;
    self.earthTextureInfo = [GLKTextureLoader textureWithCGImage:earthImageRef options:options error:NULL];
    //月球纹理
    CGImageRef moonImageRef = [UIImage imageNamed:@"Moon256x128.png"].CGImage;
    self.moonTextureInfo = [GLKTextureLoader textureWithCGImage:moonImageRef options:options error:NULL];
    
    //矩阵堆？？？？？？？？？？？
    GLKMatrixStackLoadMatrix4(self.modelviewMatrixStack, self.baseEffect.transform.modelviewMatrix);
    
    self.moonRotationAngleDegress = -20.0;
}
-(void)drawEarth
{
    self.baseEffect.texture2d0.name = self.earthTextureInfo.name;
    self.baseEffect.texture2d0.target = self.earthTextureInfo.target;
    
    GLKMatrixStackPush(self.modelviewMatrixStack);
    
    GLKMatrixStackRotate(
                         self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(SceneEarthAxialTiltDeg),
                         1.0, 0.0, 0.0);
    
    GLKMatrixStackRotate(
                         self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(self.earthRotationAngleDegress),
                         0.0, 1.0, 0.0);
    
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    
    [self.baseEffect prepareToDraw];
    
    [MHVertexAttribArrayBuffer drawPreparedArraysWidthMode:GL_TRIANGLES startVertexIndex:0 numberofVertices:sphereNumVerts];
    
    GLKMatrixStackPop(self.modelviewMatrixStack);
    
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
}
-(void)drawMoon
{
    self.baseEffect.texture2d0.name = self.moonTextureInfo.name;
    self.baseEffect.texture2d0.target = self.moonTextureInfo.target;
    
    GLKMatrixStackPush(self.modelviewMatrixStack);
    
    GLKMatrixStackRotate(
                         self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(self.moonRotationAngleDegress),
                         0.0, 1.0, 0.0);
    GLKMatrixStackTranslate(
                            self.modelviewMatrixStack,
                            0.0, 0.0, SceneMoonDistanceFromEarth);
    GLKMatrixStackScale(
                        self.modelviewMatrixStack,
                        SceneMoonRadiusFractionOfEarth,
                        SceneMoonRadiusFractionOfEarth,
                        SceneMoonRadiusFractionOfEarth);
    GLKMatrixStackRotate(
                         self.modelviewMatrixStack,
                         GLKMathDegreesToRadians(self.moonRotationAngleDegress),
                         0.0, 1.0, 0.0);
    
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
    
    [self.baseEffect prepareToDraw];
    
    [MHVertexAttribArrayBuffer drawPreparedArraysWidthMode:GL_TRIANGLES startVertexIndex:0 numberofVertices:sphereNumVerts];
    
    GLKMatrixStackPop(self.modelviewMatrixStack);
    
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrixStackGetMatrix4(self.modelviewMatrixStack);
}
-(void)change:(BOOL)change
{
    GLfloat aspectRatio =
    (float)((GLKView *)self.view).drawableWidth /
    (float)((GLKView *)self.view).drawableHeight;
    
    if (change) {
        self.baseEffect.transform.projectionMatrix =
        GLKMatrix4MakeFrustum(
                              -1.0 * aspectRatio,
                              1.0 * aspectRatio,
                              -1.0,
                              1.0,
                              2.0,
                              120.0);
    }else{
        self.baseEffect.transform.projectionMatrix =
        GLKMatrix4MakeOrtho(
                            -1.0 * aspectRatio,
                            1.0 * aspectRatio,
                            -1.0,
                            1.0,
                            1.0,
                            120.0);
    }
    //577544091
}
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.3, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    self.earthRotationAngleDegress += 360.f/60.f;
    self.moonRotationAngleDegress += (360.f/60.f)/SceneDaysPerMoonOrbit;
    
    [self.positionBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.normalBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.coordBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
    
    [self drawEarth];
    [self drawMoon];
}
@end
