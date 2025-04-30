import type { FunctionInvocationScope, MultiCallInvocationScope } from "fuels";

export const callAndWait = async <T extends unknown[], R>(
  method: FunctionInvocationScope<T, R> | MultiCallInvocationScope<R>,
) => {
  const result = await method.call();
  return result.waitForResult();
};

export const assetInput = (assetId: string) => ({ bits: assetId });
