namespace eval mdio {} {
variable phy_addr 0x3

proc config_mdio {} {
variable phy_addr
#  Write 0x4000 to SGMIICTL1 (0x00D3) to Enable differential SGMII clock to MAC.
	wmdio $phy_addr 0x0D 0x001F
	wmdio $phy_addr 0x0E 0x00D3
	wmdio $phy_addr 0x0D 0x401F
	wmdio $phy_addr 0x0E 0x4000
# Initialize MDIO(optional)
        # Reset phy
	####wmdio $phy_addr 0x0 0x8000
        # Enable autonegotiation
	wmdio $phy_addr 0x0 0x1000
        ####after 100
        # 1000 Mbps without autonegotiation
	# wmdio $phy_addr 0x0 0x140
        # 100 Mbps without autonegotiation
	# wmdio $phy_addr 0x0 0x2100
        # 10 Mbps without autonegotiation
	# wmdio $phy_addr 0x0 0x0100

# Enabling SGMII autonegotiation and speed optimiztion(optional)
	wmdio $phy_addr 0x14 0x2BC0
#  Write 0x0070 to CFG4 (0x0031) to set SGMII Auto-Negotiation Timer Duration as 11 ms
	wmdio $phy_addr 0x0D 0x001F
	wmdio $phy_addr 0x0E 0x0031
	wmdio $phy_addr 0x0D 0x401F
	####wmdio $phy_addr 0x0E 0x0160
	wmdio $phy_addr 0x0E 0x0070
#  Write 0x0 to RGMIICTL (0x0032) to set Disable RGMII
	wmdio $phy_addr 0x0D 0x001F
	wmdio $phy_addr 0x0E 0x0032
	wmdio $phy_addr 0x0D 0x401F
	wmdio $phy_addr 0x0E 0x0

}

proc check_link {} {
variable phy_addr
	set stat [silent mdio $phy_addr 0x5 greth0]
	puts [format "Phy status : 0x%08x " $stat] 
}

proc read_mdio {} {
variable phy_addr
	mdio info dev0 $phy_addr
	mdio reg greth0 $phy_addr
}

proc test {} {
        # User can use the following command to set the EDCL IP to any desired IP in the local Ethernet network
	#edcl 192.168.100.237
	read_mdio
	config_mdio
	check_link
	read_mdio
}

}
mdio::test
info reg -all -v greth0
puts "Wait until the phy init is completed..."
after 500
puts "Now reset the sgmii by pushing switch 3 of SW12 switch-set on the vcu118 board, from 0 to 1"
puts "WAIT FOR FEW SECONDS and change the switch 3 of SW12 switch-set on the vcu118 board, back : 1 to 0"


