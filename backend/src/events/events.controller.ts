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
  create(@Query('session_token') token: string, @Body('content') content: string) {
    return this.eventsService.create(token, content);
  }

  @Get(':id')
  fetch(@Param('id') id: string) {
    return this.eventsService.find(parseInt(id, 10));
  }
}
