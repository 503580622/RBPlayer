# RBPlayer

![RBPlayer](https://raw.githubusercontent.com/itribs/RBPlayer/master/video_player_running_man.jpg)

Some of the  advance features are:
- Fully customizable UI
- No view-level restrictions (have it any size and position you would like!)
- Supports HTTP Live Streaming protocol
- Orientation change support (even when orientation lock is enabled)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 7.0 or later

## Installation

RBPlayer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RBPlayer", "~> 0.1.0"
```

## Getting Start

    RBPlayerViewController *viewController = [[RBPlayerViewController alloc] init];
    [viewController.player playWithURL:[NSURL URLWithString:@"http://xxx.xxx/xx.mp4"]];
    [self presentViewController:viewController animated:YES completion:nil];
    
### Play
  
    RBPlayerItem *item = [[RBPlayerItem alloc] init];
    item.title = @"这都是什么jb电影";
    item.assetTitle = @"清晰";
    
    RBPlayerItemAsset *itemAsset1 = [[RBPlayerItemAsset alloc] initWithType:@"清晰" URL:[NSURL URLWithString:url]];
    RBPlayerItemAsset *itemAsset2 = [[RBPlayerItemAsset alloc] initWithType: @"高清" URL:[NSURL URLWithString:url]];
    
    item.assets = @[itemAsset1, itemAsset2];
    
    [self.player replaceCurrentItemWithPlayerItem:item];
    [self.player playWithItemAsset:itemAsset1];
    
### Customize

    self.player = [[RBVideoPlayer alloc] init];
    [self.view addSubview:self.player.view];
    
    self.player.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[playerView]-50-|" options:0 metrics:nil views:@{@"playerView":self.player.view}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[playerView(200)]" options:0 metrics:nil views:@{@"playerView":self.player.view}]];
  

## Author

Ribs, 234126357@qq.com

## License

RBPlayer is available under the MIT license. See the LICENSE file for more info.
