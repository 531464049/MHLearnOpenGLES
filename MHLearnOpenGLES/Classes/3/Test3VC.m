//
//  Test3VC.m
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/5/30.
//  Copyright © 2019 mh. All rights reserved.
//

#import "Test3VC.h"

@interface Test3VC ()
{
    Test3View * _view;
}
@end

@implementation Test3VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _view = [[Test3View alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height-200)];
    [self.view addSubview:_view];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_view closeTimer];
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


@interface Test3View ()
{
    float degree;
    float yDegree;
    NSTimer * myTimer;
}

@end

@implementation Test3View

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
        //加载着色器
        [self loadProgramVertFileName:@"Test3v.vs" fragFileName:@"Test3f.fs"];
        
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(onRes:) userInfo:nil repeats:YES];
    }
    return self;
}
- (void)onRes:(id)sender {
    degree += 5;
    if (degree >= 360.f) {
        degree = 0.f;
    }
    yDegree += 5;
    if (yDegree >= 360.f) {
        yDegree = 0.f;
    }
    [self render];
}
-(void)closeTimer
{
    if (myTimer) {
        [myTimer invalidate];
        myTimer = nil;
    }
}
// 渲染
-(void)render
{
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width * UIScreen.mainScreen.scale, self.frame.size.height * UIScreen.mainScreen.scale);
    
    GLfloat positionArr[] =
    {
        -1.0, 1.0, 0.0f, //左上
        1.0, 1.0, 0.0f, //右上
        -1.0, -1.0, 0.0f, //左下
        1.0, -1.0, 0.0f, //右下
        0.0f, 0.0f, 1.0f, //顶点
    };
    GLuint position = glGetAttribLocation(self.program, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) + 3, positionArr);
    glEnableVertexAttribArray(position);
    
    GLfloat textCoordArr[] =
    {
        1.0f, 0.0f, 1.0f, //左上
        1.0f, 0.0f, 1.0f, //右上
        1.0f, 1.0f, 1.0f, //左下
        1.0f, 1.0f, 1.0f, //右下
        0.0f, 1.0f, 0.0f, //顶点
    };
    GLuint textCoordinate = glGetAttribLocation(self.program, "textCoordinate");
    glVertexAttribPointer(textCoordinate, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) + 3, textCoordArr);
    glEnableVertexAttribArray(textCoordinate);
    
    
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    KSMatrix4 _projectionMatrix;
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksPerspective(&_projectionMatrix, 30.0, width/height, 5.0f, 20.0f); //透视变换，视角30°
    //设置glsl里面的投影矩阵
    GLuint projectionMatrixSlot = glGetUniformLocation(self.program, "projectionMatrix");
    glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE, (GLfloat *)&_projectionMatrix.m[0][0]);
    
    //平移
    KSMatrix4 _modelViewMatrix;
    ksMatrixLoadIdentity(&_modelViewMatrix);
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -10.0);
    
    //旋转
    KSMatrix4 _rotationMatrix;
    ksMatrixLoadIdentity(&_rotationMatrix);
    ksRotate(&_rotationMatrix, degree, 1.0, 0.0, 0.0); //绕X轴
    ksRotate(&_rotationMatrix, yDegree, 0.0, 1.0, 0.0); //绕Y轴
    
    //把变换矩阵相乘，注意先后顺序
    ksMatrixMultiply(&_modelViewMatrix, &_rotationMatrix, &_modelViewMatrix);
    //    ksMatrixMultiply(&_modelViewMatrix, &_modelViewMatrix, &_rotationMatrix);
    
    GLuint modelViewMatrixSlot = glGetUniformLocation(self.program, "modelViewMatrix");
    glUniformMatrix4fv(modelViewMatrixSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
    
    glEnable(GL_CULL_FACE);
    
    GLuint indices[] =
    {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    GLsizei count = sizeof(indices) / sizeof(indices[0]);//18/1=18
    glDrawElements(GL_TRIANGLES, count, GL_UNSIGNED_INT, indices);
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}
@end
