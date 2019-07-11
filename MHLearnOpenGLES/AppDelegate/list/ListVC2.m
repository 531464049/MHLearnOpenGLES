//
//  ListVC2.m
//  MHLearnOpenGLES
//
//  Created by mahao on 2019/6/24.
//  Copyright © 2019 mh. All rights reserved.
//

#import "ListVC2.h"

@interface ListVC2 ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView * tableview;

@property(nonatomic,copy)NSArray * titleArr;
@property(nonatomic,copy)NSArray * classArr;

@end
@implementation ListVC2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.view addSubview:self.tableview];
    
    self.titleArr = @[@"OpenGL渲染",@"OpenGL矩阵变换",@"OpenGL立方体",@"摄像机"];
    self.classArr = @[@"Test6VC",@"Test7VC",@"Test8VC",@"TestCameraVC"];

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
    static NSString * cellid = @"5656562321564";
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
