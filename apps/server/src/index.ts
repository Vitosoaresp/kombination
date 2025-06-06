import { App } from "./server/app";

async function main() {
  try {
    const app = new App();
    await app.start();
  } catch (error) {
    console.error("Error starting the server:", error);
    process.exit(1);
  }
}

main();
