//
//  ColorsVC.m
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/6/25.
//  Copyright © 2019 mh. All rights reserved.
//

#import "ColorsVC.h"

@interface ColorsVC ()

@end

@implementation ColorsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ColorsView * view = [[ColorsView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    view.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:view];
    
    self.view.backgroundColor = [UIColor whiteColor];
}
@end


@interface ColorsView ()

@property(nonatomic,strong)EAGLContext * context;
@property(nonatomic,strong)CAEAGLLayer * eaglLayer;
@property(nonatomic,assign)GLuint renderBuffer;
@property(nonatomic,assign)GLuint frameBuffer;

@property(nonatomic,assign)GLuint lightingProgram;
@property(nonatomic,assign)GLuint lampProgram;

@end

@implementation ColorsView

+(Class)layerClass
{
    return [CAEAGLLayer class];
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //初始化layer 上下文 render frame buffer
        [self setup];
        
        //加载着色器
        self.lightingProgram = [MHGLESTools loadProgramVertFileName:@"1_color_v.vs" fragFileName:@"1_color_f.fs"];
        self.lampProgram = [MHGLESTools loadProgramVertFileName:@"1_lamp_v.vs" fragFileName:@"1_lamp_f.fs"];

        //激活 顶点 坐标
        [self setPosition];
        [self render];
    }
    return self;
}
-(void)setup
{
    self.eaglLayer = (CAEAGLLayer *)self.layer;
    //放大倍数
    [self setContentScaleFactor:UIScreen.mainScreen.scale];
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    self.eaglLayer.opaque = YES;
    //设置描绘属性。设置不维持渲染内容，颜色格式RGBA8
    self.eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking :@(FALSE), kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
    
    // 指定 OpenGL 渲染 API 的版本，在这里我们使用 OpenGL ES 2.0
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSLog(@"初始化上下文失败");
        return;
    }
    //设置为当前上下文
    if (![EAGLContext setCurrentContext:self.context]) {
        NSLog(@"设置上下文失败");
        return;
    }
    
    //清空buffer引用
    [self destoryBuffer];
    
    //申请一个缓冲区
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    //为颜色缓冲区分配存储空间   渲染缓存绑定到渲染图层
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eaglLayer];
    
    //申请一个缓存区句柄
    glGenFramebuffers(1, &_frameBuffer);
    //设置为当前frameBuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将 _renderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
    glEnable(GL_DEPTH_TEST);
}
//清空buffer引用
-(void)destoryBuffer
{
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
}
-(void)setPosition
{
    GLfloat vertices[] = {
        -0.5f, -0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        0.5f,  0.5f, -0.5f,
        0.5f,  0.5f, -0.5f,
        -0.5f,  0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        
        -0.5f, -0.5f,  0.5f,
        0.5f, -0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f,  0.5f,
        -0.5f, -0.5f,  0.5f,
        
        -0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f,  0.5f,
        -0.5f,  0.5f,  0.5f,
        
        0.5f,  0.5f,  0.5f,
        0.5f,  0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        0.5f, -0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        
        -0.5f, -0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        0.5f, -0.5f,  0.5f,
        0.5f, -0.5f,  0.5f,
        -0.5f, -0.5f,  0.5f,
        -0.5f, -0.5f, -0.5f,
        
        -0.5f,  0.5f, -0.5f,
        0.5f,  0.5f, -0.5f,
        0.5f,  0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f, -0.5f,
    };
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    GLuint lightingPosition = glGetAttribLocation(self.lightingProgram, "aPos");
    glVertexAttribPointer(lightingPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, (GLfloat *)NULL + 0);
    glEnableVertexAttribArray(lightingPosition);
    
    GLuint lampPosition = glGetAttribLocation(self.lampProgram, "aPos");
    glVertexAttribPointer(lampPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, (GLfloat *)NULL + 0);
    glEnableVertexAttribArray(lampPosition);
}
-(void)render
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    CGFloat scale = UIScreen.mainScreen.scale;//当前视图放大倍数
    //设置视口大小
    glViewport(0.f, 0.f, self.frame.size.width * scale, self.frame.size.height * scale);
    
    
    float width = self.frame.size.width;
    float height = self.frame.size.height;

    ksMatrix4 projectionMat;
    ksMatrixLoadIdentity(&projectionMat);
    ksPerspective(&projectionMat, 45.0, width/height, 0.1f, 100.0);

    ksMatrix4 viewMat;
    ksMatrixLoadIdentity(&viewMat);
    ksVec3 eye = ksVectorLoad(0.0, 0.f, 5.0);
    ksVec3 target = ksVectorLoad(0.f, 0.f, 0.f);
    ksVec3 up = ksVectorLoad(0.f, 1.f, 0.f);
    ksLookAt(&viewMat, &eye, &target, &up);
    
    ksMatrix4 mode;
    ksMatrixLoadIdentity(&mode);
    ksMatrixRotate(&mode, 50.0, 1.0, 0.0, 0.0);
    ksMatrixRotate(&mode, 50.0, 0.0, 1.0, 0.0);
    ksMatrixRotate(&mode, 50.0, 0.0, 0.0, 1.0);
    ksMatrixScale(&mode, 0.8, 0.8, 0.8);

    
    GLuint lightingProjectionMatSlot = glGetUniformLocation(self.lightingProgram, "projection");
    glUniformMatrix4fv(lightingProjectionMatSlot, 1, GL_FALSE, (GLfloat *)&projectionMat.m[0][0]);
    
    GLuint lightingViewMatSlot = glGetUniformLocation(self.lightingProgram, "view");
    glUniformMatrix4fv(lightingViewMatSlot, 1, GL_FALSE, (GLfloat *)&viewMat.m[0][0]);
    
    GLuint lightingModeMatSlot = glGetUniformLocation(self.lightingProgram, "model");
    glUniformMatrix4fv(lightingModeMatSlot, 1, GL_FALSE, (GLfloat *)&mode.m[0][0]);
    
    GLuint objectColor = glGetUniformLocation(self.lightingProgram, "objectColor");
    glUniform3f(objectColor, 1.0, 0.5, 0.31);
    GLuint lightingColor = glGetUniformLocation(self.lightingProgram, "lightColor");
    glUniform3f(lightingColor, 1.0f, 1.0f, 1.0f);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    
    
    GLuint lampProjectionMatSlot = glGetUniformLocation(self.lampProgram, "projection");
    glUniformMatrix4fv(lampProjectionMatSlot, 1, GL_FALSE, (GLfloat *)&projectionMat.m[0][0]);
    
    GLuint lampViewMatSlot = glGetUniformLocation(self.lampProgram, "view");
    glUniformMatrix4fv(lampViewMatSlot, 1, GL_FALSE, (GLfloat *)&viewMat.m[0][0]);
    
    ksMatrixLoadIdentity(&mode);
    ksMatrixTranslate(&mode, -1.0, -1.0, 2.0);
    ksMatrixScale(&mode, 0.2, 0.2, 0.2);
    
    GLuint lampModeMatSlot = glGetUniformLocation(self.lampProgram, "model");
    glUniformMatrix4fv(lampModeMatSlot, 1, GL_FALSE, (GLfloat *)&mode.m[0][0]);
    
    GLuint lampColor = glGetUniformLocation(self.lampProgram, "lampColor");
    glUniform3f(lampColor, 1.0f, 1.0f, 1.0f);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}
@end
