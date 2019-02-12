from os.path import join, dirname, exists
from os import makedirs
from vunit import VUnit

root = dirname(__file__)
ui = VUnit.from_argv()

#common = ui.add_library("common")
#common.add_source_files(join(root, "*.vhd"))

libraries = dict.fromkeys([
    "lcd",
    "i2c",
    "button",
    "state",
    "system_bus",
    "testing",
    "board"
])

for name, library in libraries.items():
    library = ui.add_library(name);
    library.add_source_files(join(root, name, "*.vhd"))
    testbenches = library.get_test_benches(allow_empty = True)
    if len(testbenches) > 0 and not exists("wave"):
        makedirs("wave");
    for testbench in testbenches:
        testbench.set_sim_option("ghdl.sim_flags", [f"--wave=wave/{testbench.name}.ghw"])

ui.main()
