import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CarouselHeaderComponent } from './carousel-header.component';

describe('FooterComponent', () => {
  let component: CarouselHeaderComponent;
  let fixture: ComponentFixture<CarouselHeaderComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ CarouselHeaderComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(CarouselHeaderComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
