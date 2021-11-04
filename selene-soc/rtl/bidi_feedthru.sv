module bidi_feedthru
#(
  parameter WIDTH = 64
) 
(
  inout wire [ WIDTH - 1 : 0 ] p0,
  inout wire [ WIDTH - 1 : 0 ] p1
);
  alias p1 = p0;
endmodule
