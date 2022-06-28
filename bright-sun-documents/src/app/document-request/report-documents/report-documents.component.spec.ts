import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ReportDocumentsComponent } from './report-documents.component';

describe('UsersDocumentsComponent', () => {
  let component: ReportDocumentsComponent;
  let fixture: ComponentFixture<ReportDocumentsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ReportDocumentsComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(ReportDocumentsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
