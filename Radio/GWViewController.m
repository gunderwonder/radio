//
//  GWViewController.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "GWViewController.h"
#import "GWRadioStationMetadataCenter.h"
#import "GWSpotifySearcher.h"
#import "GWFlipSideViewController.h"
#import "GWTrackScollView.h"

#pragma mark - Contants
#define GWTunerViewWidth 280.0

#define GWIndicatorImageNameIdle @"indicator_idle"
#define GWIndicatorImageNameBuffrring @"indicator_buffering"
#define GWIndicatorImageNamePlaying @"indicator_playing"
#define GWIndicatorImageNameError @"indicator_error"

@interface GWViewController()

#pragma mark - Private accessors
@property (nonatomic, retain) GWRadioTuner *tuner;
@property (nonatomic, retain) GWOrderedDictionary *stations;
@property (nonatomic, assign) NSUInteger currentStationIndex;
@property (nonatomic, retain) NSTimer *levelMeterUpdateTimer;

#pragma mark - Private methods
- (void)didReceiveUpdateMetadataNotification:(NSNotification *)notification;
- (void)updateMetadata:(NSDictionary *)metadata;
@end


@implementation GWViewController

#pragma mark - Accessors
@synthesize tuner = _tuner;
@synthesize stations = _stations;
@synthesize currentStationIndex = _currentStationIndex;
@synthesize levelMeterUpdateTimer=_levelMeterUpdateTimer;
@synthesize trackScrollView;
@synthesize pageControl;
@synthesize currentShowLabel;
@synthesize nextShowLabel;
@synthesize currentTrackView;
@synthesize lastTrackView;
@synthesize nextTrackView;
@synthesize tunerScrollView;
@synthesize firstTunerView;
@synthesize secondTunerView;
@synthesize thirdTunerView;
@synthesize playPauseButton;
@synthesize flipsideButton;
@synthesize indicatorView;
@synthesize airplayButton;
@synthesize customAirplayButton;
@synthesize meterView;



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    // track list scolling 
    if (sender == [self trackScrollView]) {
        if ([sender contentOffset].x < GWTrackViewWidth) {
            [[self pageControl] setCurrentPage:0];
        } else if ([sender contentOffset].x >= GWTrackViewWidth && [sender contentOffset].x < GWTrackViewWidth * 2) {
            [[self pageControl] setCurrentPage:1];
        } else if ([sender contentOffset].x >= GWTrackViewWidth * 2) {
            [[self pageControl] setCurrentPage:2];
        }
    }
    
    // tuner scrolling: remember last scroll offset
    if (sender == [self tunerScrollView]) {
        
        CGFloat contentOffset = [[self tunerScrollView] contentOffset].x;
        if (contentOffset < GWTunerScrollBias + (GWTunerViewWidth / 2))
            [[self tunerScrollView] setContentOffset:CGPointMake(contentOffset + GWTunerViewWidth, 0)];
        else if (contentOffset > GWTunerScrollBias + (GWTunerViewWidth * 2 - (GWTunerViewWidth / 2)))
            [[self tunerScrollView] setContentOffset:CGPointMake(contentOffset - GWTunerViewWidth, 0)];
        
        if (lastTunerScrollViewContentOffset > contentOffset - GWTunerScrollBias)
            tunerScrollViewDirection = GWTunerScrollViewDirectionRight;
        else if (lastTunerScrollViewContentOffset < contentOffset - GWTunerScrollBias) 
            tunerScrollViewDirection = GWTunerScrollViewDirectionLeft;
        
        lastTunerScrollViewContentOffset = contentOffset - GWTunerScrollBias;
    }
    
}

- (void)snapToStationWithIndex:(NSUInteger)index scrolling:(BOOL)scrolling {
    
    NSUInteger currentIndex = [self currentStationIndex];
    
    CGFloat stationCount = (CGFloat)[[self stations] count];
    CGFloat labelWidth = [[self tunerScrollView] frame].size.width / stationCount;
    CGFloat startOffset = GWTunerScrollBias + GWTunerViewWidth + GWTunerViewWidth / 2.0 + (GWTunerViewWidth / stationCount) / 2.0;
    
    NSInteger scrollIndex = index;
    
    // if this snap is started by a single tap, scroll in the correct direction when we are past the last station index
    if (!scrolling) {
        NSInteger step = (NSInteger)index - (NSInteger)currentIndex;
        if (abs(step) != 1) {
            if (step < 1)
                scrollIndex = abs(step) + 1;
            else
                scrollIndex = -1;
        }
    }
    
    CGFloat snapOffset = startOffset - GWTunerViewWidth + scrollIndex * labelWidth;
    
    [[self tunerScrollView] setContentOffset:CGPointMake(snapOffset, 0) animated:YES];
    
    [self setCurrentStationIndex:index];
    [[self tuner] tuneInStationWithIndex:index];
}


