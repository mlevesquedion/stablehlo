// RUN: diff <(stablehlo-opt %s.0_9_0.bc --vhlo-to-version=target=current --vhlo-legalize-to-stablehlo) <(stablehlo-opt %s)
// RUN: diff <(stablehlo-opt %s --stablehlo-legalize-to-vhlo --vhlo-to-version=target=current -emit-bytecode | stablehlo-opt --vhlo-legalize-to-stablehlo) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<32> : tensor<1xi32>
    %1:2 = call @inputs() : () -> (tensor<1x50x3xui32>, tensor<1x3xui32>)
    %2 = call @expected() : () -> tensor<1x50x3xui32>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<ui32>, %arg1: tensor<ui32>):
      %5 = stablehlo.add %arg0, %arg1 : tensor<ui32>
      stablehlo.return %5 : tensor<ui32>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 1], inserted_window_dims = [1], scatter_dims_to_operand_dims = [1]>, unique_indices = true} : (tensor<1x50x3xui32>, tensor<1xi32>, tensor<1x3xui32>) -> tensor<1x50x3xui32>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<1x50x3xui32>, tensor<1x50x3xui32>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<1x50x3xui32>, tensor<1x3xui32>) {
    %0 = stablehlo.constant dense<"0x080000000100000000000000000000000300000003000000000000000600000001000000000000000200000000000000000000000100000000000000010000000500000001000000030000000000000003000000020000000100000002000000010000000000000001000000050000000400000001000000050000000100000002000000030000000300000000000000000000000000000000000000070000000200000001000000030000000300000000000000030000000000000002000000010000000100000002000000000000000000000000000000010000000100000001000000010000000100000004000000020000000000000002000000020000000200000000000000000000000600000000000000000000000000000006000000010000000000000003000000040000000000000002000000010000000900000000000000020000000000000003000000020000000200000001000000020000000100000003000000000000000100000001000000010000000000000000000000020000000100000000000000030000000200000000000000030000000400000005000000000000000400000000000000020000000000000002000000020000000100000001000000010000000400000003000000040000000200000000000000020000000200000001000000020000000000000000000000040000000300000001000000010000000300000001000000040000000000000002000000020000000900000002000000030000000000000002000000020000000000000000000000000000000000000004000000000000000500000000000000"> : tensor<1x50x3xui32>
    %1 = stablehlo.constant dense<[[0, 0, 2]]> : tensor<1x3xui32>
    return %0, %1 : tensor<1x50x3xui32>, tensor<1x3xui32>
  }
  func.func private @expected() -> tensor<1x50x3xui32> {
    %0 = stablehlo.constant dense<"0x080000000100000000000000000000000300000003000000000000000600000001000000000000000200000000000000000000000100000000000000010000000500000001000000030000000000000003000000020000000100000002000000010000000000000001000000050000000400000001000000050000000100000002000000030000000300000000000000000000000000000000000000070000000200000001000000030000000300000000000000030000000000000002000000010000000100000002000000000000000000000000000000010000000100000001000000010000000100000004000000020000000000000002000000020000000200000000000000000000000600000000000000000000000000000006000000010000000000000003000000040000000000000002000000010000000900000000000000020000000000000003000000020000000200000001000000020000000100000003000000000000000100000001000000010000000000000000000000020000000100000002000000030000000200000000000000030000000400000005000000000000000400000000000000020000000000000002000000020000000100000001000000010000000400000003000000040000000200000000000000020000000200000001000000020000000000000000000000040000000300000001000000010000000300000001000000040000000000000002000000020000000900000002000000030000000000000002000000020000000000000000000000000000000000000004000000000000000500000000000000"> : tensor<1x50x3xui32>
    return %0 : tensor<1x50x3xui32>
  }
}
