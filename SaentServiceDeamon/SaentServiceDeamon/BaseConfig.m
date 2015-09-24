//
//  BaseConfig.m
//  SaentServiceDeamon
//
//  Created by APAC Builder on 9/11/15.
//  Copyright (c) 2015 APAC Builder. All rights reserved.
//

#import "BaseConfig.h"

@implementation BaseConfig

- (NSXMLDocument*)createXMLDocumentFromFile:(NSString *)filePath {
    
    NSXMLDocument *xmlDocument;
    
    NSError *err=nil;
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    if (!fileURL) {
        
        NSLog(@"Can't create an URL from file %@.", filePath);
        
        return nil;
        
    }
    
    xmlDocument = [[NSXMLDocument alloc] initWithContentsOfURL:fileURL
                                                       options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
                                                         error:&err];
    
    if (xmlDocument == nil) {
        
        xmlDocument = [[NSXMLDocument alloc] initWithContentsOfURL:fileURL
                                                           options:NSXMLDocumentTidyXML
                                                             error:&err];
        
    }
    
    if(xmlDocument == nil){
    
        NSXMLElement *root = [NSXMLElement elementWithName:@"Root"];
        
        xmlDocument = [[NSXMLDocument alloc] initWithRootElement:root];
        
        [xmlDocument setVersion:@"1.0"];
        
        [xmlDocument setCharacterEncoding:@"UTF-8"];
        
    }
    
    return xmlDocument;
    
}

