//
//  MPGLView.m
//  GLRenderLargeImage
//
//  Created by Haoxiang Li on 11/24/11.
//  Copyright (c) 2011 DEV. All rights reserved.
//

#import "MPGLView.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <QuartzCore/QuartzCore.h>

@interface MPGLView ()

- (void)setupGLES;

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;

@end

@implementation MPGLView

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupGLES];
}

- (id)initWithFrame:(CGRect)frame
{
	if((self = [super initWithFrame:frame]))
	{
        [self setupGLES];
	}
	return self;
}

- (void)dealloc
{
	
    if([EAGLContext currentContext] == mGLContext)
	{
		[EAGLContext setCurrentContext:nil];
	}
	
	[mGLContext release], mGLContext = nil;
    
    [self destroyFramebuffer];
	[super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [EAGLContext setCurrentContext:mGLContext];
    [self destroyFramebuffer];
    [self createFramebuffer];
}

#pragma mark - Public Methods
- (id)initWithGLFrame:(CGRect)frame {
    frame.size.width = round(frame.size.width/32.0f) * 32.0f;
    frame.size.height = round(frame.size.height/32.0f) * 32.0f;
    return [self initWithFrame:frame];
}

//< To Render the specified Rect
- (void)renderRect:(CGRect)rect {
    mVisiblePartRect = rect;
    [self drawView];
}

/**< Can only be invoked inside drawViewInRect in the Inheritance */

//< Bind Texture, the partRect is used to calculate the coordinates 
- (void)bindTexture:(GLuint)texture withPartRect:(CGRect)rect withinImageSize:(CGSize)imageSize {
    
    //< texture rect should be inside the image bounds
    CGRect textureRect = CGRectIntersection(rect, CGRectMake(0, 0, imageSize.width, imageSize.height));
    if (CGRectIsNull(textureRect) || (fabs(imageSize.width) < 1e-6) || (fabs(imageSize.height) < 1e-6))
    {
        return;
    }
    
    glEnable(GL_TEXTURE_2D);            
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);    
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);

    const GLfloat texCoords[] = {
        CGRectGetMinX(textureRect)/imageSize.width, CGRectGetMaxY(textureRect)/imageSize.height,
        CGRectGetMaxX(textureRect)/imageSize.width, CGRectGetMaxY(textureRect)/imageSize.height,
        CGRectGetMinX(textureRect)/imageSize.width, CGRectGetMinY(textureRect)/imageSize.height,
        CGRectGetMaxX(textureRect)/imageSize.width, CGRectGetMinY(textureRect)/imageSize.height
    };
    
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);

    glBindTexture(GL_TEXTURE_2D, texture);

    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisable(GL_TEXTURE_2D);
}

- (void)bindTexture:(GLuint)texture {
    [self bindTexture:texture 
         withPartRect:CGRectMake(0, 0, 1, 1)
      withinImageSize:CGSizeMake(1, 1)];
}

/**< Override Point */

//< Setup Context, Bind and Present Buffers, Render Content
- (void)drawView
{
	[EAGLContext setCurrentContext:mGLContext];
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, mViewFramebuffer);
    
    if (!mViewHasSetup)
    {
        CGSize size = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
        glViewport(0, 0, size.width, size.height);
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glOrthof(0, size.width, 0, size.height, -1024, 1024);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
        
        mViewHasSetup = YES;
    }
    
	[self drawViewInRect:mVisiblePartRect];
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, mViewRenderbuffer);
	[mGLContext presentRenderbuffer:GL_RENDERBUFFER_OES];
	
	GLenum err = glGetError();
	if(err)
    {
		NSLog(@"%x error", err);
    }
}

//< Render Content, OpenGL Actions here
- (void)drawViewInRect:(CGRect)rect {
    
}

/**< Utilities */

//< Draw Image in the glSize to texture, glSize width/height is power of 2
+ (GLuint)textureFromImage:(UIImage *)image withGLSize:(CGSize)glSize {
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST); 
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST); 
    
    GLuint width = glSize.width;
    GLuint height = glSize.height;
    
    void *imageData = malloc(height * width * 4);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitMapcontext = CGBitmapContextCreate(imageData, width, height, 
                                                       8, 4 * width, 
                                                       colorSpace, 
                                                       kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(bitMapcontext, CGRectMake( 0, 0, width, height));
    UIGraphicsPushContext(bitMapcontext);
    [image drawInRect:CGRectMake((width - image.size.width)/2.0f,
                                 (height - image.size.height)/2.0f,
                                 image.size.width, image.size.height)];
    UIGraphicsPopContext();
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    CGContextRelease(bitMapcontext);        
    free(imageData);        
    
    return texture;
}

+ (GLuint)textureFromFillImage:(UIImage *)image withGLSize:(CGSize)glSize {
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST); 
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST); 
    
    GLuint width = glSize.width;
    GLuint height = glSize.height;
    
    void *imageData = malloc(height * width * 4);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitMapcontext = CGBitmapContextCreate(imageData, width, height, 
                                                       8, 4 * width, 
                                                       colorSpace, 
                                                       kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(bitMapcontext, CGRectMake( 0, 0, width, height));
    UIGraphicsPushContext(bitMapcontext);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    UIGraphicsPopContext();
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    CGContextRelease(bitMapcontext);        
    free(imageData);        
    
    return texture;
}

//< return glSize, width/height is power of 2
+ (CGSize)textureSizeForImage:(UIImage *)image {
    CGSize size = image.size;
    return CGSizeMake(pow(2, ceil(log2(size.width))), pow(2, ceil(log2(size.height))));
}

//< Centerize the Image as Texture
+ (CGRect)textureRectForImage:(UIImage *)image {
    CGSize size = image.size;
    CGSize glSize = [self textureSizeForImage:image];
    return CGRectMake((glSize.width - size.width)/2.0f,
                      (glSize.height - size.height)/2.0f,
                      size.width, size.height);
}

#pragma mark - Private Methods

- (void)setupGLES
{
    mVisiblePartRect = self.bounds;

	CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
	eaglLayer.opaque = NO;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                    nil];
	
	// Create our EAGLContext, and if successful make it current and create our framebuffer.
	mGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	if(!mGLContext || ![EAGLContext setCurrentContext:mGLContext] || ![self createFramebuffer])
	{
		[self release],	self = nil;
        return;
	}
	
    mViewHasSetup = NO;
}

- (BOOL)createFramebuffer
{
	glGenFramebuffersOES(1, &mViewFramebuffer);
	glGenRenderbuffersOES(1, &mViewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, mViewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, mViewRenderbuffer);
    
	[mGLContext renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, 
                                 GL_COLOR_ATTACHMENT0_OES, 
                                 GL_RENDERBUFFER_OES, mViewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &mBackingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &mBackingHeight);
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}

- (void)destroyFramebuffer
{
	glDeleteFramebuffersOES(1, &mViewFramebuffer), mViewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &mViewRenderbuffer), mViewRenderbuffer = 0;
	
	if(mDepthRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &mDepthRenderbuffer), mDepthRenderbuffer = 0;
	}
}

@end
