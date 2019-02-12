library vunit_lib;
context vunit_lib.vunit_context;

entity Test_StateController is
  generic (runner_cfg : string);
end entity;

architecture test of Test_StateController is
begin
  main : process
  begin
    test_runner_setup(runner, runner_cfg);
    report "Hello world!";
    test_runner_cleanup(runner);
  end process;

  
end architecture;
