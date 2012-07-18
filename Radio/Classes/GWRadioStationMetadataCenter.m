//
//  GWRadioStationMetadataCenter.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GWRadioStationMetadataCenter.h"
#import "AFNetworking.h"

#define GWDebugRadioMetadata

#ifdef GWDebugRadioMetadata
    #define GWDebugMetadata GWLog
#else
    #define GWDebugMetadata(...)
#endif

static GWRadioStationMetadataCenter *sharedMetadataCenter;

@interface GWRadioStationMetadataCenter() 
@property (nonatomic, retain) NSTimer *pollTimer;
@property (nonatomic, retain) GWRadioStation *currentStation;
@property (nonatomic, copy) NSDictionary *currentMetadata;
@property (nonatomic, copy) NSDateFormatter *dateFormatter;
- (void)gatherMetadata;
- (void)parseMetadata:(NSDictionary *)metadata;
@end

@implementation GWRadioStationMetadataCenter

@synthesize metadataURL = _metadataURL;
@synthesize pollTimer = _pollTimer;
@synthesize currentStation = _currentStation;
@synthesize currentMetadata = _currentMetadata;
@synthesize dateFormatter = _dateFormatter;

#define GWNRKTimeZoneAbbreviation   @"Europe/Oslo"
#define GWNRKDateFormatString       @"yyyy-MM-dd'T'HH:mm:ss"

+ (GWRadioStationMetadataCenter *)sharedCenter {
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        sharedMetadataCenter = [[GWRadioStationMetadataCenter alloc] init];
    }
    return sharedMetadataCenter;
}

- (id)init {
    if (self = [super init]) {
        [self setDateFormatter:[[NSDateFormatter alloc] init]];
        [[self dateFormatter] setTimeZone:[NSTimeZone timeZoneWithName:GWNRKTimeZoneAbbreviation]];
        [[self dateFormatter] setDateFormat:GWNRKDateFormatString];
    }
    return self;
}

- (void)startGatheringMetadataForStation:(GWRadioStation *)station {
    [self setCurrentStation:station];
    [self setMetadataURL:[station metadataURL]];
    [[self pollTimer] invalidate];
    [self setPollTimer:[NSTimer scheduledTimerWithTimeInterval:20 
                                                        target:self 
                                                      selector:@selector(gatherMetadata) 
                                                      userInfo:nil 
                                                       repeats:YES]];
    [[self pollTimer] fire];
}
     
- (void)gatherMetadata {
    GWLog(@"Gathering metadata from '%@'...", [[self metadataURL] absoluteString]);
    NSURL *url = [self metadataURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
#ifdef TEST
    
    NSString *testDataFileName = nil;
    if ([[[self currentStation] name] isEqualToString:@"NRK P1"])
        testDataFileName = @"p3_test_1";
    else if ([[[self currentStation] name] isEqualToString:@"NRK P2"])
        testDataFileName = @"p3_test_2";
    else if ([[[self currentStation] name] isEqualToString:@"NRK P3"])
        testDataFileName = @"p3_test_3";
    else if ([[[self currentStation] name] isEqualToString:@"NRK Alltid Nyheter"])
        testDataFileName = @"p3_test_4";
    
    NSLog(@"Gathering local test data from '%@.json'...", testDataFileName);
    NSString *testDataFilePath = [[NSBundle mainBundle] pathForResource:testDataFileName ofType:@"json"];  
    NSData *testData = [NSData dataWithContentsOfFile:testDataFilePath];

    [self parseMetadata:[NSJSONSerialization JSONObjectWithData:testData options:0 error:NULL]];
    return;
#endif
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self parseMetadata:JSON];
    } failure:nil];
    
    [operation start];
}

- (void)stopGatheringMetadata {
    [[self pollTimer] invalidate];
}

- (NSDate *)dateFromString:(NSString *)string {
    if (string == nil)
        return nil;
    GWLog(@"%@", string);
    return [[self dateFormatter] dateFromString:string];
    
    return nil;
}

- (void)parseMetadata:(NSDictionary *)data {
    
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
    GWDebugMetadata(@"Parsing metadata %@", data);
    
    NSDictionary *program = [data objectForKey:@"program"];
    NSString *showName = [[program objectForKey:@"title"] stringByReplacingOccurrencesOfString:@"::" withString:@":"];
    if (showName != nil)
        [metadata setObject:showName forKey:GWMetadataPropertyCurrentShow];
    
    NSString *showStartDateString = [program objectForKey:@"date"];
    if (showStartDateString != nil)
        [metadata setObject:[self dateFromString:showStartDateString] forKey:GWMetadataPropertyCurrentShowStartTime];    
    
    NSArray *elements = [program objectForKey:@"elements"];
    if ([elements count]) {
        
        for (NSDictionary *element in elements) {
            
            if ([[element objectForKey:@"type"] isEqualToString:@"Music"]) {
                
                NSMutableDictionary *track = [[NSMutableDictionary alloc] init];
                NSString *imageURL = [element objectForKey:@"imgurl"];
                if (imageURL && ![imageURL isEqualToString:@"http://nettradio.nrk.no/albumill/.jpg"])
                    [track setObject:[NSURL URLWithString:imageURL] forKey:@"coverArtImageURL"];
                
                NSString *artist = [element objectForKey:@"contributor"];
                if (artist)
                    [track setObject:artist forKey:@"artist"];
                
                NSString *title = [element objectForKey:@"title"];
                if (title)
                    [track setObject:title forKey:@"track"];
                
                NSString *dateString = [element objectForKey:@"date"];
                if (dateString != nil) {
                    NSDate *startTime = [self dateFromString:dateString];
                    
                    if ([[element objectForKey:@"runorder"] isEqualToString:@"present"]) {
                        NSTimeInterval intervalSinceThen = [[NSDate date] timeIntervalSinceDate:startTime];
                        if (intervalSinceThen > 0 && intervalSinceThen > 60 * 20) {
                            //GWDebugRadioMetadata("Ignoring song with title '%@' because it started too long ago", title);
                            continue;
                        }
                    }
                    
                    [track setObject:startTime forKey:@"startTime"];
                }
                     
                
                if ([[element objectForKey:@"runorder"] isEqualToString:@"past"])
                    [metadata setObject:track forKey:@"previousTrack"];
                else if ([[element objectForKey:@"runorder"] isEqualToString:@"present"])
                    [metadata setObject:track forKey:@"currentTrack"];
                else if ([[element objectForKey:@"runorder"] isEqualToString:@"future"])
                    [metadata setObject:track forKey:@"nextTrack"];
                        
                
            } else if ([[element objectForKey:@"runorder"] isEqualToString:@"nextprogram"]) {
                NSDictionary *nextProgram = [element objectForKey:@"program"];
                [metadata setObject:[nextProgram objectForKey:@"title"] forKey:@"nextShowName"];
                
                NSString *nextShowStartDateString = [nextProgram objectForKey:@"date"];
                if (nextShowStartDateString != nil)
                    [metadata setObject:[self dateFromString:nextShowStartDateString] forKey:@"nextShowStartTime"];    
            }
            
            
        }
    }
    
    GWDebugMetadata(@"Parsed metadata %@", metadata);
    
    if ([[self currentMetadata] isEqualToDictionary:metadata])
        return;
    
    GWDebugMetadata(@"Posting metadata update notification...");
    [[NSNotificationCenter defaultCenter] postNotificationName:GWRadioStationMetadataDidChangeNotification 
                                                        object:self 
                                                      userInfo:metadata];
    [self setCurrentMetadata:metadata];
}



@end
