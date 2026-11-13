import { resolve } from "node:path";
import { config as loadEnv } from "dotenv";
import { defineConfig } from "drizzle-kit";

loadEnv({ path: resolve("../../.env.local") });

if (!process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL must be set in the repository-root .env.local file.");
}

export default defineConfig({
  dialect: "postgresql",
  schema: "./src/database/schema.ts",
  out: "./drizzle",
  dbCredentials: { url: process.env.DATABASE_URL },
  strict: true,
  verbose: true,
});
