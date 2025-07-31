import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Resonance } from './resonance.entity';
import { Session } from '../sessions/session.entity';
import { Event } from '../events/event.entity';
import { validate as isUUID } from 'uuid';

@Injectable()
export class ResonanceService {
  constructor(
    @InjectRepository(Resonance) private resonances: Repository<Resonance>,
    @InjectRepository(Session) private sessions: Repository<Session>,
    @InjectRepository(Event) private events: Repository<Event>,
  ) {}

  async create(token: string, eventId: string) {
    if (!token) {
      throw new BadRequestException('No session token available');
    }
    if (!isUUID(token)) {
      throw new BadRequestException('Invalid session token');
    }
    let session = await this.sessions.findOne({ where: { token } });
    if (!session) {
      session = this.sessions.create({ token });
      await this.sessions.save(session);
    }
    const event = await this.events.findOne({ where: { id: eventId } });
    if (!event) return null;
    const res = this.resonances.create({ session, event });
    return event;
  }
}
