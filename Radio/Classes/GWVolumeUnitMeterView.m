//
//  GWVolumeUnitMeterView.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 14.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GWVolumeUnitMeterView.h"

@interface GWVolumeUnitMeterView()

@property (nonatomic,retain) UIView *needle;


@end

@implementation GWVolumeUnitMeterView

@synthesize needle=_needle;

- (void)loadSubview {
    UIImage *backgroundImage = [UIImage imageNamed:@"meter"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    
    [self addSubview:backgroundView];
    [self setBackgroundColor:[UIColor clearColor]];
    [backgroundView setCenter:[self center]];
    CGFloat y = CGRectGetHeight([self frame]) - CGRectGetHeight([backgroundView frame]) - 20.0;
    [backgroundView setFrame:CGRectWithY([backgroundView frame], y)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubview];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self loadSubview];
    }
    return self;
}

@end