- (BOOL)writeXMLDocumentToFile: (NSString*)filePath
                          data: (NSXMLDocument*)xmlDoc{
    
    NSData *xmlData = [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
    
    if(![xmlData writeToFile:filePath atomically:(true)]){
        
        
        return NO;
        
        
    }
    
    return YES;

}

- (BOOL)saveConfig: (NSString *)key
             value: (NSString*)value{
    
    NSString *filePath = @"/Users/apacbuilder/Documents/config.xml";
    
    NSXMLDocument *document = [self createXMLDocumentFromFile:filePath];
    
    NSXMLElement *root = [document rootElement];
    
    
    NSXMLElement *config = [NSXMLElement elementWithName:@"Config"];
    
    if([[root children] count] == 0){
        
        [root addChild:config];
        
    }else{
    
        [root replaceChildAtIndex:0
                             withNode:(NSXMLNode*)config];
        
    }
    
    
    NSXMLNode *keyNode = [NSXMLNode attributeWithName:@"key" stringValue:key];
    
    NSXMLNode *valueNode = [NSXMLNode attributeWithName:@"value" stringValue:value];
    
    [config addAttribute:keyNode];
    
    [config addAttribute:valueNode];
    
    BOOL result = [self writeXMLDocumentToFile:filePath
                                          data:document];
    
    return result;

}

- (BOOL)saveDeviceID: (NSString*)value{
    
    NSString *filePath = @"/Users/apacbuilder/Documents/config.xml";
    
    NSString *key = @"DefaultSaentHWUUID";
    
    NSXMLDocument *document = [self createXMLDocumentFromFile:filePath];
    
    NSXMLElement *root = [document rootElement];
    
    
    NSXMLElement *config = [NSXMLElement elementWithName:@"Config"];
    
    if([[root children] count] == 0){
        
        [root addChild:config];
        
    }else{
        
        [root replaceChildAtIndex:0
                             withNode:(NSXMLNode*)config];
        
    }
    
    NSXMLNode *keyNode = [NSXMLNode attributeWithName:@"key" stringValue:key];
    
    NSXMLNode *valueNode = [NSXMLNode attributeWithName:@"value" stringValue:value];
    
    [config addAttribute:keyNode];
    
    [config addAttribute:valueNode];
    
    BOOL result = [self writeXMLDocumentToFile:filePath
                                          data:document];
    
    return result;
    
}

-  (BOOL)getConfig: (NSString **)key
             value: (NSString **)value{
    
    NSString *filePath = @"/Users/apacbuilder/Documents/config.xml";
    
    NSXMLDocument *document = [self createXMLDocumentFromFile:filePath];
    
    NSArray *children = [[document rootElement] children];
    
    if([children count] == 1){
    
        NSXMLElement *config = [children objectAtIndex:0];
        
        NSXMLNode *keyNode = [config attributeForName:@"key"];
        
        *key = [keyNode stringValue];
        
        NSXMLNode *valueNode = [config attributeForName:@"value"];
        
        *value = [valueNode stringValue];
    
    }

    return NO;

}

-  (NSString*)getDeviceID{
    
    NSString *filePath = @"/Users/apacbuilder/Documents/config.xml";
    
    NSString *deviceID = nil;
    
    NSXMLDocument *document = [self createXMLDocumentFromFile:filePath];
    
    NSArray *children = [[document rootElement] children];
    
    if([children count] == 1){
        
        NSXMLElement *config = [children objectAtIndex:0];
        
        NSXMLNode *valueNode = [config attributeForName:@"value"];
        
        deviceID = [valueNode stringValue];
        
    }
    
    return deviceID;
    
}

- (void)test{
    
    NSString *filePath = @"/Users/apacbuilder/Documents/config.xml";
    
    NSXMLDocument *document = [self createXMLDocumentFromFile:filePath];
    
    NSArray *children = [[document rootElement] children];
    
    NSLog(@"Count child of root: %lu", [children count]);
    
    for(int i = 0; i < [children count]; i++){
        
        NSXMLElement *element = [children objectAtIndex:i];
        
        NSLog(@"%@", [element attributes]);
        
    }
    
    NSXMLElement *currentElement = [children objectAtIndex:0];
    
    NSXMLNode *attribute = [currentElement attributeForName:@"ID"];
    
    NSLog(@"Attribute: %@", attribute);
    
    NSArray *element_level2 = [currentElement children];
    
    for(int i = 0; i < [element_level2 count]; i++){
        
        NSXMLElement *element = [element_level2 objectAtIndex:i];
        
        NSLog(@"%@", [element attributes]);
        
    }
    
    NSError *error = [[NSError alloc] init];
    
    NSArray *nodes = [document nodesForXPath:@"//Peripheral[@ID=99999999999]"
                                       error:&error];
    
    if([nodes count] > 0){
        
        NSXMLNode *foundElement = [nodes objectAtIndex:0];
        
        NSLog(@"Element is found: %@", foundElement);
        
    }
    
    // Add more device
    
    NSXMLElement *root = [document rootElement];
    
    NSXMLElement *peripheral = [NSXMLElement elementWithName:@"Peripheral"];
    
    NSXMLNode *peripheralAttr = [NSXMLNode attributeWithName:@"ID" stringValue:@"888888888"];
    
    [peripheral addAttribute:peripheralAttr];
    
    [root insertChild:peripheral atIndex:0];
    
    
    NSXMLElement *swipeUp = [NSXMLElement elementWithName:@"SwipeUp"];
    
    [swipeUp setStringValue:@"Ctrl+U"];
    
    [peripheral addChild:swipeUp];
    
    
    NSXMLElement *swipeDown = [NSXMLElement elementWithName:@"SwipeDown"];
    
    [swipeDown setStringValue:@"Ctrl+D"];
    
    [peripheral addChild:swipeDown];
    
    
    NSXMLElement *swipeLeft = [NSXMLElement elementWithName:@"SwipeLeft"];
    
    [swipeLeft setStringValue:@"Ctrl+L"];
    
    [peripheral addChild:swipeLeft];
    
    
    NSXMLElement *swipeRight = [NSXMLElement elementWithName:@"SwipeRight"];
    
    [swipeRight setStringValue:@"Ctrl+R"];
    
    [peripheral addChild:swipeRight];
    
    NSData *xmlData = [document XMLDataWithOptions:NSXMLNodePrettyPrint];
    
    if([xmlData writeToFile:filePath atomically:(true)]){
        
        
        NSLog(@"Write successfully");
        
        
    }else{
        
        NSLog(@"Write fail");
        
    }

}

@end
