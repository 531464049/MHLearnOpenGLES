//
//  BaseVC.h
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/5/30.
//  Copyright © 2019 mh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>

@interface BaseVC : UIViewController<GLKViewDelegate>

@property(nonatomic,strong)EAGLContext * context;
@property(nonatomic,strong)GLKBaseEffect * baseEffect;
@property(nonatomic,strong)GLKView * glkView;

/** 初始化EAGLContext  GLKView */
- (void)setupContext_glkView;

@end



@interface BaseView : UIView

@property(nonatomic,strong)EAGLContext * context;
@property(nonatomic,strong)CAEAGLLayer * eaglLayer;
@property(nonatomic,assign)GLuint program;

@property(nonatomic,assign)GLuint renderBuffer;
@property(nonatomic,assign)GLuint frameBuffer;

/** 初始化CAEAGLLayer */
-(void)setupLayer;
/** 初始化EAGLContext */
-(void)setupContext;
/** 设置render frame buffer */
-(void)setupRender_frameBuffer;
/** 清空buffer引用 */
-(void)destoryBuffer;
/** 加载着色器 */
-(void)loadProgramVertFileName:(NSString *)vertfileName fragFileName:(NSString *)fragFileName;

@end
