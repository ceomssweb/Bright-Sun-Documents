import { ComponentFixture, TestBed } from '@angular/core/testing';
import { TranslateDocumentComponent } from './translate-document.component';

describe('TranslateDocumentComponent', () => {
  let component: TranslateDocumentComponent;
  let fixture: ComponentFixture<TranslateDocumentComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [TranslateDocumentComponent]
    }).compileComponents();

    fixture = TestBed.createComponent(TranslateDocumentComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
