//
//  MHVertexAttribArrayBuffer.h
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/6/5.
//  Copyright © 2019 mh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface MHVertexAttribArrayBuffer : NSObject

@property(nonatomic,readonly)GLuint name;
@property(nonatomic,readonly)GLsizeiptr stride;
@property(nonatomic,readonly)GLsizeiptr bufferSizeBytes;

+(void)drawPreparedArraysWidthMode:(GLenum)mode startVertexIndex:(GLint)first numberofVertices:(GLsizei)count;

-(id)initWithAttribStride:(GLsizeiptr)stride numberofVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr usage:(GLenum)usage;

- (void)prepareToDrawWithAttrib:(GLuint)index numberOfCoordinates:(GLint)count attribOffset:(GLsizeiptr)offset shouldEnable:(BOOL)shouldEnable;

- (void)drawArrayWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count;

- (void)reinitWithAttribStride:(GLsizeiptr)stride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr;

@end

