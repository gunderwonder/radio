//
//  GWViewController.h
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "GWGlowingLabel.h"
#import "GWRadioTuner.h"
#import "GWTrackView.h"
#import "GWStationTunerView.h"
#import "GWVolumeUnitMeterView.h"

typedef enum GWTunerScrollViewDirection {
    GWTunerScrollViewDirectionNone,
    GWTunerScrollViewDirectionRight,
    GWTunerScrollViewDirectionLeft
} GWTunerScrollViewDirection;

@interface GWViewController : UIViewController {
    GWRadioTuner *_tuner;
    GWOrderedDictionary *_stations;
    
    
    NSUInteger _currentStationIndex;
    
    NSInteger lastTunerScrollViewContentOffset;
    
    GWTunerScrollViewDirection tunerScrollViewDirection;
    
    NSTimer *_levelMeterUpdateTimer;
}

@property (weak, nonatomic) IBOutlet UIScrollView *trackScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet GWGlowingLabel *currentShowLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextShowLabel;
@property (weak, nonatomic) IBOutlet GWTrackView *currentTrackView;
@property (weak, nonatomic) IBOutlet GWTrackView *lastTrackView;
@property (weak, nonatomic) IBOutlet GWTrackView *nextTrackView;
@property (weak, nonatomic) IBOutlet UIScrollView *tunerScrollView;
@property (weak, nonatomic) IBOutlet GWStationTunerView *firstTunerView;
@property (weak, nonatomic) IBOutlet GWStationTunerView *secondTunerView;
@property (weak, nonatomic) IBOutlet GWStationTunerView *thirdTunerView;
@property (weak, nonatomic) IBOutlet GWVolumeUnitMeterView *meterView;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *flipsideButton;
@property (weak, nonatomic) IBOutlet UIImageView *indicatorView;
@property (weak, nonatomic) IBOutlet MPVolumeView *airplayButton;
@property (weak, nonatomic) IBOutlet UIButton *customAirplayButton;

- (IBAction)didSpotifySearch:(id)sender;

- (IBAction)didTouchPlayPause:(UIButton *)sender;
- (IBAction)didTouchFlipsideButton:(id)sender;

@end
