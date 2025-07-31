import { Controller, Get, Post, Param, Body, Query } from '@nestjs/common';
import { EventsService } from './events.service';

@Controller('moments')
export class EventsController {
  constructor(private readonly eventsService: EventsService) {}

  @Get()
  list() {
    return this.eventsService.list();
  }

  @Post()
  async create(
    @Query('session_token') token: string,
    @Body('content') content: string,
  ) {
    const created = await this.eventsService.create(token, content);
    return created;
  }

  @Get(':id')
  fetch(@Param('id') id: string) {
    return this.eventsService.find(id);
  }
}
