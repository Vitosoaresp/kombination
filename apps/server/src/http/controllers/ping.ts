import type Elysia from "elysia";
import { t } from "elysia";

import { BaseController } from "@common/controller";

export default class PingController extends BaseController {
  async ping(app: Elysia) {
    return app.get("/ping", () => ({ message: "Hello Kombination" }), {
      detail: {
        tags: ["Ping"],
        description: "Ping the server",
      },
      response: {
        200: t.Object({
          message: t.String({ default: "Hello Kombination" }),
        }),
      },
    });
  }

  async health(app: Elysia) {
    return app.get("/health", () => ({ status: "OK" }), {
      detail: {
        tags: ["Health"],
        description: "Check the server health",
      },
      response: {
        200: t.Object({
          status: t.String({ default: "OK" }),
        }),
      },
    });
  }

  public routes(app: Elysia) {
    this.ping(app);
    this.health(app);
  }
}
