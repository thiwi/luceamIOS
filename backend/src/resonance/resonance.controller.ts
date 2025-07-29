import { Controller, Post, Body, Query } from '@nestjs/common';
import { ResonanceService } from './resonance.service';

@Controller('resonance')
export class ResonanceController {
  constructor(private readonly service: ResonanceService) {}

  @Post()
  create(
    @Query('session_token') token: string,
    @Body('momentId') momentId: number,
  ) {
    return this.service.create(token, momentId);
  }
}
