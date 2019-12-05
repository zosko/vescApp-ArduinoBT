//
//  Helpers.m
//  Pedaless
//
//  Created by Bosko Petreski on 12/5/19.
//  Copyright © 2019 Bosko Petreski. All rights reserved.
//

#import "Helpers.h"

@implementation Helpers
+(void)showPopup:(UIViewController *)controller title:(NSString *)title buttonName:(NSString *)buttonName cancelName:(NSString *)cancelName ok:(VoidCallback)ok cancel:(nullable VoidCallback)cancel{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:buttonName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ok();
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:cancelName style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if(cancel)cancel();
    }]];
    [controller presentViewController:alert animated:YES completion:nil];
}
@end
