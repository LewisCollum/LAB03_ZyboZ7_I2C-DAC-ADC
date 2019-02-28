library ieee;
use ieee.std_logic_1164.all;

use work.inout_pkg;

library enabler;

entity InOutController is
  port(
    mode: in inout_pkg.Mode;
    sendable: in std_logic;
    fetchable: out std_logic;
    io: inout std_logic);
end entity;

architecture weak_low of InOutController is
begin
  ioToFetchable: entity enabler.Enabler(weak_low)
    port map(
      input => io,
      enable => mode.isFetch,
      output => fetchable);
  internalToIO: entity enabler.Enabler(weak_low)
    port map(
      input => sendable,
      enable => mode.isSend,
      output => io);
end architecture;

architecture weak_high of InOutController is
begin
  ioToFetchable: entity enabler.Enabler(weak_high)
    port map(
      input => io,
      enable => mode.isFetch,
      output => fetchable);
  internalToIO: entity enabler.Enabler(weak_high)
    port map(
      input => sendable,
      enable => mode.isSend,
      output => io);
end architecture;
