//
//  ListVC1.m
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/6/24.
//  Copyright © 2019 mh. All rights reserved.
//

#import "ListVC1.h"

@interface ListVC1 ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView * tableview;

@property(nonatomic,copy)NSArray * titleArr;
@property(nonatomic,copy)NSArray * classArr;

@end

@implementation ListVC1

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.view addSubview:self.tableview];
    
    self.titleArr = @[@"绘制一张图片",@"shader编译链接、简单图形变换",@"三维图形变换",@"图形变换、纹理贴图、着色、深度测试",@"🌎🌛错误"];
    self.classArr = @[@"Test1VC",@"Test2VC",@"Test3VC",@"Test4VC",@"Test_5VC"];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellid = @"fgfgfgfgg";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    cell.textLabel.text = self.titleArr[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString * className = self.classArr[indexPath.row];
    UIViewController * vc = (UIViewController *)[NSClassFromString(className) new];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
