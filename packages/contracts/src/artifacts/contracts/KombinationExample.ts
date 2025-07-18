/* Autogenerated file. Do not edit manually. */

/* eslint-disable max-classes-per-file */
/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable @typescript-eslint/consistent-type-imports */

/*
  Fuels version: 0.100.0
  Forc version: 0.67.0
  Fuel-Core version: 0.41.9
*/

import { Contract as __Contract, Interface } from "fuels";
import type {
  Provider,
  Account,
  StorageSlot,
  Address,
  FunctionFragment,
  InvokeFunction,
} from 'fuels';

const abi = {
  "programType": "contract",
  "specVersion": "1",
  "encodingVersion": "1",
  "concreteTypes": [
    {
      "type": "bool",
      "concreteTypeId": "b760f44fa5965c2474a3b471467a22c43185152129295af588b022ae50b50903"
    }
  ],
  "metadataTypes": [],
  "functions": [
    {
      "inputs": [],
      "name": "test_function",
      "output": "b760f44fa5965c2474a3b471467a22c43185152129295af588b022ae50b50903",
      "attributes": null
    }
  ],
  "loggedTypes": [],
  "messagesTypes": [],
  "configurables": []
};

const storageSlots: StorageSlot[] = [];

export class KombinationExampleInterface extends Interface {
  constructor() {
    super(abi);
  }

  declare functions: {
    test_function: FunctionFragment;
  };
}

export class KombinationExample extends __Contract {
  static readonly abi = abi;
  static readonly storageSlots = storageSlots;

  declare interface: KombinationExampleInterface;
  declare functions: {
    test_function: InvokeFunction<[], boolean>;
  };

  constructor(
    id: string | Address,
    accountOrProvider: Account | Provider,
  ) {
    super(id, abi, accountOrProvider);
  }
}
