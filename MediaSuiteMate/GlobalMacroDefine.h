//
//  GlobalMacroDefine.h
//  MediaSuiteMate
//
//  Created by derek on 21/10/15.
//  Copyright © 2015 derek. All rights reserved.
//

#ifndef GlobalMacroDefine_h
#define GlobalMacroDefine_h

#define NSLocalizedString(key, comment) [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]

#define isNSNull(value) [value isKindOfClass:[NSNull class]]

#endif /* GlobalMacroDefine_h */
