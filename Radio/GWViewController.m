//
//  GWViewController.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GWViewController.h"
#import "GWRadioStationMetadataCenter.h"
#import "UIImageView+AFNetworking.h"
#import "GWSpotifySearcher.h"

#define GWTrackViewWidth 280.0
#define GWTunerViewWidth 280.0
#define GWTunerScrollBias 1000

@interface GWViewController()
@property (nonatomic, retain) GWRadioTuner *tuner;
- (void)didReceiveUpdateMetadataNotification:(NSNotification *)notification;
- (void)updateMetadata:(NSDictionary *)metadata;
- (GWTunerScrollViewDirection)scrollViewDirection;

@end



@implementation GWViewController

@synthesize tuner = _tuner;
@synthesize radioStationButtons;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)didSwitchStation:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSString *stationName = [[button titleLabel] text];
    [[self tuner] tuneInStationWithName:stationName];
    for (UIButton *radioStationButton in [self radioStationButtons])
        [radioStationButton setHighlighted:NO];
    [button setHighlighted:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (sender == [self trackScrollView]) {
        if ([sender contentOffset].x < GWTrackViewWidth) {
            [[self pageControl] setCurrentPage:0];
        } else if ([sender contentOffset].x >= GWTrackViewWidth && [sender contentOffset].x < GWTrackViewWidth * 2) {
            [[self pageControl] setCurrentPage:1];
        } else if ([sender contentOffset].x >= GWTrackViewWidth * 2) {
            [[self pageControl] setCurrentPage:2];
        }
    }
    
    if (sender == [self tunerScrollView]) {
        CGFloat contentOffset = [[self tunerScrollView] contentOffset].x;
        if (contentOffset < GWTunerScrollBias + (GWTunerViewWidth / 2)) {
            [[self tunerScrollView] setContentOffset:CGPointMake(contentOffset + GWTunerViewWidth, 0)];
        } else if (contentOffset > GWTunerScrollBias + (GWTunerViewWidth * 2 - (GWTunerViewWidth / 2))) {
            [[self tunerScrollView] setContentOffset:CGPointMake(contentOffset - GWTunerViewWidth, 0)];
        }
        
        if (lastTunerScrollViewContentOffset > contentOffset)
            tunerScrollViewDirection = GWTunerScrollViewDirectionRight;
        else if (lastTunerScrollViewContentOffset < contentOffset) 
            tunerScrollViewDirection = GWTunerScrollViewDirectionLeft;
        
        lastTunerScrollViewContentOffset = contentOffset;
    }
    
    
    
}

- (void)normalizeContentOffset {
    CGFloat contentOffsetBias = GWTunerScrollBias - GWTunerViewWidth - GWTunerViewWidth / 2.0;
    
    CGFloat startOffset = GWTunerScrollBias + GWTunerViewWidth + GWTunerViewWidth / 2.0 + (GWTunerViewWidth / 4.0f) / 2.0;
    CGFloat contentOffset = [[self tunerScrollView] contentOffset].x;
    CGFloat normalized = contentOffset - contentOffsetBias;
    CGFloat visibleOffset = normalized;

    if (normalized > GWTunerViewWidth && normalized <= GWTunerViewWidth * 2)
        normalized -= GWTunerViewWidth;
    else if (normalized > GWTunerViewWidth * 2 && normalized <= GWTunerViewWidth * 3)
        normalized -= GWTunerViewWidth * 2;
    
    CGFloat labelWidth = [[self tunerScrollView] frame].size.width / 4.0f;
    CGFloat lower = 0.f;
    NSInteger i = 0;
    
//    if (normalized >= lower) {
        for (i = 0; i < 4; i++) {
            if (normalized >= lower && normalized < labelWidth * (i + 1.0f))
                break;
            
            lower += labelWidth;
        }
//    }
//    if (i == 4)
//        i = 3;
    
    NSLog(@"%f %f %f", normalized, visibleOffset, startOffset - contentOffsetBias);
    if (visibleOffset > GWTunerViewWidth && visibleOffset <= GWTunerViewWidth * 2)
        NSLog(@"Middle");
    else if (visibleOffset > GWTunerViewWidth * 2 && visibleOffset <= GWTunerViewWidth * 3)
        NSLog(@"Right");
    else
        NSLog(@"Left");
    
    CGFloat snapOffset = 0;
    if (tunerScrollViewDirection == GWTunerScrollViewDirectionRight)
        snapOffset = startOffset - GWTunerViewWidth + i * labelWidth;
    else
        snapOffset = startOffset - GWTunerViewWidth - i * labelWidth;
    [[self tunerScrollView] setContentOffset:CGPointMake(snapOffset, 0) animated:YES];
//    NSLog(@"normalized: %f, snapOffset: %f, i: %d, delta: %f", normalized, snapOffset, i, (i + 1.0f) * (labelWidth / 2.0f));
    
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (scrollView == [self tunerScrollView]) {
        if (decelerate)
            return;
        [self normalizeContentOffset];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == [self tunerScrollView]) {
        [self normalizeContentOffset];
    }
}

