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
    CGSize textureSize = [MPGLView textureSizeForImage:image];
    texture = [MPGLView textureFromFillImage:image
                              withGLSize:textureSize];
    textureRect = CGRectMake(0, 0, textureSize.width, textureSize.height);
    [self renderRect:self.bounds];
}

//< Render Content, OpenGL Actions here
- (void)drawViewInRect:(CGRect)rect {

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
        CGRectGetMinX(rect), -(CGRectGetMinY(rect) - mBackingHeight),
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

- (void)moveToImagePart:(CGRect)partRect {    
    
    partRect = CGRectIntersection(partRect, textureRect);
    
    if (CGRectIsNull(partRect))
    {
        return;
    }
    
}

@end
