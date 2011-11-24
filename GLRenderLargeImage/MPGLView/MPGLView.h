//
//  MPGLView.h
//  GLRenderLargeImage
//
//  Created by Haoxiang Li on 11/24/11.
//  Copyright (c) 2011 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class EAGLContext;

@interface MPGLView : UIView {
	GLint mBackingWidth;
	GLint mBackingHeight;
	
	EAGLContext *mGLContext;
    
	GLuint mViewRenderbuffer;
    GLuint mViewFramebuffer;
	GLuint mDepthRenderbuffer;
    
	BOOL mViewHasSetup;
    
    CGRect mVisiblePartRect;
}

//< An OpenGL View should have width/height which has factor of 32
- (id)initWithGLFrame:(CGRect)frame;

//< To Render the specified Rect
- (void)renderRect:(CGRect)rect;

////////////////////////////////////////////////////////////////////
/**< Can only be invoked inside drawViewInRect in the Inheritance */
////////////////////////////////////////////////////////////////////

//< Bind Texture, the partRect is used to calculate the coordinates 
- (void)bindTexture:(GLuint)texture withPartRect:(CGRect)rect withinImageSize:(CGSize)imageSize;
- (void)bindTexture:(GLuint)texture;

////////////////////////////////////////////////////////////////////
/**< Override Point */
////////////////////////////////////////////////////////////////////

//< Setup Context, Bind and Present Buffers, Render Content
- (void)drawView;

//< Render Content, OpenGL Actions here
- (void)drawViewInRect:(CGRect)rect;

////////////////////////////////////////////////////////////////////
/**< Utilities */
////////////////////////////////////////////////////////////////////

//< Draw Image in the glSize to texture, glSize width/height is power of 2
+ (GLuint)textureFromImage:(UIImage *)image withGLSize:(CGSize)glSize;

//< return glSize, width/height is power of 2
+ (CGSize)textureSizeForImage:(UIImage *)image;

//< Centerize the Image as Texture
+ (CGRect)textureRectForImage:(UIImage *)image;


@end
