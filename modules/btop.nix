{ ... }:

let
  btopTheme = ''
    # Theme: tokyo-night
    # By: Pascal Jaeger

    # Main bg
    theme[main_bg]="#1a1b26"

    # Main text color
    theme[main_fg]="#cfc9c2"

    # Title color for boxes
    theme[title]="#cfc9c2"

    # Highlight color for keyboard shortcuts
    theme[hi_fg]="#7dcfff"

    # Background color of selected item in processes box
    theme[selected_bg]="#414868"

    # Foreground color of selected item in processes box
    theme[selected_fg]="#cfc9c2"

    # Color of inactive/disabled text
    theme[inactive_fg]="#565f89"

    # Misc colors for processes box including mini cpu graphs, details memory graph and details status text
    theme[proc_misc]="#7dcfff"

    # Cpu box outline color
    theme[cpu_box]="#565f89"

    # Memory/disks box outline color
    theme[mem_box]="#565f89"

    # Net up/down box outline color
    theme[net_box]="#565f89"

    # Processes box outline color
    theme[proc_box]="#565f89"

    # Box divider line and small boxes line color
    theme[div_line]="#565f89"

    # Temperature graph colors
    theme[temp_start]="#9ece6a"
    theme[temp_mid]="#e0af68"
    theme[temp_end]="#f7768e"

    # CPU graph colors
    theme[cpu_start]="#9ece6a"
    theme[cpu_mid]="#e0af68"
    theme[cpu_end]="#f7768e"

    # Mem/Disk free meter
    theme[free_start]="#9ece6a"
    theme[free_mid]="#e0af68"
    theme[free_end]="#f7768e"

    # Mem/Disk cached meter
    theme[cached_start]="#9ece6a"
    theme[cached_mid]="#e0af68"
    theme[cached_end]="#f7768e"

    # Mem/Disk available meter
    theme[available_start]="#9ece6a"
    theme[available_mid]="#e0af68"
    theme[available_end]="#f7768e"

    # Mem/Disk used meter
    theme[used_start]="#9ece6a"
    theme[used_mid]="#e0af68"
    theme[used_end]="#f7768e"

    # Download graph colors
    theme[download_start]="#9ece6a"
    theme[download_mid]="#e0af68"
    theme[download_end]="#f7768e"

    # Upload graph colors
    theme[upload_start]="#9ece6a"
    theme[upload_mid]="#e0af68"
    theme[upload_end]="#f7768e"
  '';

  btopConfig = ''
    #? Config file for btop v.1.4.6

    #* Name of a btop++/bpytop/bashtop formatted ".theme" file, "Default" and "TTY" for builtin themes.
    #* Themes should be placed in "../share/btop/themes" relative to binary or "$HOME/.config/btop/themes"
    color_theme = "tokyo-night"

    #* If the theme set background should be shown, set to False if you want terminal background transparency.
    theme_background = true

    #* Sets if 24-bit truecolor should be used, will convert 24-bit colors to 256 color (6x6x6 color cube) if false.
    truecolor = true

    #* Set to true to force tty mode regardless if a real tty has been detected or not.
    force_tty = false

    #* Define presets for the layout of the boxes.
    presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty"

    #* Set to True to enable "h,j,k,l,g,G" keys for directional control in lists.
    vim_keys = false

    #* Rounded corners on boxes, is ignored if TTY mode is ON.
    rounded_corners = true

    #* Use terminal synchronized output sequences to reduce flickering on supported terminals.
    terminal_sync = true

    #* Default symbols to use for graph creation, "braille", "block" or "tty".
    graph_symbol = "braille"

    # Graph symbol to use for graphs in cpu box
    graph_symbol_cpu = "default"
    graph_symbol_gpu = "default"
    graph_symbol_mem = "default"
    graph_symbol_net = "default"
    graph_symbol_proc = "default"

    #* Manually set which boxes to show.
    shown_boxes = "cpu mem net proc"

    #* Update time in milliseconds
    update_ms = 2000

    #* Processes sorting
    proc_sorting = "cpu lazy"
    proc_reversed = false
    proc_tree = false
    proc_colors = true
    proc_gradient = true
    proc_per_core = false
    proc_mem_bytes = true
    proc_cpu_graphs = true
    proc_info_smaps = false
    proc_left = false
    proc_filter_kernel = false
    proc_aggregate = false
    keep_dead_proc_usage = false

    #* CPU settings
    cpu_graph_upper = "Auto"
    cpu_graph_lower = "Auto"
    show_gpu_info = "Auto"
    cpu_invert_lower = true
    cpu_single_graph = false
    cpu_bottom = false
    show_uptime = true
    show_cpu_watts = true
    check_temp = true
    cpu_sensor = "Auto"
    show_coretemp = true
    cpu_core_map = ""
    temp_scale = "celsius"
    base_10_sizes = false
    show_cpu_freq = true
    freq_mode = "first"
    clock_format = "%X"
    background_update = true
    custom_cpu_name = ""

    #* Disk settings
    disks_filter = ""
    mem_graphs = true
    mem_below_net = false
    zfs_arc_cached = true
    show_swap = true
    swap_disk = true
    show_disks = true
    only_physical = true
    use_fstab = true
    zfs_hide_datasets = false
    disk_free_priv = false
    show_io_stat = true
    io_mode = false
    io_graph_combined = false
    io_graph_speeds = ""

    #* Network settings
    net_download = 100
    net_upload = 100
    net_auto = true
    net_sync = true
    net_iface = ""
    base_10_bitrate = "Auto"

    #* Battery settings
    show_battery = true
    selected_battery = "Auto"
    show_battery_watts = true

    #* Logging
    log_level = "WARNING"
    save_config_on_exit = true

    #* GPU settings
    nvml_measure_pcie_speeds = true
    rsmi_measure_pcie_speeds = true
    gpu_mirror_graph = true
    shown_gpus = "nvidia amd intel"
    custom_gpu_name0 = ""
    custom_gpu_name1 = ""
    custom_gpu_name2 = ""
    custom_gpu_name3 = ""
    custom_gpu_name4 = ""
    custom_gpu_name5 = ""
  '';
in
{
  xdg.configFile."btop/btop.conf".text = btopConfig;
  xdg.configFile."btop/themes/tokyo-night.theme".text = btopTheme;
}
