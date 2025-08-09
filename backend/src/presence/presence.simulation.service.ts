import { Injectable } from '@nestjs/common';
import { RedisService } from '../infra/redis/redis.service';

interface SimState {
  timer: NodeJS.Timeout;
}

@Injectable()
export class PresenceSimulationService {
  private states = new Map<string, SimState>();
  constructor(private readonly redis: RedisService) {}

  private enabled() {
    return process.env.SIM_PRESENCE_ENABLED !== 'false';
  }

  private min() {
    return parseInt(process.env.SIM_PRESENCE_MIN || '3', 10);
  }

  private max() {
    return parseInt(process.env.SIM_PRESENCE_MAX || '19', 10);
  }

  private stepMs() {
    return parseInt(process.env.SIM_PRESENCE_STEP_MS || '4000', 10);
  }

  private decayAfter() {
    return parseInt(process.env.SIM_PRESENCE_DECAY_AFTER_MS || '180000', 10);
  }

  private ttl() {
    return parseInt(process.env.SIM_PRESENCE_TTL_SECONDS || '75', 10);
  }

  private maxDuration() {
    return parseInt(process.env.SIM_PRESENCE_MAX_DURATION_MS || '600000', 10);
  }

  private rollupPeriod() {
    return parseInt(process.env.ROLLUP_PERIOD_SECONDS || '60', 10) * 1000;
  }

  private presenceKey(id: string) {
    return `presence:moment:${id}`;
  }

  private hllKey(id: string, win: string) {
    return `presence:moment:${id}:hll:${win}`;
  }

  private peakKey(id: string, win: string) {
    return `presence:moment:${id}:peak:${win}`;
  }

  private lockKey(id: string) {
    return `presence:moment:${id}:sim:lock`;
  }

  private windowStartISO(now: number) {
    const start = now - (now % this.rollupPeriod());
    return new Date(start).toISOString();
  }

  private randomInt(min: number, max: number) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  async startForMoment(id: string) {
    if (!this.enabled()) return;
    const client = this.redis.getClient();
    const lock = await client.set(this.lockKey(id), '1', 'NX', 'PX', this.maxDuration());
    if (!lock) return; // already running
    const targetMax = this.randomInt(this.min(), this.max());
    const startedAt = Date.now();
    const timer = setInterval(async () => {
      const now = Date.now();
      if (now - startedAt > this.maxDuration()) {
        clearInterval(timer);
        await client.del(this.lockKey(id));
        this.states.delete(id);
        return;
      }
      const current = await client.scard(this.presenceKey(id));
      let nextTarget: number;
      if (now - startedAt < this.decayAfter()) {
        const t = (now - startedAt) / this.decayAfter();
        const eased = Math.pow(Math.min(1, t), 0.6);
        nextTarget = Math.floor(this.min() + (targetMax - this.min()) * eased);
      } else {
        nextTarget = Math.max(this.min(), Math.floor(current * 0.95));
      }
      const jitter = this.randomInt(-1, 1);
      nextTarget = Math.max(this.min(), Math.min(targetMax, nextTarget + jitter));
      const diff = nextTarget - current;
      if (diff > 0) {
        for (let i = 0; i < diff; i++) {
          const member = `sim:${current + i + 1}`;
          await client.sadd(this.presenceKey(id), member);
          const win = this.windowStartISO(now);
          const pfadd = (client as any).pfadd?.bind(client);
          if (pfadd) {
            try { await pfadd(this.hllKey(id, win), member); } catch {}
          }
        }
      } else if (diff < 0) {
        const members = await client.smembers(this.presenceKey(id));
        const sims = members.filter(m => m.startsWith('sim:')).slice(0, -diff);
        if (sims.length > 0) {
          await client.srem(this.presenceKey(id), ...sims);
        }
      }
      await client.expire(this.presenceKey(id), this.ttl());
      const win = this.windowStartISO(now);
      const count = await client.scard(this.presenceKey(id));
      const peakKey = this.peakKey(id, win);
      const peak = parseInt((await client.get(peakKey)) || '0', 10);
      if (count > peak) {
        await client.set(peakKey, String(count));
      }
    }, this.stepMs());
    this.states.set(id, { timer });
  }

  async stopForMoment(id: string) {
    const state = this.states.get(id);
    if (state) {
      clearInterval(state.timer);
      this.states.delete(id);
    }
    const client = this.redis.getClient();
    await client.del(this.lockKey(id));
  }
}
