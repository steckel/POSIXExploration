//
//  main.swift
//  POSIXExploration
//
//  Created by Curtis Steckel on 2015-10-02.
//  Copyright (c) 2015 Curtis Steckel. All rights reserved.
//

import Foundation

// MARK: "Example" Code
precondition(Process.argc == 2, "ERROR, no port provided\n")
let portno = Process.arguments[1].toInt()!

SwiftServer.start(UInt16(portno))

// c_server_start(Int32(portno))