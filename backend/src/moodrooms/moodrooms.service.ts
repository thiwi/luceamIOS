import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MoodRoom } from './moodroom.entity';
import { Session } from '../sessions/session.entity';
import { validate as isUUID } from 'uuid';

@Injectable()
export class MoodRoomsService {
  constructor(
    @InjectRepository(MoodRoom) private rooms: Repository<MoodRoom>,
    @InjectRepository(Session) private sessions: Repository<Session>,
  ) {}

  list(): Promise<MoodRoom[]> {
    return this.rooms.find({ relations: ['session'] });
  }

  async create(token: string, data: Partial<MoodRoom>): Promise<MoodRoom> {
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
    const room = this.rooms.create({ ...data, session });
    return this.rooms.save(room);
  }
}
