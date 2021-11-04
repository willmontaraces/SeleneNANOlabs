###############################################################################
#  This file was developed as part of H2020 SELENE project.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
###############################################################################

# Convert an integer value to 32 bit hexadecimal string.
# Example: tohex32 1 -> 0x00000001
proc tohex32 {n} {
   set n [expr {$n & 0xffffffff}]
   format "0x%08x" $n
} 


proc test_spw {} {

    puts "**************************"
    puts "Simple test of two spw IPs"
    puts "**************************"

    set base_0 0xfc000600
    set base_1 0xfc000700

    wmem $base_0 0 0 0 0
    wmem $base_1 0 0 0 0

    set base_00 0xfc000604
    set base_11 0xfc000704

    wmem $base_0 0 0 0 0
    wmem $base_1 0 0 0 0

    puts "Reset grspw IPs"

    set grspw0::ctrl::reset 1
    set grspw1::ctrl::reset 1

    puts "Status register"
    puts "Link State : 2 = READY,"
    puts "             5 = RUN"
    info reg -v 0xfc000604
    info reg -v 0xfc000704

    puts "__Configure IPs__"

    #Configuring Clock divisor startup and run
    #clkdivstart = clkdivrun = [(frequency in MHz of TXCLK = System Clk here = 100 MHz)/(link-rate in Mbits/s = 10 Mbits/s here)] - 1
    set grspw0::clkdiv::clkdivstart 9
    set grspw1::clkdiv::clkdivstart 9


    set grspw0::clkdiv::clkdivrun 9
    set grspw1::clkdiv::clkdivrun 9
    

    #Enable Autostart
    set grspw0::ctrl::as 1
    set grspw1::ctrl::as 1

    #Enable Link Start
    set grspw0::ctrl::ls 1
    set grspw1::ctrl::ls 1

    puts "Control register after configuration"
    info reg -v 0xfc000600
    info reg -v 0xfc000700

    puts "Status register to get the link run state"
    puts "Link State : 2 = READY,"
    puts "             5 = RUN"
    info reg -v 0xfc000604
    info reg -v 0xfc000704
    

}
