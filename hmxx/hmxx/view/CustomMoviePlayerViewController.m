#import "CustomMoviePlayerViewController.h"

#pragma mark -
#pragma mark Compiler Directives & Static Variables

@implementation CustomMoviePlayerViewController

@synthesize movieURL;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    loadingAni = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2-19, [[UIScreen mainScreen] bounds].size.height/2-19-40, 37, 37)];
    loadingAni.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.view addSubview:loadingAni];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2-40, [[UIScreen mainScreen] bounds].size.height/2-20, 80, 40)];
    label.text = @"加载中...";
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    
    [[self view] setBackgroundColor:[UIColor blackColor]];
    
    [loadingAni startAnimating];
    [self.view addSubview:label];
    
    
}


- (void) moviePlayerLoadStateChanged:(NSNotification*)notification
{
    
    // Unless state is unknown, start playback
    if ([mp loadState] != MPMovieLoadStateUnknown)
    {
        // Remove observer
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerLoadStateDidChangeNotification
                                                      object:nil];
        
        // When tapping movie, status bar will appear, it shows up
        // in portrait mode by default. Set orientation to landscape
//        //设置横屏
//        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
//        // Rotate the view for landscape playback
//        [[self view] setBounds:[[UIScreen mainScreen] bounds]];
//        [[self view] setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2)];
//        //选中当前view
//        [[self view] setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
        
        // Set frame of movieplayer
        [[mp view] setFrame:self.view.frame];
//        [mp setFullscreen:YES animated:YES];
        // Add movie player as subview
        [[self view] addSubview:[mp view]];
        
        // Play the movie
        [mp play];
    }else{
        NSLog(@"MPMovieLoadStateUnknown");
    }
}


- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    //还原状态栏为默认状态
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    // Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void) readyPlayer
{
    mp = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    
    if ([mp respondsToSelector:@selector(loadState)])
    {
        // Set movie player layout
        [mp setControlStyle:MPMovieControlStyleFullscreen]; //MPMovieControlStyleFullscreen //MPMovieControlStyleEmbedded
        //满屏
        [mp setFullscreen:YES];
        // 有助于减少延迟
        [mp prepareToPlay];
        
        // Register that the load state changed (movie is ready)
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayerLoadStateChanged:) 
                                                     name:MPMoviePlayerLoadStateDidChangeNotification 
                                                   object:nil]; 
    } 
    else 
    { 
        // Play the movie For 3.1.x devices 
        [mp play]; 
    } 
    
    // Register to receive a notification when the movie has finished playing. 
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayBackDidFinish:) 
                                                 name:MPMoviePlayerPlaybackDidFinishNotification 
                                               object:nil]; 
} 




@end