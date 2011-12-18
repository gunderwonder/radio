//
//  GWRadioTuner.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GWRadioTuner.h"
#import <AVFoundation/AVFoundation.h>
#import "GWRadioStationMetadataCenter.h"

@interface GWRadioTuner()
@property (nonatomic, retain) AudioStreamer *streamer;
@end

@implementation GWRadioTuner

@synthesize streamer = _streamer;
@synthesize radioStations = _radioStations;
@synthesize currentStation = _currentStation;

- (id)initWithStations:(NSDictionary *)stations {
    self = [super init];
    if (self == nil)
        return nil;
    
    [self setRadioStations:stations];
    [self setCurrentStation:nil];
    return self;
}

- (void)tuneInStationWithName:(NSString *)name {
    if ([name isEqualToString:[[self currentStation] name]])
        return;
    
    NSLog(@"Playing station %@...", name);
    
    [self stop];
    [self setCurrentStation:[[self radioStations] objectForKey:name]];
    [self setStreamer:[[AudioStreamer alloc] initWithURL:[[self currentStation] streamURL]]];
    [[self streamer] start];
    [[GWRadioStationMetadataCenter sharedCenter] startGatheringMetadataForStation:[self currentStation]];
}

- (void)pause {
    [[self streamer] pause];
}

- (void)stop {
    [[self streamer] stop];
}

- (void)start {
    [[self streamer] start];
}

- (BOOL)isPlaying {
    return [[self streamer] isPlaying];
}



@end
