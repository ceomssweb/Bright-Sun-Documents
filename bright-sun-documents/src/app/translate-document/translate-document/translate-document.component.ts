import { Component, OnInit } from '@angular/core';
import { PdfExtractService } from '../services/pdf-extract.service';
import { Language, TranslationService } from '../services/translation.service';

@Component({
  selector: 'bsd-translate-document',
  templateUrl: './translate-document.component.html',
  styleUrls: ['./translate-document.component.scss']
})
export class TranslateDocumentComponent implements OnInit {

  languages: Language[] = [];
  sourceLang: string = 'ta';
  targetLang: string = 'en';

  extractedText: string = '';
  translatedText: string = '';
  fileName: string = '';

  isExtracting: boolean = false;
  isTranslating: boolean = false;
  errorMessage: string = '';

  // For manual text input mode
  manualText: string = '';
  inputMode: 'pdf' | 'manual' = 'pdf';

  constructor(
    private pdfExtractService: PdfExtractService,
    private translationService: TranslationService
  ) {}

  ngOnInit(): void {
    this.languages = this.translationService.supportedLanguages;
  }

  onFileSelect(event: any): void {
    const file: File = event.target.files[0];
    if (!file) return;

    if (file.type !== 'application/pdf') {
      this.errorMessage = 'Please select a valid PDF file.';
      return;
    }

    this.errorMessage = '';
    this.fileName = file.name;
    this.extractText(file);
  }

  async extractText(file: File): Promise<void> {
    this.isExtracting = true;
    this.extractedText = '';
    this.translatedText = '';

    try {
      this.extractedText = await this.pdfExtractService.extractTextFromFile(file);
      if (!this.extractedText.trim()) {
        this.errorMessage = 'No text could be extracted from this PDF. The file may contain scanned images instead of text.';
      }
    } catch (err) {
      this.errorMessage = 'Failed to extract text from PDF. Please ensure the file is a valid PDF.';
    } finally {
      this.isExtracting = false;
    }
  }

  async translateContent(): Promise<void> {
    const textToTranslate = this.inputMode === 'pdf' ? this.extractedText : this.manualText;

    if (!textToTranslate || !textToTranslate.trim()) {
      this.errorMessage = 'No text available to translate.';
      return;
    }

    if (this.sourceLang === this.targetLang) {
      this.errorMessage = 'Source and target languages must be different.';
      return;
    }

    this.errorMessage = '';
    this.isTranslating = true;
    this.translatedText = '';

    try {
      const result = await this.translationService.translateText(
        textToTranslate,
        this.sourceLang,
        this.targetLang
      );
      this.translatedText = result.translatedText;
    } catch (err) {
      this.errorMessage = 'Translation failed. Please try again later.';
    } finally {
      this.isTranslating = false;
    }
  }

  swapLanguages(): void {
    const temp = this.sourceLang;
    this.sourceLang = this.targetLang;
    this.targetLang = temp;
  }

  clearAll(): void {
    this.extractedText = '';
    this.translatedText = '';
    this.manualText = '';
    this.fileName = '';
    this.errorMessage = '';
  }

  copyTranslatedText(): void {
    if (this.translatedText) {
      navigator.clipboard.writeText(this.translatedText);
    }
  }

  getLanguageName(code: string): string {
    return this.languages.find(l => l.code === code)?.name || code;
  }
}
