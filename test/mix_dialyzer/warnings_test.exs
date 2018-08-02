defmodule Dialyzer.Plt.WarningsTest do
  use ExUnit.Case
  import Dialyzer.Test.Util

  test "it has a corresponding module for each warning emitted by dialyzer" do
    dialyzer_warnings = [
      :opaque_neq,
      :opaque_guard,
      :callback_type_mismatch,
      :exact_eq,
      :callback_info_missing,
      :pattern_match_cov,
      :call_with_opaque,
      :record_matching,
      :race_condition,
      :contract_subtype,
      :bin_construction,
      :opaque_type_test,
      :fun_app_args,
      :call_to_missing,
      :invalid_contract,
      :overlapping_contract,
      :guard_fail_pat,
      :unknown_behaviour,
      :no_return,
      :extra_range,
      :callback_arg_type_mismatch,
      :improper_list_constr,
      :callback_spec_type_mismatch,
      :guard_fail,
      :contract_with_opaque,
      :record_constr,
      :app_call,
      :callback_spec_arg_type_mismatch,
      :unknown_function,
      :callback_missing,
      :unknown_type,
      :contract_supertype,
      :call_without_opaque,
      :apply,
      :unused_fun,
      :opaque_eq,
      :contract_diff,
      :neg_guard_fail,
      :call,
      :unmatched_return,
      :opaque_match,
      :fun_app_no_fun,
      :pattern_match
    ]

    Dialyzer.Formatter.Warnings.warnings()
    |> Enum.any?(fn {warning, _mod} ->
      warning in dialyzer_warnings
    end)
    |> assert
  end
end
