//
//  GCJLog.swift
//  Project 04 - Calculator
//
//  Created by 龚晨杰 on 2019/11/27.
//  Copyright © 2019 Jiong. All rights reserved.
//

import Foundation


func GLog<T>(_ message: T,
                 file: String = #file,
                 method: String = #function,
                 line: Int = #line,
                 lineChgMark: String = " >>>\n    >>> ")
{
    let logMessage = """
    \((file as NSString).lastPathComponent)\
    [\(line)],\
    \(method)\
    \(lineChgMark)\
    \(message)
    """
    print(logMessage)

}


