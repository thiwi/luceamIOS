import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Event } from './event.entity';
import { Session } from '../sessions/session.entity';

@Injectable()
export class EventsService {
  constructor(
    @InjectRepository(Event) private events: Repository<Event>,
    @InjectRepository(Session) private sessions: Repository<Session>,
  ) {}

  async list(): Promise<Event[]> {
    return this.events.find({ relations: ['session'] });
  }

  async create(sessionToken: string, content: string): Promise<Event> {
    let session = await this.sessions.findOne({ where: { token: sessionToken } });
    if (!session) {
      session = this.sessions.create({ token: sessionToken });
      await this.sessions.save(session);
    }
    const event = this.events.create({ content, session });
    return this.events.save(event);
  }

  async find(id: number): Promise<Event | null> {
    return this.events.findOne({ where: { id } });
  }
}
