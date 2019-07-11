//
//  Test6VC.m
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/6/11.
//  Copyright © 2019 mh. All rights reserved.
//

#import "Test6VC.h"


@interface Test6VC ()

@end

@implementation Test6VC

- (void)viewDidLoad {
    [super viewDidLoad];
 
    Test6View * view = [[Test6View alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    view.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:view];
    
    self.view.backgroundColor = [UIColor whiteColor];
}
@end


@interface Test6View ()

@property(nonatomic,strong)EAGLContext * context;
@property(nonatomic,strong)CAEAGLLayer * eaglLayer;
@property(nonatomic,assign)GLuint program;
@property(nonatomic,assign)GLuint renderBuffer;
@property(nonatomic,assign)GLuint frameBuffer;

@end

@implementation Test6View

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
        
        //渲染一个三角形
        // [self renderTriangle];
        //渲染一张图片，中间菱形空心
        // [self renderImage];
        //渲染两张图片(混合)
        [self renderTwoImage];
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
//渲染一个三角形
-(void)renderTriangle
{
    //加载着色器
    self.program = [MHGLESTools loadProgramVertFileName:@"test6v.vs" fragFileName:@"test6f.fs"];
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGFloat scale = UIScreen.mainScreen.scale;//当前视图放大倍数
    //设置视口(?视图窗口？)大小
    glViewport(0.f, 0.f, self.frame.size.width * scale, self.frame.size.height * scale);

    
    //获取着色器里边的变量（必须在glLinkProgram链接后使用）
    GLuint position = glGetAttribLocation(self.program, "aPos");
    //设置顶点坐标
    GLfloat positonAttr[] = {
        -0.5 , -0.5,
        0.5 , -0.5,
        0.0 , 0.5,
    };
    glVertexAttribPointer(position, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 2, positonAttr);
    //激活顶点数组
    glEnableVertexAttribArray(position);
    
    GLuint positionColor = glGetAttribLocation(self.program, "aColor");
    GLfloat positionColorAttr[] = {
        1.0,0.0,0.0,
        0.0,1.0,0.0,
        0.0,0.0,1.0,
    };
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, positionColorAttr);
    glEnableVertexAttribArray(positionColor);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 3);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}
//渲染一个图片
-(void)renderImage
{
    //加载着色器
    self.program = [MHGLESTools loadProgramVertFileName:@"test6_2v.vs" fragFileName:@"test6_2f.fs"];
    
    //绑定图片纹理
    [self bindImageTexture:@"forTest.jpeg" textureID:0 uniformName:"ourTexture"];

    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    CGFloat scale = UIScreen.mainScreen.scale;//当前视图放大倍数
    //设置视口大小
    glViewport(0.f, 0.f, self.frame.size.width * scale, self.frame.size.height * scale);
    
    GLfloat vertices[] = {
        1.0,1.0,0.0,    1.0,0.0,
        1.0,-1.0,0.0,   1.0,1.0,
        -1.0,-1.0,0.0,  0.0,1.0,
        -1.0,1.0,0.0,   0.0,0.0,
        0.0,0.5,0.0,    0.5,0.25,
        0.5,0.0,0.0,    0.75,0.5,
        0.0,-0.5,0.0,   0.5,0.75,
        -0.5,0.0,0.0,   0.25,0.5,
    };
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.program, "aPos");
    GLuint textCoor = glGetAttribLocation(self.program, "aTexCoord");
    
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL + 0);
    //激活顶点数组
    glEnableVertexAttribArray(position);
    
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL + 3);
    glEnableVertexAttribArray(textCoor);
    
    GLbyte indices[] = {
        0,4,5,
        0,5,1,
        1,5,6,
        1,6,2,
        2,6,7,
        2,3,7,
        3,4,7,
        3,4,0,
    };
    GLuint elemBuffer;
    glGenBuffers(1, &elemBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elemBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    GLsizei count = sizeof(indices) / sizeof(indices[0]);
    glDrawElements(GL_TRIANGLES, count, GL_UNSIGNED_BYTE, 0);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}
