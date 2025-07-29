import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Session } from './session.entity';

@Injectable()
export class SessionsService {
  constructor(
    @InjectRepository(Session) private sessions: Repository<Session>,
  ) {}

  async create(): Promise<{ token: string }> {
    const session = this.sessions.create();
    await this.sessions.save(session);
    return { token: session.token };
  }
}
