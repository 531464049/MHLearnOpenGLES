//
//  MHGLESTools.m
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/6/24.
//  Copyright © 2019 mh. All rights reserved.
//

#import "MHGLESTools.h"

@implementation MHGLESTools

+(GLuint)loadProgramVertFileName:(NSString *)vertfileName fragFileName:(NSString *)fragFileName
{
    NSArray * vertNameArr = [vertfileName componentsSeparatedByString:@"."];
    NSArray * fragNameArr = [fragFileName componentsSeparatedByString:@"."];
    //Test2V.vs  Test2F.fs
    NSString * vertFile = [[NSBundle mainBundle] pathForResource:vertNameArr[0] ofType:vertNameArr[1]];
    NSString * fragFile = [[NSBundle mainBundle] pathForResource:fragNameArr[0] ofType:fragNameArr[1]];
    
    GLuint program = glCreateProgram();
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
    
    //链接
    glLinkProgram(program);
    //获取链接结果
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        //链接错误
        GLchar messages[256];
        glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"着色器链接失败--->%@", messageString);
        return -1;
    }
    //链接成功便使用，避免由于未使用导致bug
    glUseProgram(program);
    return program;
}
+(void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
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
        
        GLchar messages[256];
        glGetShaderInfoLog(*shader,sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"编译着色器失败--->%@", messageString);
        
    }
}
// 绑定图片纹理单元
+(void)bindImageTexture:(NSString *)imgName textureID:(int)ID program:(GLuint)program uniformName:(const GLchar *)name
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
    
    GLuint uniformTesture  = glGetUniformLocation(program, name);
    glUniform1i(uniformTesture, ID);
    
    free(spriteData);
}
@end
