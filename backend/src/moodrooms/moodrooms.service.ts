import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { MoodRoom } from './moodroom.entity';
import { Session } from '../sessions/session.entity';
import { validate as isUUID } from 'uuid';
import { FavoriteMoodRoom } from '../favorites/favorite-moodroom.entity';
import { User } from '../users/user.entity';

@Injectable()
export class MoodRoomsService {
  constructor(
    @InjectRepository(MoodRoom) private rooms: Repository<MoodRoom>,
    @InjectRepository(Session) private sessions: Repository<Session>,
    @InjectRepository(FavoriteMoodRoom) private favorites: Repository<FavoriteMoodRoom>,
    @InjectRepository(User) private users: Repository<User>,
  ) {}

  list(): Promise<MoodRoom[]> {
    return this.rooms.find({ relations: ['session'] });
  }

  async listWithFavorites(userId: string): Promise<(MoodRoom & { isFavorite: boolean })[]> {
    const rooms = await this.rooms.find({ relations: ['session'] });
    const favs = await this.favorites.find({ where: { user: { id: userId }, unfavoritedAt: IsNull() } });
    const favIds = new Set(favs.map((f) => f.moodRoom.id));
    return rooms.map((r) => ({ ...r, isFavorite: favIds.has(r.id) }));
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
