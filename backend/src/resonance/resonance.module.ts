import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Resonance } from './resonance.entity';
import { ResonanceService } from './resonance.service';
import { ResonanceController } from './resonance.controller';
import { Session } from '../sessions/session.entity';
import { Event } from '../events/event.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Resonance, Session, Event])],
  controllers: [ResonanceController],
  providers: [ResonanceService],
})
export class ResonanceModule {}
