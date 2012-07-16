//
//  GWVolumeUnitMeterView.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 14.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GWVolumeUnitMeterView.h"

#import <QuartzCore/CALayer.h>

#define GWLevelMeterRange                   1.0
#define GWVUMaximumDegrees                  45.0
#define GWVUMinimumDegrees                  -45.0
#define GWVURange                           (GWVUMaximumDegrees - GWVUMinimumDegrees)
#define GWLevelMeterValueToDegrees(value)   (value * GWVURange + GWVUMinimumDegrees)

@interface GWVolumeUnitMeterView()

@property (nonatomic,retain) UIView *needle;

- (void)loadSubviews;


@end

@implementation GWVolumeUnitMeterView

@synthesize needle=_needle;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (void)loadSubviews {
    UIImage *backgroundImage = [UIImage imageNamed:@"meter"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    
    [self addSubview:backgroundView];
    [self setBackgroundColor:[UIColor clearColor]];
    [backgroundView setCenter:[self center]];
    CGFloat y = CGRectGetHeight([self frame]) - CGRectGetHeight([backgroundView frame]);
    [backgroundView setFrame:CGRectWithY([backgroundView frame], y - 25.0)];
    
    [self setClipsToBounds:YES];
    
    UIView *needleView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth([self frame]) / 2.0, 0, 3.0, 140.0)];
    
    [needleView setBackgroundColor:UIColorHex(0xbcbec0)];
    
    [[needleView layer] setMasksToBounds:YES];
    [[needleView layer] setBorderColor:[UIColor whiteColor].CGColor];
    [[needleView layer] setBorderWidth:1];
    
    [self setNeedle:needleView];
    [self addSubview:needleView];
    
    [needleView setFrame:CGRectWithY([needleView frame], 80.0)];
    [[needleView layer] setAnchorPoint:CGPointMake(0.5, 1)];
    
    [self updateMeterWithLeftValue:0 rightValue:0];
    
}


- (void)updateMeterWithLeftValue:(CGFloat)leftValue rightValue:(CGFloat)rightValue {
    
    CGFloat average = (leftValue + rightValue) / 2.0;
    CGFloat degrees = GWLevelMeterValueToDegrees(average);
    
    [UIView animateWithDuration:.1 animations:^() {
        CGAffineTransform rotationTransform = CGAffineTransformIdentity;
        rotationTransform = CGAffineTransformRotate(rotationTransform, GWDegreesToRadians(degrees));
        [[self needle] setTransform:rotationTransform];
    }];
}

@end
