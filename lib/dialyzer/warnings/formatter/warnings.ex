# Credits: this code was originally part of the `dialyxir` project
# Copyright by Andrew Summers
# https://github.com/jeremyjh/dialyxir

defmodule Dialyzer.Formatter.Warnings do
  @warnings Enum.into(
              [
                Dialyzer.Formatter.Warnings.AppCall,
                Dialyzer.Formatter.Warnings.Apply,
                Dialyzer.Formatter.Warnings.BinaryConstruction,
                Dialyzer.Formatter.Warnings.Call,
                Dialyzer.Formatter.Warnings.CallToMissingFunction,
                Dialyzer.Formatter.Warnings.CallWithOpaque,
                Dialyzer.Formatter.Warnings.CallWithoutOpaque,
                Dialyzer.Formatter.Warnings.CallbackArgumentTypeMismatch,
                Dialyzer.Formatter.Warnings.CallbackInfoMissing,
                Dialyzer.Formatter.Warnings.CallbackMissing,
                Dialyzer.Formatter.Warnings.CallbackSpecArgumentTypeMismatch,
                Dialyzer.Formatter.Warnings.CallbackSpecTypeMismatch,
                Dialyzer.Formatter.Warnings.CallbackTypeMismatch,
                Dialyzer.Formatter.Warnings.ContractDiff,
                Dialyzer.Formatter.Warnings.ContractSubtype,
                Dialyzer.Formatter.Warnings.ContractSupertype,
                Dialyzer.Formatter.Warnings.ContractWithOpaque,
                Dialyzer.Formatter.Warnings.ExactEquality,
                Dialyzer.Formatter.Warnings.ExtraRange,
                Dialyzer.Formatter.Warnings.FuncionApplicationArguments,
                Dialyzer.Formatter.Warnings.FunctionApplicationNoFunction,
                Dialyzer.Formatter.Warnings.GuardFail,
                Dialyzer.Formatter.Warnings.GuardFailPattern,
                Dialyzer.Formatter.Warnings.ImproperListConstruction,
                Dialyzer.Formatter.Warnings.InvalidContract,
                Dialyzer.Formatter.Warnings.NegativeGuardFail,
                Dialyzer.Formatter.Warnings.NoReturn,
                Dialyzer.Formatter.Warnings.OpaqueGuard,
                Dialyzer.Formatter.Warnings.OpaqueEquality,
                Dialyzer.Formatter.Warnings.OpaqueMatch,
                Dialyzer.Formatter.Warnings.OpaqueNonequality,
                Dialyzer.Formatter.Warnings.OpaqueTypeTest,
                Dialyzer.Formatter.Warnings.OverlappingContract,
                Dialyzer.Formatter.Warnings.PatternMatch,
                Dialyzer.Formatter.Warnings.PatternMatchCovered,
                Dialyzer.Formatter.Warnings.RaceCondition,
                Dialyzer.Formatter.Warnings.RecordConstruction,
                Dialyzer.Formatter.Warnings.RecordMatching,
                Dialyzer.Formatter.Warnings.UnknownBehaviour,
                Dialyzer.Formatter.Warnings.UnknownFunction,
                Dialyzer.Formatter.Warnings.UnknownType,
                Dialyzer.Formatter.Warnings.UnmatchedReturn,
                Dialyzer.Formatter.Warnings.UnusedFunction
              ],
              %{},
              fn warning -> {warning.warning(), warning} end
            )

  @doc """
  Returns a mapping of the warning to the warning module.
  """
  def warnings(), do: @warnings
end
