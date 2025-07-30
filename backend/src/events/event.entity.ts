import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';
import { Session } from '../sessions/session.entity';

@Entity()
export class Event {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  content: string;

  @Column({ nullable: true })
  mood?: string;

  @Column({ nullable: true })
  symbol?: string;

  @ManyToOne(() => Session, (session) => session.events, {
    onDelete: 'CASCADE',
  })
  session: Session;
}
