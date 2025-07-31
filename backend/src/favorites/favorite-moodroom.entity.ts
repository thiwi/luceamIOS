import { Entity, PrimaryGeneratedColumn, ManyToOne, Column, Unique } from 'typeorm';
import { User } from '../users/user.entity';
import { MoodRoom } from '../moodrooms/moodroom.entity';

@Entity()
@Unique(['user', 'moodRoom'])
export class FavoriteMoodRoom {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, { eager: true, onDelete: 'CASCADE' })
  user: User;

  @ManyToOne(() => MoodRoom, { eager: true, onDelete: 'CASCADE' })
  moodRoom: MoodRoom;

  @Column({ type: 'timestamptz' })
  favoritedAt: Date;

  @Column({ type: 'timestamptz', nullable: true })
  unfavoritedAt?: Date | null;
}
