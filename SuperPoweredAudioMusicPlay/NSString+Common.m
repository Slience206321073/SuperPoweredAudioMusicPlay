//
//  NSString+Common.m
//  SuperPoweredAudioMusicPlay
//
//  Created by 岳克奎 on 17/1/22.
//  Copyright © 2017年 岳克奎. All rights reserved.
//

#import "NSString+Common.h"

@implementation NSString (Common)
/**
 * @brief:lrc字符串转lrc数据源数组
 *
 */
-(NSMutableDictionary *)st_parsingLrcStr{
    NSLog(@" ----------------11111----------- %@     ",self);
   // NSString *musicLrcContentDataStr =[musicBaseDic valueForKey:@"musicLrcContentDataStr"];
    //歌曲 信息
    //    NSString *musicInfoStr = [NSString stringWithFormat:@"歌曲：%@ 演唱:%@",musicNameStr, musicSingerStr];
    NSString *musicInfoStr = @" ";
    //临时存每行歌词
    // 因为分割后 只有时间str+歌词内容str  需要扩展mdoel功能，让model变得很强大才对
    NSMutableArray *tempMArray =[@[]mutableCopy];
    //存歌词model  数据源  存每行歌词对应的 mdoel
    NSMutableArray *lrcDataSoureMArray =[@[]mutableCopy];
    //存歌词时间
    //主要是 因为。C++代理每次来判断歌词时间点，如果直接判断，下一次也就是+1，
    //但是index直接取数据总是那么不令人放心。所以通过时间点区域 获得index而不是简单的index++，这样代码更加安全
    NSMutableArray *lrcPointTimeStrArray =[@[]mutableCopy];
    __weak  typeof(self)weak_Self = self;
    //调 enumerateLinesUsingBlock 一行一行的读取数据
    [self enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        
        
        //拿到每一行
        //判断是否 包含 []
        if ([self  containsString:@"["]&&[self containsString:@"]"]) {
            //分割  如果里面是数字  （歌词很多种，特别给出前几行 很多种，看着不爽，直接不要了。前期时间就直接显示歌手+歌名）
            NSString *regex = @"[0-9]+:[0-9]+\\.[0-9]+";
            NSRange r = [line rangeOfString:regex options:NSRegularExpressionSearch];
            //存在数字
            if(r.location !=NSNotFound){
                NSArray *lrcArray = [line componentsSeparatedByString:@"]"];
                NSLog(@"---     array         -------%lu",(unsigned long)lrcArray.count);
                //[01:33.22][00:35.75]我应该在车底                  lrcArray.count =  3   2+1
                //[02:23.65][02:11.47][01:13.79]不会像我这样孩子气   lrcArray.count =  4   3+1
                
                
                
                
             
                
                if (lrcArray.count>1) {
                    for (int i = 0; i<lrcArray.count-1; i++) {
                        //时间在前  内容 在后，
                        NSDictionary *tempDic =@{@"lrcStartTimeStr":[weak_Self st_timeTypeOfMSToTimeTypeOfS:[lrcArray[i] substringFromIndex:1]],
                                                 @"lrcContentStr":[[lrcArray lastObject] st_isEmpty]?@"  ":[lrcArray lastObject]};
                        //临时存每行先别MJ去转mdoel
                        [tempMArray addObject:tempDic];
                    }
                }
                
            }
        }
    }];
    
    
    
    
    
    // 临时歌词数据排序
    tempMArray = [[tempMArray.copy sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        int number1 =(int)[obj1[@"lrcStartTimeStr"]  integerValue];
        int number2 =(int) [obj2[@"lrcStartTimeStr"] integerValue];
        //按照降序排列，如果升序就返回结果对换
        if (number1 > number2) {
            return NSOrderedDescending;
        }else{
            return NSOrderedAscending;
        }
    }]mutableCopy];
    
    
    //数据model的扩展成完美nmodle
    //存歌词时间//
    for(int i = 0;i<tempMArray.count;i++){
        [lrcPointTimeStrArray addObject:tempMArray[i][@"lrcStartTimeStr"]];
    }
    // 至少有10行吧。。才算有歌词的歌曲 数组里就存歌曲得信息而已  最后一行时间统一设置10086s
    if(tempMArray.count<5){
        //歌词小于5的。。去一次就够了。。获取歌曲信息：歌手+歌曲名
        NSDictionary *modelDic =@{@"lrcStartTimeStr":@"10086",
                                  @"lrcEndTimeStr":@"10086",
                                  @"lrcContentStr":musicInfoStr,
                                  @"lrcLineNumStr":@"10086",
                                  @"lrcNextContentStr":musicInfoStr};
        //返回数据源
        [lrcDataSoureMArray addObject:[STMusicLrcModel mj_objectWithKeyValues:modelDic]];
        //这里处理下-----------------------------------------------
//        return ;
        return  @{@"lrcModelDataSourceArray":lrcDataSoureMArray,@"lrcTimePointDataArray":lrcPointTimeStrArray}.mutableCopy;
    }
    
    NSLog(@"eqeqwe======         tempMArray     === %lu",(unsigned long)tempMArray.count);
    
    // tempMArray 存 临时的每行数据 的数据要+1  我要增加1个
    //目的：让mdoel 不仅装下自己的信息。还装有下一行的信息
    for (int i = 0 ;i<tempMArray.count+1;i++) {
        //某一行对应的  临时dic（包含 时间起点+这行歌词）
        NSDictionary *firstLrcDic;
        if (i<tempMArray.count) {
            firstLrcDic = tempMArray[i];
        }
        //歌词上最后一行  不是数组里加的最后一行
        if (i == tempMArray.count-1) {//52
            NSDictionary *modelDic =@{@"lrcStartTimeStr":firstLrcDic[@"lrcStartTimeStr"],
                                      @"lrcEndTimeStr":@"10086",
                                      @"lrcContentStr":firstLrcDic[@"lrcContentStr"],
                                      @"lrcLineNumStr":[NSString stringWithFormat:@"%d",i],
                                      @"lrcNextContentStr":musicInfoStr};
            [lrcDataSoureMArray addObject:[STMusicLrcModel mj_objectWithKeyValues:modelDic]];
        }
        else if (i == tempMArray.count) {//53
            // 最后 多加一行
            NSDictionary *modelDic =@{@"lrcStartTimeStr":@"10086",
                                      @"lrcEndTimeStr":@"10086",
                                      @"lrcContentStr":musicInfoStr,
                                      @"lrcLineNumStr":[NSString stringWithFormat:@"%d",i],
                                      @"lrcNextContentStr":musicInfoStr};
            [lrcDataSoureMArray addObject:[STMusicLrcModel mj_objectWithKeyValues:modelDic]];
        } else{//50
            //注意i+2  因为当前这行 歌词走完了。那么他应该显示的是 下 下一行歌词 对不对！但是，如果下一行为空呢。这都要考虑
            NSDictionary *secondLrcDic = tempMArray[i+1];
            NSString *nextStr =  @"";
            if ([secondLrcDic[@"lrcContentStr"] st_isEmpty]) {
                if (i+2 >= tempMArray.count-1) {
                    nextStr = @"";
                }else{
                    nextStr =  [secondLrcDic[@"lrcContentStr"] st_isEmpty]?tempMArray[i+2][@"lrcContentStr"]:secondLrcDic[@"lrcContentStr"];
                }
            }
            NSDictionary *modelDic =@{@"lrcStartTimeStr":firstLrcDic[@"lrcStartTimeStr"],
                                      @"lrcEndTimeStr":secondLrcDic[@"lrcStartTimeStr"],
                                      @"lrcContentStr":firstLrcDic[@"lrcContentStr"],
                                      @"lrcLineNumStr":[NSString stringWithFormat:@"%d",i],
                                      @"lrcNextContentStr":nextStr};
            [lrcDataSoureMArray addObject:[STMusicLrcModel mj_objectWithKeyValues:modelDic]];
        }
    }
