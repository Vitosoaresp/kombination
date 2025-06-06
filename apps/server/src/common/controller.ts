import type Elysia from "elysia";

export abstract class BaseController {
  abstract routes(app: Elysia): void;
}
