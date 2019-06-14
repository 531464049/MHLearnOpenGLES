//
//  MHVertexAttribArrayBuffer.m
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/6/5.
//  Copyright © 2019 mh. All rights reserved.
//

#import "MHVertexAttribArrayBuffer.h"
@interface MHVertexAttribArrayBuffer ()


@end

@implementation MHVertexAttribArrayBuffer

-(id)initWithAttribStride:(GLsizeiptr)stride numberofVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr usage:(GLenum)usage
{
    self = [super init];
    if (self) {
        _stride = stride;
        _bufferSizeBytes = stride * count;
        
        // STEP 1
        glGenBuffers(1, &_name);
        // STEP 2
        glBindBuffer(GL_ARRAY_BUFFER, self.name);
        // STEP 3
        glBufferData(
                     GL_ARRAY_BUFFER,      // Initialize buffer contents
                     self.bufferSizeBytes, // Number of bytes to copy
                     dataPtr,              // Address of bytes to copy
                     usage);               // Hint: cache in GPU memory
    }
    return self;
}
-(void)reinitWithAttribStride:(GLsizeiptr)stride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr
{
    _stride = stride;
    _bufferSizeBytes = stride * count;
    
    // STEP 2
    glBindBuffer(GL_ARRAY_BUFFER, self.name);
    // STEP 3
    glBufferData(GL_ARRAY_BUFFER, self.bufferSizeBytes, dataPtr, GL_DYNAMIC_DRAW);
}
-(void)prepareToDrawWithAttrib:(GLuint)index numberOfCoordinates:(GLint)count attribOffset:(GLsizeiptr)offset shouldEnable:(BOOL)shouldEnable
{
    // STEP 2
    glBindBuffer(GL_ARRAY_BUFFER, self.name);
    if (shouldEnable) {
        // STEP 4
        glEnableVertexAttribArray(index);
    }
    // STEP 5
    glVertexAttribPointer(index,
                          count,
                          GL_FLOAT,
                          GL_FALSE,
                          self.stride,
                          NULL + offset);
}
-(void)drawArrayWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count
{
    // STEP 6
    glDrawArrays(mode, first, count);
}
+(void)drawPreparedArraysWidthMode:(GLenum)mode startVertexIndex:(GLint)first numberofVertices:(GLsizei)count
{
    // STEP 6
    glDrawArrays(mode, first, count);
}
-(void)dealloc
{
    // Step 7
    if (self.name) {
        glDeleteBuffers(1, &_name);
        _name = 0;
    }
}
@end
