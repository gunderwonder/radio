//
//  GWRadioTuner.h
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "GWRadioStation.h"
#import "AudioStreamer.h"

#define GWRadioTunerDidChangeStateNotification @"GWRadioTunerDidChangeStateNotification"

@interface GWRadioTuner : NSObject {

    NSDictionary *_radioStations;
    GWRadioStation *_currentStation;
    AVPlayer *_player;
    AudioStreamer *_streamer;
    
    NSUInteger _currentStationIndex;
}

#pragma mark - Accessors
@property (nonatomic, retain) NSDictionary *radioStations;
@property (nonatomic, retain) GWRadioStation *currentStation;
@property (nonatomic, readonly) NSUInteger currentStationIndex;

#pragma mark - Initializers
- (id)initWithStations:(NSDictionary *)stations;

#pragma mark - Station selection
- (void)tuneInStationWithName:(NSString *)name;
- (void)tuneInStationWithIndex:(NSUInteger)index;
- (GWRadioStation *)currentStation;

#pragma mark - Playback
- (void)pause;
- (void)play;
- (BOOL)isPlaying;
- (BOOL)isPaused;
- (BOOL)cannotPlay;

- (float)averagePowerForChannel:(NSUInteger)channelNumber;
- (NSUInteger)numberOfChannels;


@end
