//
//  GWTrackView.h
//  Radio
//
//  Created by Øystein Riiser Gundersen on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GWGlowingLabel.h"

@interface GWTrackView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *coverArtView;
@property (weak, nonatomic) IBOutlet UILabel *trackLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet GWGlowingLabel *label;
@property (weak, nonatomic) IBOutlet UIButton *spotifyButton;


- (void)configureWithTrackData:(NSDictionary *)trackData;
- (IBAction)didTouchSpotifyButton:(UIButton *)sender;

@end
