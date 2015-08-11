//
//  CServer.c
//  POSIXExploration
//
//  Created by Curtis Steckel on 2015-10-02.
//  Copyright (c) 2015 Curtis Steckel. All rights reserved.
//

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#include "CServer.h"

void dostuff(int); /* function prototype */

void error(const char *msg)
{
  perror(msg);
  exit(1);
}

void c_server_start(int portno)
{
  signal(SIGCHLD,SIG_IGN);

  int sockfd, newsockfd, pid;
  socklen_t clilen;
  struct sockaddr_in serv_addr, cli_addr;

  // if (argc < 2) {
  //   fprintf(stderr,"ERROR, no port provided\n");
  //   exit(1);
  // }
  sockfd = socket(AF_INET, SOCK_STREAM, 0);
  if (sockfd < 0)
    error("ERROR opening socket");
  bzero((char *) &serv_addr, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = INADDR_ANY;
  serv_addr.sin_port = htons(portno);
  if (bind(sockfd, (struct sockaddr *) &serv_addr,
           sizeof(serv_addr)) < 0)
    error("ERROR on binding");
  listen(sockfd,5);
  clilen = sizeof(cli_addr);
  while (1) {
    newsockfd = accept(sockfd,
                       (struct sockaddr *) &cli_addr, &clilen);
    if (newsockfd < 0)
      error("ERROR on accept");
    pid = fork();
    if (pid < 0)
      error("ERROR on fork");
    if (pid == 0)  {
      close(sockfd);
      dostuff(newsockfd);
      exit(0);
    }
    else close(newsockfd);
  } /* end of while */
  close(sockfd);
}

/******** DOSTUFF() *********************
 There is a separate instance of this function
 for each connection.  It handles all communication
 once a connnection has been established.
 *****************************************/
void dostuff (int sock)
{
  int n;
  char buffer[256];

  bzero(buffer,256);
  n = read(sock,buffer,255);
  if (n < 0) error("ERROR reading from socket");
  printf("Here is the message: %s\n",buffer);
  n = write(sock,"I got your message",18);
  if (n < 0) error("ERROR writing to socket");
}