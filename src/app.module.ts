import { Module } from "@nestjs/common";
import { AppController } from "./app.controller";
import { AppService } from "./app.service";
import { TypeOrmModule } from "@nestjs/typeorm";
import { UserModule } from "./api/user/user.module";
import { AuthModule } from "./api/auth/auth.module";
import { CommonModule } from "./common/common.module";
import * as dotenv from "dotenv";
import { PredefineModule } from "./api/predefine/predefine.module";
import { DropdownListModule } from "./api/dropdown-list/dropdown-list.module";

import { ScheduleModule } from "@nestjs/schedule";
import { PredefineItemModule } from "./api/predefine-item/predefine-item.module";
dotenv.config(); // Load environment variables from .env file
@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      useFactory: () => ({
        type: "mssql",
        host: process.env.DB_HOST,
        port: Number(process.env.DB_PORT),
        username: process.env.DB_USERNAME,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
        entities: [__dirname + "/**/*.entity{.ts,.js}"],
        synchronize: false,
        extra: {
          trustServerCertificate: true,
        },
      }),
    }),
    ScheduleModule.forRoot(),
    UserModule,
    AuthModule,
    CommonModule,
    PredefineModule,
    UserModule,
    DropdownListModule,
    PredefineItemModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
