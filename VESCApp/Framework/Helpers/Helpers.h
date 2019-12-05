//
//  Helpers.h
//  Pedaless
//
//  Created by Bosko Petreski on 12/5/19.
//  Copyright © 2019 Bosko Petreski. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef void(^VoidCallback)(void);

@interface Helpers : NSObject
+(void)showPopup:(UIViewController *)controller title:(NSString *)title buttonName:(NSString *)buttonName cancelName:(NSString *)cancelName ok:(VoidCallback)ok cancel:(nullable VoidCallback)cancel;
@end

NS_ASSUME_NONNULL_END
