//
//  ViewController.m
//  BTFMDatabase
//
//  Created by Beautilut on 2017/6/6.
//  Copyright © 2017年 beautilut. All rights reserved.
//

#import "ViewController.h"
#import "BTBaseDBTest.h"
#import "BTDBCondition.h"
#import "BTDBManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  基础的保存 搜索
 */
-(void)normalSaveAndSearch
{
    BTDBManager * manager = [BTBaseDBTest dbManager];
    BOOL open = [manager openDBWithName:@"testDBModel"];

    [BTBaseDBTest createTable];

    BTBaseDBTest * dbTest = [[BTBaseDBTest alloc] init];
    dbTest.key = (id)@"test";
    dbTest.value = @"value";
    [dbTest insertModel];

    BTDBConditionPair * pair = [[BTDBConditionPair alloc] init];
    pair.equlPair = @{@"key" : @"test"};
    BTDBSearchCondition * search = [[BTDBSearchCondition alloc] init];
    search.andPairs = pair;

    NSArray * array = [BTBaseDBTest searchWithCondition:search];
    NSLog(@"%@" , array);
}



@end
