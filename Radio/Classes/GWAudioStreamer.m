//
//  GWAudioStreamer.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GWAudioStreamer.h"

#define kDefaultNumAQBufs 16
#define kDefaultAQDefaultBufSize 2048

@implementation GWAudioStreamer

+ (GWAudioStreamer*) streamWithURL:(NSURL*)url {
    assert(url != nil);
    GWAudioStreamer *stream = [[GWAudioStreamer alloc] init];
    stream->url = url;
    stream->bufferCnt  = kDefaultNumAQBufs;
    stream->bufferSize = kDefaultAQDefaultBufSize;
    stream->timeoutInterval = 10;
    return stream;
}


- (NSUInteger)numberOfChannels {
    return self->asbd.mChannelsPerFrame;
}

- (BOOL)isMeteringEnabled {
	UInt32 enabled;
	UInt32 propertySize = sizeof(UInt32);
	OSStatus status = AudioQueueGetProperty(self->audioQueue, kAudioQueueProperty_EnableLevelMetering, &enabled, &propertySize);
	if(!status) {
		return (enabled == 1);
	}
	return NO;
}


//
// setMeteringEnabled
//

- (void)setMeteringEnabled:(BOOL)enable {
	if(enable == [self isMeteringEnabled])
		return;
	UInt32 enabled = (enable ? 1 : 0);
	OSStatus status = AudioQueueSetProperty(self->audioQueue, kAudioQueueProperty_EnableLevelMetering, &enabled, sizeof(UInt32));
	// do something if failed?
	if(status)
		return;
}


// level metering
- (float)peakPowerForChannel:(NSUInteger)channelNumber {
	if(![self isMeteringEnabled] || channelNumber >= [self numberOfChannels])
		return 0;
	float peakPower = 0;
	UInt32 propertySize = [self numberOfChannels] * sizeof(AudioQueueLevelMeterState);
	AudioQueueLevelMeterState *audioLevels = calloc(sizeof(AudioQueueLevelMeterState), [self numberOfChannels]);
	OSStatus status = AudioQueueGetProperty(self->audioQueue, kAudioQueueProperty_CurrentLevelMeter, audioLevels, &propertySize);
	if(!status) {
		peakPower = audioLevels[channelNumber].mPeakPower;
	}
	free(audioLevels);
	return peakPower;
}

- (float)averagePowerForChannel:(NSUInteger)channelNumber {
	if(![self isMeteringEnabled] || channelNumber >= [self numberOfChannels])
		return 0;
	float peakPower = 0;
	UInt32 propertySize = [self numberOfChannels] * sizeof(AudioQueueLevelMeterState);
	AudioQueueLevelMeterState *audioLevels = calloc(sizeof(AudioQueueLevelMeterState), [self numberOfChannels]);
	OSStatus status = AudioQueueGetProperty(self->audioQueue, kAudioQueueProperty_CurrentLevelMeter, audioLevels, &propertySize);
	if(!status) {
		peakPower = audioLevels[channelNumber].mAveragePower;
	}
	free(audioLevels);
	return peakPower;
}

@end
