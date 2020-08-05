//
//  JKReachabilityExtension.h
//  JKReachability
//
//  Created by 王冲 on 2019/1/25.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKSingle.h"
NS_ASSUME_NONNULL_BEGIN

@interface JKReachabilityExtension : NSObject

jkSingleH(JKReachabilityExtension)

/**
 no_network：没有网
 WIFI：WIFI
 ReachableViaWWAN：2G、3G、4G
 */
@property(nonatomic,strong) NSString *status;



@end

NS_ASSUME_NONNULL_END
