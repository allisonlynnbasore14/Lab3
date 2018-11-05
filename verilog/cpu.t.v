`include "cpu.v"
`timescale 1ns/1ps
//------------------------------------------------------------------------
// Simple fake CPU testbench sequence
//------------------------------------------------------------------------

module cpu_test ();

    reg clk;
    reg reset;

    // Clock generation
    initial clk=0;
    always #10 clk = !clk;


    CPU cpu(.clk(clk), .reset(reset));

    // Filenames for memory images and VCD dump file
    reg [1023:0] mem_text_fn;
    reg [1023:0] mem_data_fn;
    reg [1023:0] dump_fn;
    reg init_data = 0;      // Initializing .data segment is optional

    // Test sequence
    initial begin

	// Get command line arguments for memory image(s) and VCD dump file
	//   http://iverilog.wikia.com/wiki/Simulation
	//   http://www.project-veripage.com/plusarg.php
	if (! $value$plusargs("mem_text_fn=%s", mem_text_fn)) begin
	    $display("ERROR: provide +mem_text_fn=[path to .text memory image] argument");
	    $finish();
        end
	if (! $value$plusargs("mem_data_fn=%s", mem_data_fn)) begin
	    $display("INFO: +mem_data_fn=[path to .data memory image] argument not provided; data memory segment uninitialized");
	    init_data = 0;
        end

	if (! $value$plusargs("dump_fn=%s", dump_fn)) begin
	    $display("ERROR: provide +dump_fn=[path for VCD dump] argument");
	    $finish();
        end

    $display(mem_text_fn);
	$dumpfile("CPUtestN.vcd");


	$readmemh(mem_text_fn, cpu.Dmem.memory, 0);
    	if (init_data) begin
    	$readmemh(mem_data_fn, cpu.Dmem.memory, 2048);
    	end
	$dumpvars();

	// Assert reset pulse
	reset = 0; #10;
	reset = 1; #10;
	reset = 0; #10;


	$display("PC | IMM  | ALUOutput | MemoryOutput | MEMORY input | Da  | Db  | reg input | branch ");
	repeat(10) begin
        $display("%4t | %b | %b | %b | %d | %d | %d | %d | %d | %d", $time, cpu.PCaddr, cpu.MemoryDb, cpu.addr, cpu.DataOutMem, cpu.Db, cpu.Da, cpu.jump, cpu.jumpaddrPC, cpu.imm); #20 ;
        end
	$display("... more execution (see waveform)");

	#2000;

	if (cpu.registerfile.ReadData2 === 32'd48)
		$display("Fibonnaci test passed!");
	else
		$display("%b",cpu.DataOut);
		$display(cpu.registerfile.ReadData1);

	// End execution after some time delay - adjust to match your program
	// or use a smarter approach like looking sfor an exit syscall or the
	// PC to be the value of the last instruction in your program.
	$display("%4t | %b | %d", $time, cpu.MemoryDb, cpu.DataOut, "jee");
	$finish();
    end

endmodule
