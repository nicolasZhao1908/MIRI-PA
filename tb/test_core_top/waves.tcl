set top [list clk reset]
set fetch [list brisc_core.pc_F brisc_core.instr_F brisc_core.fetch.mem_req_out brisc_core.fetch.mem_req_addr]
set icache [list brisc_core.grant_icache\
                 brisc_core.fetch.icache.cache_unit.cache_sets_q\[0\].data\
                 brisc_core.fetch.icache.cache_unit.cache_sets_q\[1\].data\
                 brisc_core.fetch.icache.cache_unit.cache_sets_q\[2\].data\
                 brisc_core.fetch.icache.cache_unit.cache_sets_q\[3\].data\
                 ]
set dcache [list brisc_core.grant_dcache\
                 brisc_core.cache.dcache.cache_unit.cache_sets_q\[0\].data\
                 brisc_core.cache.dcache.cache_unit.cache_sets_q\[1\].data\
                 brisc_core.cache.dcache.cache_unit.cache_sets_q\[2\].data\
                 brisc_core.cache.dcache.cache_unit.cache_sets_q\[3\].data\
                 ]
set mem [list mem.fill mem.fill_addr mem.fill_data]

# Set view
gtkwave::nop
gtkwave::/Edit/Set_Trace_Max_Hier 0
gtkwave::/View/Show_Filled_High_Values 1
gtkwave::/View/Show_Wave_Highlight 1
gtkwave::/View/Show_Mouseover 1
gtkwave::/Time/Zoom/Zoom_Best_Fit

# Adding signals
gtkwave::addSignalsFromList $top
gtkwave::/Edit/Color_Format/Indigo

gtkwave::addSignalsFromList $fetch
gtkwave::/Edit/Color_Format/Red

gtkwave::addSignalsFromList $icache
gtkwave::/Edit/Color_Format/Orange

gtkwave::addSignalsFromList $dcache
gtkwave::/Edit/Color_Format/Violet

gtkwave::addSignalsFromList $mem
gtkwave::/Edit/Color_Format/Green