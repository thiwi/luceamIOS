import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from 'typeorm';
import { Event } from '../events/event.entity';
import { Resonance } from '../resonance/resonance.entity';
import { MoodRoom } from '../moodrooms/moodroom.entity';

@Entity()
export class Session {
  @PrimaryGeneratedColumn('uuid')
  token: string;

  @Column({ type: 'timestamptz', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @OneToMany(() => Event, (event) => event.session)
  events: Event[];

  @OneToMany(() => Resonance, (resonance) => resonance.session)
  resonances: Resonance[];

  @OneToMany(() => MoodRoom, (room) => room.session)
  moodRooms: MoodRoom[];
}
