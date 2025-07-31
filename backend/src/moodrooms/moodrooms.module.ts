import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MoodRoom } from './moodroom.entity';
import { MoodRoomsService } from './moodrooms.service';
import { MoodRoomsController } from './moodrooms.controller';
import { Session } from '../sessions/session.entity';
import { FavoriteMoodRoom } from '../favorites/favorite-moodroom.entity';
import { User } from '../users/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([MoodRoom, Session, FavoriteMoodRoom, User])],
  controllers: [MoodRoomsController],
  providers: [MoodRoomsService],
})
export class MoodRoomsModule {}
