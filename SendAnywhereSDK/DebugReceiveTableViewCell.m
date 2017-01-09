//
//  DebugReceiveTableViewCell.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 05/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "DebugReceiveTableViewCell.h"

@implementation DebugReceiveTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.lbMsg = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        self.lbMsg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.lbMsg.font = [UIFont systemFontOfSize:11];
        self.lbMsg.numberOfLines = 0;
        [self.contentView addSubview:self.lbMsg];
    }
    return self;    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
