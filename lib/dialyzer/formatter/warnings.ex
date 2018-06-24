defmodule Dialyzer.Warnings do
  @warnings Enum.into(
              [
                Dialyzer.Warnings.AppCall,
                Dialyzer.Warnings.Apply,
                Dialyzer.Warnings.BinaryConstruction,
                Dialyzer.Warnings.Call,
                Dialyzer.Warnings.CallToMissingFunction,
                Dialyzer.Warnings.CallWithOpaque,
                Dialyzer.Warnings.CallWithoutOpaque,
                Dialyzer.Warnings.CallbackArgumentTypeMismatch,
                Dialyzer.Warnings.CallbackInfoMissing,
                Dialyzer.Warnings.CallbackMissing,
                Dialyzer.Warnings.CallbackSpecArgumentTypeMismatch,
                Dialyzer.Warnings.CallbackSpecTypeMismatch,
                Dialyzer.Warnings.CallbackTypeMismatch,
                Dialyzer.Warnings.ContractDiff,
                Dialyzer.Warnings.ContractSubtype,
                Dialyzer.Warnings.ContractSupertype,
                Dialyzer.Warnings.ContractWithOpaque,
                Dialyzer.Warnings.ExactEquality,
                Dialyzer.Warnings.ExtraRange,
                Dialyzer.Warnings.FuncionApplicationArguments,
                Dialyzer.Warnings.FunctionApplicationNoFunction,
                Dialyzer.Warnings.GuardFail,
                Dialyzer.Warnings.GuardFailPattern,
                Dialyzer.Warnings.ImproperListConstruction,
                Dialyzer.Warnings.InvalidContract,
                Dialyzer.Warnings.NegativeGuardFail,
                Dialyzer.Warnings.NoReturn,
                Dialyzer.Warnings.OpaqueGuard,
                Dialyzer.Warnings.OpaqueEquality,
                Dialyzer.Warnings.OpaqueMatch,
                Dialyzer.Warnings.OpaqueNonequality,
                Dialyzer.Warnings.OpaqueTypeTest,
                Dialyzer.Warnings.OverlappingContract,
                Dialyzer.Warnings.PatternMatch,
                Dialyzer.Warnings.PatternMatchCovered,
                Dialyzer.Warnings.RaceCondition,
                Dialyzer.Warnings.RecordConstruction,
                Dialyzer.Warnings.RecordMatching,
                Dialyzer.Warnings.UnknownBehaviour,
                Dialyzer.Warnings.UnknownFunction,
                Dialyzer.Warnings.UnknownType,
                Dialyzer.Warnings.UnmatchedReturn,
                Dialyzer.Warnings.UnusedFunction
              ],
              %{},
              fn warning -> {warning.warning(), warning} end
            )

  @doc """
  Returns a mapping of the warning to the warning module.
  """
  def warnings(), do: @warnings
end