// 绑定图片纹理单元
-(void)bindImageTexture:(NSString *)imgName textureID:(int)ID uniformName:(const GLchar *)name
{
    //获取图片CGImageRef
    UIImage * image = [UIImage imageNamed:imgName];
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
    
    GLuint texture;
    /* glGenTextures 函数首先需要输入生成纹理的数量，
     然后把它们储存在第二个参数的`unsigned int`数组中（我们的例子中只是单独的一个`unsigned int`），
     就像其他对象一样，我们需要绑定它，让之后任何的纹理指令都可以配置当前绑定的纹理
     */
    glGenTextures(1, &texture);
    glActiveTexture(GL_TEXTURE0 + ID);
    //绑定纹理
    glBindTexture(GL_TEXTURE_2D, texture);
    
    // 为当前绑定的纹理对象设置环绕、过滤方式
    //过滤方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    //环绕方式
    /*
     GL_REPEAT            | 对纹理的默认行为。重复纹理图像。
     GL_MIRRORED_REPEAT   | 和 GL_REPEAT 一样，但每次重复图片是镜像放置的。
     GL_CLAMP_TO_EDGE     | 纹理坐标会被约束在0到1之间，超出的部分会重复纹理坐标的边缘，产生一种边缘被拉伸的效果。
     GL_CLAMP_TO_BORDER   | 超出的坐标为用户指定的边缘颜色。
     
     GL_TEXTURE_WRAP_S|GL_TEXTURE_WRAP_T s,t,w轴，等价于x,y,z
     如果选择 GL_CLAMP_TO_BORDER 选项，还需要指定一个边缘的颜色。这需要使用 glTexParameter 函数的`fv`后缀形式，用 GL_TEXTURE_BORDER_COLOR 作为它的选项，并且传递一个float数组作为边缘的颜色值
     float borderColor[] = { 1.0f, 1.0f, 0.0f, 1.0f };
     glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, borderColor);
     */
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    //生成纹理
    /*
     - 第一个参数指定了纹理目标(Target)。设置为 GL_TEXTURE_2D 意味着会生成与当前绑定的纹理对象在同一个目标上的纹理（任何绑定到 GL_TEXTURE_1D 和 GL_TEXTURE_3D 的纹理不会受到影响）。
     - 第二个参数为纹理指定多级渐远纹理的级别，填0，也就是基本级别。
     - 第三个参数告诉OpenGL我们希望把纹理储存为何种格式。
     - 第四个和第五个参数设置最终的纹理的宽度和高度。
     - 下个参数应该总是被设为`0`（历史遗留的问题）。
     - 第七第八个参数定义了源图的格式和数据类型。
     - 最后一个参数是真正的图像数据。
     */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (float)width, (float)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    glGenerateMipmap(GL_TEXTURE_2D);//这会为当前绑定的纹理自动生成所有需要的多级渐远纹理。
    
    //绑定纹理
    glBindTexture(GL_TEXTURE_2D, texture);
    
    GLuint uniformTesture  = glGetUniformLocation(self.program, name);
    glUniform1i(uniformTesture, ID);
    
    free(spriteData);
}
// 渲染两张图片
-(void)renderTwoImage
{
    //加载着色器
    self.program = [MHGLESTools loadProgramVertFileName:@"test6_3v.vs" fragFileName:@"test6_3f.fs"];
    
    //绑定两张图片纹理
    [self bindImageTexture:@"forTest.jpeg" textureID:0 uniformName:"texture1"];
    [self bindImageTexture:@"awesomeface.png" textureID:1 uniformName:"texture2"];
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    CGFloat scale = UIScreen.mainScreen.scale;//当前视图放大倍数
    //设置视口大小
    glViewport(0.f, 0.f, self.frame.size.width * scale, self.frame.size.height * scale);
    
    GLfloat vertices[] = {
        1.0,1.0,0.0,    1.0,0.0,
        1.0,-1.0,0.0,   1.0,1.0,
        -1.0,-1.0,0.0,  0.0,1.0,
        -1.0,1.0,0.0,   0.0,0.0,
        0.0,0.5,0.0,    0.5,0.25,
        0.5,0.0,0.0,    0.75,0.5,
        0.0,-0.5,0.0,   0.5,0.75,
        -0.5,0.0,0.0,   0.25,0.5,
    };
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.program, "aPos");
    GLuint textCoor = glGetAttribLocation(self.program, "aTexCoord");
    
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL + 0);
    //激活顶点数组
    glEnableVertexAttribArray(position);
    
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL + 3);
    glEnableVertexAttribArray(textCoor);
    
    GLbyte indices[] = {
        0,4,5,
        0,5,1,
        1,5,6,
        1,6,2,
        2,6,7,
        2,3,7,
        3,4,7,
        3,4,0,
    };
    GLuint elemBuffer;
    glGenBuffers(1, &elemBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elemBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    GLsizei count = sizeof(indices) / sizeof(indices[0]);
    glDrawElements(GL_TRIANGLES, count, GL_UNSIGNED_BYTE, 0);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}
//-(void)
@end
