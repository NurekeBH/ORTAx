import { Controller, Get } from '@nestjs/common';

import { OnboardingService } from './onboarding.service';

@Controller('onboarding')
export class OnboardingController {
  constructor(private readonly onboarding: OnboardingService) {}

  @Get()
  list() {
    return this.onboarding.listPublished();
  }
}
