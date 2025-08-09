import { Injectable } from '@nestjs/common';
import { Redis } from 'ioredis';
import { RedisService } from '../infra/redis/redis.service';

interface PresenceCount { count: number }

@Injectable()
export class PresenceService {
  constructor(private readonly redis: RedisService) {}

  private ttl(): number {
    return parseInt(process.env.PRESENCE_TTL_SECONDS || '75', 10);
  }

  private rollupPeriod(): number {
    return parseInt(process.env.ROLLUP_PERIOD_SECONDS || '60', 10) * 1000;
  }

  private presenceKey(momentId: string) {
    return `presence:moment:${momentId}`;
  }

  private userTsKey(momentId: string, userId: string) {
    return `presence:moment:${momentId}:user:${userId}:ts`;
  }

  private hllKey(momentId: string, win: string) {
    return `presence:moment:${momentId}:hll:${win}`;
  }

  private peakKey(momentId: string, win: string) {
    return `presence:moment:${momentId}:peak:${win}`;
  }

  private windowStartISO(now: number) {
    const start = now - (now % this.rollupPeriod());
    return new Date(start).toISOString();
  }

  async join(momentId: string, userId: string): Promise<PresenceCount> {
    const c = this.redis.getClient();
    const ttl = this.ttl();
    const now = Date.now();
    const win = this.windowStartISO(now);
    await c.multi()
      .sadd(this.presenceKey(momentId), userId)
      .expire(this.presenceKey(momentId), ttl)
      .set(this.userTsKey(momentId, userId), String(now), 'EX', ttl)
      .pfadd(this.hllKey(momentId, win), userId)
      .exec();
    const count = await c.scard(this.presenceKey(momentId));
    await this.updatePeak(c, momentId, win, count);
    return { count };
  }

  async leave(momentId: string, userId: string): Promise<PresenceCount> {
    const c = this.redis.getClient();
    await c.srem(this.presenceKey(momentId), userId);
    const count = await c.scard(this.presenceKey(momentId));
    return { count };
  }

  async count(momentId: string): Promise<PresenceCount> {
    const c = this.redis.getClient();
    const count = await c.scard(this.presenceKey(momentId));
    return { count };
  }

  private async updatePeak(c: Redis, momentId: string, win: string, count: number) {
    const key = this.peakKey(momentId, win);
    const current = parseInt((await c.get(key)) || '0', 10);
    if (count > current) {
      await c.set(key, String(count));
    }
  }
}
