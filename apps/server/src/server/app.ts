import cors from "@elysiajs/cors";
import swagger from "@elysiajs/swagger";
import { apiEnv } from "@kombination/env";
import Elysia from "elysia";
import { readdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export class App {
  private _app: Elysia;

  constructor() {
    this._app = new Elysia();

    this.setupPlugins();
    this.setupRoutes();
  }

  private setupRoutes() {
    const controllersDir = join(__dirname, "../http/controllers");
    const files = readdirSync(controllersDir);
    for (const file of files) {
      if (file.endsWith(".ts") || file.endsWith(".js")) {
        const ControllerClass = require(join(controllersDir, file)).default;
        if (typeof ControllerClass === "function") {
          const controllerInstance = new ControllerClass();
          if (typeof controllerInstance.routes === "function") {
            controllerInstance.routes(this._app);
          } else {
            console.warn(
              `Controller in ${file} does not have a routes method.`,
            );
          }
        } else {
          console.warn(
            `File ${file} does not export a valid controller class.`,
          );
        }
      }
    }
  }

  private setupPlugins() {
    this._app.use(
      swagger({
        path: "/swagger",
        documentation: {
          info: { title: "Kombination API", version: "0.0.1" },
        },
      }),
    );

    this._app.use(cors());
  }

  public async start() {
    const PORT = apiEnv.PORT || 3001;

    this._app.listen(Number(PORT));
    console.log(
      `🦊 Elysia is running at ${this._app.server?.hostname}:${this._app.server?.port}`,
    );
  }
}
