//
//  NSString+Extend.h
//  CoreCategory
//
//  Created by block on 15/4/6.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extend)


/*
 *  时间戳对应的NSDate
 */
@property (nonatomic,strong,readonly) NSDate *date;



- (NSString *)created_at;





@end
