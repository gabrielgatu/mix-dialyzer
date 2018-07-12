[
  apps: [
    remove: [],
    include: []
  ],
  warnings: [
    ignore: [
      {"non_existing", :*, :unknown_type},

      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/stdlib-3.4.5/ebin/beam_lib.beam", :*, :unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/kernel-5.4.3/ebin/code.beam", :*, :unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/dialyzer-3.2.4/ebin/dialyzer.beam",:*, :unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/stdlib-3.4.5/ebin/erl_anno.beam", :*, :unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/stdlib-3.4.5/ebin/erl_scan.beam", :*, :unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/stdlib-3.4.5/ebin/erl_scan.beam", :*, :unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/stdlib-3.4.5/ebin/erl_scan.beam", :*, :unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/hipe-3.17.1/ebin/erl_types.beam", :*, :unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/hipe-3.17.1/ebin/erl_types.beam", :*, :unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/stdlib-3.4.5/ebin/filelib.beam", :*, :unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/stdlib-3.4.5/ebin/io_lib.beam", :*,:unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/stdlib-3.4.5/ebin/io_lib.beam", :*,:unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/stdlib-3.4.5/ebin/io_lib.beam", :*,:unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/stdlib-3.4.5/ebin/io_lib.beam", :*,:unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/stdlib-3.4.5/ebin/io_lib.beam", :*,:unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/stdlib-3.4.5/ebin/io_lib.beam", :*,:unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/stdlib-3.4.5/ebin/lists.beam", :*, :unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/stdlib-3.4.5/ebin/maps.beam", :*, :unknown_function},
      {"/usr/local/Cellar/erlang/20.3.6/lib/erlang/lib/stdlib-3.4.5/ebin/maps.beam", :*, :unknown_function},
      {"lib/dialyzer/config/config.ex", 73, :invalid_contract},
      {"lib/dialyzer/config/config.ex", 129, :invalid_contract},

      {"lib/dialyzer/warnings/formatter/pretty_print.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warning_helpers.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/app_call.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/apply.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/binary_construction.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/call.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/callback_argument_type_mismatch.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/callback_spec_argument_type_mismatch.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/callback_spec_type_mismatch.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/callback_type_mismatch.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/contract_diff.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/contract_subtype.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/contract_supertype.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/contract_with_opaque.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/exact_equality.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/extra_range.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/function_application_arguments.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/function_application_no_function.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/guard_fail_pattern.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/improper_list_construction.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/invalid_contract.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/pattern_match.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/pattern_match_covered.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/race_condition.ex", :*, :no_return},
      {"lib/dialyzer/warnings/formatter/warnings/unmatched_return.ex", :*, :no_return}
    ],
    active: [
      :unmatched_returns,
      :error_handling,
      :unknown
    ]
  ],
  extra_build_dir: []
]
