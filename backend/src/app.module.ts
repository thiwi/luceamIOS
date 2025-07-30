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

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'db',
      port: parseInt(process.env.DB_PORT || '5432', 10),
      username: process.env.DB_USER || 'luma',
      password: process.env.DB_PASS || 'luma',
      database: process.env.DB_NAME || 'luma',
      synchronize: true,
      entities: [Session, Event, Resonance, MoodRoom],
    }),
    SessionsModule,
    EventsModule,
    ResonanceModule,
    MoodRoomsModule,
  ],
})
export class AppModule {}
