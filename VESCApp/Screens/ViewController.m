//
//  ViewController.m
//  Pedaless
//
//  Created by Bosko Petreski on 4/19/18.
//  Copyright © 2018 Bosko Petreski. All rights reserved.
//

#import "ViewController.h"
#import "DataCell.h"
#import "Helpers.h"

typedef struct {
    float v_in;
    float current_in;
    float rpm;
    float watt_hours;
    uint8_t tachometer_abs[4];
} packet;

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - CentralManager
-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSString *message = @"Bluetooth";
    switch (central.state) {
        case CBManagerStateUnknown: message = @"Bluetooth Unknown."; break;
        case CBManagerStateResetting: message = @"The update is being started. Please wait until Bluetooth is ready."; break;
        case CBManagerStateUnsupported: message = @"This device does not support Bluetooth low energy."; break;
        case CBManagerStateUnauthorized: message = @"This app is not authorized to use Bluetooth low energy."; break;
        case CBManagerStatePoweredOff: message = @"You must turn on Bluetooth in Settings in order to use the reader."; break;
        default: break;
    }
    NSLog(@"Bluetooth: %@",message);
}
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if (![peripherals containsObject:peripheral]) {
        [peripherals addObject:peripheral];
    }
}
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    connectedPeripheral = peripheral;
    
    [connectedPeripheral setDelegate:self];
    [connectedPeripheral discoverServices:nil];
}
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error != nil) {
        NSLog(@"Error connect: %@",error.description);
    }
}
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error != nil) {
        NSLog(@"Error disconnect: %@",error.description);
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (error) {
        NSLog(@"Error receiving didWriteValueForCharacteristic %@: %@", characteristic, error);
        return;
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error receiving notification for characteristic %@: %@", characteristic, error);
        return;
    }
    
    packet vesc_packet;
    [characteristic.value getBytes:&vesc_packet length:sizeof(vesc_packet)];
    [self presentData:vesc_packet];
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"FFE1"]] forService:service];
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (error) {
        NSLog(@"Error receiving didUpdateNotificationStateForCharacteristic %@: %@", characteristic, error);
        return;
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

#pragma mark - IBActions
-(IBAction)onBtnConnect:(UIButton *)sender{
    if (connectedPeripheral != nil) {
        [Helpers showPopup:self title:@"Are you sure ?" buttonName:@"Dissconnect" cancelName:@"Cancel" ok:^{
            [self->centralManager cancelPeripheralConnection:self->connectedPeripheral];
            self->connectedPeripheral = nil;
            [self->peripherals removeAllObjects];
            [sender setTitle:@"Connect" forState:UIControlStateNormal];
        } cancel:nil];
    }
    else{
        [peripherals removeAllObjects];
        [centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFE0"]] options:nil];
        [self performSelector:@selector(stopSearchReader) withObject:nil afterDelay:2];
        [sender setTitle:@"Disconnect" forState:UIControlStateNormal];
    }
}
int32_t buffer_get_int32(const uint8_t *buffer) {
    int32_t res = ((uint32_t) buffer[0]) << 24 | ((uint32_t) buffer[1]) << 16 | ((uint32_t) buffer[2]) << 8 | ((uint32_t) buffer[3]);
    return res;
}
#pragma mark - CustomFunctions
-(void)presentData:(packet)dataVesc {
    int tachometer_abs = buffer_get_int32(dataVesc.tachometer_abs);
    
    double wheelDiameter = 700; //mm diameter
    double motorDiameter = 63; //mm diameter
    double gearRatio = motorDiameter / wheelDiameter;
    double motorPoles = 14;
    
    double ratioRpmSpeed = (gearRatio * 60 * wheelDiameter * M_PI) / ((motorPoles / 2) * 1000000); // ERPM to Km/h
    double ratioPulseDistance = (gearRatio * wheelDiameter * M_PI) / ((motorPoles * 3) * 1000000); // Pulses to km travelled
    
    double speed = dataVesc.rpm * ratioRpmSpeed;
    double distance = tachometer_abs * ratioPulseDistance;
    double power = dataVesc.current_in * dataVesc.v_in;
    
    arrPedalessData = @[@{@"title":@"Current Batt",@"data":[NSString stringWithFormat:@"%.2f A",dataVesc.current_in]},
                        @{@"title":@"Watts",@"data":[NSString stringWithFormat:@"%.4f Wh" ,dataVesc.watt_hours]},
                        @{@"title":@"Voltage",@"data":[NSString stringWithFormat:@"%.2f V",dataVesc.v_in]},
                        @{@"title":@"Distance",@"data":[NSString stringWithFormat:@"%.1f km", distance]},
                        @{@"title":@"Speed",@"data":[NSString stringWithFormat:@"%.1f km/h",speed]},
                        @{@"title":@"Power",@"data":[NSString stringWithFormat:@"%.f W",power]}
    ];
    [colPedalessData reloadData];
}
-(void)stopSearchReader{
    [centralManager stopScan];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Search device" message:@"Choose Pedaless device" preferredStyle:UIAlertControllerStyleActionSheet];
    for(CBPeripheral *periperal in peripherals){
        [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@",periperal.name] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self->centralManager connectPeripheral:periperal options:nil];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Re-scan pedaless" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self onBtnConnect:self->btnConnect];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self->btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - CollectionView
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return arrPedalessData.count;
}
-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"DataCell";
    DataCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *dictData = arrPedalessData[indexPath.row];
    
    cell.lblData.text = dictData[@"data"];
    cell.lblTitle.text = dictData[@"title"];
    
    cell.layer.borderColor = UIColor.lightGrayColor.CGColor;
    cell.layer.borderWidth = 2;
    
    return cell;
}

#pragma mark - UIViewDelegates
-(void)viewDidLoad {
    [super viewDidLoad];
    centralManager = [CBCentralManager.alloc initWithDelegate:self queue:nil];
    peripherals = NSMutableArray.new;
}
-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
