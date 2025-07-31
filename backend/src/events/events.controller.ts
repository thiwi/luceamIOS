import { Controller, Get, Post, Param, Body, Query } from '@nestjs/common';
import { EventsService } from './events.service';

class CreateEventDto {
  content: string;
  session_token: string;
}

@Controller('moments')
export class EventsController {
  constructor(private readonly eventsService: EventsService) {}

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
}
