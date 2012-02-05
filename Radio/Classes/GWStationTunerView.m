//
//  GWStationTunerView.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 27.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GWStationTunerView.h"
#import "GWRadioStation.h"

@implementation GWStationTunerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)configureWithStations:(NSArray *)stations {
    
    CGSize scrollViewSize = [[self superview] bounds].size;
    CGFloat scrollViewWidth = scrollViewSize.width;
    CGFloat scrollViewHeight = scrollViewSize.height;
    
    NSUInteger stationCount = [stations count];
    [self setFrame:CGRectMake(0, 0, scrollViewHeight, scrollViewWidth)];
    
    CGFloat stationLabelWidth = floorf(scrollViewWidth / (CGFloat)stationCount);
    
    CGFloat labelOffset = 0;
    for (GWRadioStation *station in stations) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelOffset, 0, stationLabelWidth, scrollViewHeight)];
        [label setText:[station name]];
        [label setFont:[UIFont fontWithName:@"Helvetica" size:11]];
        [label setTextAlignment:UITextAlignmentCenter];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
