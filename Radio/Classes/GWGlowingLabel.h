//
//  GWGlowingLabel.h
//  Radio
//
//  Created by Øystein Riiser Gundersen on 08.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GWGlowingLabel : UILabel {
    BOOL _isGlowing;
}

@property(setter = setShouldGlow:, assign) BOOL isGlowing;

@end
