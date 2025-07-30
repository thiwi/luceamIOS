import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';
import { Session } from '../sessions/session.entity';

@Entity()
export class MoodRoom {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column()
  schedule: string;

  @Column()
  background: string;

  @Column({ default: 'black' })
  textColor: string;

  @Column({ type: 'timestamptz' })
  startTime: Date;

  @Column({ type: 'timestamptz', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @Column()
  durationMinutes: number;

  @ManyToOne(() => Session, (session) => session.moodRooms, {
    onDelete: 'CASCADE',
    nullable: true,
  })
  session?: Session;
}
