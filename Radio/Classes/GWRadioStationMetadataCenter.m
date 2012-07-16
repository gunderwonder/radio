//
//  GWRadioStationMetadataCenter.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GWRadioStationMetadataCenter.h"
#import "AFNetworking.h"

#ifdef GWDebugRadioMetadata
    #define GWDebugMetadata GWLog
#else
    #define GWDebugMetadata(...)
#endif

static GWRadioStationMetadataCenter *sharedMetadataCenter;

@interface GWRadioStationMetadataCenter() 
@property (nonatomic, retain) NSTimer *pollTimer;
@property (nonatomic, retain) GWRadioStation *currentStation;
@property (nonatomic, retain) NSDictionary *currentMetadata;
- (void)gatherMetadata;
- (void)parseMetadata:(NSDictionary *)metadata;
@end

@implementation GWRadioStationMetadataCenter

@synthesize metadataURL = _metadataURL;
@synthesize pollTimer = _pollTimer;
@synthesize currentStation = _currentStation;
@synthesize currentMetadata = _currentMetadata;

+ (GWRadioStationMetadataCenter *)sharedCenter {
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        sharedMetadataCenter = [[GWRadioStationMetadataCenter alloc] init];
    }
    return sharedMetadataCenter;
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

- (void)parseMetadata:(NSDictionary *)data {
    
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
    GWDebugMetadata(@"Parsing metadata %@", data);
    
    NSDictionary *program = [data objectForKey:@"program"];
    NSString *showName = [program objectForKey:@"title"];
    if (showName != nil)
        [metadata setObject:showName forKey:@"currentShowName"];
    
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
                
                if ([[element objectForKey:@"runorder"] isEqualToString:@"past"])
                    [metadata setObject:track forKey:@"previousTrack"];
                else if ([[element objectForKey:@"runorder"] isEqualToString:@"present"])
                    [metadata setObject:track forKey:@"currentTrack"];
                else if ([[element objectForKey:@"runorder"] isEqualToString:@"future"])
                    [metadata setObject:track forKey:@"nextTrack"];
                
            } else if ([[element objectForKey:@"runorder"] isEqualToString:@"nextprogram"]) {
                NSDictionary *nextProgram = [element objectForKey:@"program"];
                [metadata setObject:[nextProgram objectForKey:@"title"] forKey:@"nextShowName"];
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
