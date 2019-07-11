//
//  TestCameraVC.m
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/6/24.
//  Copyright © 2019 mh. All rights reserved.
//

#import "TestCameraVC.h"

@interface TestCameraVC ()

@end

@implementation TestCameraVC

- (void)viewDidLoad {
    [super viewDidLoad];
    TCameraView * view = [[TCameraView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    view.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:view];
    
    self.view.backgroundColor = [UIColor whiteColor];
}
@end


@interface TCameraView ()

@property(nonatomic,strong)EAGLContext * context;
@property(nonatomic,strong)CAEAGLLayer * eaglLayer;
@property(nonatomic,assign)GLuint program;
@property(nonatomic,assign)GLuint renderBuffer;
@property(nonatomic,assign)GLuint frameBuffer;

@property (nonatomic , assign)CGFloat offTime;
@property(nonatomic,strong)dispatch_source_t timer;//定时器

@end

@implementation TCameraView

+(Class)layerClass
{
    return [CAEAGLLayer class];
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //初始化layer
        [self setupLayer];
        //初始化上下文
        [self setupContext];
        //设置render frame buffer
        [self setupRender_frameBuffer];
        
        glEnable(GL_DEPTH_TEST);
        
        //加载着色器
        self.program = [MHGLESTools loadProgramVertFileName:@"TCameraV.vs" fragFileName:@"TCameraF.fs"];
        
        //绑定两张图片纹理
        [MHGLESTools bindImageTexture:@"container.jpg" textureID:0 program:self.program uniformName:"texture1"];
        [MHGLESTools bindImageTexture:@"awesomeface.png" textureID:1 program:self.program uniformName:"texture2"];
        
        //激活 顶点 纹理 坐标
        [self setPosition_coord];
        //开启定时器
        [self openTimer];
    }
    return self;
}
-(void)setupLayer
{
    self.eaglLayer = (CAEAGLLayer *)self.layer;
    //放大倍数
    [self setContentScaleFactor:UIScreen.mainScreen.scale];
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    self.eaglLayer.opaque = YES;
    //设置描绘属性。设置不维持渲染内容，颜色格式RGBA8
    self.eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking :@(FALSE), kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
}
-(void)setupContext
{
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
}
-(void)setupRender_frameBuffer
{
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
// 激活 顶点 纹理坐标
-(void)setPosition_coord
{
    GLfloat vertices[] = {
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
    };
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    GLuint position = glGetAttribLocation(self.program, "aPos");
    GLuint textCoor = glGetAttribLocation(self.program, "aTexCoord");
    //激活顶点数组
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL + 0);
    glEnableVertexAttribArray(position);
    //激活纹理坐标
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL + 3);
    glEnableVertexAttribArray(textCoor);
}
-(void)timerRun
{
    self.offTime += 0.1;
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    CGFloat scale = UIScreen.mainScreen.scale;//当前视图放大倍数
    //设置视口大小
    glViewport(0.f, 0.f, self.frame.size.width * scale, self.frame.size.height * scale);
    
    
    //投影
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    ksMatrix4 projectionMat;
    ksMatrixLoadIdentity(&projectionMat);
    ksPerspective(&projectionMat, 45.0, width/height, 0.1f, 100.0);
    GLuint projectionMatSlot = glGetUniformLocation(self.program, "projection");
    glUniformMatrix4fv(projectionMatSlot, 1, GL_FALSE, (GLfloat *)&projectionMat.m[0][0]);
    
    //lookat
    ksMatrix4 lookAt;
    ksMatrixLoadIdentity(&lookAt);
    CGFloat radius = 10.f;
    CGFloat camZ = fabs(sin(_offTime) * radius);
    NSLog(@"%f",camZ);
    ksVec3 eye = ksVectorLoad(0.0, 0.f, camZ);
    ksVec3 target = ksVectorLoad(0.f, 0.f, 0.f);
    ksVec3 up = ksVectorLoad(0.f, 1.f, 0.f);
    ksLookAt(&lookAt, &eye, &target, &up);
    GLuint viewMatSlot = glGetUniformLocation(self.program, "view");
    glUniformMatrix4fv(viewMatSlot, 1, GL_FALSE, (GLfloat *)&lookAt.m[0][0]);
    
    
    ksMatrix4 mode;
    ksMatrixLoadIdentity(&mode);
    ksMatrixRotate(&mode, _offTime*10, 1.0, 0.0, 0.0);
    ksMatrixRotate(&mode, _offTime*10, 0.0, 1.0, 0.0);
    ksMatrixRotate(&mode, _offTime*10, 0.0, 0.0, 1.0);
    GLuint modeMatSlot = glGetUniformLocation(self.program, "model");
    glUniformMatrix4fv(modeMatSlot, 1, GL_FALSE, (GLfloat *)&mode.m[0][0]);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}
-(void)openTimer
{
    self.offTime = 0.f;
    
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    //设置定时器的各种属性
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1*NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(0.1*NSEC_PER_SEC);
    dispatch_source_set_timer(self.timer, start, interval, 0);
    
    //设置回调
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.timer, ^{
        //定时器需要执行的操作
        [weakSelf timerRun];
    });
    //启动定时器（默认是暂停）
    dispatch_resume(self.timer);
}
-(void)dealloc
{
    [self destoryBuffer];
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}
@end
