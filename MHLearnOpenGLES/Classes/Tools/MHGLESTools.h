//
//  MHGLESTools.h
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/6/24.
//  Copyright © 2019 mh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import "ksVector.h"
#import "ksMatrix.h"

@interface MHGLESTools : NSObject

+(GLuint)loadProgramVertFileName:(NSString *)vertfileName fragFileName:(NSString *)fragFileName;

+(void)bindImageTexture:(NSString *)imgName textureID:(int)ID program:(GLuint)program uniformName:(const GLchar *)name;

@end

