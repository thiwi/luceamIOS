import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DataSource } from 'typeorm';
import { Event } from './events/event.entity';
import { MoodRoom } from './moodrooms/moodroom.entity';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const dataSource = app.get(DataSource);
  const count = await dataSource.getRepository(Event).count();
  if (count === 0) {
    await dataSource
      .getRepository(Event)
      .save([
        { content: 'A sunny walk in the park' },
        { content: 'Coffee with friends' },
        { content: 'Reading a good book' },
      ]);
  }
  const roomRepo = dataSource.getRepository(MoodRoom);
  const roomCount = await roomRepo.count();
  if (roomCount === 0) {
    const now = new Date();
    await roomRepo.save([
      {
        name: 'Monday Blues',
        schedule: 'Every Monday at 17:30',
        background: 'MoodRoomSad',
        textColor: 'black',
        startTime: new Date(now.getTime() + 600000),
        durationMinutes: 30,
        createdAt: now,
      },
      {
        name: 'Mindful night routine',
        schedule: 'Daily at 22:00',
        background: 'MoodRoomNight',
        textColor: 'white',
        startTime: new Date(now.getTime() + 900000),
        durationMinutes: 30,
        createdAt: now,
      },
      {
        name: 'Saturday for Reflection',
        schedule: 'Every Saturday at 10:00',
        background: 'MoodRoomNature',
        textColor: 'black',
        startTime: new Date(now.getTime() + 1200000),
        durationMinutes: 30,
        createdAt: now,
      },
    ]);
  }
  await app.close();
}
bootstrap();
