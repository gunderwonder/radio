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

- (void)tuneInStation:(GWRadioStation *)station;
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
    if (theStation == nil)
        NSLog(@"Couldn't find station with index %d", index);
    
    [self tuneInStationWithName:theStation];
}

- (void)tuneInStation:(GWRadioStation *)station {
    if (station == [self currentStation])
        return;
    
    NSLog(@"Tuning to station %@...", [station name]);
    
    [self stop];
    [self setCurrentStation:station];
    [self setStreamer:[[AudioStreamer alloc] initWithURL:[[self currentStation] streamURL]]];
    [[self streamer] start];
    
    NSUInteger index = 0;
    for (NSString *name in [self radioStations]) {
        if ([name isEqualToString:[[self currentStation] name]])
            break;
        index++;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                station, @"radioStation", 
                                [NSNumber numberWithUnsignedInteger:index], @"index",
                              nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GWRadioTunerDidTuneInNotification 
                                                        object:nil 
                                                      userInfo:userInfo];
    
    
    
    [[GWRadioStationMetadataCenter sharedCenter] startGatheringMetadataForStation:[self currentStation]];
}

- (void)pause {
    [[self streamer] pause];
}

- (void)stop {
    [[self streamer] stop];
    [self setStreamer:nil];
}

- (void)start {
    [[self streamer] start];
}

- (BOOL)isPlaying {
    return [[self streamer] isPlaying];
}



@end
