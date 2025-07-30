import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MoodRoom } from './moodroom.entity';
import { MoodRoomsService } from './moodrooms.service';
import { MoodRoomsController } from './moodrooms.controller';
import { Session } from '../sessions/session.entity';

@Module({
  imports: [TypeOrmModule.forFeature([MoodRoom, Session])],
  controllers: [MoodRoomsController],
  providers: [MoodRoomsService],
})
export class MoodRoomsModule {}
