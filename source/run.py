from os.path import join, dirname, exists
from os import makedirs
from vunit import VUnit

class WaveFile:
    def __init__(self, command: str, path: str, extension: str):
        self.command = command
        self.path = path
        self.extension = extension
        self.updateDirectory()

    def updateDirectory(self):
        if not exists(self.path):
            makedirs(self.path)

    def ghdlWaveFlag(self, testbenchName: str) -> str:
        return f"{self.command}={self.path}/{testbenchName}.{self.extension}"

def ghdlWaveFlag(testbenchName: str) -> list:
    return [waves[wavefile].ghdlWaveFlag(testbenchName) for wavefile in waves]
    
root = dirname(__file__)
ui = VUnit.from_argv()
vunit_out = join(root, "vunit_out")

waves = {
    "ghw_wave": WaveFile(command = "--wave",
                     path = join(vunit_out, "ghw_wave"),
                     extension = "ghw"),

    "vcd_wave": WaveFile(command = "--vcd",
                     path = join(vunit_out, "vcd_wave"),
                     extension = "vcd")
}

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
    "enabler"
])

for name, library in libraries.items():
    library = ui.add_library(name);
    library.add_source_files(join(root, name, "*.vhd"))
    testbenches = library.get_test_benches(allow_empty = True)
            
    for testbench in testbenches:
        testbench.set_sim_option("ghdl.sim_flags", ghdlWaveFlag(testbench.name))

ui.main()
