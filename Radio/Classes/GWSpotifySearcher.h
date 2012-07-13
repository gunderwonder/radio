//
//  GWSpotifySearcher.h
//  Radio
//
//  Created by Øystein Riiser Gundersen on 18.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GWSpotifySearcher : NSObject <UIAlertViewDelegate>

+ (void)searchForTrack:(NSString *)trackName byArtist:(NSString *)artistName;
+ (BOOL)canOpenSpotify;

@end
