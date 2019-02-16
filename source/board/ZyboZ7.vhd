use work.Board;

package ZyboZ7 is
  constant clock: Board.Clock := (
    frequency => 50e6,
    period => 20 ns);
end package;
