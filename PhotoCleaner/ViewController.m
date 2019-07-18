//
//  ViewController.m
//  PhotoCleaner
//
//  Created by GuanChe on 2019/1/21.
//  Copyright © 2019 GuanChe. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>

@interface ViewController ()

@property (nonatomic, strong) NSMutableDictionary *pathToHash;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *originImageView;
@property (weak, nonatomic) IBOutlet UIImageView *duplicateImageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *pathLabel;
@property (nonatomic, strong) NSArray *foundPhotos;
@property (nonatomic) NSInteger index;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _pathToHash = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Users/guanche/Documents/pathToHash.plist"];
    if (_pathToHash == nil) {
        _pathToHash = [NSMutableDictionary dictionary];
    }
}

- (NSString *)documentsPath {
    static NSString *documentsPath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    });
    
    return documentsPath;
}

- (IBAction)buttonClicked:(UIButton *)sender {
    [_label setText:@"finding..."];
    [_originImageView setImage:nil];
    [_duplicateImageView setImage:nil];
    NSString *text = _textField.text;
    NSString *path;
    for (NSString *key in _pathToHash) {
        if ([text isEqualToString:key]) {
            path = key;
            [_originImageView setImage:[UIImage imageWithContentsOfFile:key]];
            break;
        }
        if ([key containsString:text]) {
            if (path == nil) {
                path = key;
                [_originImageView setImage:[UIImage imageWithContentsOfFile:key]];
            }
            NSLog(@"path: %@", key);
        }
    }
    if (path == nil) {
        [_label setText:@"not found"];
        return;
    }
    
    _foundPhotos = [self findDuplicatePhotos:path];
    [_label setText:[NSString stringWithFormat:@"found %td", _foundPhotos.count]];
    _index = 0;
    if (_foundPhotos.count > 0) {
        NSLog(@"found photos: %@", _foundPhotos);
        [_pathLabel setText:_foundPhotos[0]];
        [_duplicateImageView setImage:[UIImage imageWithContentsOfFile:_foundPhotos[0]]];
    }
}

- (NSArray *)findDuplicatePhotos:(NSString *)path {
    NSString *hash = [_pathToHash objectForKey:path];
    
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *key in _pathToHash) {
        if (![key isEqualToString:path]) {
            NSString *hash2 = [_pathToHash objectForKey:key];
            if ([self diffOfString1:hash String2:hash2] <= 3) {
                [result addObject:key];
            }
        }
    }
    
    return [result copy];
}

- (NSInteger)diffOfString1:(NSString *)str1 String2:(NSString *)str2 {
    NSInteger count = 0;
    for (NSInteger i = 0; i < str1.length; i++) {
        if ([str1 characterAtIndex:i] != [str2 characterAtIndex:i]) {
            count++;
        }
    }
    return count;
}

- (IBAction)next:(UIButton *)sender {
    if (_foundPhotos.count > 0) {
        _index = (_index + 1) % _foundPhotos.count;
        [_pathLabel setText:_foundPhotos[_index]];
        [_duplicateImageView setImage:[UIImage imageWithContentsOfFile:_foundPhotos[_index]]];
    }
}

@end
