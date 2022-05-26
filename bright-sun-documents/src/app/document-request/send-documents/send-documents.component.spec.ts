import { ComponentFixture, TestBed } from '@angular/core/testing';

import { UsersDocumentsComponent } from './send-documents.component';

describe('UsersDocumentsComponent', () => {
  let component: UsersDocumentsComponent;
  let fixture: ComponentFixture<UsersDocumentsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ UsersDocumentsComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(UsersDocumentsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
