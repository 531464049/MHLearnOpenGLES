//
//  BaseVC.m
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/5/30.
//  Copyright © 2019 mh. All rights reserved.
//

#import "BaseVC.h"

@interface BaseVC ()

@end

@implementation BaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}
// 初始化EAGLContext  GLKView
- (void)setupContext_glkView
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    self.glkView = [[GLKView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) context:self.context];
    self.glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;//颜色缓冲区格式
    self.glkView.delegate = self;
    [self.view addSubview:self.glkView];
    
    [EAGLContext setCurrentContext:self.context];
}
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
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



@interface BaseView ()

@end

@implementation BaseView

+(Class)layerClass
{
    return [CAEAGLLayer class];
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
-(void)dealloc
{
    [self destoryBuffer];
}
@end