//    if (block) {
//        //返回 强大lrcMdoel  和 装有每行时间点的 数组
//        block(lrcDataSoureMArray,lrcPointTimeStrArray);
    
//    }
    return @{@"lrcModelDataSourceArray":lrcDataSoureMArray,@"lrcTimePointDataArray":lrcPointTimeStrArray}.mutableCopy;
    
}
#pragma mark - 时间转S处理（Data）
/**
 * @brief: 时间转S处理（
 *
 * @use:将 01：07.45 转为 秒
 */
//-(NSString *)timeWithString:(NSString *)timeString
//{
//    // 01:02.38
//    NSInteger min = [[timeString componentsSeparatedByString:@":"][0] integerValue];
//    NSInteger sec = [[timeString substringWithRange:NSMakeRange(3, 2)] integerValue];
//    NSInteger hs = [[timeString componentsSeparatedByString:@"."][1] integerValue];
//    return [NSString stringWithFormat:@"%f",(min * 60 + sec + hs * 0.01)];
//}
-(NSString *)st_timeTypeOfMSToTimeTypeOfS:(NSString *)msTimeString{
    // 01:02.38
    NSInteger min = [[msTimeString componentsSeparatedByString:@":"][0] integerValue];
    NSInteger sec = [[msTimeString substringWithRange:NSMakeRange(3, 2)] integerValue];
    NSInteger hs = [[msTimeString componentsSeparatedByString:@"."][1] integerValue];
    return [NSString stringWithFormat:@"%f",(min * 60 + sec + hs * 0.01)];
}
/**
 * @brief: 时间转S处理（
 *
 * @use:将 秒s 转为  01：07.45
 */
-(NSString *)st_timeTypeOfSToTimeTypeOfMS{
   return  [NSString stringWithFormat:@"-%02d:%02d",
     (int)(self.integerValue/60)%60,
            (int)self.integerValue%60];
}




/**
 *  判断字符串是否为空
 *
 *  @return BOOL
 */
- (BOOL)st_isEmpty{
    if (self == nil || self == NULL) {
        return YES;
    }
    if ([self isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}
































@end
