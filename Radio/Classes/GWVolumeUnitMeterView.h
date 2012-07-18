//
//  GWVolumeUnitMeterView.h
//  Radio
//
//  Created by Øystein Riiser Gundersen on 14.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>

@interface GWVolumeUnitMeterView : UIView {
    UIView *_needle;
    
    CGAffineTransform _originalTransform;
}

- (void)updateMeterWithLeftValue:(CGFloat)leftValue rightValue:(CGFloat)rightValue;
- (void)minimize;
- (void)maximize;

@end
