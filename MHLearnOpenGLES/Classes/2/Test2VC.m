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


@end

@implementation Test2View

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