- (void)snapToStationWithContentOffset:(CGFloat)contentOffset {
    
    CGFloat stationCount = (CGFloat)[[self stations] count];
    CGFloat contentOffsetBias = GWTunerScrollBias - GWTunerViewWidth - GWTunerViewWidth / 2.0;
    CGFloat normalized = contentOffset - contentOffsetBias;

    if (normalized > GWTunerViewWidth && normalized <= GWTunerViewWidth * 2)
        normalized -= GWTunerViewWidth;
    else if (normalized > GWTunerViewWidth * 2 && normalized <= GWTunerViewWidth * 3)
        normalized -= GWTunerViewWidth * 2;
    
    CGFloat labelWidth = [[self tunerScrollView] frame].size.width / stationCount;
    CGFloat lower = 0.f;
    NSInteger i = 0;
    
    for (i = 0; i < stationCount ; i++) {
        if (normalized >= lower && normalized < labelWidth * (i + 1.0f))
            break;
        
        lower += labelWidth;
    }
    GWLog(@"Snapping to station with index %d...", i);
    [self snapToStationWithIndex:i scrolling:YES];
    
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (scrollView == [self tunerScrollView]) {
        if (decelerate)
            return;
        [self snapToStationWithContentOffset:[scrollView contentOffset].x];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == [self tunerScrollView]) {
        [self snapToStationWithContentOffset:[scrollView contentOffset].x];
    }
}

- (IBAction)didSpotifySearch:(id)sender {
//     
}


- (IBAction)didTouchPlayPause:(UIButton *)sender {

    if ([[self tuner] isPlaying])
        [[self tuner] pause];
    else
        [[self tuner] play];
}

- (IBAction)didTouchFlipsideButton:(id)sender {
    GWFlipSideViewController *flipsideViewController = [[GWFlipSideViewController alloc] init];
    
    [flipsideViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    [self presentModalViewController:flipsideViewController animated:YES];
    
}

- (void)didReceiveUpdateMetadataNotification:(NSNotification *)notification {
    [self updateMetadata:[notification userInfo]];
}

- (void)layoutTrackViews {
    [[self trackScrollView] setAlpha:0.0];
    
    NSUInteger i = 0;
    for (UIView *view in [[self trackScrollView] subviews]) {
        if (![view isKindOfClass:[GWTrackView class]])
            continue;
        
        GWTrackView *trackView = (GWTrackView *)view;
        if ([trackView isHidden])
            continue;
        
        CGRect trackFrame = [trackView frame];
        trackFrame.origin.x = i * GWTrackViewWidth;
        [trackView setFrame:trackFrame];
        i++;
    }
    
    [[self pageControl] setNumberOfPages:i];
    [[self trackScrollView] setContentSize:CGSizeMake(i * GWTrackViewWidth, 
                                                      [[self trackScrollView] bounds].size.height)];
    
    CGFloat contentOffset = 0;
    NSUInteger currentPage = 0;
    if ((i == 2 || i == 3) && ![[self currentTrackView] isHidden]) {
        
        contentOffset = GWTrackViewWidth;
        currentPage = 1;
        
        if (i == 2 && [[self lastTrackView] isHidden]) {
            contentOffset = 0;
            currentPage = 0;
        }
            
    }
    [[self pageControl] setCurrentPage:currentPage];
    [[self trackScrollView] setContentOffset:CGPointMake(contentOffset, 0) animated:NO];
    
    [UIView animateWithDuration:0.8f animations:^(void) {
        [[self trackScrollView] setAlpha:1.0f];
    }];
    
}

- (void)layoutTunerView {
    
    [[self firstTunerView] configureWithStations:[[self stations] allValues]];
    [[self secondTunerView] configureWithStations:[[self stations] allValues]];
    [[self thirdTunerView] configureWithStations:[[self stations] allValues]];
    
    NSUInteger i = 0;
    for (GWStationTunerView *tunerView in [NSArray arrayWithObjects:[self firstTunerView], 
                                           [self secondTunerView], [self thirdTunerView], nil]) {
        
        CGRect frame = [tunerView frame];
        frame.origin.x = GWTunerScrollBias + (i * GWTunerViewWidth);
        [tunerView setFrame:frame];
        
        i++;
    }
    
    [[self tunerScrollView] setContentSize:CGSizeMake(GWTunerScrollBias * 2 + GWTunerViewWidth * 3, 
                                                      [[self tunerScrollView] bounds].size.height)];
    [[self tunerScrollView] setContentOffset:CGPointMake(GWTunerScrollBias + GWTunerViewWidth + GWTunerViewWidth / 2.0 + (GWTunerViewWidth / [[self stations] count]) / 2.0, 0)];
    
    lastTunerScrollViewContentOffset = [[self tunerScrollView] contentOffset].x;
}

- (void)updateLockscreenMetadataWithTrackData:(NSMutableDictionary *)trackData {
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
    
    NSString *artist = [trackData objectForKey:@"artist"];
    artist = (artist == nil) ? @"" : artist;
    [metadata setObject:artist forKey:MPMediaItemPropertyArtist];
    
    
    NSString *title = [trackData objectForKey:@"track"];
    title = (title == nil) ? @"" : title;
    [metadata setObject:title forKey:MPMediaItemPropertyTitle];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:metadata];
}


