//
//  Test4_2VC.m
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/5/31.
//  Copyright © 2019 mh. All rights reserved.
//

#import "Test4VC.h"

@interface Test4VC ()
{
    Test4_2View * _view;
}
@end

@implementation Test4VC

- (void)viewDidLoad {
    [super viewDidLoad];
    _view = [[Test4_2View alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height-200)];
    [self.view addSubview:_view];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

@interface Test4_2View ()

@property(nonatomic,strong)EAGLContext * context;
@property(nonatomic,strong)CAEAGLLayer * eaglLayer;
@property(nonatomic,assign)GLuint program;
@property(nonatomic,assign)GLuint renderBuffer;
@property(nonatomic,assign)GLuint frameBuffer;


@property (nonatomic , assign) float mDegreeX;
@property (nonatomic , assign) float mDegreeY;
@property (nonatomic , assign) float mDegreeZ;

@property(nonatomic,strong)dispatch_source_t timer;//定时器

@end

@implementation Test4_2View

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
        glEnable(GL_DEPTH_TEST);
        //设置render frame buffer
        [self setupRender_frameBuffer];
        //加载着色器
        [self loadProgramVertFileName:@"Test4v.vs" fragFileName:@"Test4f.fs"];

        [self setupTexture];
        
        
//        [self renderNew];
        [self openTimer];
    }
    return self;
}
// 初始化layer
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
//初始化上下文
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
//设置render frame buffer
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
// 加载着色器
-(void)loadProgramVertFileName:(NSString *)vertfileName fragFileName:(NSString *)fragFileName
{
    NSArray * vertNameArr = [vertfileName componentsSeparatedByString:@"."];
    NSArray * fragNameArr = [fragFileName componentsSeparatedByString:@"."];
    //Test2V.vs  Test2F.fs
    NSString * vertFile = [[NSBundle mainBundle] pathForResource:vertNameArr[0] ofType:vertNameArr[1]];
    NSString * fragFile = [[NSBundle mainBundle] pathForResource:fragNameArr[0] ofType:fragNameArr[1]];
    
    GLint program = glCreateProgram();
    //编译
    GLuint verShader;
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vertFile];
    GLuint fragShader;
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragFile];
    
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    //释放不需要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    self.program = program;
    
    //链接
    glLinkProgram(self.program);
    //获取链接结果
    GLint linkStatus;
    glGetProgramiv(self.program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        //链接错误
        GLchar messages[256];
        glGetProgramInfoLog(self.program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"着色器链接失败--->%@", messageString);
        return ;
    }
    //链接成功便使用，避免由于未使用导致bug
    glUseProgram(self.program);
}
-(void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    //读取字符
    NSString * content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar * source = (GLchar *)content.UTF8String;
    //创建着色器
    *shader = glCreateShader(type);
    //加载着色器源码
    glShaderSource(*shader, 1, &source, NULL);
    //编译着色器
    glCompileShader(*shader);
    
    //获取编译结果
    GLint status = 0;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        NSLog(@"编译着色器失败");
    }
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
//加载纹理
-(void)setupTexture
{
    //获取图片CGImageRef
    UIImage * image = [UIImage imageNamed:@"forTest.jpeg"];
    CGImageRef spriteImage = image.CGImage;
    if (!spriteImage) {
        NSLog(@"图片加载失败??????");
        return;
    }
    
    //图片大小
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    //rgba共4个byte
    GLubyte * spriteData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    //获取图片上下文
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    //绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    //释放
    CGContextRelease(spriteContext);
    
    //绑定纹理到默认的纹理ID（这里只有一张图片，故而相当于默认于片元着色器里面的colorMap，如果有多张图不可以这么做）
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (float)width, (float)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    GLuint colorMap  = glGetUniformLocation(self.program, "colorMap");
    glUniform1i(colorMap, 0);
    
    free(spriteData);
}
-(void)renderNew
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    CGFloat scale = UIScreen.mainScreen.scale;//当前视图放大倍数
    //设置视口(?视图窗口？)大小
    glViewport(0.f, 0.f, self.frame.size.width * scale, self.frame.size.height * scale);

    GLfloat positionArr[] =
    {
        -0.5f, 0.5f, 0.0f,
        0.5f, 0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        0.0f, 0.0f, 1.0f,
    };
    GLuint position = glGetAttribLocation(self.program, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, positionArr);
    glEnableVertexAttribArray(position);
    
////    //顶点颜色
//    GLfloat mapColorArr[] =
//    {
//        0.0f, 0.0f, 0.5f,
//        0.0f, 0.5f, 0.0f,
//        0.5f, 0.0f, 1.0f,
//        0.0f, 0.0f, 0.5f,
//        1.0f, 1.0f, 1.0f,
//    };
//    GLuint mapColor  = glGetAttribLocation(self.program, "mapColor");
//    glVertexAttribPointer(mapColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, mapColorArr);
//    glEnableVertexAttribArray(mapColor);
    
    GLfloat textCoorArr[] =
    {
        0.0f, 1.0f,//左上
        1.0f, 1.0f,//右上
        0.0f, 0.0f,//左下
        1.0f, 0.0f,//右下
        0.5f, 0.5f,//顶点
    };
    GLuint textCoor = glGetAttribLocation(self.program, "textCoordinate");
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 2, textCoorArr);
    glEnableVertexAttribArray(textCoor);

    
    float width = self.frame.size.width;
    float height = self.frame.size.height;

    ksMatrix4 _projectionMatrix;
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksPerspective(&_projectionMatrix, 90.0, width/height, 0.1f, 10.f);
    //设置glsl里面的投影矩阵
    GLuint projectionMatrixSlot = glGetUniformLocation(self.program, "projectionMatrix");
    glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE, (GLfloat *)&_projectionMatrix.m[0][0]);

    //平移
    ksMatrix4 _modelViewMatrix;
    ksMatrixLoadIdentity(&_modelViewMatrix);
    ksMatrixTranslate(&_modelViewMatrix, 0.0, 0.0, -2.0f);
    ksMatrixRotate(&_modelViewMatrix, self.mDegreeX, 1.0, 0.0, 0.0);
    ksMatrixRotate(&_modelViewMatrix, self.mDegreeY, 0.0, 1.0, 0.0);
    ksMatrixRotate(&_modelViewMatrix, self.mDegreeZ, 0.0, 0.0, 1.0);
    
    
    GLuint modelViewMatrixSlot = glGetUniformLocation(self.program, "modelViewMatrix");
    glUniformMatrix4fv(modelViewMatrixSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
    
    //顶点索引
    GLuint indices[] =
    {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    glDrawElements(GL_TRIANGLES, 18, GL_UNSIGNED_INT, indices);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}
-(void)timerRun
{
    self.mDegreeX += 6.0;
    self.mDegreeY += 6.0;
    self.mDegreeZ += 6.0;
    [self renderNew];
}
-(void)openTimer
{
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
