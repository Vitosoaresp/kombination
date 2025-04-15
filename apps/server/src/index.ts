import swagger from "@elysiajs/swagger";
import { Elysia } from "elysia";

const x = Bun.env.PORT;

const app = new Elysia()
  .use(swagger())
  .get("/", () => "Hello Kombination")
  .listen(process.env.PORT);

console.log(
  `🦊 Elysia is running at ${app.server?.hostname}:${app.server?.port}`,
);
