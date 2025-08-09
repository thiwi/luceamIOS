import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RedisModule } from '../infra/redis/redis.module';
import { EventsController } from './events.controller';
import { EventsService } from './events.service';
import { Event } from './event.entity';
import { Session } from '../sessions/session.entity';
import { PresenceService } from '../presence/presence.service';

@Module({
  imports: [TypeOrmModule.forFeature([Event, Session]), RedisModule],
  controllers: [EventsController],
  providers: [EventsService, PresenceService],
  exports: [EventsService],
})
export class EventsModule {}
