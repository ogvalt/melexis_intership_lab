onbreak resume
onerror resume
vsim -novopt work.filter_tb
add wave sim:/filter_tb/u_bandpass_filter/clk
add wave sim:/filter_tb/u_bandpass_filter/clk_enable
add wave sim:/filter_tb/u_bandpass_filter/reset
add wave sim:/filter_tb/u_bandpass_filter/filter_in
add wave sim:/filter_tb/u_bandpass_filter/filter_out
add wave sim:/filter_tb/filter_out_ref
run -all