- (void)updateMetadata:(NSDictionary *)metadata {
    [[self currentShowLabel] setText:[metadata objectForKey:@"currentShowName"]];
    
    NSString *nextShowName = [metadata objectForKey:@"nextShowName"];
    if ([nextShowName length])
        nextShowName = [NSString stringWithFormat:@"NESTE: %@", nextShowName];
    
    [[self nextShowLabel] setText:nextShowName];
    
    NSDictionary *currentTrack = [metadata objectForKey:@"currentTrack"];
    NSDictionary *previousTrack = [metadata objectForKey:@"previousTrack"];
    NSDictionary *nextTrack = [metadata objectForKey:@"nextTrack"];
    
    BOOL trackScrollViewHidden = currentTrack == nil && previousTrack == nil && nextTrack == nil;
    [[self trackScrollView] setHidden:trackScrollViewHidden];
    [[self meterView] setHidden:!trackScrollViewHidden];
        
    [[self lastTrackView] configureWithTrackData:previousTrack];
    [[self currentTrackView] configureWithTrackData:currentTrack];
    [[self nextTrackView] configureWithTrackData:nextTrack];
    
    [self layoutTrackViews];
    
    [self updateLockscreenMetadataWithTrackData:[NSDictionary dictionaryWithDictionary:currentTrack]];
    GWLog(@"Updated metadata.");
}


#pragma mark - View lifecycle

- (void)trackScrollView:(GWTrackScollView *)scrollView didDetectSingleTouch:(UITouch *)touch {
    CGFloat leftOffset = [touch locationInView:scrollView].x;
    CGFloat contentLeftOffset = leftOffset - [scrollView contentOffset].x;
    
    CGFloat visibleStationsCount = 3.0f;
    CGFloat stationSelectionWidth = [scrollView frame].size.width / visibleStationsCount;
    
    NSInteger stationIndex = -1;
    if (contentLeftOffset < stationSelectionWidth)
        stationIndex = ([self currentStationIndex] - 1) % [[self stations] count];
    else if (contentLeftOffset > stationSelectionWidth)
        stationIndex = ([self currentStationIndex] + 1) % [[self stations] count];
        
    //NSLog(@"%f %f", contentLeftOffset, stationSelectionWidth * visibleStationsCount - 1);
    
    if (stationIndex != -1)
        [self snapToStationWithIndex:stationIndex scrolling:NO];
}

- (void)updateLevelMeter {
	[[self meterView] updateMeterWithLeftValue:[[self tuner] averagePowerForChannel:0] 
                                    rightValue:[[self tuner] averagePowerForChannel:([[self tuner] numberOfChannels] > 1 ? 1 : 0)]];
}

- (void)startUpdatingLevelMeter {
    [self setLevelMeterUpdateTimer:[NSTimer scheduledTimerWithTimeInterval:.15 
                                                                    target:self 
                                                                  selector:@selector(updateLevelMeter) 
                                                                  userInfo:nil 
                                                                   repeats:YES]];
}

