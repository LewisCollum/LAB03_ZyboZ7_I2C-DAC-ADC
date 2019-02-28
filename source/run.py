from os.path import join, dirname, exists
from os import makedirs
from vunit import VUnit

vhdl_standard = ["2002", "2008"]
root = dirname(__file__)
ui = VUnit.from_argv(vhdl_standard=vhdl_standard[1])
vunit_out = join(root, "vunit_out")

libraries = dict.fromkeys([
    "lcd",
    "i2c",
    "button",
    "state",
    "system_bus",
    "testing",
    "board",
    "binary_counter",
    "address_counter",
    "timer_counter",
    "debouncer",
    "enabler",
    "toggler",
    "edge_detector",
    "inout_controller",
    "flip_flop"
])

for name, library in libraries.items():
    library = ui.add_library(name);
    library.add_source_files(join(root, name, "*.vhd"))

ui.main()
