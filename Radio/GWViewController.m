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

@interface GWViewController()
@property (nonatomic, retain) GWRadioTuner *tuner;
- (void)didReceiveUpdateMetadataNotification:(NSNotification *)notification;
- (void)updateMetadata:(NSDictionary *)metadata;

@end

@implementation GWViewController

@synthesize tuner = _tuner;
@synthesize radioStationButtons;
@synthesize currentShowLabel;
@synthesize currentArtistLabel;
@synthesize currentTrackLabel;
@synthesize coverArtImageView;
@synthesize nextShowLabel;
@synthesize spotifySearchButton;

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

- (IBAction)didSpotifySearch:(id)sender {
    [GWSpotifySearcher searchForTrack:[[self currentTrackLabel] text] byArtist:[[self currentArtistLabel] text]]; 
}

- (void)didReceiveUpdateMetadataNotification:(NSNotification *)notification {
    [self updateMetadata:[notification userInfo]];
}

- (void)updateMetadata:(NSDictionary *)metadata {
    [[self currentShowLabel] setText:[metadata objectForKey:@"currentShowName"]];
    [[self nextShowLabel] setText:[metadata objectForKey:@"nextShowName"]];
    
    NSURL *coverArtURL = [metadata objectForKey:@"coverArtImageURL"];
    NSLog(@"%@", coverArtURL);
    if (coverArtURL) {
        [[self coverArtImageView] setImageWithURL:coverArtURL];
        [[self coverArtImageView] setHidden:NO];
    } else {
        [[self coverArtImageView] setHidden:YES];
    }
    
    NSString *artist = [metadata objectForKey:@"currentArtist"];
    artist = (artist == nil) ? @"" : artist;
    [[self currentArtistLabel] setText:artist];
    
    NSString *title = [metadata objectForKey:@"currentTrackTitle"];
    title = (title == nil) ? @"" : title;
    [[self currentTrackLabel] setText:title];
    
    [[self spotifySearchButton] setHidden:!([artist length] || [title length])];
    
    NSLog(@"Updated metadata.");
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
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
    
    
    [self setTuner:[[GWRadioTuner alloc] initWithStations:stations]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didReceiveUpdateMetadataNotification:) 
                                                 name:GWRadioStationMetadataDidChangeNotification 
                                               object:nil];
        
    [super viewDidLoad];
}

- (void)viewDidUnload {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[self coverArtImageView] cancelImageRequestOperation];
    
    [self setCurrentShowLabel:nil];
    [self setCurrentArtistLabel:nil];
    [self setCurrentTrackLabel:nil];
    [self setCoverArtImageView:nil];
    [self setNextShowLabel:nil];
    [self setSpotifySearchButton:nil];
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
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    NSLog(@"HER");
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
