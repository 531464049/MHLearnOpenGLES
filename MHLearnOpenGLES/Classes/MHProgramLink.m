//
//  MHProgramLink.m
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/6/11.
//  Copyright © 2019 mh. All rights reserved.
//

#import "MHProgramLink.h"

@implementation MHProgramLink


+(GLint)loadProgramVertFileName:(NSString *)vertfileName fragFileName:(NSString *)fragFileName
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
    }
}
@end
