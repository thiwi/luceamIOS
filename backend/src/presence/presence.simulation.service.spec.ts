import { Test, TestingModule } from '@nestjs/testing';
import * as RedisMock from 'ioredis-mock';
import { RedisService } from '../infra/redis/redis.service';
import { PresenceSimulationService } from './presence.simulation.service';

class MockRedisService {
  private client = new (RedisMock as any)();
  getClient() { return this.client as any; }
  getPublisher() { return this.client as any; }
  getSubscriber() { return this.client as any; }
}

describe('PresenceSimulationService', () => {
  let service: PresenceSimulationService;
  let redis: RedisMock;

  beforeEach(async () => {
    process.env.SIM_PRESENCE_ENABLED = 'true';
    process.env.SIM_PRESENCE_STEP_MS = '50';
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PresenceSimulationService,
        { provide: RedisService, useClass: MockRedisService },
      ],
    }).compile();
    service = module.get(PresenceSimulationService);
    redis = module.get(RedisService).getClient();
  });

  it('simulates presence and populates redis', async () => {
    await service.startForMoment('abc');
    await new Promise(res => setTimeout(res, 80));
    const count = await redis.scard('presence:moment:abc');
    expect(count).toBeGreaterThan(0);
    await service.stopForMoment('abc');
  });
});
