import { Controller, Get, Post, Body, Query, Param } from '@nestjs/common';
import { MoodRoomsService } from './moodrooms.service';
import { MoodRoom } from './moodroom.entity';

@Controller('moodrooms')
export class MoodRoomsController {
  constructor(private readonly service: MoodRoomsService) {}

  @Get()
  list() {
    return this.service.list();
  }

  @Get(':userId')
  listForUser(@Param('userId') userId: string) {
    return this.service.listWithFavorites(userId);
  }

  @Post()
  create(@Query('session_token') token: string, @Body() body: MoodRoom) {
    return this.service.create(token, body);
  }
}
