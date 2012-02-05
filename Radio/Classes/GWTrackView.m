//
//  GWTrackView.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GWTrackView.h"

@implementation GWTrackView
@synthesize coverArtView;
@synthesize trackLabel;
@synthesize artistLabel;
@synthesize label;

- (void)loadSubview {
    NSArray *b = [[NSBundle mainBundle] loadNibNamed:@"GWTrackView" owner:self options:nil];
    for (id v in b) {
        if ([v isKindOfClass:[UIView class]])
            [self addSubview:v];
    }
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


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
