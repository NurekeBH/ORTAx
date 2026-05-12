import { Injectable, Logger, NotFoundException, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { UpsertOnboardingSlideDto } from './dto/onboarding.dto';
import { OnboardingSlide } from './onboarding-slide.entity';
import { seedOnboardingSlides } from './onboarding.seed';

@Injectable()
export class OnboardingService implements OnModuleInit {
  private readonly logger = new Logger(OnboardingService.name);

  constructor(
    @InjectRepository(OnboardingSlide)
    private readonly slides: Repository<OnboardingSlide>,
  ) {}

  async onModuleInit() {
    try {
      await seedOnboardingSlides(this.slides, this.logger);
    } catch (err) {
      this.logger.warn(`Onboarding seed skipped: ${(err as Error).message}`);
    }
  }

  listPublished(): Promise<OnboardingSlide[]> {
    return this.slides.find({
      where: { published: true },
      order: { position: 'ASC', createdAt: 'ASC' },
    });
  }

  listAll(): Promise<OnboardingSlide[]> {
    return this.slides.find({
      order: { position: 'ASC', createdAt: 'ASC' },
    });
  }

  async findOne(id: string): Promise<OnboardingSlide> {
    const s = await this.slides.findOne({ where: { id } });
    if (!s) throw new NotFoundException('Slide not found');
    return s;
  }

  create(dto: UpsertOnboardingSlideDto): Promise<OnboardingSlide> {
    return this.slides.save(this.slides.create(dto));
  }

  async update(id: string, dto: UpsertOnboardingSlideDto): Promise<OnboardingSlide> {
    const slide = await this.findOne(id);
    Object.assign(slide, dto);
    return this.slides.save(slide);
  }

  async remove(id: string): Promise<void> {
    const res = await this.slides.delete({ id });
    if (!res.affected) throw new NotFoundException('Slide not found');
  }
}
