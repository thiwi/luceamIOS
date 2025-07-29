import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DataSource } from 'typeorm';
import { Event } from './events/event.entity';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const dataSource = app.get(DataSource);
  const count = await dataSource.getRepository(Event).count();
  if (count === 0) {
    await dataSource.getRepository(Event).save([
      { content: 'A sunny walk in the park' },
      { content: 'Coffee with friends' },
      { content: 'Reading a good book' },
    ]);
  }
  await app.close();
}
bootstrap();
