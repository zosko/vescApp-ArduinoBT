//
//  ViewController.h
//  Pedaless
//
//  Created by Bosko Petreski on 4/19/18.
//  Copyright © 2018 Bosko Petreski. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreBluetooth;

@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate,UICollectionViewDelegate,UICollectionViewDataSource>{
    CBCentralManager *centralManager;
    CBPeripheral *connectedPeripheral;
    NSMutableArray *peripherals;
    
    NSArray *arrPedalessData;
    IBOutlet UICollectionView *colPedalessData;
}


@end

