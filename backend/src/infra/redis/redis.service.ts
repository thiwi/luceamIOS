import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis, { Redis as RedisClient } from 'ioredis';

@Injectable()
export class RedisService {
  private readonly client: RedisClient;
  constructor(private readonly config: ConfigService) {
    const url = this.config.get<string>('REDIS_URL', 'redis://localhost:6379');
    this.client = new Redis(url);
  }

  getClient(): RedisClient {
    return this.client;
  }

  getSubscriber(): RedisClient {
    return this.client.duplicate();
  }

  getPublisher(): RedisClient {
    return this.client.duplicate();
  }
}
