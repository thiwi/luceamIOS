import { Controller, Get, Post, Body, Param } from '@nestjs/common';
import { FavoritesService } from './favorites.service';

@Controller('favorites')
export class FavoritesController {
  constructor(private readonly service: FavoritesService) {}

  @Post()
  toggle(@Body() body: { userId: string; moodRoomId: string }) {
    return this.service.toggle(body.userId, body.moodRoomId);
  }

  @Get(':userId')
  list(@Param('userId') userId: string) {
    return this.service.list(userId);
  }
}
