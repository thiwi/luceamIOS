import { Controller, Get, Post, Param, Body } from '@nestjs/common';
import { EventsService } from './events.service';
import { PresenceService } from '../presence/presence.service';

class CreateEventDto {
  content: string;
  session_token: string;
}

@Controller('moments')
export class EventsController {
  constructor(
    private readonly eventsService: EventsService,
    private readonly presenceService: PresenceService,
  ) {}

  @Get()
  list() {
    return this.eventsService.list();
  }

  @Post()
  async create(@Body() dto: CreateEventDto) {
    const created = await this.eventsService.create({ content: dto.content, session_token: dto.session_token ?? "" });
    return created;
  }

  @Get(':id')
  fetch(@Param('id') id: string) {
    return this.eventsService.find(id);
  }

  @Post(':id/join')
  join(@Param('id') id: string, @Body('userId') userId: string) {
    return this.presenceService.join(id, userId);
  }

  @Post(':id/leave')
  leave(@Param('id') id: string, @Body('userId') userId: string) {
    return this.presenceService.leave(id, userId);
  }

  @Get(':id/presence')
  presence(@Param('id') id: string) {
    return this.presenceService.count(id);
  }
}
