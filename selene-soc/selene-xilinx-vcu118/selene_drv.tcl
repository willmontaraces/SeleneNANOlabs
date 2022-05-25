

namespace eval drivers::ahbdrv {
    # These variables are required
    variable vendor 0x1
    variable device 0x09F
    variable version_min 1
    variable version_max 1
    variable description "AMBA AHB/AXI Bridge"

    source selene_hwinfo.tcl

    proc info devname {
        if {$devname == "ahbdrv1"} {
            set str "SELENE-specific cores implemented in this SoC"
            append str [list_selene_cores]
            return $str
        
        }
    }



}; 