set top { clk reset }
set xcpt { brisc_core.xcpt_D brisc_core.xcpt_A }
set stall { brisc_core.stall_F 
            brisc_core.stall_D 
            brisc_core.stall_A 
            brisc_core.stall_C 
            brisc_core.flush_D 
            brisc_core.flush_A
            brisc_core.flush_WB
          }
set fetch { brisc_core.pc_F
            brisc_core.instr_F
          }
set core {
            brisc_core.igrant
            brisc_core.dgrant
            mem_req.valid
            mem_req.rw
            mem_req.addr
            mem_req.data
            mem_resp.valid
            mem_resp.addr
            mem_resp.data
          }
set icache {
                 brisc_core.fetch.icache.cache_unit.cache_sets_q[0].valid
                 brisc_core.fetch.icache.cache_unit.cache_sets_q[0].dirty
                 brisc_core.fetch.icache.cache_unit.cache_sets_q[0].data
                 brisc_core.fetch.icache.cache_unit.cache_sets_q[1].valid
                 brisc_core.fetch.icache.cache_unit.cache_sets_q[1].dirty
                 brisc_core.fetch.icache.cache_unit.cache_sets_q[1].data
                 brisc_core.fetch.icache.cache_unit.cache_sets_q[2].valid
                 brisc_core.fetch.icache.cache_unit.cache_sets_q[2].dirty
                 brisc_core.fetch.icache.cache_unit.cache_sets_q[2].data
                 brisc_core.fetch.icache.cache_unit.cache_sets_q[3].valid
                 brisc_core.fetch.icache.cache_unit.cache_sets_q[3].dirty
                 brisc_core.fetch.icache.cache_unit.cache_sets_q[3].data
            }
set dcache { 
                 brisc_core.cache.dcache.cache_unit.cache_sets_q[0].valid
                 brisc_core.cache.dcache.cache_unit.cache_sets_q[0].dirty
                 brisc_core.cache.dcache.cache_unit.cache_sets_q[0].data
                 brisc_core.cache.dcache.cache_unit.cache_sets_q[1].valid
                 brisc_core.cache.dcache.cache_unit.cache_sets_q[1].dirty
                 brisc_core.cache.dcache.cache_unit.cache_sets_q[1].data
                 brisc_core.cache.dcache.cache_unit.cache_sets_q[2].valid
                 brisc_core.cache.dcache.cache_unit.cache_sets_q[2].dirty
                 brisc_core.cache.dcache.cache_unit.cache_sets_q[2].data
                 brisc_core.cache.dcache.cache_unit.cache_sets_q[3].valid
                 brisc_core.cache.dcache.cache_unit.cache_sets_q[3].dirty
                 brisc_core.cache.dcache.cache_unit.cache_sets_q[3].data
            }

set stb { 
                 brisc_core.cache.stb.entries_q[0].valid
                 brisc_core.cache.stb.entries_q[0].addr
                 brisc_core.cache.stb.entries_q[0].data
                 brisc_core.cache.stb.entries_q[1].valid
                 brisc_core.cache.stb.entries_q[1].addr
                 brisc_core.cache.stb.entries_q[1].data
                 brisc_core.cache.stb.entries_q[2].valid
                 brisc_core.cache.stb.entries_q[2].addr
                 brisc_core.cache.stb.entries_q[2].data
                 brisc_core.cache.stb.entries_q[3].valid
                 brisc_core.cache.stb.entries_q[3].addr
                 brisc_core.cache.stb.entries_q[3].data
            }

set alu { 
                 brisc_core.alu.src1
                 brisc_core.alu.src2
                 brisc_core.alu_res_A
        }

proc addSignals {signals color prefix} {
    set i 0
    foreach sig $signals  {
        set sufix [split $sig .]
        set sufix [lindex $sufix end]
        gtkwave::addSignalsFromList $sig
        gtkwave::/Edit/Color_Format/$color
        gtkwave::highlightSignalsFromList $sig
        gtkwave::/Edit/Alias_Highlighted_Trace $prefix\_$sufix\_$i
        gtkwave::/Edit/UnHighlight_All $prefix\_$sufix\_$i
        if {$sufix == "data"} {
            incr i
        }
    }
}

proc prettifySignal {signal color alias} {
  gtkwave::addSignalsFromList $signal
  gtkwave::/Edit/Color_Format/$color
  gtkwave::highlightSignalsFromList $signal
  gtkwave::/Edit/Alias_Highlighted_Trace $alias
  gtkwave::/Edit/UnHighlight_All $alias
}

# Set view
gtkwave::nop
# show long name
#gtkwave::/Edit/Set_Trace_Max_Hier 0
gtkwave::/View/Show_Filled_High_Values 1
gtkwave::/View/Show_Wave_Highlight 1
gtkwave::/Time/Zoom/Zoom_Best_Fit
gtkwave::/Edit/UnHighlight_All


# Adding signals
gtkwave::addSignalsFromList $top
gtkwave::/Edit/Color_Format/Indigo

gtkwave::addSignalsFromList $fetch
gtkwave::/Edit/Color_Format/Yellow

gtkwave::addSignalsFromList $core
gtkwave::/Edit/Color_Format/Violet

gtkwave::addSignalsFromList $alu
gtkwave::/Edit/Color_Format/Blue

gtkwave::addSignalsFromList $stall
gtkwave::/Edit/Color_Format/Red

gtkwave::addSignalsFromList $xcpt
gtkwave::/Edit/Color_Format/Red

prettifySignal brisc_core.fetch.icache.state_q Violet icache_state
addSignals $icache Orange icache_line
prettifySignal brisc_core.cache.dcache.state_q Violet dcache_state
addSignals $dcache Violet dcache_line
addSignals $stb Yellow stb_entry

set regColor Orange

set registers {{10 a0} {11 a1} {12 a2} {13 a3} {14 a4} {5 t0} {6 t1} {7 t2} {28 t3} {29 t4} {30 t5} {31 t6}}


foreach reg $registers {
  prettifySignal brisc_core.decode.rfile.regs_n\[[lindex $reg 0]\] $regColor [lindex $reg 1]
}

for {set i 4096} {$i < 4353} {incr i} {
  prettifySignal mem.datas_q\[$i\] Blue mem_data_$i
}
