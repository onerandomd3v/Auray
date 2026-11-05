export type HealthStatus = { status: "ok"; service: "api" };

export function getHealth(): HealthStatus {
  return { status: "ok", service: "api" };
}
