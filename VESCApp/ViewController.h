//
//  ViewController.h
//  Pedaless
//
//  Created by Bosko Petreski on 4/19/18.
//  Copyright © 2018 Bosko Petreski. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct {
  float v_in;
  float current_in;
  float rpm;
  float watt_hours;
  float tachometer_abs;
} mc_values_packet;

@import CoreBluetooth;

@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate,UICollectionViewDelegate,UICollectionViewDataSource>{
    CBCentralManager *centralManager;
    CBPeripheral *connectedPeripheral;
    NSMutableArray *peripherals;
    CBCharacteristic *txCharacteristic;
    CBCharacteristicWriteType writeType;
    
    NSArray *arrPedalessData;
    IBOutlet UICollectionView *colPedalessData;
}


@end

