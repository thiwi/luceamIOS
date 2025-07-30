import { Controller, Get, Post, Body, Query } from '@nestjs/common';
import { MoodRoomsService } from './moodrooms.service';
import { MoodRoom } from './moodroom.entity';

@Controller('moodrooms')
export class MoodRoomsController {
  constructor(private readonly service: MoodRoomsService) {}

  @Get()
  list() {
    return this.service.list();
  }

  @Post()
  create(@Query('session_token') token: string, @Body() body: MoodRoom) {
    return this.service.create(token, body);
  }
}
