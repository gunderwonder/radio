//
//  GWGlowingLabel.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 08.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GWGlowingLabel.h"

@implementation GWGlowingLabel

@synthesize isGlowing = _isGlowing;

// http://stackoverflow.com/questions/1274168/drop-shadow-on-uitextfield-text/1537079#1537079
- (void)drawTextInRect:(CGRect)rect {
    if (![self isGlowing]) {
        [super drawTextInRect:rect];
        return;
    }
    
    CGSize myShadowOffset = CGSizeMake(0, 0);
    float myColorValues[] = {102 / 255.0, 199 / 255.0, 255 / 255.0, .4};
    
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(myContext);
    
    CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef myColor = CGColorCreate(myColorSpace, myColorValues);
    CGContextSetShadowWithColor (myContext, myShadowOffset, 5, myColor);
    
    [super drawTextInRect:rect];
    
    CGColorRelease(myColor);
    CGColorSpaceRelease(myColorSpace); 
    
    CGContextRestoreGState(myContext);
}

@end
