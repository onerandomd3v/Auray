import { Controller, Get } from "@nestjs/common";
import { getHealth, type HealthStatus } from "./health.js";

@Controller()
export class AppController {
  @Get("health")
  health(): HealthStatus {
    return getHealth();
  }
}
