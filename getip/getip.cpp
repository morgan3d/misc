/**
 @file getip.cpp

 @author Morgan McGuire, morgan@cs.williams.edu
 @date   November 2008
 
 Enumerates the "interfaces" on a Unix (e.g. OS X, Linux, FreeBSD)
 system.  This includes what we consider to be the Ethernet and
 Wireless adapters.

 This code will:

 - get the IP address
 - get the broadcast address
 - get the subnet mask

 and print them for all such devices.  This is similar functionality
 to the Unix program ifconfig.  The purpose of this program is to
 demonstrate how to access that functionality within a C program.

 */
#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <netinet/in.h>
#include <net/if.h>
#ifdef __linux__
#    include <sys/ioctl.h>
#    include <netinet/in.h>
#    include <unistd.h>
#    include <string.h>

//    Match Linux to FreeBSD
#    define AF_LINK AF_PACKET
#else
#    include <net/if_dl.h>
#endif

#include <stdio.h>
#include <stdlib.h>

const sockaddr_in* castToIP4(const sockaddr* addr) {
    if (addr == NULL) {
        return NULL;
    } else if (addr->sa_family == AF_INET) {
        // An IPv4 address
        return reinterpret_cast<const sockaddr_in*>(addr);
    } else {
        // Not an IPv4 address
        return NULL;
    }
}


/** Assumes addr is in host byte order */
void printIP(const char* name, int addr) {
    printf("%s = %3d.%3d.%3d.%3d\n", name, (addr >> 24) & 0xFF, (addr >> 16) & 0xFF,
           (addr >> 8) & 0xFF, addr & 0xFF);
}


void printIP(const char* name, const sockaddr_in* addr) {
    if (addr != NULL) {
        printIP(name, ntohl(addr->sin_addr.s_addr));
    } 
}

const char* levelToString(int level) {
    switch(level) {
    case AF_INET:
        return "Internet (AF_INET)";

    case AF_LINK:
        return "Link (AF_LINK/AF_PACKET)";
    default:
        return "Other";
    }
}

int main(int argc, const char** argv) {
    // Head of the interface address linked list
    ifaddrs* ifap = NULL;

    int r = getifaddrs(&ifap);

    if (r != 0) {
        // Non-zero return code means an error
        printf("return code = %d\n", r);
        exit(r);
    }

    ifaddrs* current = ifap;

    if (current == NULL) {
        printf("No interfaces found\n");
    }

    while (current != NULL) {

        const sockaddr_in* interfaceAddress = castToIP4(current->ifa_addr);
        const sockaddr_in* broadcastAddress = castToIP4(current->ifa_dstaddr);
        const sockaddr_in* subnetMask       = castToIP4(current->ifa_netmask);

        printf("Interface %s", current->ifa_name);
        if (current->ifa_addr != NULL) {
            printf(" %s", levelToString(current->ifa_addr->sa_family));
        }
        printf("\nStatus    = %s\n", (current->ifa_flags & IFF_UP) ? "Online" : "Down");
        printIP("IP       ", interfaceAddress);
        printIP("Broadcast", broadcastAddress);
        printIP("Subnet   ", subnetMask);
        
        // The MAC address and the interfaceAddress come in as
        // different interfaces with the same name.

        if ((current->ifa_addr != NULL) && (current->ifa_addr->sa_family == AF_LINK)) {
#           ifdef __linux__
            // Linux
            struct ifreq ifr;

            int fd = socket(AF_INET, SOCK_DGRAM, 0);

            ifr.ifr_addr.sa_family = AF_INET;
            strcpy(ifr.ifr_name, current->ifa_name);
            ioctl(fd, SIOCGIFHWADDR, &ifr);
            close(fd);

            uint8_t* MAC = reinterpret_cast<uint8_t*>(ifr.ifr_hwaddr.sa_data);
            
#else
            // Posix/FreeBSD/Mac OS
            sockaddr_dl* sdl = (struct sockaddr_dl *)current->ifa_addr;
            uint8_t* MAC = reinterpret_cast<uint8_t*>(LLADDR(sdl));
#endif
            printf("MAC       = %02x:%02x:%02x:%02x:%02x:%02x\n", MAC[0], MAC[1], MAC[2], MAC[3], MAC[4], MAC[5]);
        }
        
        printf("\n");
    
        current = current->ifa_next;
    }

    freeifaddrs(ifap);
    ifap = NULL;

    return 0;
}
