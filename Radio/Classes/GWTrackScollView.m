//
//  GWTrackScollView.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GWTrackScollView.h"

@implementation GWTrackScollView

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {	
	if (![self isDragging]) {
        UITouch *touch = [touches anyObject];

        SEL tapSelector = @selector(trackScrollView:didDetectSingleTouch:);
        if ([[self delegate] respondsToSelector:tapSelector])
            [[self delegate] performSelector:tapSelector withObject:self withObject:touch];
        
    }
    
	[super touchesEnded:touches withEvent:event];
}

#pragma clang diagnostic pop

@end