- (void)didReceiveTunerStateChangeNotification:(NSNotification *)notification {
    GWRadioTuner *tuner = [self tuner];
    if ([tuner isPlaying]) {
        [self startUpdatingLevelMeter];
        [[self playPauseButton] setImage:[UIImage imageNamed:@"button_pause"] forState:UIControlStateNormal];
        [[self indicatorView] setImage:[UIImage imageNamed:GWIndicatorImageNamePlaying]];
    } else if ([tuner isPaused]) {
        [[self playPauseButton] setImage:[UIImage imageNamed:@"button_play"] forState:UIControlStateNormal];
        [[self indicatorView] setImage:[UIImage imageNamed:GWIndicatorImageNameIdle]];
    } else if ([tuner cannotPlay]) {
        [[self playPauseButton] setImage:[UIImage imageNamed:@"button_play"] forState:UIControlStateNormal];
        [[self indicatorView] setImage:[UIImage imageNamed:GWIndicatorImageNameError]];
    } else {
        [[self indicatorView] setImage:[UIImage imageNamed:GWIndicatorImageNameBuffrring]];
    }
}

#define GWAirplayButtonTag 0xDEADBEEF

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[UIButton class]] && [(UIView *)object tag] == GWAirplayButtonTag) {
        UIButton *button = (UIButton *)object;
        
        if ([[change valueForKey:NSKeyValueChangeNewKey] intValue] == 1) {
            [button setImage:[UIImage imageNamed:@"button_airplay"] forState:UIControlStateNormal];
            [button setBounds:CGRectMake(0, 0, 50, 50)];
            
            [[self airplayButton] bringSubviewToFront:[self customAirplayButton]];
        } else {
            [[self customAirplayButton] bringSubviewToFront:[self airplayButton]];
        }
            
    }
}

- (void)viewDidLoad {
    
#ifdef DEBUG
    GWDebug(@"Starting in debug mode...");
#endif
    
    [self setStations:[GWRadioStation loadRadioStations]];    
    [[[self lastTrackView] label] setText:@"FORRIGE LÅT"];
    [[[self lastTrackView] label] setShouldGlow:YES];
    [[[self currentTrackView] label] setText:@"SPILLES NÅ"];
    [[[self currentTrackView] label] setShouldGlow:YES];
    [[[self nextTrackView] label] setText:@"NESTE LÅT"];
    [[[self nextTrackView] label] setShouldGlow:YES];
    
    //[[self currentShowLabel] setShouldGlow:YES];
    
    [self setTuner:[[GWRadioTuner alloc] initWithStations:[self stations]]];
    [self layoutTunerView];
    
    [[self trackScrollView] setCanCancelContentTouches:NO]; 
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didReceiveUpdateMetadataNotification:) 
                                                 name:GWRadioStationMetadataDidChangeNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTunerStateChangeNotification:)
                                                 name:GWRadioTunerDidChangeStateNotification
                                               object:[self tuner]];
    
    
    [[self airplayButton] setShowsVolumeSlider:NO];
    [[self airplayButton] setBackgroundColor:[UIColor clearColor]];
    for (UIView *view in [[self airplayButton] subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            [button setTag:GWAirplayButtonTag];
            
            [button setImage:[UIImage imageNamed:@"button_airplay"] forState:UIControlStateNormal];
            [button setBounds:CGRectMake(0, 0, 50, 50)];
            
            [button addObserver:self forKeyPath:@"alpha" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
    
    [self layoutTrackViews];        
    [super viewDidLoad];
}

- (void)viewDidUnload {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setCurrentShowLabel:nil];;
    [self setNextShowLabel:nil];
    [self setTrackScrollView:nil];
    [self setNextTrackView:nil];
    [self setCurrentTrackView:nil];
    [self setLastTrackView:nil];
    [self setPageControl:nil];
    [self setTunerScrollView:nil];
    [self setFirstTunerView:nil];
    [self setSecondTunerView:nil];
    [self setThirdTunerView:nil];
    [self setPlayPauseButton:nil];
    [self setFlipsideButton:nil];
    [self setIndicatorView:nil];
    [self setAirplayButton:nil];
    [self setCustomAirplayButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
	switch (event.subtype) {
		case UIEventSubtypeRemoteControlTogglePlayPause:
			[[self tuner] pause];
			break;
		case UIEventSubtypeRemoteControlPlay:
			[[self tuner] play];
			break;
		case UIEventSubtypeRemoteControlPause:
			[[self tuner] pause];
			break;
		case UIEventSubtypeRemoteControlStop:
			[[self tuner] pause];
			break;
		default:
			break;
	}
}


@end
