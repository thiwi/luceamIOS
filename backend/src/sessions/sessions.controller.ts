import { Controller, Post } from '@nestjs/common';
import { SessionsService } from './sessions.service';

@Controller('session')
export class SessionsController {
  constructor(private readonly service: SessionsService) {}

  @Post()
  create() {
    return this.service.create();
  }
}
