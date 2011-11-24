//
//  GLImageViewer.m
//  GLRenderLargeImage
//
//  Created by Haoxiang Li on 11/24/11.
//  Copyright (c) 2011 DEV. All rights reserved.
//

#import "GLImageViewer.h"

@implementation GLImageViewer

- (void)showImageNamed:(NSString *)imageNamed {
    UIImage *image = [UIImage imageNamed:imageNamed];
    texture = [MPGLView textureFromImage:image
                              withGLSize:[MPGLView textureSizeForImage:image]];
    [self renderRect:self.bounds];
}

//< Render Content, OpenGL Actions here
- (void)drawViewInRect:(CGRect)rect {

//    glColor4f(0.0f, 0.0f, 0.0f, 1.0f);    
//    glClear(GL_COLOR_BUFFER_BIT);
//    
//    glEnableClientState(GL_VERTEX_ARRAY);        
//    glColor4f(0x24/255.0f, 0x24/255.0f, 0x24/255.0f, 1.0f);
//            
//    GLfloat minTextAreaY = 20.0f;
//    GLfloat maxTextAreaY = 40;
//            
//    GLfloat currentX = 10;
//    int lineCount = 2;
//    GLfloat points[lineCount*4];
//    for (int i = 0; i < lineCount * 4; i += 4)
//    {
//        //< Start Point
//        points[i] = currentX;
//        points[i+1] = minTextAreaY;
//        
//        //< End Point
//        points[i+2] = currentX;
//        points[i+3] = maxTextAreaY;
//        
////        points[i+1] -= mBackingHeight;
////        points[i+3] -= mBackingHeight;
////        points[i+1] *= -1;
////        points[i+3] *= -1;
//        currentX += 10;
//    }
//    glVertexPointer(2, GL_FLOAT, 0, points);
//    glDrawArrays(GL_LINES, 0, lineCount*2);
//    glDisableClientState(GL_VERTEX_ARRAY);

    //[self bindTexture:texture];
        
    glEnable(GL_TEXTURE_2D);            
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    const GLfloat texCoords[] = {
        0, 1,
        1, 1,
        0, 0,
        1, 0
    };
    
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    
    glBindTexture(GL_TEXTURE_2D, texture);
    
    const GLfloat points[] = {
        CGRectGetMinX(rect), -CGRectGetMinY(rect),
        CGRectGetMaxX(rect), -(CGRectGetMinY(rect) - mBackingHeight),
        CGRectGetMinX(rect), -(CGRectGetMaxY(rect) - mBackingHeight),
        CGRectGetMaxX(rect), -(CGRectGetMaxY(rect) - mBackingHeight),
    };

    glVertexPointer(2, GL_FLOAT, 0, points);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);    
        
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisable(GL_TEXTURE_2D);

    glFlush();
}

@end
