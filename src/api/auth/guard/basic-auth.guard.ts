// src/auth/basic-auth.guard.ts
import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from "@nestjs/common";

@Injectable()
export class BasicAuthGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers["authorization"];

    if (!authHeader || !authHeader.startsWith("Basic ")) {
      throw new UnauthorizedException(
        "Missing or invalid Authorization header"
      );
    }

    const base64Credentials = authHeader.split(" ")[1];
    const credentials = Buffer.from(base64Credentials, "base64").toString(
      "ascii"
    );
    const [username, password] = credentials.split(":");

    // Replace with real credential check
    if (
      username === process.env.APP_USERNAME &&
      password === process.env.APP_PASSWORD
    ) {
      return true;
    }

    throw new UnauthorizedException("Invalid credentials");
  }
}
