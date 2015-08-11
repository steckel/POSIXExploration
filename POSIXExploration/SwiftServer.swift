//
//  SwiftServer.swift
//  POSIXExploration
//
//  Created by Curtis Steckel on 2015-10-02.
//  Copyright (c) 2015 Curtis Steckel. All rights reserved.
//

import CoreFoundation

// MARK: Halp

func sockaddr_cast(p: UnsafePointer<sockaddr_in>) -> UnsafePointer<sockaddr> {
  return UnsafePointer<sockaddr>(p)
}

func sockaddr_cast_m(p: UnsafePointer<sockaddr_in>) -> UnsafeMutablePointer<sockaddr> {
  return UnsafeMutablePointer<sockaddr>(p)
}

let INADDR_ANY = UInt32(0x00000000) // INADDR_ANY = (u_int32_t)0x00000000 ----- <netinet/in.h>

class SwiftServer {
  static func start(portNumber: UInt16) {
    let sockfd = socket(AF_INET, SOCK_STREAM, 0)
    precondition(sockfd >= 0, "ERROR opening socket")
    println("sockfd: \(sockfd)")

    var serv_addr = sockaddr_in()
    serv_addr.sin_family = sa_family_t(AF_INET)
    serv_addr.sin_addr.s_addr = INADDR_ANY
    serv_addr.sin_port = in_port_t(portNumber.bigEndian)

    var binded = bind(sockfd, sockaddr_cast(&serv_addr), socklen_t(sizeof(sockaddr_in)))
    precondition(binded >= 0, "ERROR on binding")
    println("binded: \(binded)")
    listen(sockfd,5)
    var cli_addr = sockaddr_in()
    var cli_len = socklen_t(sizeof(sockaddr_in))

    while true {
      var newsockfd = accept(sockfd, sockaddr_cast_m(&cli_addr), &cli_len)
      precondition(newsockfd >= 0, "ERROR on accept")
      println("newsockfd: \(newsockfd)")

      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
        var buffer: Array<CChar> = Array(count: 256, repeatedValue: 0)
        var n = read(newsockfd, &buffer, 255)
        precondition(n >= 0, "ERROR reading from socket")

        println("------------------------------------------")
        println("n: \(n)")
        println("Here is the message: \n")
        println(String.fromCString(buffer)!)

        // let message = "Requests fulfilled: \(requestsFulfilled)";
        let message = "Hello World"
        n = write(newsockfd, message, count(message))
        precondition(n >= 0, "ERROR writing to socket")
        close(newsockfd)
      }
    }

    close(sockfd)
  }
}

