//
//  Test2VC.m
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/5/30.
//  Copyright © 2019 mh. All rights reserved.
//

#import "Test2VC.h"

@interface Test2VC ()

@end

@implementation Test2VC

- (void)viewDidLoad {
    [super viewDidLoad];
    Test2View * view = [[Test2View alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    view.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:view];
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


@interface Test2View ()

@property(nonatomic,strong)EAGLContext * context;
@property(nonatomic,strong)CAEAGLLayer * eaglLayer;
@property(nonatomic,assign)GLuint program;
@property(nonatomic,assign)GLuint renderBuffer;
@property(nonatomic,assign)GLuint frameBuffer;

@end

@implementation Test2View

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
        //加载h着色器
        [self loadProgramVertFileName:@"Test2V.vs" fragFileName:@"Test2F.fs"];
        //加载纹理
        [self setupTexture];
        //渲染
        [self render];
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
//渲染
-(void)render
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGFloat scale = UIScreen.mainScreen.scale;//当前视图放大倍数
    //设置视口(?视图窗口？)大小
    glViewport(0.f, 0.f, self.frame.size.width * scale, self.frame.size.height * scale);
    /*
    //顶点-纹理坐标(顶点x,y，z默认都是0（不写了）)
    GLfloat attrArr[] =
    {
        -0.5 , -0.5,   0.0,0.0,//左下
         0.5 , -0.5,   1.0,0.0,//右下
        -0.5 , 0.5,    0.0,1.0,//左上
         0.5 , 0.5,    1.0,1.0,//右上
    };//如果用这个，图片是反的
    GLfloat attrArr2[] =
    {
        -0.5 , -0.5,   0.0,1.0,//左下
        0.5 , -0.5,   1.0,1.0,//右下
        -0.5 , 0.5,    0.0,0.0,//左上
        0.5 , 0.5,    1.0,0.0,//右上
    };
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr2), attrArr2, GL_DYNAMIC_DRAW);
    //获取着色器里边的变量（必须在glLinkProgram链接后使用）
    GLuint position = glGetAttribLocation(self.myProgram, "position");
    GLuint textCoor = glGetAttribLocation(self.myProgram, "textCoordinate");
    //设置顶点坐标
    glVertexAttribPointer(position, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, NULL);
    //激活顶点数组
    glEnableVertexAttribArray(position);
    //设置纹理坐标
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, (float *)NULL + 2);
    //激活纹理数组
    glEnableVertexAttribArray(textCoor);
    */
    
    //获取着色器里边的变量（必须在glLinkProgram链接后使用）
    GLuint position = glGetAttribLocation(self.program, "position");
    GLuint textCoor = glGetAttribLocation(self.program, "textCoordinate");
    //设置顶点坐标
    GLfloat positonAttr[] = {
        -0.5 , -0.5,//左下
        0.5 , -0.5,//右下
        -0.5 , 0.5,//左上
        0.5 , 0.5,//右上
    };
    glVertexAttribPointer(position, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 2, positonAttr);
    //激活顶点数组
    glEnableVertexAttribArray(position);
    
    //设置纹理坐标
    GLfloat textCoorAttr[] = {
        0.0,1.0,
        1.0,1.0,
        0.0,0.0,
        1.0,0.0,
    };
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 2, textCoorAttr);
    //激活纹理数组
    glEnableVertexAttribArray(textCoor);
    
    GLuint rotate = glGetUniformLocation(self.program, "rotate");
    //设置旋转角度
    glUniform1f(rotate, GLKMathDegreesToRadians(360-90));
    
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}
@end
