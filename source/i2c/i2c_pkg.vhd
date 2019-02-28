library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package i2c_pkg is
  subtype Byte is unsigned(7 downto 0);
  subtype SlaveAddress is unsigned(6 downto 0);
  type DataDirection is (sending, fetching);
  
  type SystemState is (
    idle,
    run,
    stop);
  type RunState is (
    start,
    sendControl,
    getFirstAcknowledge,
    send,
    fetch,
    getAcknowledge,
    sendAcknowledge);

  type State is record
    system: SystemState;
    run: RunState;
  end record;
  
  type Interrupt is record
    isBusy: std_logic;
  end record;

  type Control is record
    enable: std_logic;
    slaveAddress: SlaveAddress;
    dataDirection: DataDirection;
  end record;

  type InternalInterrupt is record
    isBitCounterDone: std_logic;
    hasAddressChanged: std_logic;
    isStartBitDone: std_logic;
    isBusy: std_logic;
  end record;

  type Slave is record
    data: std_logic;
    clock: std_logic;
  end record;


  type I2CController is record
    clock: std_logic;
    reset: std_logic;
    control: i2c_pkg.Control;
    data: i2c_pkg.Byte;
    slave: i2c_pkg.Slave;
    interrupt: i2c_pkg.Interrupt;    
  end record;

  type ResetHandler is record
    clock: std_logic;
    resetUnhandled: std_logic;
    readyToReset: std_logic;
    resetHandled: std_logic;
  end record;

  type EnableHandler is record
    clock: std_logic;
    resetStart: std_logic;
    resetFinish: std_logic;
    enableUnhandled: std_logic;
    enableHandled: std_logic;    
  end record;

  type StateController is record
    clock: std_logic;
    reset: std_logic;
    control: i2c_pkg.Control;
    interrupt: i2c_pkg.InternalInterrupt;
    state: i2c_pkg.State;
  end record;
end package;
