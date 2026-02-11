import { Injectable } from '@nestjs/common';
import { v4 as uuidv4 } from 'uuid';

interface Captcha {
  question: string;
  answer: string;
  expiresAt: number;
}

@Injectable()
export class CaptchaService {
  private captchas = new Map<string, Captcha>();
  private readonly EXPIRATION_MS = 5 * 60 * 1000; // 5 minutes

  generateCaptcha(): { id: string; question: string } {
    this.cleanup();
    const id = uuidv4();
    const num1 = Math.floor(Math.random() * 10);
    const num2 = Math.floor(Math.random() * 10);
    const question = `${num1} + ${num2} = ?`;
    const answer = (num1 + num2).toString();

    this.captchas.set(id, {
      question,
      answer,
      expiresAt: Date.now() + this.EXPIRATION_MS,
    });

    return { id, question };
  }

  validateCaptcha(id: string, answer: string): boolean {
    const captcha = this.captchas.get(id);
    if (!captcha) return false;

    if (Date.now() > captcha.expiresAt) {
      this.captchas.delete(id);
      return false;
    }

    const isValid = captcha.answer === answer;
    if (isValid) {
      this.captchas.delete(id); // One-time use
    }
    return isValid;
  }

  private cleanup() {
    const now = Date.now();
    for (const [id, captcha] of this.captchas.entries()) {
      if (now > captcha.expiresAt) {
        this.captchas.delete(id);
      }
    }
  }
}
