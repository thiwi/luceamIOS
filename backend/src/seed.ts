const { NestFactory } = require('@nestjs/core');
const { AppModule } = require('./app.module');
const { DataSource } = require('typeorm');
const { Event: EventEntity } = require('./events/event.entity');
const { MoodRoom } = require('./moodrooms/moodroom.entity');

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  try {
    const dataSource = app.get(DataSource);

    const eventRepo = dataSource.getRepository(EventEntity);
    const eventCount = await eventRepo.count();
    if (eventCount === 0) {
      console.log('[seed] Seeding events...');
      await eventRepo.save([
        { content: 'A sunny walk in the park' },
        { content: 'Coffee with friends' },
        { content: 'Reading a good book' },
      ]);
    } else {
      console.log('[seed] Events already seeded. Skipping...');
    }

    const roomRepo = dataSource.getRepository(MoodRoom);
    const roomCount = await roomRepo.count();
    if (roomCount === 0) {
      console.log('[seed] Seeding mood rooms...');
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
    } else {
      console.log('[seed] Mood rooms already seeded. Skipping...');
    }
    console.log('[seed] Seeding completed successfully.');
  } catch (err) {
    console.error('[seed] Error while seeding data:', err);
    process.exit(1);
  } finally {
    await app.close();
  }
}

bootstrap();
