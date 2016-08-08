//
//  NSString+Extend.m
//  CoreCategory
//
//  Created by 成林 on 15/4/6.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#import "NSString+Extend.h"
#import "NSDate+Extend.h"
@implementation NSString (Extend)


/*
 *  时间戳对应的NSDate
 */
-(NSDate *)date{
    
    NSTimeInterval timeInterval=self.floatValue;
    
    return [NSDate dateWithTimeIntervalSince1970:timeInterval];
}



- (NSString *)created_at {
    // 获得服务器返回的时间
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *createdAtDate = [fmt dateFromString:self];
    // 获得当前时间
    NSDate *nowDate = [NSDate date];
    // 获取日历对象
    NSCalendar *calender = [NSCalendar currentCalendar];
    if (createdAtDate.isZMJThisYear) { // 如果是今年
        
        if (createdAtDate.isZMJToday) { // 如果是今天
            
            NSCalendarUnit unit = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            NSDateComponents *comps = [calender components:unit fromDate:createdAtDate toDate:nowDate options:0];
            if (comps.hour >= 1) { // 如果时间间隔 >= 1小时
                return [NSString stringWithFormat:@"%zd小时前",comps.hour];
            } else if (comps.minute >= 1) { //  1小时 >如果时间间隔 >= 1分钟
                return [NSString stringWithFormat:@"%zd分钟前",comps.minute];
            } else { // 时间间隔 < 一分钟
                return @"刚刚";
            }
            
        }else if (createdAtDate.isZMJYesterday) { // 如果是昨天
            fmt.dateFormat = @"HH:mm:ss";
            return [NSString stringWithFormat:@"昨天 %@",[fmt stringFromDate:createdAtDate]];
        } else { // 不是今年
            fmt.dateFormat = @"MM-dd HH:mm:ss";
            return [fmt stringFromDate:createdAtDate];
        }
        
    }else {
        
        return self;
    }
}


@end
