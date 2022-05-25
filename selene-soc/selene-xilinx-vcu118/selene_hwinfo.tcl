proc get_HwInfo { adr } {
    set str ""
    set dsc [silent mem [expr {$adr}] 4]
    set ptr [silent mem [expr {$adr + 4}] 4]
    if {$dsc != 0x0} {
        set dev_type     [expr ($dsc)&0xF]
        set dev_version  [expr ($dsc>>4)&0xF]
        set dev_id       [expr ($dsc>>8)&0xF]
        set dev_features [expr ($dsc>>12)&0xFFFFF]
        append str "\nDevice at ADR: $ptr"
        append str "\n\tID:      $dev_id"
        
        if { $dev_type == 0x2 } {
            set MaxDasets [expr ($dev_features)&0x1F]
            set ListFailures [expr ($dev_features>>5)&0x1]
            set ListMatches [expr ($dev_features>>6)&0x1]
            set CountMatches [expr ($dev_features>>7)&0x1]
            append str "\n\tType:    RootVoter"
            append str "\n\tVersion: $dev_version"           
            append str "\n\tMax Datasets:             $MaxDasets"
            append str "\n\tDetection of Data Errors: $ListFailures"
            append str "\n\tTracking of Match Pairs:  $ListMatches"
            append str "\n\tCount Matches:            $CountMatches"                                 
        } elseif { $dev_type == 0x1 } {
            append str "\n\tType:    HLSinf Accelerator core"
            append str "\n\tVersion: $dev_version" 
            if {  $dev_version == 10} {
                append str "\n\tFeatures: U200, 4x4, FP32: DIRECT_CONV, RELU, STM, CLIPPING, POOLING, BATCH_NORM, ADD, UPSIZE"
            } elseif {$dev_version == 11} {
                append str "\n\tFeatures: U200, 8x8, MIXED PRECISSION: DIRECT_CONV, RELU, CLIPPING, SHIFT, POOLING, BN, ADD, UPSIZE"
            } elseif {$dev_version == 12} {
                append str "\n\tFeatures: U200, 16x8, MIXED PRECISSION: DIRECT_CONV, RELU, CLIPPING, SHIFT, POOLING, BN, ADD, UPSIZE"
            } elseif {$dev_version == 13} {
                append str "\n\tFeatures: U200, 8x4, FP32: DIRECT_CONV, RELU, STM, CLIPPING, POOLING, BATCH_NORM, ADD, UPSIZE"
            } else {
                append str "\n\tUnknown Version"
            } 
        } elseif { $dev_type == 0x3 } {
            set Crossbar_in [expr ($dev_features>>8)&0x1FF]
            set Counters [expr ($dev_features)&0x1F]
            append str "\n\tType:    SafeSU, statistics unit"
            append str "\n\tVersion: $dev_version" 
            append str "\n\tCounters: $Counters" 
            append str "\n\tCrossbar inputs: $Crossbar_in" 
            if {  $dev_version == 0} {
                append str "\n\tFeatures:CROSSBAR, COUNTERS, OVERFLOW, MCCU" 
            } else {
                append str "\n\tUnknown Version"
            } 
        } else {
            #NEW CORES
            #append new rules to parse core-specific HW feratures for other dev_types
            append str "\n\tType:    $dev_type (Unknown device)"
            append str "\n\tVersion: $dev_version"            
        }
    }
    return $str
}

proc list_selene_cores { } {
    set str ""
    set AxiRomBaseAdr 0xFFFC0700
    set SyncWord [silent mem [expr {$AxiRomBaseAdr}] 4]
    if { $SyncWord == 0xAACC5577 } {
        for {set i 1} {$i < 16} {incr i} {
            append str [get_HwInfo [expr $AxiRomBaseAdr + ($i*8)]]
        }
    } else {
        append str "\nHWInfo ROM not present in this SoC"
    }

    return $str
}

