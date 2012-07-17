//
//  GWRadioTuner.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GWRadioTuner.h"
#import "GWRadioStationMetadataCenter.h"

@interface GWRadioTuner()
@property (nonatomic, retain) AVPlayer *player;
@property (nonatomic, retain) GWAudioStreamer *streamer;

- (void)tuneInStation:(GWRadioStation *)station;
@end

@implementation GWRadioTuner

@synthesize player = _player;
@synthesize streamer = _streamer;
@synthesize radioStations = _radioStations;
@synthesize currentStation = _currentStation;
@synthesize currentStationIndex = _currentStationIndex;

- (id)initWithStations:(NSDictionary *)stations {
    self = [super init];
    if (self == nil)
        return nil;
    
    [self setRadioStations:stations];
    [self setCurrentStation:nil];
    return self;
}

- (void)tuneInStationWithName:(NSString *)name {
    [self tuneInStation:[[self radioStations] objectForKey:name]];
}

- (void)tuneInStationWithIndex:(NSUInteger)index {
    
    NSUInteger i = 0;
    NSString *theStation = nil;
    for (NSString *stationName in [self radioStations]) {
        if (index == i)
            theStation = stationName;
        
        i++;
    }
    if (theStation == nil) {
        NSLog(@"Couldn't find station with index %d", index);
        return;
    }
        
    
    [self tuneInStationWithName:theStation];
}

- (void)observeValueForKeyPath:(NSString*) path 
                      ofObject:(id)object 
                        change:(NSDictionary*)change 
                       context:(void*)context {
    
    AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
    switch (status) {
        case AVPlayerStatusUnknown:
            break;
            
        case AVPlayerStatusReadyToPlay:
            [[self player] play];
            break;
            
        case AVPlayerStatusFailed:
            break;
    }
}

- (void)didReceiveStreamerStateChangeNotification:(NSNotification*)notification {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GWRadioTunerDidChangeStateNotification object:self];
    
    if ([[self streamer] isPlaying])
        [[self streamer] setMeteringEnabled:YES];
}

- (void)start {
//    [self setPlayer:[[AVPlayer alloc] initWithURL:[[self currentStation] streamURL]]];
//    
//    
//    [[self player] addObserver:self 
//                    forKeyPath:@"status"
//                       options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
//                       context:NULL];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(start) object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ASStatusChangedNotification object:[self streamer]];
    
    [self setStreamer:[GWAudioStreamer streamWithURL:[[self currentStation] streamURL]]];
    [[self streamer] start];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveStreamerStateChangeNotification:)
                                                 name:ASStatusChangedNotification
                                               object:[self streamer]];
}

- (float)averagePowerForChannel:(NSUInteger)channelNumber {
    if (![[self streamer] isMeteringEnabled])
        return 0.0;
    
    return [[self streamer] averagePowerForChannel:channelNumber];
}

- (NSUInteger)numberOfChannels {
    return [[self streamer] numberOfChannels];
}

- (void)tuneInStation:(GWRadioStation *)station {
    
    if (station == [self currentStation])
        return;
    
    [self setCurrentStation:station];
    
    [[self streamer] pause];
    [[self streamer] stop];
    [self setStreamer:nil];
    
    [self performSelector:@selector(start) withObject:nil afterDelay:.5];
    
    NSUInteger index = 0;
    for (NSString *name in [self radioStations]) {
        if ([name isEqualToString:[[self currentStation] name]])
            break;
        index++;
    }
    
    _currentStationIndex = index;
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              station, @"radioStation", 
                              [NSNumber numberWithUnsignedInteger:index], @"index",
                              nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GWRadioTunerDidTuneInNotification 
                                                        object:nil 
                                                      userInfo:userInfo];

    
    if ([[[[self currentStation] metadataURL] absoluteString] length])
        [[GWRadioStationMetadataCenter sharedCenter] startGatheringMetadataForStation:[self currentStation]];
    else
        [[GWRadioStationMetadataCenter sharedCenter] stopGatheringMetadata];
}

- (void)pause {
//    [[self player] pause];
    [[self streamer] pause];
}

- (void)play {
//    [[self player] play];
    [[self streamer] play];
}

- (BOOL)isPlaying {
    return [[self streamer] isPlaying];
//    return [[self player] rate] == 1.0;
}

- (BOOL)isPaused {
    return [[self streamer] isPaused];
}

- (BOOL)cannotPlay {
    return [[self streamer] errorCode] != AS_NO_ERROR;
}



@end
