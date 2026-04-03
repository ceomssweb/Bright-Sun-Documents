import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { firstValueFrom } from 'rxjs';

export interface Language {
  code: string;
  name: string;
}

export interface TranslationResult {
  translatedText: string;
  sourceLanguage: string;
  targetLanguage: string;
}

@Injectable({
  providedIn: 'root'
})
export class TranslationService {

  private readonly apiUrl = 'https://api.mymemory.translated.net/get';

  readonly supportedLanguages: Language[] = [
    { code: 'ta', name: 'Tamil' },
    { code: 'en', name: 'English' },
    { code: 'hi', name: 'Hindi' },
    { code: 'fr', name: 'French' },
    { code: 'de', name: 'German' },
    { code: 'es', name: 'Spanish' },
    { code: 'ar', name: 'Arabic' },
    { code: 'zh', name: 'Chinese' },
    { code: 'ja', name: 'Japanese' },
    { code: 'ko', name: 'Korean' },
    { code: 'ml', name: 'Malayalam' },
    { code: 'te', name: 'Telugu' },
    { code: 'kn', name: 'Kannada' },
    { code: 'bn', name: 'Bengali' },
    { code: 'mr', name: 'Marathi' },
    { code: 'gu', name: 'Gujarati' },
    { code: 'ur', name: 'Urdu' },
    { code: 'pt', name: 'Portuguese' },
    { code: 'ru', name: 'Russian' },
    { code: 'it', name: 'Italian' }
  ];

  constructor(private http: HttpClient) {}

  /**
   * Translate text using MyMemory free translation API.
   * Splits large text into chunks to stay within API limits (500 chars per request).
   */
  async translateText(text: string, sourceLang: string, targetLang: string): Promise<TranslationResult> {
    if (!text || !text.trim()) {
      return { translatedText: '', sourceLanguage: sourceLang, targetLanguage: targetLang };
    }

    const chunks = this.splitTextIntoChunks(text, 450);
    const translatedChunks: string[] = [];

    for (const chunk of chunks) {
      const translated = await this.translateChunk(chunk, sourceLang, targetLang);
      translatedChunks.push(translated);
    }

    return {
      translatedText: translatedChunks.join(' '),
      sourceLanguage: sourceLang,
      targetLanguage: targetLang
    };
  }

  private async translateChunk(text: string, sourceLang: string, targetLang: string): Promise<string> {
    const langPair = `${sourceLang}|${targetLang}`;
    const params = new HttpParams()
      .set('q', text)
      .set('langpair', langPair);

    try {
      const response: any = await firstValueFrom(
        this.http.get(this.apiUrl, { params })
      );

      if (response?.responseStatus === 200 && response?.responseData?.translatedText) {
        return response.responseData.translatedText;
      }
      return `[Translation failed for chunk]`;
    } catch {
      return `[Translation error]`;
    }
  }

  private splitTextIntoChunks(text: string, maxLength: number): string[] {
    const chunks: string[] = [];
    const sentences = text.split(/(?<=[.!?\n])\s+/);
    let currentChunk = '';

    for (const sentence of sentences) {
      if ((currentChunk + ' ' + sentence).length > maxLength && currentChunk.length > 0) {
        chunks.push(currentChunk.trim());
        currentChunk = sentence;
      } else {
        currentChunk += (currentChunk ? ' ' : '') + sentence;
      }
    }

    if (currentChunk.trim()) {
      chunks.push(currentChunk.trim());
    }

    // Handle case where a single sentence exceeds maxLength
    return chunks.flatMap(chunk => {
      if (chunk.length > maxLength) {
        const subChunks: string[] = [];
        for (let i = 0; i < chunk.length; i += maxLength) {
          subChunks.push(chunk.substring(i, i + maxLength));
        }
        return subChunks;
      }
      return [chunk];
    });
  }
}
