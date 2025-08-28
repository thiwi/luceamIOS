import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { SessionsModule } from './sessions/sessions.module';
import { EventsModule } from './events/events.module';
import { ResonanceModule } from './resonance/resonance.module';
import { Session } from './sessions/session.entity';
import { Event } from './events/event.entity';
import { Resonance } from './resonance/resonance.entity';
import { MoodRoomsModule } from './moodrooms/moodrooms.module';
import { MoodRoom } from './moodrooms/moodroom.entity';
import { FavoritesModule } from './favorites/favorites.module';
import { FavoriteMoodRoom } from './favorites/favorite-moodroom.entity';
import { UsersModule } from './users/users.module';
import { User } from './users/user.entity';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'db',
      port: parseInt(process.env.DB_PORT || '5432', 10),
      username: process.env.DB_USER || process.env.DB_USERNAME || 'postgres',
      password: process.env.DB_PASS || process.env.DB_PASSWORD || 'postgres',
      database: process.env.DB_NAME || 'luceam',
      synchronize: true,
      entities: [Session, Event, Resonance, MoodRoom, FavoriteMoodRoom, User],
    }),
    SessionsModule,
    EventsModule,
    ResonanceModule,
    MoodRoomsModule,
    FavoritesModule,
    UsersModule,
  ],
})
export class AppModule {}
