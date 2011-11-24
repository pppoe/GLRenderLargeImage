//
//  GLImageViewer.h
//  GLRenderLargeImage
//
//  Created by Haoxiang Li on 11/24/11.
//  Copyright (c) 2011 DEV. All rights reserved.
//

#import "MPGLView.h"

@interface GLImageViewer : MPGLView {
    GLuint texture;
    CGRect textureRect;
}

- (void)showImageNamed:(NSString *)imageNamed;
- (void)moveToImagePart:(CGRect)partRect;

@end
