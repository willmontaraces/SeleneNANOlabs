

proc get_RVC_info { adr } {
    set HWInfo [silent mem [expr {$adr + 0x98}] 4]
    set ID [expr ($HWInfo>>8)&0xF]
    set Version [expr ($HWInfo>>20)&0xF]
    set MaxDasets [expr ($HWInfo>>12)&0xF]
    set ListFailures [expr ($HWInfo>>17)&0x1]
    set ListMatches [expr ($HWInfo>>18)&0x1]
    set CountMatches [expr ($HWInfo>>19)&0x1]
    set FSMState [expr ($HWInfo>>0)&0x1F]
    set STATEDICT [dict create 1 "IDLE" 2 "WAIT FOR DATASETS" 4 "VOTING" 8 "TIMEOUT" 16 "RESULT"]
    
    puts [format "RootVoter at address: %s\n\tID: %s\n\tVersion: %s\n\tMax Daset Registers: %s\n\tSTATE: %s" \
        $adr $ID $Version $MaxDasets [dict get $STATEDICT $FSMState]]
    puts [format "\tDetection of DSC failures: %s\n\tCounting number of matches: %s\n\tTracking of match pairs: %s" \
        $ListFailures $CountMatches $ListMatches ]     
    
}

proc get_HLSinf_info { adr } {
    set Status [silent mem [expr {$adr + 0x0}] 1]
    set ap_start [expr ($Status>>0)&0x1]
    set ap_done  [expr ($Status>>1)&0x1]
    set ap_idle  [expr ($Status>>2)&0x1]
    set ap_ready [expr ($Status>>3)&0x1]
    set ap_continue [expr ($Status>>4)&0x1]
    set auto_restart [expr ($Status>>7)&0x1]
    set HSL_active [expr ($ap_start | $ap_done | $ap_idle | $ap_ready | $ap_continue | $auto_restart) ]
    
    if { $HSL_active == 0x1 }  {
        puts "HLSinf core present at the addess: $adr"
    
    } else {
        puts "HLSinf core NOT found at the address: $adr"
    }
}


source selene_hwinfo.tcl



proc info_selene { } {
    info sys
    puts [list_selene_cores]

    #get_HLSinf_info 0xFFFC0000
    #get_RVC_info 0xFFFC0100
    #get_RVC_info 0xFFFC0200
    #get_RVC_info 0xFFFC0300
    #get_RVC_info 0xFFFC0400
}


