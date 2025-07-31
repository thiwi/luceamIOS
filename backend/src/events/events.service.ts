import * as crypto from 'crypto';
import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Event } from './event.entity';
import { Session } from '../sessions/session.entity';
import { validate as isUUID } from 'uuid';
import { CreateEventDto } from './dto/create-event.dto';

@Injectable()
export class EventsService {
  constructor(
    @InjectRepository(Event) private events: Repository<Event>,
    @InjectRepository(Session) private sessions: Repository<Session>,
  ) {}

  async list(): Promise<Event[]> {
    return this.events.find({ relations: ['session'] });
  }

  async create(dto: CreateEventDto): Promise<Event> {
    const { content: eventContent, session_token } = dto;
    const sessionTokenVal = session_token ?? null;
    if (!sessionTokenVal) {
      console.error("❌ No session token available");
      throw new BadRequestException('No session token available');
    }
    if (!isUUID(sessionTokenVal)) {
      console.error(`❌ Invalid session token received: ${sessionTokenVal}`);
      throw new BadRequestException('Invalid session token');
    }
    let session = await this.sessions.findOne({
      where: { token: sessionTokenVal },
    });
    if (!session) {
      session = this.sessions.create({ token: sessionTokenVal });
      await this.sessions.save(session);
    }
    console.log(`📤 Sending event with token: ${sessionTokenVal}, content: ${eventContent}`);
    const event = this.events.create({ content: eventContent, session, id: crypto.randomUUID() });
    const saved = await this.events.save(event);
    console.log("✅ Created event with id: " + saved.id + ", content: " + saved.content);
    console.log("Raw response data:", JSON.stringify(saved));
    const found = await this.events.findOne({ where: { id: saved.id } });
    if (!found) {
      throw new Error('Event not found after saving');
    }
    return found;
  }

  async find(id: string): Promise<Event | null> {
    return this.events.findOne({ where: { id } });
  }
}
