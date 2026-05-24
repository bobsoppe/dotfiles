# Pure prompt: skip slow container probe; show k8s context with `|` separator; show clock.
set --export pure_enable_container_detection false
set --export pure_enable_k8s                 true
set --export pure_symbol_k8s_prefix          "|"
set --export pure_show_system_time           true
