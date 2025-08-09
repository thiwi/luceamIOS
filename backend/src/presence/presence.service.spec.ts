import { Test, TestingModule } from '@nestjs/testing';
import { PresenceService } from './presence.service';
import { RedisService } from '../infra/redis/redis.service';

class FakeRedis {
  private sets = new Map<string, Set<string>>();
  private values = new Map<string, string>();

  multi() {
    const ops: Array<() => void> = [];
    const chain = {
      sadd: (key: string, member: string) => {
        ops.push(() => this.sadd(key, member));
        return chain;
      },
      expire: () => chain,
      set: (key: string, val: string) => {
        ops.push(() => this.set(key, val));
        return chain;
      },
      pfadd: () => chain,
      exec: async () => {
        ops.forEach(fn => fn());
        return [];
      },
    } as any;
    return chain;
  }

  sadd(key: string, member: string) {
    const set = this.sets.get(key) || new Set<string>();
    set.add(member);
    this.sets.set(key, set);
  }

  srem(key: string, member: string) {
    const set = this.sets.get(key);
    if (!set) return;
    set.delete(member);
  }

  scard(key: string) {
    const set = this.sets.get(key);
    return set ? set.size : 0;
  }

  set(key: string, val: string) {
    this.values.set(key, val);
  }

  get(key: string) {
    return this.values.get(key) ?? null;
  }
}

class MockRedisService {
  private client = new FakeRedis();
  getClient() {
    return this.client as any;
  }
  getSubscriber() {
    return this.client as any;
  }
  getPublisher() {
    return this.client as any;
  }
}

describe('PresenceService', () => {
  let service: PresenceService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PresenceService,
        { provide: RedisService, useClass: MockRedisService },
      ],
    }).compile();

    service = module.get<PresenceService>(PresenceService);
  });

  it('should track join and leave correctly', async () => {
    const a = await service.join('moment1', 'user1');
    expect(a.count).toBe(1);
    const b = await service.join('moment1', 'user2');
    expect(b.count).toBe(2);
    const c = await service.count('moment1');
    expect(c.count).toBe(2);
    const d = await service.leave('moment1', 'user1');
    expect(d.count).toBe(1);
  });
});
