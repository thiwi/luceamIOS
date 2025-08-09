import { Module } from '@nestjs/common';
import { RedisModule } from '../infra/redis/redis.module';
import { PresenceService } from './presence.service';
import { PresenceSimulationService } from './presence.simulation.service';

@Module({
  imports: [RedisModule],
  providers: [PresenceService, PresenceSimulationService],
  exports: [PresenceService, PresenceSimulationService],
})
export class PresenceModule {}
