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


proc test_grcan {} {

    puts "*********************************"
    puts "Simple test for two grcanfd IPs connected to the same bus"
    puts "*********************************"

    set base_rx0 0x00000000
    set base_tx0 [expr $base_rx0 + 0x1000]
    set base_rx1 [expr $base_rx0 + 0x2000]
    set base_tx1 [expr $base_rx0 + 0x3000]

    wmem $base_rx0 0 0 0 0
    wmem $base_tx0 0 0 0 0

    wmem $base_rx1 0 0 0 0
    wmem $base_tx1 0 0 0 0

    puts "Reset grcanfd IPs"

    set grcanfd0::ctrl::reset 1
    set grcanfd1::ctrl::reset 1

    puts "Configure IPs"

    set grcanfd0::cfg::abort 1
    set grcanfd1::cfg::abort 1

    #set 1Mbps Nominal bit rate for a 100 MHz clk
    set grcanfd0::nombtr::scaler 9
    set grcanfd1::nombtr::scaler 9
    set grcanfd0::nombtr::ps1 4
    set grcanfd1::nombtr::ps1 4
    set grcanfd0::nombtr::ps2 5
    set grcanfd1::nombtr::ps2 5
    set grcanfd0::nombtr::sjw 3
    set grcanfd1::nombtr::sjw 3

    set grcanfd0::fdbtr::scaler 9
    set grcanfd1::fdbtr::scaler 9
    set grcanfd0::fdbtr::ps1 4
    set grcanfd1::fdbtr::ps1 4
    set grcanfd0::fdbtr::ps2 5
    set grcanfd1::fdbtr::ps2 5
    set grcanfd0::fdbtr::sjw 3
    set grcanfd1::fdbtr::sjw 3

    set grcanfd0::cfg::enable0 1
    set grcanfd1::cfg::enable0 1
    

    ##Enable Codec
    set grcanfd0::ctrl::enable 1 
    set grcanfd1::ctrl::enable 1 


    #Set RX buffer size to 16 descriptors
    set grcanfd0::rx_size::size 4
    set grcanfd1::rx_size::size 4
    #Set RX buffer base address
    set grcanfd0::rx_addr $base_rx0
    set grcanfd1::rx_addr $base_rx1
    #Set RX MASK to all zeroes to receive any frame
    set grcanfd0::rx_mask 0
    set grcanfd1::rx_mask 0
    #Enable RX channel
    set grcanfd0::rx_ctrl::enable 1
    set grcanfd1::rx_ctrl::enable 1

    #Set TX buffer size to 16 descriptors
    set grcanfd0::tx_size::size 4
    set grcanfd1::tx_size::size 4
    #Set TX buffer base address
    set grcanfd0::tx_addr $base_tx0
    set grcanfd1::tx_addr $base_tx1

    #Enable TX channel
    set grcanfd0::tx_ctrl::single 1
    set grcanfd0::tx_ctrl::enable 1
    set grcanfd1::tx_ctrl::enable 1

    #Unmask all interrupts
    set grcanfd0::irq -1
    set grcanfd1::irq -1

    #Write 4 frames in the circular buffer of grcanfd0
    set addr $base_tx0

    #Set descriptor for a standard can frame with DLC=8
    set txdata0 0x00000000
    set txdata1 0x80000000
    set txdata2 0x00010203
    set txdata3 0x04050607


    for {set i 0} {$i < 4} {incr i} {
	#IDE=0 #RTR=0
	wmem $addr $txdata0;
	incr addr 4
	#DLC=8
	wmem $addr $txdata1;
	incr addr 4

	wmem $addr $txdata2;
	incr addr 4

	wmem $addr $txdata3;
	incr addr 4
    }

    puts "Sending a FRAME from grcanfd0 to grcanfd1"
    set grcanfd0::tx_write::write 1

    after 1000


    set rxdata0 [tohex32 [silent mem $base_rx1 4] ]
    set rxdata1 [tohex32 [silent mem [expr  $base_rx1 +4 ] 4] ]
    set rxdata2 [tohex32 [silent mem [expr  $base_rx1 +8 ] 4] ]
    set rxdata3 [tohex32 [silent mem [expr  $base_rx1 +12 ] 4] ]
    if {$rxdata0 == $txdata0 & $rxdata1 == $txdata1 & $rxdata2 == $txdata2 & $rxdata3 == $txdata3} {
	puts "Received and transmitted data match\n"
    } else {
	puts "Received and transmitted data do not match.\n"
	puts "RXDATA: $rxdata0 $rxdata1 $rxdata2 $rxdata3"
	puts "TXDATA: $txdata0 $txdata1 $txdata2 $txdata3"
    }

    #Write 4 frames in the circular buffer of grcanfd1
    set addr $base_tx1

    #Set descriptor for a standard can frame with DLC=8
    set txdata0 0x00000000
    set txdata1 0x80000000
    set txdata2 0x00010203
    set txdata3 0x04050607

    for {set i 0} {$i < 4} {incr i} {
	#IDE=0 #RTR=0
	wmem $addr $txdata0;
	incr addr 4
	#DLC=8
	wmem $addr $txdata1;
	incr addr 4

	wmem $addr $txdata2;
	incr addr 4

	wmem $addr $txdata3;
	incr addr 4
    }

    puts "Sending a FRAME from grcanfd1 to grcanfd0"
    set grcanfd1::tx_write::write 1

    after 1000
    
    set rxdata0 0
    set rxdata1 0
    set rxdata2 0
    set rxdata3 0

    set rxdata0 [tohex32 [silent mem $base_rx0 4] ]
    set rxdata1 [tohex32 [silent mem [expr  $base_rx0 +4 ] 4]  ]
    set rxdata2 [tohex32 [silent mem [expr  $base_rx0 +8 ] 4]  ]
    set rxdata3 [tohex32 [silent mem [expr  $base_rx0 +12 ] 4] ]
    if {$rxdata0 == $txdata0 & $rxdata1 == $txdata1 & $rxdata2 == $txdata2 & $rxdata3 == $txdata3} {
	puts "Received and transmitted data match\n"
    } else {
	puts "Received and transmitted data do not match.\n"
	puts "RXDATA: $rxdata0 $rxdata1 $rxdata2 $rxdata3"
	puts "TXDATA: $txdata0 $txdata1 $txdata2 $txdata3"
    }

}
