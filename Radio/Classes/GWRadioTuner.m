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

- (void)tuneInStation:(GWRadioStation *)station;
@end

@implementation GWRadioTuner

@synthesize player = _player;
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
    NSLog(@"status %d", status);
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


- (void)tuneInStation:(GWRadioStation *)station {
    
    
    if (station == [self currentStation])
        return;
    
    [self setCurrentStation:station];
    
    [[self player] pause];
    [[self player] removeObserver:self forKeyPath:@"status"];
    
    [self setPlayer:[[AVPlayer alloc] initWithURL:[[self currentStation] streamURL]]];
    
    
    [[self player] addObserver:self 
                    forKeyPath:@"status"
                       options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                       context:NULL];


    
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
    
    
    if ([[[[self currentStation] metadataURL] absoluteString] length])
        [[GWRadioStationMetadataCenter sharedCenter] startGatheringMetadataForStation:[self currentStation]];
    else
        [[GWRadioStationMetadataCenter sharedCenter] stopGatheringMetadata];
}

- (void)pause {
    [[self player] pause];
}

- (void)play {
    [[self player] play];
}

- (BOOL)isPlaying {
    return [[self player] rate] == 1.0;
}



@end