- (IBAction)didSpotifySearch:(id)sender {
//    [GWSpotifySearcher searchForTrack:[[self currentTrackLabel] text] byArtist:[[self currentArtistLabel] text]]; 
}

- (void)didReceiveUpdateMetadataNotification:(NSNotification *)notification {
    [self updateMetadata:[notification userInfo]];
}

- (void)layoutTrackViews {
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
    [[self trackScrollView] setContentOffset:CGPointMake(contentOffset, 0) animated:YES];
    
}

- (void)configureTrackView:(GWTrackView *)trackView withDictionary:(NSDictionary *)trackData {
    
    if (trackData == nil) {
        [trackView setHidden:YES];
        return;
    }
        
    
    NSURL *coverArtURL = [trackData objectForKey:@"coverArtImageURL"];
    UIImageView *coverArtView = [trackView coverArtView];
    if (coverArtURL) {
        [coverArtView setImageWithURL:coverArtURL];
        [coverArtView setHidden:NO];
    } else {
        [coverArtView setHidden:YES];
    }
    
    NSString *artist = [trackData objectForKey:@"artist"];
    artist = (artist == nil) ? @"" : artist;
    [[trackView artistLabel] setText:artist];
    
    NSString *title = [trackData objectForKey:@"track"];
    title = (title == nil) ? @"" : title;
    
    [[trackView trackLabel] setText:title];
    [trackView setHidden:NO];
//    [[self spotifySearchButton] setHidden:!([artist length] || [title length])];
}


- (void)updateMetadata:(NSDictionary *)metadata {
    [[self currentShowLabel] setText:[metadata objectForKey:@"currentShowName"]];
    [[self nextShowLabel] setText:[metadata objectForKey:@"nextShowName"]];
    
    
    NSDictionary *currentTrack = [metadata objectForKey:@"currentTrack"];
    NSDictionary *previousTrack = [metadata objectForKey:@"previousTrack"];
    NSDictionary *nextTrack = [metadata objectForKey:@"nextTrack"];
    
    [self configureTrackView:[self lastTrackView] withDictionary:previousTrack];
    [self configureTrackView:[self currentTrackView] withDictionary:currentTrack];
    [self configureTrackView:[self nextTrackView] withDictionary:nextTrack];
    
    [self layoutTrackViews];
    
    NSLog(@"Updated metadata.");
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
#ifdef DEBUG
    NSLog(@"Starting in debug mode...");
#endif
    
    NSString *stationFile = [[NSBundle mainBundle] pathForResource:@"RadioStations" ofType:@"plist"];
    NSDictionary *stationData = [[NSDictionary alloc] initWithContentsOfFile:stationFile];
    
    GWRadioStation *station = nil;
    NSMutableDictionary *stations = [[NSMutableDictionary alloc] init];
    for (NSString *stationName in stationData) {
        NSDictionary *data = [stationData objectForKey:stationName];
        
        station = [[GWRadioStation alloc] init];
        [station setName:stationName];
        [station setStreamURL:[NSURL URLWithString:[data objectForKey:@"streamURL"]]];
        [station setMetadataURL:[NSURL URLWithString:[data objectForKey:@"metadataURL"]]];
        
        [stations setObject:station forKey:stationName];
    }
    
    [[[self lastTrackView] label] setText:@"Forrige låt"];
    [[[self currentTrackView] label] setText:@"Spilles nå"];
    [[[self nextTrackView] label] setText:@"Neste låt"];
    
    [self setTuner:[[GWRadioTuner alloc] initWithStations:stations]];
    
    [[self firstTunerView] configureWithStations:[stations allValues]];
    [[self secondTunerView] configureWithStations:[stations allValues]];
    [[self thirdTunerView] configureWithStations:[stations allValues]];
    
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
    [[self tunerScrollView] setContentOffset:CGPointMake(GWTunerScrollBias + GWTunerViewWidth + GWTunerViewWidth / 2.0 + (GWTunerViewWidth / [stations count]) / 2.0, 0)];

    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didReceiveUpdateMetadataNotification:) 
                                                 name:GWRadioStationMetadataDidChangeNotification 
                                               object:nil];
    
    
    
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
			[[self tuner] start];
			break;
		case UIEventSubtypeRemoteControlPause:
			[[self tuner] pause];
			break;
		case UIEventSubtypeRemoteControlStop:
			[[self tuner] stop];
			break;
		default:
			break;
	}
}

@end
