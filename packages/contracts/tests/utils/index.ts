import type { FunctionInvocationScope } from "fuels";

export const callAndWait = async <T extends unknown[], R>(
  method: FunctionInvocationScope<T, R>,
) => {
  const result = await method.call();
  return result.waitForResult();
};
