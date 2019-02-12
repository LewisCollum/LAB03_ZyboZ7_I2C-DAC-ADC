from os.path import join, dirname
from vunit import VUnit

root = dirname(__file__)
ui = VUnit.from_argv()

#common = ui.add_library("common")
#common.add_source_files(join(root, "*.vhd"))

libraries = dict.fromkeys(["lcd", "i2c", "button", "state", "system_bus"])

for name, library in libraries.items():
    library = ui.add_library(name);
    library.add_source_files(join(root, name, "*.vhd"))

ui.main()
