//
//  GWTrackView.h
//  Radio
//
//  Created by Øystein Riiser Gundersen on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GWTrackView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *coverArtView;
@property (weak, nonatomic) IBOutlet UILabel *trackLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
