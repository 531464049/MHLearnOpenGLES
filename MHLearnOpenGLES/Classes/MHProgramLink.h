//
//  MHProgramLink.h
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/6/11.
//  Copyright © 2019 mh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

@interface MHProgramLink : NSObject

+(GLint)loadProgramVertFileName:(NSString *)vertfileName fragFileName:(NSString *)fragFileName;

@end

