//
//  Test1VC.m
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/5/30.
//  Copyright © 2019 mh. All rights reserved.
//

#import "Test1VC.h"


//#define nomal       //正常
//#define overturn    //翻转
#define symmetry    //对称

@interface Test1VC ()<GLKViewDelegate>

@property(nonatomic,strong)EAGLContext * context;
@property(nonatomic,strong)GLKBaseEffect * baseEffect;
@property(nonatomic,strong)GLKView * glkView;

@end

@implementation Test1VC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupConfig];
#ifdef nomal
    //正常
    [self uploadVertexArray1];
#endif
    
#ifdef overturn
    //翻转
    [self uploadVertexArray2];
#endif
    
#ifdef symmetry
    //对称
    [self uploadVertexArray3];
#endif
    
    [self uploadTexture];
}
- (void)setupConfig
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    self.glkView = [[GLKView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width) context:self.context];
    self.glkView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    self.glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;//颜色缓冲区格式
    self.glkView.delegate = self;
    [self.view addSubview:self.glkView];

    [EAGLContext setCurrentContext:self.context];
}

- (void)uploadTexture
{
    //纹理贴图 GLKTextureLoader读取图片，创建纹理GLKTextureInfo
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"forTest" ofType:@"jpeg"];
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];//GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    //着色器 创建着色器GLKBaseEffect，把纹理赋值给着色器
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.texture2d0.enabled = GL_TRUE;
    self.baseEffect.texture2d0.name = textureInfo.name;
}
//正常
-(void)uploadVertexArray1
{
    /*
    顶点数组里包括顶点坐标，OpenGLES的世界坐标系是[-1, 1]，故而点(0, 0)是在屏幕的正中间。
    纹理坐标系的取值范围是[0, 1]，原点是在左下角。故而点(0, 0)在左下角，点(1, 1)在右上角。
    索引数组是顶点数组的索引，把squareVertexData数组看成4个顶点，每个顶点会有5个GLfloat数据，索引从0开始。
    */
    //顶点数据，前三个是顶点坐标（x、y、z轴），后面两个是纹理坐标（x，y）
    GLfloat vertexData2[] =
    {
        -0.5, -0.5, 0.0f, 0.0, 0.0, //左下
        -0.5, 0.5, 0.0f, 0.0, 1.0, //左上
        0.5, -0.5, 0.0f, 1.0, 0.0, //右下
        0.5, 0.5, 0.0f, 1.0, 1.0, //右上
    };
    //顶点数据缓存
    GLuint buffer;
    //申请一个标识符
    glGenBuffers(1, &buffer);
    //把标识符绑定到GL_ARRAY_BUFFER上
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    //把顶点数据从cpu内存复制到gpu内存
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData2), vertexData2, GL_STATIC_DRAW);
    
    //开启对应的顶点属性
    glEnableVertexAttribArray(GLKVertexAttribPosition); //顶点数据缓存
    //设置合适的格式从buffer里面读取数据   sizeof GLfloat * 5，这表明隔五个浮点数读取一组数据
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, 0, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); //纹理
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, 0, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
}
// 翻转
-(void)uploadVertexArray2
{
    GLfloat vertexData2[] =
    {
        -0.5, -0.5, 0.0f, 1.0, 0.0, //左下
        -0.5, 0.5, 0.0f, 1.0, 1.0, //左上
        0.5, -0.5, 0.0f, 0.0, 0.0, //右下
        0.5, 0.5, 0.0f, 0.0, 1.0, //右上
    };
    
    //顶点数据缓存
    GLuint buffer;
    //申请一个标识符
    glGenBuffers(1, &buffer);
    //把标识符绑定到GL_ARRAY_BUFFER上
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    //把顶点数据从cpu内存复制到gpu内存
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData2), vertexData2, GL_STATIC_DRAW);
    
    //开启对应的顶点属性
    glEnableVertexAttribArray(GLKVertexAttribPosition); //顶点数据缓存
    //设置合适的格式从buffer里面读取数据   sizeof GLfloat * 5，这表明隔五个浮点数读取一组数据
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, 0, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); //纹理
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, 0, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
}
//对称
-(void)uploadVertexArray3
{
    GLfloat squareVertexData[] =
    {
        1, -0.5, 0.0f, 0.0f, 0.0f, //右下
        1, 0.5, -0.0f, 0.0f, 1.0f, //右上
        0.0, 0.5, 0.0f, 1.0f, 1.0f, //中上
        0.0, -0.5, 0.0f, 1.0f, 0.0f, //中下
        
        -1, 0.5, 0.0f, 0.0f, 1.0f, //左上
        -1, -0.5, 0.0f, 0.0f, 0.0f, //左下
        0.0, -0.5, 0.0f, 1.0f, 0.0f, //中下
        0.0, 0.5, 0.0f, 1.0f, 1.0f, //中上
    };
    
    GLbyte indices[] =
    {
        0,1,2,
        2,3,0,
        4,5,6,
        6,7,4
    };
    
    //顶点数据缓存
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    
    GLuint texturebuffer;
    glGenBuffers(1, &texturebuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, texturebuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition); //顶点数据缓存
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); //纹理
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
}
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0, 0.0, 0.0, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //启动着色器
    [self.baseEffect prepareToDraw];
#ifdef nomal
    //正常
    /*
     glDrawArrays(int mode, int first,int count)
     参数1：有三种取值
     1.GL_TRIANGLES：将用数组中开始的三个顶点来组成一个三角形。完成后,再用下一组的三个顶点来组成三角形,直到数组结束 。既 0,1,2组成1个三角形，3,4,5组成一个三角形， 最后不够3个顶点就不会画出图形。 比如如果数组长度为5,则只会用0,1,2三个顶点画出一个三角形。
     2.GL_TRIANGLE_FAN：以012,023,034，……的形式绘制三角形
     3.GL_TRIANGLE_STRIP 顺序在每三个顶点之间均绘制三角形 以012,123,234……的形式绘制三角形
     参数2：从数组缓存中的哪一位开始绘制，一般都定义为0
     参数3：顶点的数量
     */
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
#endif
    
#ifdef overturn
    //翻转
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
#endif
    
#ifdef symmetry
    //对称
    /*
     glDrawElements(GLenum mode, GLsizei count, GLenum type, const GLvoid * indices);
     参数1：大致同上
     参数2：绘制三角形个数*3，比如要绘制4个三角形，count=3*4=12
     参数3：参数4的类型？？？？
     参数4：三角形索引数组
     */
    glDrawElements(GL_TRIANGLES, 12, GL_UNSIGNED_BYTE, 0);
#endif

    

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
