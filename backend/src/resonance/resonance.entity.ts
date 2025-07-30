import { Entity, PrimaryGeneratedColumn, ManyToOne, Column } from 'typeorm';
import { Session } from '../sessions/session.entity';
import { Event } from '../events/event.entity';

@Entity()
export class Resonance {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Session, (session) => session.resonances, {
    onDelete: 'CASCADE',
  })
  session: Session;

  @ManyToOne(() => Event, { onDelete: 'CASCADE' })
  event: Event;

  @Column({ type: 'timestamptz', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;
}
