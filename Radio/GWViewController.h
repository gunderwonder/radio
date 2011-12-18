//
//  GWViewController.h
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GWRadioTuner.h"

@interface GWViewController : UIViewController {
    GWRadioTuner *_tuner;
}

@property (weak, nonatomic) IBOutletCollection(UIButton) NSArray *radioStationButtons;
@property (weak, nonatomic) IBOutlet UILabel *currentShowLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentArtistLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTrackLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverArtImageView;
@property (weak, nonatomic) IBOutlet UILabel *nextShowLabel;
@property (weak, nonatomic) IBOutlet UIButton *spotifySearchButton;


- (IBAction)didSwitchStation:(id)sender;
- (IBAction)didSpotifySearch:(id)sender;

@end
