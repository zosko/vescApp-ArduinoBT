//
//  DataCell.h
//  Pedaless
//
//  Created by Bosko Petreski on 9/5/19.
//  Copyright © 2019 Bosko Petreski. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataCell : UICollectionViewCell
@property (nonatomic,strong) IBOutlet UILabel *lblTitle;
@property (nonatomic,strong) IBOutlet UILabel *lblData;
@end

NS_ASSUME_NONNULL_END
