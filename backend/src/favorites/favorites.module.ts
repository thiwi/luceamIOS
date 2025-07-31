import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FavoriteMoodRoom } from './favorite-moodroom.entity';
import { FavoritesService } from './favorites.service';
import { FavoritesController } from './favorites.controller';
import { User } from '../users/user.entity';
import { MoodRoom } from '../moodrooms/moodroom.entity';

@Module({
  imports: [TypeOrmModule.forFeature([FavoriteMoodRoom, User, MoodRoom])],
  providers: [FavoritesService],
  controllers: [FavoritesController],
  exports: [FavoritesService],
})
export class FavoritesModule {}
