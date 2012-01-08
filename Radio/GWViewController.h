//
//  GWViewController.h
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GWRadioTuner.h"
#import "GWTrackView.h"
#import "GWStationTunerView.h"

typedef enum GWTunerScrollViewDirection {
    GWTunerScrollViewDirectionNone,
    GWTunerScrollViewDirectionRight,
    GWTunerScrollViewDirectionLeft
} GWTunerScrollViewDirection;

@interface GWViewController : UIViewController {
    GWRadioTuner *_tuner;
    NSInteger lastTunerScrollViewContentOffset;
    GWTunerScrollViewDirection tunerScrollViewDirection;
}

@property (weak, nonatomic) IBOutletCollection(UIButton) NSArray *radioStationButtons;
@property (weak, nonatomic) IBOutlet UIScrollView *trackScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *currentShowLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextShowLabel;
@property (weak, nonatomic) IBOutlet GWTrackView *currentTrackView;
@property (weak, nonatomic) IBOutlet GWTrackView *lastTrackView;
@property (weak, nonatomic) IBOutlet GWTrackView *nextTrackView;
@property (weak, nonatomic) IBOutlet UIScrollView *tunerScrollView;
@property (weak, nonatomic) IBOutlet GWStationTunerView *firstTunerView;
@property (weak, nonatomic) IBOutlet GWStationTunerView *secondTunerView;
@property (weak, nonatomic) IBOutlet GWStationTunerView *thirdTunerView;

- (IBAction)didSwitchStation:(id)sender;
- (IBAction)didSpotifySearch:(id)sender;


@end
