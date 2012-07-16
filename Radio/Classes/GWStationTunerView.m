//
//  GWStationTunerView.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 27.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GWStationTunerView.h"
#import "GWRadioStation.h"
#import "GWRadioTuner.h"
#import "GWGlowingLabel.h"


#define GWStationLabelInactiveTextColor UIColorHex(0x828c96)
#define GWStationLabelActiveTextColor   [UIColor whiteColor]
#define GWStationLabelShadowColor       UIColorHex(0x66c7ff)

@interface GWStationTunerView()

#pragma mark - Private methods
- (void)didReceiveTunerNotification:(NSNotification *)notification;
- (void)configureStationLabel:(UILabel *)label;

@end

@implementation GWStationTunerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dots"]];
        
        
        [self addSubview:backgroundImage];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dots"]];
        
        
        [self addSubview:backgroundImage];
        [backgroundImage setFrame:CGRectWithY([backgroundImage frame], [self center].y - 6.0)];
    }
    return self;
}

- (void)didReceiveTunerNotification:(NSNotification *)notification {
    NSUInteger index = [[[notification userInfo] objectForKey:@"index"] unsignedIntegerValue];
    
    for (NSUInteger i = 0; i < [[self subviews] count]; i++) {
        UIView *view = [[self subviews] objectAtIndex:i];
        if (![view isKindOfClass:[GWGlowingLabel class]]) {
            index++;
            continue;
        }
            
        
        GWGlowingLabel *label = (GWGlowingLabel *)view;
        [label setTextColor:GWStationLabelInactiveTextColor];
        [label setShadowColor:[UIColor clearColor]];
        [label setShouldGlow:NO];
        if (i == index) {
            [label setTextColor:GWStationLabelActiveTextColor];
            [label setShouldGlow:YES];
        }
    }
}

- (void)configureStationLabel:(UILabel *)label {
    [label setTextColor:GWStationLabelInactiveTextColor];
    [label setFont:[UIFont fontWithName:@"Futura-Medium" size:14]];

    [label setTextAlignment:UITextAlignmentCenter];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setNumberOfLines:2];
    label.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    [label setContentMode:UIViewContentModeTop];
    
}

- (void)configureWithStations:(NSArray *)stations {
    [self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin)];
    [self setAutoresizesSubviews:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didReceiveTunerNotification:) 
                                                 name:GWRadioTunerDidTuneInNotification 
                                               object:nil];
    
    CGSize scrollViewSize = [[self superview] bounds].size;
    CGFloat scrollViewWidth = scrollViewSize.width;
    CGFloat scrollViewHeight = scrollViewSize.height;
    
    NSUInteger stationCount = [stations count];
    [self setFrame:CGRectMake(0, 0, scrollViewHeight, scrollViewWidth)];
    
    CGFloat stationLabelWidth = floorf(scrollViewWidth / (CGFloat)stationCount);
    
    CGFloat labelOffset = 0;
    for (GWRadioStation *station in stations) {
        GWGlowingLabel *label = [[GWGlowingLabel alloc] initWithFrame:CGRectMake(labelOffset, 0, stationLabelWidth, scrollViewHeight)];
        
        [self configureStationLabel:label];
        
        [label setText:[[station name] uppercaseString]];
        [self addSubview:label];
        
        labelOffset += stationLabelWidth;
    }
    
    
    
}

- (CGFloat)snapOffsetForScrollOffset:(CGFloat)scrollOffset {
    NSUInteger stationCount = 4;
    CGFloat width = [self frame].size.width;
    
    CGFloat labelWidth = floorf(width / (CGFloat)stationCount);
    
    CGFloat lower = 0.0;
    
    for (NSUInteger i = 0; i < stationCount; i++) {
        if (scrollOffset <= lower && scrollOffset > labelWidth * i)
            return i * labelWidth / 2.0;
        
    }
    return stationCount;
    
}

- (void)finalize {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
