//
//  GWTrackView.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GWTrackView.h"
#import "UIImageView+AFNetworking.h"
#import "GWSpotifySearcher.h"

#define GWTrackViewMetadataLeftOffset 78.0
#define GWTrackViewMetadataDefaultWidth 145.0

@implementation GWTrackView
@synthesize coverArtView;
@synthesize trackLabel;
@synthesize artistLabel;
@synthesize label;
@synthesize spotifyButton;

- (void)loadSubview {
    NSArray *b = [[NSBundle mainBundle] loadNibNamed:@"GWTrackView" owner:self options:nil];
    for (id v in b) {
        if ([v isKindOfClass:[UIView class]])
            [self addSubview:v];
    }
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubview];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self loadSubview];
    }
    return self;
}

- (void)animateMetadataToOffset:(CGFloat)offset width:(CGFloat)width {
    [UIView animateWithDuration:.3 animations:^{
        CGRect artistLabelFrame = [[self artistLabel] frame];
        artistLabelFrame = CGRectWithX(artistLabelFrame, offset);
        artistLabelFrame = CGRectWithWidth(artistLabelFrame, width);
        [[self artistLabel] setFrame:artistLabelFrame];
        
        CGRect trackLabelFrame = [[self trackLabel] frame];
        trackLabelFrame = CGRectWithX(trackLabelFrame, offset);
        [[self trackLabel] setFrame:trackLabelFrame];
        
        CGRect spotifyButtonFrame = [[self spotifyButton] frame];
        spotifyButtonFrame = CGRectWithX(spotifyButtonFrame, offset);
        spotifyButtonFrame = CGRectWithX(spotifyButtonFrame, offset);
        [[self spotifyButton] setFrame:spotifyButtonFrame];
        
    }];
}

- (void)configureWithTrackData:(NSDictionary *)trackData {
    if (trackData == nil) {
        [self setHidden:YES];
        return;
    }
    
    NSURL *coverArtURL = [trackData objectForKey:@"coverArtImageURL"];
    
    
    CGFloat metadataOffset = 0.0f;
    CGFloat metadataWidth = GWTrackViewMetadataDefaultWidth;
    if (coverArtURL) {
        [[self coverArtView] setImageWithURLRequest:[NSURLRequest requestWithURL:coverArtURL] 
                                   placeholderImage:nil 
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                [UIView animateWithDuration:.5 animations:^{
                                                    [[self coverArtView] setAlpha:1.0];
                                                }];
                                            }
                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                [self animateMetadataToOffset:0.0f width:metadataWidth]; 
                                            }];
        metadataOffset = GWTrackViewMetadataLeftOffset;
        metadataWidth = GWTrackViewWidth;
    } else {
        
        [UIView animateWithDuration:.5 animations:^{
            [[self coverArtView] setAlpha:0.0];
        }];
        
    }
    
    
    NSString *artist = [[trackData objectForKey:@"artist"] uppercaseString];
    artist = (artist == nil) ? @"" : artist;
    [[self artistLabel] setText:artist];
    
    NSString *title = [[trackData objectForKey:@"track"] uppercaseString];
    title = (title == nil) ? @"" : title;
    [[self trackLabel] setText:title];
    
    [self setHidden:NO];
    
    [self animateMetadataToOffset:metadataOffset width:metadataWidth];
    
    
}

- (IBAction)didTouchSpotifyButton:(UIButton *)sender {
    
    [GWSpotifySearcher searchForTrack:[[[self trackLabel] text] lowercaseString] 
                             byArtist:[[[self artistLabel] text] lowercaseString]];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
