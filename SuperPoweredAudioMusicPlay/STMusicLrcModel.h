//
//  STMusicLrcModel.h
//  FanweApp
//
//  Created by 岳克奎 on 17/1/12.
//  Copyright © 2017年 xfg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STMusicLrcModel : NSObject
@property (nonatomic, copy)NSString  *lrcStartTimeStr;       //歌词起点时间
@property (nonatomic, copy)NSString  *lrcEndTimeStr;         // 歌词结束时间（也是下一行歌词开始时间）
@property (nonatomic, copy) NSString *lrcContentStr;        // 每行歌词
@property (nonatomic, copy) NSString *lrcNextContentStr;    // 下行歌词
@property (nonatomic, copy) NSString *lrcLineNumStr;        //歌词行数
@end
