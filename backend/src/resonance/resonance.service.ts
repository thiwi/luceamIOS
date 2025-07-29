import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Resonance } from './resonance.entity';
import { Session } from '../sessions/session.entity';
import { Event } from '../events/event.entity';

@Injectable()
export class ResonanceService {
  constructor(
    @InjectRepository(Resonance) private resonances: Repository<Resonance>,
    @InjectRepository(Session) private sessions: Repository<Session>,
    @InjectRepository(Event) private events: Repository<Event>,
  ) {}

  async create(token: string, eventId: number) {
    let session = await this.sessions.findOne({ where: { token } });
    if (!session) {
      session = this.sessions.create({ token });
      await this.sessions.save(session);
    }
    const event = await this.events.findOne({ where: { id: eventId } });
    if (!event) return null;
    const res = this.resonances.create({ session, event });
    return this.resonances.save(res);
  }
}
