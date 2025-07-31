import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { FavoriteMoodRoom } from './favorite-moodroom.entity';
import { User } from '../users/user.entity';
import { MoodRoom } from '../moodrooms/moodroom.entity';

@Injectable()
export class FavoritesService {
  constructor(
    @InjectRepository(FavoriteMoodRoom) private favorites: Repository<FavoriteMoodRoom>,
    @InjectRepository(User) private users: Repository<User>,
    @InjectRepository(MoodRoom) private rooms: Repository<MoodRoom>,
  ) {}

  async toggle(userId: string, moodRoomId: string): Promise<{ isFavorite: boolean }> {
    let user = await this.users.findOne({ where: { id: userId } });
    if (!user) {
      user = this.users.create({ id: userId });
      await this.users.save(user);
    }
    const room = await this.rooms.findOne({ where: { id: moodRoomId } });
    if (!room) {
      throw new NotFoundException('MoodRoom not found');
    }
    let fav = await this.favorites.findOne({ where: { user: { id: userId }, moodRoom: { id: moodRoomId } } });
    if (!fav) {
      fav = this.favorites.create({ user, moodRoom: room, favoritedAt: new Date(), unfavoritedAt: null });
      await this.favorites.save(fav);
      return { isFavorite: true };
    }
    if (fav.unfavoritedAt) {
      fav.unfavoritedAt = null;
      fav.favoritedAt = new Date();
      await this.favorites.save(fav);
      return { isFavorite: true };
    }
    fav.unfavoritedAt = new Date();
    await this.favorites.save(fav);
    return { isFavorite: false };
  }

  async list(userId: string): Promise<MoodRoom[]> {
    const favs = await this.favorites.find({
      where: { user: { id: userId }, unfavoritedAt: IsNull() },
      relations: ['moodRoom', 'moodRoom.session'],
    });
    return favs.map((f) => f.moodRoom);
  }
}
