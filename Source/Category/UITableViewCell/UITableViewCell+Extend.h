//
//  UITableViewCell+Extend.h
//  Carpenter
//
//  Created by block on 15/4/29.
//  Copyright (c) 2015年 block. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (Extend)


/**
 *  创建cell
 *
 *  @param tableView 所属tableView
 *
 *  @return cell实例
 */
+(instancetype)cellWithTableView:(UITableView *)tableView;

@end
