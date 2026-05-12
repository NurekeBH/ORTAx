import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { OnboardingController } from './onboarding.controller';
import { OnboardingSlide } from './onboarding-slide.entity';
import { OnboardingService } from './onboarding.service';

@Module({
  imports: [TypeOrmModule.forFeature([OnboardingSlide])],
  controllers: [OnboardingController],
  providers: [OnboardingService],
  exports: [OnboardingService],
})
export class OnboardingModule {}
